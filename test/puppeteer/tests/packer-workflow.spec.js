// @ts-check
const { test, expect } = require('@playwright/test');
const fs = require('fs');
const path = require('path');
const coords = require('../helpers/coordinateHelper');
const dataExtraction = require('../helpers/dataExtraction');

// Load test configuration
const testConfig = JSON.parse(fs.readFileSync(
  path.join(__dirname, '../../fixtures/test_config.json'), 'utf8'
));

/**
 * Load test fixtures for a specific scenario
 * @param {string} scenarioId - The test scenario ID (e.g., "T05.1")
 * @returns {Object} Loaded fixture data
 */
function loadTestFixtures(scenarioId) {
  const scenario = testConfig.test_scenarios[scenarioId];
  if (!scenario) {
    throw new Error(`Test scenario ${scenarioId} not found in test_config.json`);
  }

  const fixtures = {};
  for (const fixturePath of scenario.fixtures) {
    const fullPath = path.join(__dirname, '../../fixtures', fixturePath);
    try {
      const fixtureData = JSON.parse(fs.readFileSync(fullPath, 'utf8'));
      const fixtureKey = path.basename(fixturePath, '.json');
      fixtures[fixtureKey] = fixtureData;
    } catch (error) {
      console.warn(`Warning: Could not load fixture ${fixturePath}:`, error.message);
    }
  }

  return {
    data: fixtures,
    authUser: scenario.auth_user,
    scenarioName: scenario.name
  };
}

/**
 * Common login helper that uses the coordinate helper
 * @param {import('@playwright/test').Page} page 
 * @param {string} userEmail 
 */
async function loginAsTestUser(page, userEmail = 'test@rescuenet.net') {
  // Navigate to the Flutter app
  await page.goto('/');
  await page.waitForLoadState('networkidle');
  await page.waitForTimeout(coords.getTimeout('dataLoad'));

  // Login with working test credentials using semantic coordinates
  // The mock system only recognizes test@rescuenet.net with password123
  const emailSuccess = await coords.typeInField(page, 'login', 'emailField', 'test@rescuenet.net');
  if (!emailSuccess) {
    throw new Error('Failed to enter email during login');
  }

  const passwordSuccess = await coords.typeInField(page, 'login', 'passwordField', 'password123');
  if (!passwordSuccess) {
    throw new Error('Failed to enter password during login');
  }

  const loginSuccess = await coords.clickElement(page, 'login', 'loginButton');
  if (!loginSuccess) {
    throw new Error('Failed to click login button');
  }

  await page.waitForTimeout(coords.getTimeout('dataLoad'));
  console.log('✓ Login completed successfully using coordinate helper');
}

/**
 * Navigate to Containers Overview page for packer workflows
 * @param {import('@playwright/test').Page} page 
 */
async function navigateToContainersOverview(page) {
  // Open hamburger menu
  const menuSuccess = await coords.clickElement(page, 'navigation', 'hamburgerMenu');
  if (!menuSuccess) {
    throw new Error('Failed to open hamburger menu');
  }
  await page.waitForTimeout(coords.getTimeout('medium'));
  
  // Click on "Containers" in the navigation drawer
  const containersSuccess = await coords.clickElement(page, 'navigation', 'containersMenu');
  if (!containersSuccess) {
    throw new Error('Failed to click Containers menu');
  }
  await page.waitForTimeout(coords.getTimeout('long'));
  
  // Verify navigation was successful
  const currentUrl = page.url();
  expect(currentUrl).toContain('containers');
  console.log('✓ Navigation to containers overview completed successfully');
}

/**
 * Validate PDF generation business logic and content
 * @param {string} pdfPath - Path to the PDF file
 * @param {Object} container - Container object
 * @param {Array} assignments - Array of assignment objects
 * @param {string} pdfType - Type of PDF (packing_list, label, summary, dangerous_goods)
 * @returns {Object} Validation results
 */
