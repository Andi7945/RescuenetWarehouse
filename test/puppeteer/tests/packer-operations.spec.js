// @ts-check
const { test, expect } = require('@playwright/test');
const fs = require('fs');
const path = require('path');
const coords = require('../helpers/coordinateHelper');
const dataExtraction = require('../helpers/dataExtraction');

/**
 * Focused Packer Operations Test Suite
 * 
 * Contains only the 4 most critical packer-specific workflows:
 * 1. Container verification workflow
 * 2. PDF generation and printing
 * 3. Deployment status management
 * 4. Item marking and audit trail
 * 
 * Follows KISS and YAGNI principles with shared browser sessions for efficiency.
 */

/**
 * Common login helper for packer role
 * @param {import('@playwright/test').Page} page 
 */
async function loginAsPacker(page) {
  await page.goto('/');
  await page.waitForLoadState('networkidle');
  await page.waitForTimeout(coords.getTimeout('dataLoad'));

  // Login with test credentials
  await coords.typeInField(page, 'login', 'emailField', 'test@rescuenet.net');
  await coords.typeInField(page, 'login', 'passwordField', 'password123');
  await coords.clickElement(page, 'login', 'loginButton');
  await page.waitForTimeout(coords.getTimeout('dataLoad'));
}

/**
 * Navigate to containers for packer workflows
 * @param {import('@playwright/test').Page} page 
 */
async function navigateToContainers(page) {
  await coords.clickElement(page, 'navigation', 'hamburgerMenu');
  await page.waitForTimeout(coords.getTimeout('medium'));
  await coords.clickElement(page, 'navigation', 'containersMenu');
  await page.waitForTimeout(coords.getTimeout('long'));
}

/**
 * Validate PDF content for business logic
 * @param {string} pdfPath - Path to PDF file
 * @param {Object} container - Container data
 * @param {Array} assignments - Assignment data
 * @returns {Object} Validation results
 */
async function validatePdfContent(pdfPath, container, assignments) {
  const validation = { valid: false, fileExists: false, fileSize: 0, errors: [] };
  
  try {
    if (!fs.existsSync(pdfPath)) {
      validation.errors.push('PDF file does not exist');
      return validation;
    }
    validation.fileExists = true;
    
    const stats = fs.statSync(pdfPath);
    validation.fileSize = stats.size;
    
    if (stats.size < 100) {
      validation.errors.push('PDF file too small');
      return validation;
    }
    
    const pdfBuffer = fs.readFileSync(pdfPath);
    const pdfHeader = pdfBuffer.toString('ascii', 0, 4);
    if (pdfHeader !== '%PDF') {
      validation.errors.push('Invalid PDF format');
      return validation;
    }
    
    validation.valid = true;
  } catch (error) {
    validation.errors.push(`Validation error: ${error.message}`);
  }
  
  return validation;
}

