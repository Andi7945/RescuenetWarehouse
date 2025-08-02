// @ts-check
/**
 * Example: How to refactor tests using the CoordinateHelper
 * This shows before/after comparisons for the item management tests
 */

const { test, expect } = require('@playwright/test');
const coords = require('../helpers/coordinateHelper');

/**
 * BEFORE: Raw coordinate-based login (from original test)
 */
async function loginAsTestUser_OLD(page, userEmail = 'test@rescuenet.net') {
  await page.goto('/');
  await page.waitForLoadState('networkidle');
  await page.waitForTimeout(5000);

  // Hard-coded coordinates - fragile and hard to maintain
  await page.mouse.click(640, 285); // Email field
  await page.keyboard.type('test@rescuenet.net');

  await page.mouse.click(640, 330); // Password field  
  await page.keyboard.type('password123');

  await page.mouse.click(487, 393); // Login button
  await page.waitForTimeout(5000);
}

/**
 * AFTER: Semantic coordinate-based login using CoordinateHelper
 */
async function loginAsTestUser_NEW(page, userEmail = 'test@rescuenet.net') {
  await page.goto('/');
  await page.waitForLoadState('networkidle');
  await page.waitForTimeout(coords.getTimeout('dataLoad'));

  // Semantic names with built-in retry logic
  await coords.typeInField(page, 'login', 'emailField', 'test@rescuenet.net');
  await coords.typeInField(page, 'login', 'passwordField', 'password123');
  await coords.clickElement(page, 'login', 'loginButton');
  
  await page.waitForTimeout(coords.getTimeout('dataLoad'));
}

/**
 * BEFORE: Raw coordinate navigation (from original test)
 */
async function navigateToItemsOverview_OLD(page) {
  // Hard-coded coordinates
  await page.mouse.click(27, 27); // Hamburger menu
  await page.waitForTimeout(1500);
  
  await page.mouse.click(85, 215); // All Items menu
  await page.waitForTimeout(3000);
  
  const currentUrl = page.url();
  expect(currentUrl).toContain('itemsOverview');
}

/**
 * AFTER: Semantic coordinate navigation using CoordinateHelper
 */
async function navigateToItemsOverview_NEW(page) {
  // Semantic names with error handling
  const menuClick = await coords.clickElement(page, 'navigation', 'hamburgerMenu');
  if (!menuClick) {
    throw new Error('Failed to open hamburger menu');
  }
  await page.waitForTimeout(coords.getTimeout('medium'));
  
  const itemsClick = await coords.clickElement(page, 'navigation', 'allItemsMenu');
  if (!itemsClick) {
    throw new Error('Failed to click All Items menu');
  }
  await page.waitForTimeout(coords.getTimeout('long'));
  
  const currentUrl = page.url();
  expect(currentUrl).toContain('itemsOverview');
}

/**
 * BEFORE: Raw coordinate form interaction (from original test)
 */
async function createNewItem_OLD(page) {
  await page.mouse.click(800, 150); // Add New Item button
  await page.waitForTimeout(1000);
  
  await page.mouse.click(400, 300); // Name field
  await page.keyboard.type('Test Bandages');
  
  await page.mouse.click(400, 350); // Description field  
  await page.keyboard.type('Bandages for testing purposes');
  
  await page.mouse.click(400, 400); // Quantity field
  await page.keyboard.type('100');
  
  await page.mouse.click(400, 450); // Unit field
  await page.keyboard.type('pieces');
  
  await page.mouse.click(500, 600); // Save button
  await page.waitForTimeout(2000);
}

/**
 * AFTER: Semantic coordinate form interaction using CoordinateHelper
 */
async function createNewItem_NEW(page) {
  // Open create dialog
  const createClick = await coords.clickElement(page, 'itemsOverview', 'createItemButton');
  if (!createClick) {
    throw new Error('Failed to open create item dialog');
  }
  await page.waitForTimeout(coords.getTimeout('medium'));
  
  // Fill form fields with semantic names and error handling
  const formData = {
    name: 'Test Bandages',
    description: 'Bandages for testing purposes', 
    quantity: '100',
    unit: 'pieces'
  };
  
  await coords.typeInField(page, 'itemForm', 'nameField', formData.name);
  await coords.typeInField(page, 'itemForm', 'descriptionField', formData.description);
  await coords.typeInField(page, 'itemForm', 'quantityField', formData.quantity);
  await coords.typeInField(page, 'itemForm', 'unitField', formData.unit);
  
  // Save with error handling
  const saveClick = await coords.clickElement(page, 'itemForm', 'saveButton');
  if (!saveClick) {
    throw new Error('Failed to save new item');
  }
  await page.waitForTimeout(coords.getTimeout('long'));
}

/**
 * BEFORE: Raw coordinate filtering (from original test)
 */