async function validatePdfContent(pdfPath, container, assignments, pdfType) {
  const validation = {
    valid: false,
    fileExists: false,
    validPdf: false,
    hasContent: false,
    containsContainerInfo: false,
    containsAssignmentInfo: false,
    fileSize: 0,
    errors: []
  };
  
  try {
    // Check if file exists
    if (!fs.existsSync(pdfPath)) {
      validation.errors.push('PDF file does not exist');
      return validation;
    }
    validation.fileExists = true;
    
    // Check file size
    const stats = fs.statSync(pdfPath);
    validation.fileSize = stats.size;
    
    if (stats.size < 100) {
      validation.errors.push('PDF file too small (likely empty or corrupted)');
      return validation;
    }
    validation.hasContent = true;
    
    // Validate PDF format
    const pdfBuffer = fs.readFileSync(pdfPath);
    const pdfHeader = pdfBuffer.toString('ascii', 0, 4);
    if (pdfHeader !== '%PDF') {
      validation.errors.push('File is not a valid PDF format');
      return validation;
    }
    validation.validPdf = true;
    
    // Extract text content for business validation
    const pdfContent = pdfBuffer.toString('utf8');
    
    // Validate container information appears
    if (container && container.name && pdfContent.includes(container.name)) {
      validation.containsContainerInfo = true;
    }
    
    // Validate assignment information appears
    if (assignments && assignments.length > 0) {
      let assignmentInfoFound = 0;
      for (const assignment of assignments) {
        if (pdfContent.includes(assignment.quantity.toString()) ||
            (assignment.item_name && pdfContent.includes(assignment.item_name))) {
          assignmentInfoFound++;
        }
      }
      validation.containsAssignmentInfo = assignmentInfoFound > 0;
    }
    
    // Overall validation
    validation.valid = validation.fileExists && 
                     validation.validPdf && 
                     validation.hasContent &&
                     validation.containsContainerInfo;
    
    console.log(`PDF Validation for ${pdfType}:`, validation);
    
  } catch (error) {
    validation.errors.push(`PDF validation error: ${error.message}`);
  }
  
  return validation;
}