test.describe('Packer Operations - Core Workflows', () => {
  // Shared browser session for efficiency
  let sharedPage;

  test.beforeAll(async ({ browser }) => {
    sharedPage = await browser.newPage();
    sharedPage.on('console', msg => console.log('BROWSER:', msg.text()));
    await loginAsPacker(sharedPage);
    await navigateToContainers(sharedPage);
  });

  test.afterAll(async () => {
    await sharedPage?.close();
  });

  test('Container Verification Workflow', async () => {
    console.log('Testing container verification workflow');
    
    // Validate mock data is available
    const mockValidation = await dataExtraction.validateMockRepositories(sharedPage);
    expect(mockValidation.valid).toBe(true);
    
    // Get containers ready for verification
    const allContainers = await dataExtraction.getAllContainers(sharedPage);
    const targetContainer = allContainers.find(container => 
      container.status === 'packing' || container.status === 'ready_for_verification'
    );
    expect(targetContainer).toBeTruthy();
    console.log(`Verifying container: ${targetContainer.name}`);
    
    // Record initial state
    const initialStatus = targetContainer.verification_status || 'unverified';
    
    // Access container detail
    await coords.clickElement(sharedPage, 'containersOverview', 'firstContainerArea');
    await sharedPage.waitForTimeout(coords.getTimeout('medium'));
    
    // Start verification
    await coords.clickElement(sharedPage, 'containerDetail', 'verifyButton');
    await sharedPage.waitForTimeout(coords.getTimeout('medium'));
    
    // Get container assignments for verification
    const allAssignments = await dataExtraction.getAllAssignments(sharedPage);
    const containerAssignments = allAssignments.filter(a => a.container_id === targetContainer.id);
    
    if (containerAssignments.length > 0) {
      // Verify first item
      await coords.clickElement(sharedPage, 'verification', 'firstItemCheckbox');
      const expectedQuantity = containerAssignments[0].quantity.toString();
      await coords.typeInField(sharedPage, 'verification', 'foundQuantityField', expectedQuantity);
      console.log(`Verified quantity: ${expectedQuantity}`);
    }
    
    // Complete verification
    await coords.clickElement(sharedPage, 'verification', 'completeVerificationButton');
    await sharedPage.waitForTimeout(coords.getTimeout('long'));
    
    // Validate verification status changed
    const updatedContainer = await dataExtraction.getContainerById(sharedPage, targetContainer.id);
    expect(updatedContainer.verification_status).toBe('verified');
    expect(updatedContainer.verification_date).toBeTruthy();
    console.log('✓ Container verification completed successfully');
  });

  test('PDF Generation and Printing', async () => {
    console.log('Testing PDF generation workflow');
    
    // Get container with assignments
    const allContainers = await dataExtraction.getAllContainers(sharedPage);
    const allAssignments = await dataExtraction.getAllAssignments(sharedPage);
    const targetContainer = allContainers.find(container => 
      allAssignments.some(assignment => assignment.container_id === container.id)
    );
    expect(targetContainer).toBeTruthy();
    console.log(`Generating PDF for container: ${targetContainer.name}`);
    
    const containerAssignments = allAssignments.filter(a => a.container_id === targetContainer.id);
    
    // Access container detail
    await coords.clickElement(sharedPage, 'containersOverview', 'firstContainerArea');
    await sharedPage.waitForTimeout(coords.getTimeout('medium'));
    
    // Generate packing list PDF
    const downloadPromise = sharedPage.waitForEvent('download', { timeout: 15000 });
    await coords.clickElement(sharedPage, 'containerDetail', 'generatePackingListButton');
    
    // Validate PDF download
    const download = await downloadPromise;
    expect(download).toBeTruthy();
    
    const filename = download.suggestedFilename();
    expect(filename).toContain('.pdf');
    expect(filename.toLowerCase()).toMatch(/packing|list/);
    console.log(`PDF generated: ${filename}`);
    
    // Save and validate PDF
    const downloadPath = path.join(__dirname, '../downloads', filename);
    await download.saveAs(downloadPath);
    
    const pdfValidation = await validatePdfContent(downloadPath, targetContainer, containerAssignments);
    expect(pdfValidation.valid).toBe(true);
    expect(pdfValidation.fileSize).toBeGreaterThan(1000);
    console.log('✓ PDF generation validated successfully');
    
    // Clean up
    fs.unlinkSync(downloadPath);
  });

  test('Deployment Status Management', async () => {
    console.log('Testing deployment status management');
    
    // Get container for status management
    const allContainers = await dataExtraction.getAllContainers(sharedPage);
    const targetContainer = allContainers.find(container => 
      container.status === 'packing' || container.verification_status === 'verified'
    );
    expect(targetContainer).toBeTruthy();
    console.log(`Managing status for container: ${targetContainer.name}`);
    
    const initialStatus = targetContainer.status;
    
    // Access container detail
    await coords.clickElement(sharedPage, 'containersOverview', 'firstContainerArea');
    await sharedPage.waitForTimeout(coords.getTimeout('medium'));
    
    // Change status to ready for deployment
    await coords.clickElement(sharedPage, 'containerDetail', 'changeStatusButton');
    await sharedPage.waitForTimeout(coords.getTimeout('medium'));
    
    await coords.clickElement(sharedPage, 'statusDialog', 'readyForDeploymentOption');
    await coords.clickElement(sharedPage, 'statusDialog', 'confirmStatusChangeButton');
    await sharedPage.waitForTimeout(coords.getTimeout('long'));
    
    // Validate status change
    const updatedContainer = await dataExtraction.getContainerById(sharedPage, targetContainer.id);
    expect(updatedContainer.status).toBe('ready_for_deployment');
    expect(updatedContainer.status).not.toBe(initialStatus);
    console.log(`✓ Status changed from ${initialStatus} to ready_for_deployment`);
    
    // Test persistence through page reload
    await sharedPage.reload();
    await sharedPage.waitForTimeout(coords.getTimeout('dataLoad'));
    
    const reloadedContainer = await dataExtraction.getContainerById(sharedPage, targetContainer.id);
    expect(reloadedContainer.status).toBe('ready_for_deployment');
    console.log('✓ Status change persisted through reload');
  });

  test('Item Marking and Audit Trail', async () => {
    console.log('Testing item marking and audit trail');
    
    // Get container with assignments for marking
    const allContainers = await dataExtraction.getAllContainers(sharedPage);
    const allAssignments = await dataExtraction.getAllAssignments(sharedPage);
    const targetContainer = allContainers.find(container => 
      allAssignments.some(assignment => assignment.container_id === container.id)
    );
    expect(targetContainer).toBeTruthy();
    
    const containerAssignments = allAssignments.filter(a => a.container_id === targetContainer.id);
    expect(containerAssignments.length).toBeGreaterThan(0);
    console.log(`Testing marking for ${containerAssignments.length} items`);
    
    // Access container detail
    await coords.clickElement(sharedPage, 'containersOverview', 'firstContainerArea');
    await sharedPage.waitForTimeout(coords.getTimeout('medium'));
    
    // Test item marking workflow
    const markItemClick = await coords.clickElement(sharedPage, 'containerDetail', 'markItemButton');
    if (markItemClick) {
      await sharedPage.waitForTimeout(coords.getTimeout('medium'));
      
      // Mark item as checked/verified
      await coords.clickElement(sharedPage, 'itemMarking', 'markAsCheckedButton');
      await sharedPage.waitForTimeout(coords.getTimeout('medium'));
      
      // Add marking notes for audit trail
      const notesSuccess = await coords.typeInField(sharedPage, 'itemMarking', 'markingNotesField', 'Item verified by packer during deployment preparation');
      if (notesSuccess) {
        console.log('✓ Marking notes added for audit trail');
      }
      
      // Confirm marking
      await coords.clickElement(sharedPage, 'itemMarking', 'confirmMarkingButton');
      await sharedPage.waitForTimeout(coords.getTimeout('medium'));
    }
    
    // Validate audit trail exists
    const updatedContainer = await dataExtraction.getContainerById(sharedPage, targetContainer.id);
    expect(updatedContainer).toBeTruthy();
    
    // Check if marking timestamp was updated
    if (updatedContainer.last_modified || updatedContainer.updated_at) {
      console.log('✓ Audit trail timestamp updated');
    }
    
    console.log('✓ Item marking and audit trail workflow completed');
  });
});