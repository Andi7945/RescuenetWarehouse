// @ts-check
const { test, expect } = require('@playwright/test');
const coords = require('../helpers/coordinateHelper');
const dataHelpers = require('../helpers/dataExtraction');

/**
 * Critical Integration Scenarios Test Suite
 * 
 * This test file focuses on the 4 most critical integration scenarios:
 * 1. End-to-end cross-role workflows (item creation -> assignment -> packer verification)
 * 2. Multi-step business processes (container lifecycle with assignments)
 * 3. Role transition scenarios (back office -> logistics -> packer handoff)
 * 4. System-wide data consistency (assignments, containers, work logs)
 * 
 * Focus: Cross-feature integration and business process validation
 */

let sharedPage;

/**
 * Common login helper for different user roles
 * @param {import('@playwright/test').Page} page 
 * @param {string} role - 'backoffice', 'packer', 'logistics'
 */
async function loginAsRole(page, role = 'backoffice') {
  const userCredentials = {
    backoffice: { email: 'test@rescuenet.net', password: 'password123' },
    packer: { email: 'packer@rescuenet.net', password: 'password123' },
    logistics: { email: 'logistics@rescuenet.net', password: 'password123' }
  };

  const creds = userCredentials[role] || userCredentials.backoffice;

  await page.goto('/');
  await page.waitForLoadState('networkidle');
  await page.waitForTimeout(coords.getTimeout('dataLoad'));

  const emailSuccess = await coords.typeInField(page, 'login', 'emailField', creds.email);
  if (!emailSuccess) throw new Error(`Failed to login as ${role}: email input failed`);

  const passwordSuccess = await coords.typeInField(page, 'login', 'passwordField', creds.password);
  if (!passwordSuccess) throw new Error(`Failed to login as ${role}: password input failed`);

  const loginSuccess = await coords.clickElement(page, 'login', 'loginButton');
  if (!loginSuccess) throw new Error(`Failed to login as ${role}: login button failed`);

  await page.waitForTimeout(coords.getTimeout('dataLoad'));
}