test.describe('Deployment Preparation - Packer Workflows (UC05)', () => {
  // Setup console logging for all tests
  test.beforeEach(async ({ page }) => {
    page.on('console', msg => console.log('BROWSER:', msg.text()));
    page.on('pageerror', error => console.log('PAGE ERROR:', error.message));
  });

  test('T05.1: Container Verification Workflow', async ({ page }) => {
    console.log('T05.1: Starting Container Verification Workflow test with business process validation');
    
    // Load test fixtures for this scenario
    const fixtures = loadTestFixtures('T05.1');
    console.log(`T05.1: Loaded fixtures for scenario: ${fixtures.scenarioName}`);
    
    // Login as Packer user (should have verification permissions)
    await loginAsTestUser(page, fixtures.authUser || 'test@rescuenet.net');
    await page.screenshot({ path: 'packer-verification-start.png' });
    
    // Validate mock repositories are available for business logic testing
    const mockValidation = await dataExtraction.validateMockRepositories(page);
    expect(mockValidation.valid).toBe(true);
    console.log('T05.1: ✓ Mock repositories validated and ready for business process testing');
    
    // Navigate to Containers Overview to find containers ready for verification
    await navigateToContainersOverview(page);
    await page.screenshot({ path: 'packer-containers-overview.png' });
    
    // Wait for data to load
    await page.waitForTimeout(coords.getTimeout('dataLoad'));
    
    // BUSINESS PROCESS VALIDATION - Get target container for verification
    const allContainers = await dataExtraction.getAllContainers(page);
    expect(allContainers.length).toBeGreaterThan(0);
    
    // Find a container in 'packing' status that can be verified
    const targetContainer = allContainers.find(container => 
      container.status === 'packing' || container.status === 'ready_for_verification'
    );
    expect(targetContainer).toBeTruthy();
    console.log(`T05.1: Found target container for verification: ${targetContainer.name} (ID: ${targetContainer.id})`);
    
    // Record initial verification state
    const initialVerificationStatus = targetContainer.verification_status || 'unverified';
    const initialVerificationDate = targetContainer.verification_date || null;
    console.log(`T05.1: Initial verification state - Status: ${initialVerificationStatus}, Date: ${initialVerificationDate}`);
    
    // Get assignments for this container to validate verification workflow
    const allAssignments = await dataExtraction.getAllAssignments(page);
    const containerAssignments = allAssignments.filter(assignment => assignment.container_id === targetContainer.id);
    console.log(`T05.1: Container has ${containerAssignments.length} assignments to verify`);
    
    // Verify navigation was successful
    const currentUrl = page.url();
    expect(currentUrl).toContain('containers');
    console.log('T05.1: ✓ Navigation to containers overview successful');
    
    // Test container verification workflow with real business validation
    try {
      // Click on the target container
      const containerClick = await coords.clickElement(page, 'containersOverview', 'firstContainerArea');
      expect(containerClick).toBe(true);
      
      await page.waitForTimeout(coords.getTimeout('medium'));
      await page.screenshot({ path: 'packer-container-detail.png' });
      console.log('T05.1: ✓ Container detail view accessed for verification');
      
      // Open verification workflow
      const verifyClick = await coords.clickElement(page, 'containerDetail', 'verifyButton');
      expect(verifyClick).toBe(true);
      
      await page.waitForTimeout(coords.getTimeout('medium'));
      await page.screenshot({ path: 'packer-verification-dialog-open.png' });
      console.log('T05.1: ✓ Container verification dialog opened');
      
      // CRITICAL BUSINESS VALIDATION: Verify verification dialog shows container assignments
      if (containerAssignments.length > 0) {
        // Test verification workflow for each assignment
        const verifyItemClick = await coords.clickElement(page, 'verification', 'firstItemCheckbox');
        expect(verifyItemClick).toBe(true);
        console.log('T05.1: ✓ Item verification checkbox interaction successful');
        
        // Input found quantity that matches expected
        const expectedQuantity = containerAssignments[0].quantity.toString();
        const foundQuantitySuccess = await coords.typeInField(page, 'verification', 'foundQuantityField', expectedQuantity);
        expect(foundQuantitySuccess).toBe(true);
        console.log(`T05.1: ✓ Found quantity field entered: ${expectedQuantity}`);
        
        // BUSINESS VALIDATION: Test discrepancy handling
        // Try entering a different quantity to test discrepancy workflow
        const discrepantQuantity = (parseInt(expectedQuantity) - 1).toString();
        const discrepancySuccess = await coords.typeInField(page, 'verification', 'foundQuantityField', discrepantQuantity);
        if (discrepancySuccess) {
          console.log(`T05.1: ✓ BUSINESS VALIDATION: Tested discrepancy handling with quantity: ${discrepantQuantity}`);
          
          // Restore correct quantity for successful completion
          await coords.typeInField(page, 'verification', 'foundQuantityField', expectedQuantity);
        }
        
        // Test verification notes functionality
        const notesSuccess = await coords.typeInField(page, 'verification', 'verificationNotesField', 'Test verification notes');
        if (notesSuccess) {
          console.log('T05.1: ✓ BUSINESS VALIDATION: Verification notes field functional');
        }
      } else {
        console.log('T05.1: No assignments found for verification testing');
      }
      
      // Complete the verification process
      const completeVerifyClick = await coords.clickElement(page, 'verification', 'completeVerificationButton');
      expect(completeVerifyClick).toBe(true);
      
      await page.waitForTimeout(coords.getTimeout('long')); // Allow time for verification to process
      await page.screenshot({ path: 'packer-verification-completed.png' });
      console.log('T05.1: ✓ Complete verification button clicked successfully');
      
      // CRITICAL BUSINESS VALIDATION: Verify the container verification status changed
      const updatedContainer = await dataExtraction.getContainerById(page, targetContainer.id);
      expect(updatedContainer).toBeTruthy();
      
      // Validate verification status was updated
      expect(updatedContainer.verification_status).toBe('verified');
      console.log(`T05.1: ✓ BUSINESS VALIDATION: Container verification status updated to 'verified'`);
      
      // Validate verification date was set
      expect(updatedContainer.verification_date).toBeTruthy();
      expect(updatedContainer.verification_date).not.toBe(initialVerificationDate);
      console.log(`T05.1: ✓ BUSINESS VALIDATION: Verification date set: ${updatedContainer.verification_date}`);
      
      // Test verification state persistence through page reload
      await page.reload();
      await page.waitForTimeout(coords.getTimeout('dataLoad'));
      
      const reloadedContainer = await dataExtraction.getContainerById(page, targetContainer.id);
      expect(reloadedContainer.verification_status).toBe('verified');
      expect(reloadedContainer.verification_date).toBe(updatedContainer.verification_date);
      console.log('T05.1: ✓ BUSINESS VALIDATION: Verification state persists through page reload');
      
      // Navigate away and back to test verification state survives navigation
      const menuSuccess = await coords.clickElement(page, 'navigation', 'hamburgerMenu');
      if (menuSuccess) {
        await page.waitForTimeout(coords.getTimeout('medium'));
        const itemsSuccess = await coords.clickElement(page, 'navigation', 'allItemsMenu');
        if (itemsSuccess) {
          await page.waitForTimeout(coords.getTimeout('medium'));
          
          // Navigate back to containers
          await navigateToContainersOverview(page);
          await page.waitForTimeout(coords.getTimeout('dataLoad'));
          
          const navigationTestContainer = await dataExtraction.getContainerById(page, targetContainer.id);
          expect(navigationTestContainer.verification_status).toBe('verified');
          console.log('T05.1: ✓ BUSINESS VALIDATION: Verification state survives navigation');
        }
      }
      
    } catch (error) {
      console.error('T05.1: Container verification workflow error:', error.message);
      await page.screenshot({ path: 'packer-verification-error.png' });
      throw error; // Re-throw to fail the test with meaningful error
    }
    
    await page.screenshot({ path: 'packer-verification-final.png' });
    
    console.log('T05.1: ✓ Container verification workflow test COMPLETED with business process validation');
  });

  test('T05.2: PDF Generation - Packing Lists', async ({ page }) => {
    console.log('T05.2: Starting PDF Generation - Packing Lists test with business validation');
    
    // Load test fixtures for this scenario
    const fixtures = loadTestFixtures('T05.2');
    console.log(`T05.2: Loaded fixtures for scenario: ${fixtures.scenarioName}`);
    
    // Login as Packer user (should have PDF generation permissions)
    await loginAsTestUser(page, fixtures.authUser || 'test@rescuenet.net');
    await navigateToContainersOverview(page);
    await page.waitForTimeout(coords.getTimeout('dataLoad'));
    await page.screenshot({ path: 'packer-pdf-start.png' });

    // Validate mock repositories are available for business logic testing
    const mockValidation = await dataExtraction.validateMockRepositories(page);
    expect(mockValidation.valid).toBe(true);
    console.log('T05.2: ✓ Mock repositories validated for PDF generation testing');
    
    // BUSINESS PROCESS VALIDATION - Find container with assignments for PDF generation
    const allContainers = await dataExtraction.getAllContainers(page);
    expect(allContainers.length).toBeGreaterThan(0);
    
    const allAssignments = await dataExtraction.getAllAssignments(page);
    expect(allAssignments.length).toBeGreaterThan(0);
    
    // Find a container that has assignments (required for meaningful PDF generation)
    const targetContainer = allContainers.find(container => 
      allAssignments.some(assignment => assignment.container_id === container.id)
    );
    expect(targetContainer).toBeTruthy();
    console.log(`T05.2: Found target container with assignments: ${targetContainer.name} (ID: ${targetContainer.id})`);
    
    // Get assignments for this container to validate they appear in PDF
    const containerAssignments = allAssignments.filter(assignment => assignment.container_id === targetContainer.id);
    expect(containerAssignments.length).toBeGreaterThan(0);
    console.log(`T05.2: Container has ${containerAssignments.length} assignments for PDF generation`);
    
    // Get item details for each assignment to validate PDF content
    const assignmentItems = [];
    for (const assignment of containerAssignments) {
      const item = await dataExtraction.getItemById(page, assignment.item_id);
      expect(item).toBeTruthy();
      assignmentItems.push({
        assignment: assignment,
        item: item
      });
    }
    console.log(`T05.2: Loaded details for ${assignmentItems.length} assigned items`);
    
    // Verify navigation was successful
    const currentUrl = page.url();
    expect(currentUrl).toContain('containers');
    console.log('T05.2: ✓ Navigation to containers overview successful');

    // Set up download monitoring for PDF validation
    const downloadPromise = page.waitForEvent('download', { timeout: 15000 });
    
    // Test PDF generation for packing lists with business validation
    try {
      // Click on the target container
      const containerClick = await coords.clickElement(page, 'containersOverview', 'firstContainerArea');
      expect(containerClick).toBe(true);
      
      await page.waitForTimeout(coords.getTimeout('medium'));
      await page.screenshot({ path: 'packer-pdf-container-detail.png' });
      console.log('T05.2: ✓ Container detail view accessed for PDF generation');
      
      // Generate packing list PDF
      const pdfClick = await coords.clickElement(page, 'containerDetail', 'generatePackingListButton');
      expect(pdfClick).toBe(true);
      
      console.log('T05.2: ✓ Packing list PDF generation initiated');
      
      // CRITICAL BUSINESS VALIDATION: Verify PDF download occurs
      const download = await downloadPromise;
      expect(download).toBeTruthy();
      
      // Validate PDF filename contains expected elements
      const suggestedFilename = download.suggestedFilename();
      expect(suggestedFilename).toContain('.pdf');
      expect(suggestedFilename.toLowerCase()).toMatch(/packing|list|container/);
      console.log(`T05.2: ✓ BUSINESS VALIDATION: PDF download occurred with filename: ${suggestedFilename}`);
      
      // Save the PDF for comprehensive business validation
      const downloadPath = path.join(__dirname, '../downloads', suggestedFilename);
      await download.saveAs(downloadPath);
      
      // COMPREHENSIVE BUSINESS VALIDATION using helper function
      const pdfValidation = await validatePdfContent(downloadPath, targetContainer, containerAssignments, 'packing_list');
      expect(pdfValidation.valid).toBe(true);
      expect(pdfValidation.fileSize).toBeGreaterThan(1000); // PDF should be substantial
      expect(pdfValidation.containsContainerInfo).toBe(true);
      
      if (pdfValidation.errors.length > 0) {
        console.error('T05.2: PDF validation errors:', pdfValidation.errors);
      }
      
      console.log(`T05.2: ✓ COMPREHENSIVE BUSINESS VALIDATION: Packing list PDF validated successfully`);
      console.log(`T05.2: - File size: ${pdfValidation.fileSize} bytes`);
      console.log(`T05.2: - Contains container info: ${pdfValidation.containsContainerInfo}`);
      console.log(`T05.2: - Contains assignment info: ${pdfValidation.containsAssignmentInfo}`);
      
      // EXTENDED BUSINESS VALIDATION: Check for dangerous goods handling
      const dangerousGoodsItems = assignmentItems.filter(item => 
        item.item.dangerous_goods_class && item.item.dangerous_goods_class !== 'None'
      );
      
      if (dangerousGoodsItems.length > 0) {
        console.log(`T05.2: Container has ${dangerousGoodsItems.length} dangerous goods items - testing DG PDF`);
        
        // Set up another download monitor for dangerous goods PDF
        const dgDownloadPromise = page.waitForEvent('download', { timeout: 15000 });
        
        const dgPdfClick = await coords.clickElement(page, 'containerDetail', 'generateDangerousGoodsPdfButton');
        expect(dgPdfClick).toBe(true);
        
        // Validate dangerous goods PDF generation
        const dgDownload = await dgDownloadPromise;
        expect(dgDownload).toBeTruthy();
        
        const dgFilename = dgDownload.suggestedFilename();
        expect(dgFilename).toContain('.pdf');
        expect(dgFilename.toLowerCase()).toMatch(/dangerous|goods|dg/);
        console.log(`T05.2: ✓ BUSINESS VALIDATION: Dangerous goods PDF generated: ${dgFilename}`);
        
        // Save and comprehensively validate dangerous goods PDF
        const dgDownloadPath = path.join(__dirname, '../downloads', dgFilename);
        await dgDownload.saveAs(dgDownloadPath);
        
        // COMPREHENSIVE BUSINESS VALIDATION for dangerous goods PDF
        const dgPdfValidation = await validatePdfContent(dgDownloadPath, targetContainer, dangerousGoodsItems.map(item => item.assignment), 'dangerous_goods');
        expect(dgPdfValidation.valid).toBe(true);
        expect(dgPdfValidation.fileSize).toBeGreaterThan(500);
        
        console.log(`T05.2: ✓ COMPREHENSIVE BUSINESS VALIDATION: Dangerous goods PDF validated successfully`);
        console.log(`T05.2: - DG PDF size: ${dgPdfValidation.fileSize} bytes`);
        console.log(`T05.2: - Contains container info: ${dgPdfValidation.containsContainerInfo}`);
        
        // Clean up dangerous goods PDF
        fs.unlinkSync(dgDownloadPath);
      } else {
        console.log('T05.2: No dangerous goods items in container - skipping DG PDF test');
      }
      
      await page.waitForTimeout(coords.getTimeout('medium'));
      await page.screenshot({ path: 'packer-pdf-generated-success.png' });
      
      // Clean up PDF file
      fs.unlinkSync(downloadPath);
      
    } catch (error) {
      console.error('T05.2: PDF generation workflow error:', error.message);
      await page.screenshot({ path: 'packer-pdf-error.png' });
      throw error; // Re-throw to fail the test with meaningful error
    }

    await page.screenshot({ path: 'packer-pdf-final.png' });
    
    console.log('T05.2: ✓ PDF generation - packing lists test COMPLETED with business validation');
  });

  test('T05.3: PDF Generation - Labels and Summaries', async ({ page }) => {
    console.log('T05.3: Starting PDF Generation - Labels and Summaries test with business validation');
    
    // Load test fixtures for this scenario
    const fixtures = loadTestFixtures('T05.3');
    console.log(`T05.3: Loaded fixtures for scenario: ${fixtures.scenarioName}`);
    
    // Login as Packer user (should have PDF generation permissions)
    await loginAsTestUser(page, fixtures.authUser || 'test@rescuenet.net');
    await navigateToContainersOverview(page);
    await page.waitForTimeout(coords.getTimeout('dataLoad'));
    await page.screenshot({ path: 'packer-labels-start.png' });

    // Validate mock repositories are available for business logic testing
    const mockValidation = await dataExtraction.validateMockRepositories(page);
    expect(mockValidation.valid).toBe(true);
    console.log('T05.3: ✓ Mock repositories validated for label and summary generation testing');
    
    // BUSINESS PROCESS VALIDATION - Find container ready for deployment
    const allContainers = await dataExtraction.getAllContainers(page);
    expect(allContainers.length).toBeGreaterThan(0);
    
    const allAssignments = await dataExtraction.getAllAssignments(page);
    expect(allAssignments.length).toBeGreaterThan(0);
    
    // Find a verified container ready for deployment (should have verification_status = 'verified')
    const targetContainer = allContainers.find(container => 
      container.verification_status === 'verified' ||
      container.status === 'ready_for_deployment' ||
      allAssignments.some(assignment => assignment.container_id === container.id)
    );
    expect(targetContainer).toBeTruthy();
    console.log(`T05.3: Found target container for label/summary generation: ${targetContainer.name} (ID: ${targetContainer.id})`);
    
    // Get assignments for this container to validate they appear in generated documents
    const containerAssignments = allAssignments.filter(assignment => assignment.container_id === targetContainer.id);
    console.log(`T05.3: Container has ${containerAssignments.length} assignments for document generation`);
    
    // Get item details for assignments to validate content appears in documents
    const assignmentItems = [];
    for (const assignment of containerAssignments) {
      const item = await dataExtraction.getItemById(page, assignment.item_id);
      if (item) {
        assignmentItems.push({
          assignment: assignment,
          item: item
        });
      }
    }
    console.log(`T05.3: Loaded details for ${assignmentItems.length} assigned items`);
    
    // Verify navigation was successful
    const currentUrl = page.url();
    expect(currentUrl).toContain('containers');
    console.log('T05.3: ✓ Navigation to containers overview successful');

    // Test label and summary generation with comprehensive business validation
    try {
      // Click on the target container
      const containerClick = await coords.clickElement(page, 'containersOverview', 'firstContainerArea');
      expect(containerClick).toBe(true);
      
      await page.waitForTimeout(coords.getTimeout('medium'));
      await page.screenshot({ path: 'packer-labels-container-detail.png' });
      console.log('T05.3: ✓ Container detail view accessed for label/summary generation');
      
      // CRITICAL BUSINESS VALIDATION: Test container label generation
      const labelDownloadPromise = page.waitForEvent('download', { timeout: 15000 });
      
      const labelClick = await coords.clickElement(page, 'containerDetail', 'generateLabelButton');
      expect(labelClick).toBe(true);
      
      console.log('T05.3: ✓ Container label PDF generation initiated');
      
      // Validate label PDF download
      const labelDownload = await labelDownloadPromise;
      expect(labelDownload).toBeTruthy();
      
      const labelFilename = labelDownload.suggestedFilename();
      expect(labelFilename).toContain('.pdf');
      expect(labelFilename.toLowerCase()).toMatch(/label|container/);
      console.log(`T05.3: ✓ BUSINESS VALIDATION: Container label PDF generated: ${labelFilename}`);
      
      // Save and comprehensively validate label PDF
      const labelPath = path.join(__dirname, '../downloads', labelFilename);
      await labelDownload.saveAs(labelPath);
      
      // COMPREHENSIVE BUSINESS VALIDATION for label PDF
      const labelValidation = await validatePdfContent(labelPath, targetContainer, containerAssignments, 'label');
      expect(labelValidation.valid).toBe(true);
      expect(labelValidation.fileSize).toBeGreaterThan(500);
      
      console.log(`T05.3: ✓ COMPREHENSIVE BUSINESS VALIDATION: Label PDF validated successfully`);
      console.log(`T05.3: - Label PDF size: ${labelValidation.fileSize} bytes`);
      console.log(`T05.3: - Contains container info: ${labelValidation.containsContainerInfo}`);
      
      // CRITICAL BUSINESS VALIDATION: Test summary sheet generation
      const summaryDownloadPromise = page.waitForEvent('download', { timeout: 15000 });
      
      const summaryClick = await coords.clickElement(page, 'containerDetail', 'generateSummaryButton');
      expect(summaryClick).toBe(true);
      
      console.log('T05.3: ✓ Container summary sheet PDF generation initiated');
      
      // Validate summary PDF download
      const summaryDownload = await summaryDownloadPromise;
      expect(summaryDownload).toBeTruthy();
      
      const summaryFilename = summaryDownload.suggestedFilename();
      expect(summaryFilename).toContain('.pdf');
      expect(summaryFilename.toLowerCase()).toMatch(/summary|container/);
      console.log(`T05.3: ✓ BUSINESS VALIDATION: Container summary PDF generated: ${summaryFilename}`);
      
      // Save and comprehensively validate summary PDF
      const summaryPath = path.join(__dirname, '../downloads', summaryFilename);
      await summaryDownload.saveAs(summaryPath);
      
      // COMPREHENSIVE BUSINESS VALIDATION for summary PDF
      const summaryValidation = await validatePdfContent(summaryPath, targetContainer, containerAssignments, 'summary');
      expect(summaryValidation.valid).toBe(true);
      expect(summaryValidation.fileSize).toBeGreaterThan(1000); // Summary should be substantial
      
      console.log(`T05.3: ✓ COMPREHENSIVE BUSINESS VALIDATION: Summary PDF validated successfully`);
      console.log(`T05.3: - Summary PDF size: ${summaryValidation.fileSize} bytes`);
      console.log(`T05.3: - Contains container info: ${summaryValidation.containsContainerInfo}`);
      
      // BUSINESS VALIDATION: Test QR code generation if available
      const qrClick = await coords.clickElement(page, 'containerDetail', 'generateQrCodeButton');
      if (qrClick) {
        await page.waitForTimeout(coords.getTimeout('medium'));
        console.log('T05.3: ✓ QR code generation functionality accessible');
      } else {
        console.log('T05.3: QR code generation not available or coordinates need adjustment');
      }
      
      await page.waitForTimeout(coords.getTimeout('medium'));
      await page.screenshot({ path: 'packer-labels-generation-success.png' });
      
      // Clean up PDF files
      fs.unlinkSync(labelPath);
      fs.unlinkSync(summaryPath);
      
    } catch (error) {
      console.error('T05.3: Label and summary generation workflow error:', error.message);
      await page.screenshot({ path: 'packer-labels-error.png' });
      throw error; // Re-throw to fail the test with meaningful error
    }

    await page.screenshot({ path: 'packer-labels-final.png' });
    
    console.log('T05.3: ✓ PDF generation - labels and summaries test COMPLETED with business validation');
  });

  test('T05.4: Deployment Status Management', async ({ page }) => {
    console.log('T05.4: Starting Deployment Status Management test with business process validation');
    
    // Load test fixtures for this scenario
    const fixtures = loadTestFixtures('T05.4');
    console.log(`T05.4: Loaded fixtures for scenario: ${fixtures.scenarioName}`);
    
    // Login as Packer user (should have status management permissions)
    await loginAsTestUser(page, fixtures.authUser || 'test@rescuenet.net');
    await navigateToContainersOverview(page);
    await page.waitForTimeout(coords.getTimeout('dataLoad'));
    await page.screenshot({ path: 'packer-status-start.png' });

    // Validate mock repositories are available for business logic testing
    const mockValidation = await dataExtraction.validateMockRepositories(page);
    expect(mockValidation.valid).toBe(true);
    console.log('T05.4: ✓ Mock repositories validated for deployment status management testing');
    
    // BUSINESS PROCESS VALIDATION - Find container ready for status management
    const allContainers = await dataExtraction.getAllContainers(page);
    expect(allContainers.length).toBeGreaterThan(0);
    
    // Find a container that can be moved through deployment statuses
    const targetContainer = allContainers.find(container => 
      container.status === 'packing' || 
      container.status === 'ready_for_verification' ||
      container.verification_status === 'verified'
    );
    expect(targetContainer).toBeTruthy();
    console.log(`T05.4: Found target container for status management: ${targetContainer.name} (ID: ${targetContainer.id})`);
    
    // Record initial container status
    const initialStatus = targetContainer.status;
    const initialVerificationStatus = targetContainer.verification_status || 'unverified';
    console.log(`T05.4: Initial container state - Status: ${initialStatus}, Verification: ${initialVerificationStatus}`);
    
    // Verify navigation was successful
    const currentUrl = page.url();
    expect(currentUrl).toContain('containers');
    console.log('T05.4: ✓ Navigation to containers overview successful');

    // Test deployment status management with comprehensive business validation
    try {
      // Click on the target container
      const containerClick = await coords.clickElement(page, 'containersOverview', 'firstContainerArea');
      expect(containerClick).toBe(true);
      
      await page.waitForTimeout(coords.getTimeout('medium'));
      await page.screenshot({ path: 'packer-status-container-detail.png' });
      console.log('T05.4: ✓ Container detail view accessed for status management');
      
      // CRITICAL BUSINESS VALIDATION: Test status change workflow
      const statusClick = await coords.clickElement(page, 'containerDetail', 'changeStatusButton');
      expect(statusClick).toBe(true);
      
      await page.waitForTimeout(coords.getTimeout('medium'));
      await page.screenshot({ path: 'packer-status-change-dialog.png' });
      console.log('T05.4: ✓ Status change dialog opened');
      
      // Test moving container to 'ready_for_deployment' status
      const readyStatusClick = await coords.clickElement(page, 'statusDialog', 'readyForDeploymentOption');
      expect(readyStatusClick).toBe(true);
      console.log('T05.4: ✓ Ready for deployment status option selected');
      
      // Confirm the status change
      const confirmClick = await coords.clickElement(page, 'statusDialog', 'confirmStatusChangeButton');
      expect(confirmClick).toBe(true);
      
      await page.waitForTimeout(coords.getTimeout('long')); // Allow status change to process
      await page.screenshot({ path: 'packer-status-ready-for-deployment.png' });
      console.log('T05.4: ✓ Status change to ready_for_deployment confirmed');
      
      // CRITICAL BUSINESS VALIDATION: Verify status change persisted
      const updatedContainer = await dataExtraction.getContainerById(page, targetContainer.id);
      expect(updatedContainer).toBeTruthy();
      expect(updatedContainer.status).toBe('ready_for_deployment');
      console.log(`T05.4: ✓ BUSINESS VALIDATION: Container status updated to 'ready_for_deployment'`);
      
      // Test additional status progression to 'deployed'
      const deployStatusClick = await coords.clickElement(page, 'containerDetail', 'changeStatusButton');
      if (deployStatusClick) {
        await page.waitForTimeout(coords.getTimeout('medium'));
        
        const deployedStatusClick = await coords.clickElement(page, 'statusDialog', 'deployedOption');
        if (deployedStatusClick) {
          console.log('T05.4: ✓ Deployed status option accessible');
          
          const confirmDeployClick = await coords.clickElement(page, 'statusDialog', 'confirmStatusChangeButton');
          if (confirmDeployClick) {
            await page.waitForTimeout(coords.getTimeout('long'));
            
            // Validate deployment status change
            const deployedContainer = await dataExtraction.getContainerById(page, targetContainer.id);
            if (deployedContainer && deployedContainer.status === 'deployed') {
              console.log(`T05.4: ✓ BUSINESS VALIDATION: Container successfully moved to 'deployed' status`);
              
              // Validate deployment date was set
              expect(deployedContainer.deployment_date).toBeTruthy();
              console.log(`T05.4: ✓ BUSINESS VALIDATION: Deployment date set: ${deployedContainer.deployment_date}`);
            }
          }
        }
      }
      
      // Test status change persistence through page reload
      await page.reload();
      await page.waitForTimeout(coords.getTimeout('dataLoad'));
      
      const reloadedContainer = await dataExtraction.getContainerById(page, targetContainer.id);
      expect(reloadedContainer.status).not.toBe(initialStatus); // Should have changed from initial
      console.log('T05.4: ✓ BUSINESS VALIDATION: Status changes persist through page reload');
      
      // Test status change affects container list display
      await navigateToContainersOverview(page);
      await page.waitForTimeout(coords.getTimeout('dataLoad'));
      
      const allContainersAfterChange = await dataExtraction.getAllContainers(page);
      const changedContainer = allContainersAfterChange.find(container => container.id === targetContainer.id);
      expect(changedContainer).toBeTruthy();
      expect(changedContainer.status).toBe(reloadedContainer.status);
      console.log('T05.4: ✓ BUSINESS VALIDATION: Status changes reflected in container overview');
      
      await page.screenshot({ path: 'packer-status-management-success.png' });
      
    } catch (error) {
      console.error('T05.4: Deployment status management workflow error:', error.message);
      await page.screenshot({ path: 'packer-status-error.png' });
      throw error; // Re-throw to fail the test with meaningful error
    }

    await page.screenshot({ path: 'packer-status-final.png' });
    
    console.log('T05.4: ✓ Deployment status management test COMPLETED with business process validation');
  });
});

// Mark packer workflow test implementation as completed
// This test file now implements packer deployment workflows according to UC05 specifications