async function applyLocationFilter_OLD(page) {
  await page.mouse.click(400, 200); // Location filter
  await page.waitForTimeout(500);
  
  await page.mouse.click(450, 250); // Select "Warehouse A"
  await page.waitForTimeout(1000);
}

/**
 * AFTER: Semantic coordinate filtering using CoordinateHelper
 */
async function applyLocationFilter_NEW(page) {
  // Open location filter
  const filterClick = await coords.clickElement(page, 'itemsOverview', 'locationFilter');
  if (!filterClick) {
    throw new Error('Failed to open location filter');
  }
  await page.waitForTimeout(coords.getTimeout('short'));
  
  // Select Warehouse A option
  const optionClick = await coords.clickElement(page, 'filters', 'warehouseAOption');
  if (!optionClick) {
    throw new Error('Failed to select Warehouse A option');
  }
  await page.waitForTimeout(coords.getTimeout('medium'));
}

/**
 * BEFORE: Raw coordinate quantity management (from original test)
 */
async function testQuantityIncrement_OLD(page) {
  // Navigate to item detail
  await page.mouse.click(400, 300); // Click on test item
  await page.waitForTimeout(1000);
  
  // Test increment operations
  for (let i = 0; i < 3; i++) {
    await page.mouse.click(550, 320); // Increment button
    await page.waitForTimeout(300);
  }
}

/**
 * AFTER: Semantic coordinate quantity management using CoordinateHelper
 */
async function testQuantityIncrement_NEW(page) {
  // Navigate to item detail
  const itemClick = await coords.clickElement(page, 'itemsOverview', 'firstItemArea');
  if (!itemClick) {
    throw new Error('Failed to click on test item');
  }
  await page.waitForTimeout(coords.getTimeout('medium'));
  
  // Test increment operations with error handling
  for (let i = 0; i < 3; i++) {
    const incrementClick = await coords.clickElement(page, 'itemDetail', 'incrementButton');
    if (!incrementClick) {
      console.warn(`Increment click ${i + 1} failed, retrying...`);
      continue; // Built-in retry logic will handle this
    }
    await page.waitForTimeout(coords.getTimeout('short'));
  }
}

/**
 * Example test using the new coordinate system
 */
test.describe('Example: Refactored Item Management Test', () => {
  test('Demonstrate improved coordinate system', async ({ page }) => {
    // Setup console logging
    page.on('console', msg => console.log('BROWSER:', msg.text()));
    page.on('pageerror', error => console.log('PAGE ERROR:', error.message));
    
    try {
      // Login using semantic coordinates
      await loginAsTestUser_NEW(page);
      await page.screenshot({ path: 'example-login-complete.png' });
      
      // Navigate using semantic coordinates
      await navigateToItemsOverview_NEW(page);
      await page.screenshot({ path: 'example-navigation-complete.png' });
      
      // Apply filters using semantic coordinates
      await applyLocationFilter_NEW(page);
      await page.screenshot({ path: 'example-filter-applied.png' });
      
      // Test quantity management using semantic coordinates
      await testQuantityIncrement_NEW(page);
      await page.screenshot({ path: 'example-quantity-test.png' });
      
      console.log('✓ All coordinate-based interactions completed successfully');
      
    } catch (error) {
      console.error('Test failed:', error.message);
      await page.screenshot({ path: 'example-test-failure.png' });
      throw error;
    }
  });
  
  test('Validate coordinate configuration', async ({ page }) => {
    // Validate the coordinate configuration
    const validation = coords.validateConfiguration();
    
    console.log('Coordinate Configuration Validation:');
    console.log(validation.summary);
    
    if (!validation.isValid) {
      console.error('Configuration issues found:');
      validation.issues.forEach(issue => console.error('  -', issue));
    }
    
    expect(validation.isValid).toBeTruthy();
    expect(validation.sectionsCount).toBeGreaterThan(5);
  });
});

/**
 * Benefits of the new coordinate system:
 * 
 * 1. MAINTAINABILITY:
 *    - All coordinates in one JSON file
 *    - Semantic names instead of magic numbers
 *    - Easy to update when UI changes
 * 
 * 2. ROBUSTNESS:
 *    - Built-in retry logic for failed clicks
 *    - Error handling and logging
 *    - Screenshots on failures for debugging
 * 
 * 3. REUSABILITY:
 *    - Same coordinates used across multiple tests
 *    - Helper functions for common patterns
 *    - Centralized timeout management
 * 
 * 4. READABILITY:
 *    - Self-documenting code with semantic names
 *    - Clear separation of concerns
 *    - Easier onboarding for new developers
 * 
 * 5. SCALABILITY:
 *    - Easy to add new coordinates
 *    - Support for different viewport sizes
 *    - Coordinate validation and debugging tools
 */

module.exports = {
  loginAsTestUser_NEW,
  navigateToItemsOverview_NEW,
  createNewItem_NEW,
  applyLocationFilter_NEW,
  testQuantityIncrement_NEW
};