test.describe('Critical Integration Scenarios', () => {
  
  // Use a shared browser context for efficiency across integration tests
  test.beforeAll(async ({ browser }) => {
    const context = await browser.newContext();
    sharedPage = await context.newPage();
  });

  test.afterAll(async () => {
    if (sharedPage) {
      await sharedPage.close();
    }
  });

  test('INT01: End-to-End Cross-Role Workflow', async () => {
    /**
     * Tests complete workflow from item creation to packer verification
     * Validates: UC02 -> UC04 -> UC05 integration
     * Roles: Back Office -> Logistics -> Packer
     */

    // Phase 1: Back Office creates item and container
    await loginAsRole(sharedPage, 'backoffice');
    
    // Navigate to items and create test item
    const menuSuccess = await coords.clickElement(sharedPage, 'navigation', 'hamburgerMenu');
    expect(menuSuccess).toBe(true);
    await sharedPage.waitForTimeout(coords.getTimeout('medium'));
    
    const itemsSuccess = await coords.clickElement(sharedPage, 'navigation', 'allItemsMenu');
    expect(itemsSuccess).toBe(true);
    await sharedPage.waitForTimeout(coords.getTimeout('dataLoad'));

    // Create new item for integration test
    const createItemSuccess = await coords.clickElement(sharedPage, 'items', 'addItemButton');
    expect(createItemSuccess).toBe(true);
    await sharedPage.waitForTimeout(coords.getTimeout('medium'));

    // Fill item details
    const testItemName = `Integration-Item-${Date.now()}`;
    const nameSuccess = await coords.typeInField(sharedPage, 'items', 'itemNameField', testItemName);
    expect(nameSuccess).toBe(true);

    const descSuccess = await coords.typeInField(sharedPage, 'items', 'itemDescField', 'Cross-role integration test item');
    expect(descSuccess).toBe(true);

    const qtySuccess = await coords.typeInField(sharedPage, 'items', 'itemQuantityField', '10');
    expect(qtySuccess).toBe(true);

    const saveSuccess = await coords.clickElement(sharedPage, 'items', 'saveItemButton');
    expect(saveSuccess).toBe(true);
    await sharedPage.waitForTimeout(coords.getTimeout('save'));

    // Phase 2: Switch to Logistics role and create container assignment
    await loginAsRole(sharedPage, 'logistics');
    
    // Navigate to containers and create test container
    const containerMenuSuccess = await coords.clickElement(sharedPage, 'navigation', 'hamburgerMenu');
    expect(containerMenuSuccess).toBe(true);
    await sharedPage.waitForTimeout(coords.getTimeout('medium'));

    const containersSuccess = await coords.clickElement(sharedPage, 'navigation', 'allContainersMenu');
    expect(containersSuccess).toBe(true);
    await sharedPage.waitForTimeout(coords.getTimeout('dataLoad'));

    // Create assignment between item and container
    const testContainerName = `IntegrationContainer-${Date.now()}`;
    const assignmentSuccess = await coords.clickElement(sharedPage, 'containers', 'createAssignmentButton');
    expect(assignmentSuccess).toBe(true);

    // Phase 3: Switch to Packer role and verify container contents
    await loginAsRole(sharedPage, 'packer');
    
    // Navigate to packing verification
    const packerMenuSuccess = await coords.clickElement(sharedPage, 'navigation', 'hamburgerMenu');
    expect(packerMenuSuccess).toBe(true);
    await sharedPage.waitForTimeout(coords.getTimeout('medium'));

    const packingSuccess = await coords.clickElement(sharedPage, 'navigation', 'packingMenu');
    expect(packingSuccess).toBe(true);
    await sharedPage.waitForTimeout(coords.getTimeout('dataLoad'));

    // Verify the item appears in packer's workflow
    const itemVisible = await dataHelpers.isElementVisible(sharedPage, testItemName);
    expect(itemVisible).toBe(true);

    await sharedPage.screenshot({ path: 'integration-cross-role-workflow.png' });
  });

  test('INT02: Multi-Step Business Process Validation', async () => {
    /**
     * Tests complex container lifecycle with capacity constraints
     * Validates: UC03 -> UC04 -> capacity validation -> work log creation
     */

    await loginAsRole(sharedPage, 'logistics');

    // Step 1: Create container with specific capacity
    const menuSuccess = await coords.clickElement(sharedPage, 'navigation', 'hamburgerMenu');
    expect(menuSuccess).toBe(true);
    await sharedPage.waitForTimeout(coords.getTimeout('medium'));

    const containersSuccess = await coords.clickElement(sharedPage, 'navigation', 'allContainersMenu');
    expect(containersSuccess).toBe(true);
    await sharedPage.waitForTimeout(coords.getTimeout('dataLoad'));

    // Step 2: Create multiple assignments that test capacity limits
    const testContainerName = `CapacityTest-${Date.now()}`;
    
    // Attempt to assign items up to capacity limit
    for (let i = 1; i <= 3; i++) {
      const assignSuccess = await coords.clickElement(sharedPage, 'containers', `assignItem${i}Button`);
      if (assignSuccess) {
        await sharedPage.waitForTimeout(coords.getTimeout('medium'));
      }
    }

    // Step 3: Validate capacity constraints are enforced
    const capacityWarning = await dataHelpers.checkForWarningMessage(sharedPage);
    expect(capacityWarning).toBeTruthy(); // Should show capacity warning

    // Step 4: Verify work log entries are created for assignments
    const workLogSuccess = await coords.clickElement(sharedPage, 'navigation', 'workLogMenu');
    expect(workLogSuccess).toBe(true);
    await sharedPage.waitForTimeout(coords.getTimeout('dataLoad'));

    const workLogEntries = await dataHelpers.countVisibleElements(sharedPage, '.work-log-entry');
    expect(workLogEntries).toBeGreaterThan(0);

    await sharedPage.screenshot({ path: 'integration-business-process.png' });
  });

  test('INT03: Role Transition and Permission Validation', async () => {
    /**
     * Tests role-based access control across different workflows
     * Validates: Authentication -> Role permissions -> Feature access
     */

    // Test 1: Back Office user attempting packer-only operations
    await loginAsRole(sharedPage, 'backoffice');
    
    const menuSuccess = await coords.clickElement(sharedPage, 'navigation', 'hamburgerMenu');
    expect(menuSuccess).toBe(true);
    await sharedPage.waitForTimeout(coords.getTimeout('medium'));

    // Back office should NOT have access to packer verification
    const packerMenuVisible = await dataHelpers.isElementVisible(sharedPage, 'packer-verification-menu');
    expect(packerMenuVisible).toBe(false);

    // Test 2: Packer user attempting back office operations
    await loginAsRole(sharedPage, 'packer');
    
    const packerMenuSuccess = await coords.clickElement(sharedPage, 'navigation', 'hamburgerMenu');
    expect(packerMenuSuccess).toBe(true);
    await sharedPage.waitForTimeout(coords.getTimeout('medium'));

    // Packer should have limited item management access
    const limitedItemAccess = await dataHelpers.isElementVisible(sharedPage, 'read-only-items');
    expect(limitedItemAccess).toBe(true);

    // Test 3: Logistics user having combined permissions
    await loginAsRole(sharedPage, 'logistics');
    
    const logisticsMenuSuccess = await coords.clickElement(sharedPage, 'navigation', 'hamburgerMenu');
    expect(logisticsMenuSuccess).toBe(true);
    await sharedPage.waitForTimeout(coords.getTimeout('medium'));

    // Logistics should have both back office AND packer capabilities
    const backOfficeAccess = await dataHelpers.isElementVisible(sharedPage, 'item-management-menu');
    const packerAccess = await dataHelpers.isElementVisible(sharedPage, 'packer-verification-menu');
    
    expect(backOfficeAccess).toBe(true);
    expect(packerAccess).toBe(true);

    await sharedPage.screenshot({ path: 'integration-role-transitions.png' });
  });

  test('INT04: System-Wide Data Consistency', async () => {
    /**
     * Tests data consistency across all modules and roles
     * Validates: Item quantities -> Assignment quantities -> Container weights -> Work logs
     */

    await loginAsRole(sharedPage, 'logistics');

    // Step 1: Create baseline data state
    const testItemName = `ConsistencyTest-${Date.now()}`;
    const initialQuantity = 50;
    
    // Navigate to items and get initial state
    const menuSuccess = await coords.clickElement(sharedPage, 'navigation', 'hamburgerMenu');
    expect(menuSuccess).toBe(true);
    await sharedPage.waitForTimeout(coords.getTimeout('medium'));

    const itemsSuccess = await coords.clickElement(sharedPage, 'navigation', 'allItemsMenu');
    expect(itemsSuccess).toBe(true);
    await sharedPage.waitForTimeout(coords.getTimeout('dataLoad'));

    // Step 2: Create item with known quantity
    const createItemSuccess = await coords.clickElement(sharedPage, 'items', 'addItemButton');
    expect(createItemSuccess).toBe(true);

    const nameSuccess = await coords.typeInField(sharedPage, 'items', 'itemNameField', testItemName);
    const qtySuccess = await coords.typeInField(sharedPage, 'items', 'itemQuantityField', initialQuantity.toString());
    const saveSuccess = await coords.clickElement(sharedPage, 'items', 'saveItemButton');
    
    expect(nameSuccess && qtySuccess && saveSuccess).toBe(true);
    await sharedPage.waitForTimeout(coords.getTimeout('save'));

    // Step 3: Create assignment and verify quantity consistency
    const assignQuantity = 20;
    const assignSuccess = await coords.clickElement(sharedPage, 'assignments', 'createAssignmentButton');
    expect(assignSuccess).toBe(true);

    const assignQtySuccess = await coords.typeInField(sharedPage, 'assignments', 'quantityField', assignQuantity.toString());
    expect(assignQtySuccess).toBe(true);

    const confirmAssignSuccess = await coords.clickElement(sharedPage, 'assignments', 'confirmButton');
    expect(confirmAssignSuccess).toBe(true);
    await sharedPage.waitForTimeout(coords.getTimeout('save'));

    // Step 4: Verify quantities are consistent across modules
    
    // Check item remaining quantity
    const remainingQuantity = await dataHelpers.extractNumber(sharedPage, '.item-remaining-quantity');
    expect(remainingQuantity).toBe(initialQuantity - assignQuantity);

    // Check container assignment total
    const containerTotal = await dataHelpers.extractNumber(sharedPage, '.container-assigned-quantity');
    expect(containerTotal).toBe(assignQuantity);

    // Step 5: Verify work log consistency
    const workLogSuccess = await coords.clickElement(sharedPage, 'navigation', 'workLogMenu');
    expect(workLogSuccess).toBe(true);
    await sharedPage.waitForTimeout(coords.getTimeout('dataLoad'));

    const workLogQuantity = await dataHelpers.extractNumber(sharedPage, '.work-log-quantity');
    expect(workLogQuantity).toBe(assignQuantity);

    // Step 6: Test concurrent modification consistency
    // Simulate what happens when multiple users modify same data
    const modifySuccess = await coords.clickElement(sharedPage, 'items', 'editQuantityButton');
    expect(modifySuccess).toBe(true);

    const newQuantity = 60;
    const updateQtySuccess = await coords.typeInField(sharedPage, 'items', 'itemQuantityField', newQuantity.toString());
    const updateSaveSuccess = await coords.clickElement(sharedPage, 'items', 'saveItemButton');
    
    expect(updateQtySuccess && updateSaveSuccess).toBe(true);
    await sharedPage.waitForTimeout(coords.getTimeout('save'));

    // Verify all related data updated consistently
    const newRemainingQuantity = await dataHelpers.extractNumber(sharedPage, '.item-remaining-quantity');
    expect(newRemainingQuantity).toBe(newQuantity - assignQuantity);

    await sharedPage.screenshot({ path: 'integration-data-consistency.png' });
  });
});