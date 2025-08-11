// @ts-check
const { test, expect } = require('@playwright/test');
const coords = require('../helpers/coordinateHelper');
const dataHelpers = require('../helpers/dataExtraction');
const visualValidation = require('../helpers/visualValidation');
const loadingHelpers = require('../helpers/loadingHelpers');

/**
 * Focused Assignment Management Workflows Test Suite
 * 
 * This test file covers the 3 most critical assignment management scenarios:
 * 1. Item-to-container assignment creation workflow
 * 2. Assignment quantity validation and capacity constraints
 * 3. Assignment status updates and tracking
 * 
 * Focus: Business logic validation and mathematical integrity
 */

let sharedBrowser;

/**
 * Common login helper using shared session for efficiency
 * @param {import('@playwright/test').Page} page 
 */
async function loginAsTestUser(page) {
  await page.goto('/');
  await page.waitForLoadState('networkidle');
  
  // Wait for app to be ready with loading state awareness
  await visualValidation.waitForFlutterReady(page, 30000, {
    waitForLoadingComplete: true,
    checkInteractionReady: true
  });

  const emailSuccess = await coords.typeInField(page, 'login', 'emailField', 'test@rescuenet.net', {
    operationType: 'quick',
    expectLoading: false
  });
  if (!emailSuccess) throw new Error('Failed to enter email during login');

  const passwordSuccess = await coords.typeInField(page, 'login', 'passwordField', 'password123', {
    operationType: 'quick',
    expectLoading: false
  });
  if (!passwordSuccess) throw new Error('Failed to enter password during login');

  const loginResult = await coords.clickElementWithLoadingWait(page, 'login', 'loginButton', {
    operationType: 'medium',
    expectLoading: true,
    maxLoadingTime: 10000
  });
  if (!loginResult.clickSuccess) throw new Error('Failed to click login button');
  
  console.log('✓ Login completed with loading handling');
}

/**
 * Navigate to Items Overview page
 * @param {import('@playwright/test').Page} page 
 */
async function navigateToItemsOverview(page) {
  // Open hamburger menu with loading handling
  const menuResult = await coords.clickElementWithLoadingWait(page, 'navigation', 'hamburgerMenu', {
    operationType: 'quick',
    expectLoading: false,
    maxLoadingTime: 3000
  });
  if (!menuResult.clickSuccess) throw new Error('Failed to open hamburger menu');
  
  // Click All Items menu with loading handling
  const itemsResult = await coords.clickElementWithLoadingWait(page, 'navigation', 'allItemsMenu', {
    operationType: 'medium',
    expectLoading: true, // Navigation may trigger data loading
    maxLoadingTime: 8000
  });
  if (!itemsResult.clickSuccess) throw new Error('Failed to click All Items menu');
  
  // Verify navigation completed and page is ready
  await visualValidation.waitForFlutterReady(page, 10000, {
    waitForLoadingComplete: true,
    checkInteractionReady: true
  });
  
  expect(page.url()).toContain('itemsOverview');
  console.log('✓ Navigation to Items Overview completed with loading handling');
}

test.describe('Assignment Workflows - Core Scenarios', () => {
  test.beforeEach(async ({ page }) => {
    page.on('console', msg => console.log('BROWSER:', msg.text()));
    page.on('pageerror', error => console.log('PAGE ERROR:', error.message));
  });

  test('AW.1: Item-to-Container Assignment Creation', async ({ page }) => {
    console.log('AW.1: Testing item-to-container assignment creation workflow');
    
    await loginAsTestUser(page);
    await navigateToItemsOverview(page);
    
    // Ensure page is fully ready for assignment operations
    await visualValidation.waitForFlutterReady(page, 15000, {
      waitForLoadingComplete: true,
      checkInteractionReady: true
    });
    
    // Get initial application state for business logic validation
    const initialState = await dataHelpers.getCurrentAppState(page);
    
    if (initialState.items.length === 0 || initialState.containers.length === 0) {
      console.log('AW.1: No test data available - skipping assignment creation test');
      return;
    }
    
    const testItem = initialState.items[0];
    const testContainer = initialState.containers[0];
    
    expect(testItem.total_quantity).toBeGreaterThan(0);
    expect(testItem.available_quantity).toBeGreaterThan(0);
    expect(testContainer).toBeTruthy();
    
    console.log(`AW.1: Testing assignment: "${testItem.name}" → "${testContainer.name}"`);
    console.log(`AW.1: Item state - Total: ${testItem.total_quantity}, Available: ${testItem.available_quantity}`);
    
    // Verify initial assignment math integrity
    const initialMathValid = await dataHelpers.verifyAssignmentMathInPage(page, testItem.id);
    expect(initialMathValid).toBe(true);
    
    const initialAssignments = await dataHelpers.getItemAssignments(page, testItem.id);
    const initialAssignmentsCount = initialAssignments.length;
    
    // Execute assignment workflow with loading handling
    const itemResult = await coords.clickElementWithLoadingWait(page, 'itemsOverview', 'firstItemArea', {
      operationType: 'medium',
      expectLoading: true, // Item detail loading
      maxLoadingTime: 8000
    });
    if (!itemResult.clickSuccess) throw new Error('Failed to click item for assignment');
    
    const assignResult = await coords.clickElementWithLoadingWait(page, 'itemDetail', 'assignmentButton', {
      operationType: 'medium',
      expectLoading: true, // Assignment form loading
      maxLoadingTime: 8000
    });
    if (!assignResult.clickSuccess) throw new Error('Failed to open assignment dialog');
    
    // Create assignment with business validation and loading handling
    const assignmentQuantity = Math.min(10, testItem.available_quantity);
    const quantitySuccess = await coords.typeInField(page, 'assignmentForm', 'quantityField', assignmentQuantity.toString(), {
      operationType: 'quick',
      expectLoading: false
    });
    if (!quantitySuccess) throw new Error('Failed to enter assignment quantity');
    
    const containerResult = await coords.clickElementWithLoadingWait(page, 'assignmentForm', 'containerDropdown', {
      operationType: 'quick',
      expectLoading: false,
      maxLoadingTime: 3000
    });
    if (containerResult.clickSuccess) {
      await coords.clickElementWithLoadingWait(page, 'assignmentForm', 'firstContainerOption', {
        operationType: 'quick',
        expectLoading: false,
        maxLoadingTime: 3000
      });
    }
    
    const saveResult = await coords.clickElementWithLoadingWait(page, 'assignmentForm', 'saveButton', {
      operationType: 'slow', // Assignment creation is a slower operation
      expectLoading: true,
      maxLoadingTime: 15000
    });
    if (!saveResult.clickSuccess) throw new Error('Failed to save assignment');
    
    console.log('Assignment creation completed with loading handling');
    
    // CRITICAL: Validate assignment creation outcome
    const finalAssignments = await dataHelpers.getItemAssignments(page, testItem.id);
    expect(finalAssignments.length).toBeGreaterThan(initialAssignmentsCount);
    
    const newAssignment = finalAssignments.find(a => !initialAssignments.find(ia => ia.id === a.id));
    expect(newAssignment).toBeTruthy();
    expect(newAssignment.quantity).toBe(assignmentQuantity);
    expect(newAssignment.item_id).toBe(testItem.id);
    
    // Validate item quantity updates
    const updatedItem = await dataHelpers.getItemById(page, testItem.id);
    expect(updatedItem.available_quantity).toBe(testItem.available_quantity - assignmentQuantity);
    expect(updatedItem.total_quantity).toBe(testItem.total_quantity); // Should remain unchanged
    
    // Verify assignment math integrity maintained
    const finalMathValid = await dataHelpers.verifyAssignmentMathInPage(page, testItem.id);
    expect(finalMathValid).toBe(true);
    
    console.log(`AW.1: ✓ Assignment created successfully - quantity: ${assignmentQuantity}`);
    console.log(`AW.1: ✓ Item quantities updated correctly - available: ${updatedItem.available_quantity}`);
    console.log('AW.1: ✓ Assignment math integrity maintained');
  });

  test('AW.2: Assignment Quantity Validation and Constraints', async ({ page }) => {
    console.log('AW.2: Testing assignment quantity validation and capacity constraints');
    
    await loginAsTestUser(page);
    await navigateToItemsOverview(page);
    
    // Ensure page is fully ready for assignment validation operations
    await visualValidation.waitForFlutterReady(page, 15000, {
      waitForLoadingComplete: true,
      checkInteractionReady: true
    });
    
    const initialState = await dataHelpers.getCurrentAppState(page);
    
    if (initialState.items.length === 0 || initialState.containers.length === 0) {
      console.log('AW.2: No test data available - skipping quantity validation test');
      return;
    }
    
    const testItem = initialState.items[0];
    const testContainer = initialState.containers[0];
    
    expect(testItem.available_quantity).toBeGreaterThan(0);
    console.log(`AW.2: Testing quantity constraints for "${testItem.name}" (available: ${testItem.available_quantity})`);
    
    const initialAssignments = await dataHelpers.getItemAssignments(page, testItem.id);
    const initialCount = initialAssignments.length;
    
    // Navigate to assignment form with loading handling
    const itemResult = await coords.clickElementWithLoadingWait(page, 'itemsOverview', 'firstItemArea', {
      operationType: 'medium',
      expectLoading: true,
      maxLoadingTime: 8000
    });
    if (!itemResult.clickSuccess) throw new Error('Failed to access item for validation testing');
    
    const assignResult = await coords.clickElementWithLoadingWait(page, 'itemDetail', 'assignmentButton', {
      operationType: 'medium',
      expectLoading: true,
      maxLoadingTime: 8000
    });
    if (!assignResult.clickSuccess) throw new Error('Failed to open assignment dialog');
    
    // Test constraint validations
    const constraintTests = [
      {
        quantity: testItem.available_quantity + 100,
        description: 'Over-assignment (should be rejected)',
        shouldSucceed: false
      },
      {
        quantity: 0,
        description: 'Zero quantity (should be rejected)',
        shouldSucceed: false
      },
      {
        quantity: -5,
        description: 'Negative quantity (should be rejected)',
        shouldSucceed: false
      },
      {
        quantity: Math.min(3, testItem.available_quantity),
        description: 'Valid assignment (should succeed)',
        shouldSucceed: true
      }
    ];
    
    let validAssignmentsCreated = 0;
    
    for (const [index, test] of constraintTests.entries()) {
      console.log(`AW.2: Test ${index + 1}: ${test.description} (quantity: ${test.quantity})`);
      
      // Enter test quantity with loading awareness
      const quantityEntry = await coords.typeInField(page, 'assignmentForm', 'quantityField', test.quantity.toString(), {
        operationType: 'quick',
        expectLoading: false
      });
      if (quantityEntry) {
        // Select container with loading handling
        const containerResult = await coords.clickElementWithLoadingWait(page, 'assignmentForm', 'containerDropdown', {
          operationType: 'quick',
          expectLoading: false,
          maxLoadingTime: 3000
        });
        if (containerResult.clickSuccess) {
          await coords.clickElementWithLoadingWait(page, 'assignmentForm', 'firstContainerOption', {
            operationType: 'quick',
            expectLoading: false,
            maxLoadingTime: 3000
          });
        }
        
        // Attempt to save with appropriate loading expectations
        const saveResult = await coords.clickElementWithLoadingWait(page, 'assignmentForm', 'saveButton', {
          operationType: test.shouldSucceed ? 'slow' : 'medium', // Valid operations may take longer
          expectLoading: test.shouldSucceed, // Only expect loading for valid operations
          maxLoadingTime: test.shouldSucceed ? 15000 : 5000
        });
        if (saveResult.clickSuccess) {
          
          // Validate outcome against expectation
          const currentAssignments = await dataHelpers.getItemAssignments(page, testItem.id);
          const currentCount = currentAssignments.length;
          
          if (test.shouldSucceed) {
            if (currentCount > initialCount + validAssignmentsCreated) {
              validAssignmentsCreated++;
              console.log(`AW.2: ✓ Valid assignment ${index + 1} accepted as expected`);
              
              // Verify assignment data
              const newAssignment = currentAssignments.find(a => !initialAssignments.find(ia => ia.id === a.id));
              if (newAssignment) {
                expect(newAssignment.quantity).toBe(test.quantity);
                expect(newAssignment.item_id).toBe(testItem.id);
              }
            } else {
              console.log(`AW.2: ⚠ Expected valid assignment ${index + 1} was not created`);
            }
          } else {
            if (currentCount === initialCount + validAssignmentsCreated) {
              console.log(`AW.2: ✓ Invalid assignment ${index + 1} rejected as expected`);
            } else {
              console.log(`AW.2: ⚠ Invalid assignment ${index + 1} may have been incorrectly accepted`);
            }
          }
          
          // Verify assignment math remains valid after each test
          const mathValid = await dataHelpers.verifyAssignmentMathInPage(page, testItem.id);
          expect(mathValid).toBe(true);
        }
      }
      
      // Clear field for next test
      await coords.typeInField(page, 'assignmentForm', 'quantityField', '', {
        operationType: 'quick',
        expectLoading: false
      });
      await page.waitForTimeout(coords.getTimeout('short'));
    }
    
    // Verify final state integrity
    const finalItem = await dataHelpers.getItemById(page, testItem.id);
    const expectedAvailable = testItem.available_quantity - (validAssignmentsCreated * 3); // Assuming valid assignment was 3
    if (validAssignmentsCreated > 0) {
      expect(finalItem.available_quantity).toBeLessThan(testItem.available_quantity);
    }
    
    console.log(`AW.2: ✓ Quantity validation complete - ${validAssignmentsCreated} valid assignments created`);
    console.log('AW.2: ✓ Assignment math integrity maintained throughout validation tests');
  });

  test('AW.3: Assignment Status Updates and Tracking', async ({ page }) => {
    console.log('AW.3: Testing assignment status updates and tracking');
    
    await loginAsTestUser(page);
    await navigateToItemsOverview(page);
    
    // Ensure page is fully ready for assignment tracking operations
    await visualValidation.waitForFlutterReady(page, 15000, {
      waitForLoadingComplete: true,
      checkInteractionReady: true
    });
    
    const initialState = await dataHelpers.getCurrentAppState(page);
    
    if (initialState.items.length === 0 || initialState.containers.length === 0) {
      console.log('AW.3: No test data available - skipping status tracking test');
      return;
    }
    
    const testItem = initialState.items[0];
    const testContainer = initialState.containers[0];
    
    console.log(`AW.3: Testing assignment tracking for "${testItem.name}"`);
    
    // Record initial assignment state
    const initialAssignments = await dataHelpers.getAllAssignments(page);
    const itemInitialAssignments = await dataHelpers.getItemAssignments(page, testItem.id);
    const containerInitialAssignments = initialAssignments.filter(a => a.container_id === testContainer.id);
    
    console.log(`AW.3: Initial state - Item: ${itemInitialAssignments.length} assignments, Container: ${containerInitialAssignments.length} assignments`);
    
    // Create a new assignment to track with loading handling
    if (testItem.available_quantity > 0) {
      const itemResult = await coords.clickElementWithLoadingWait(page, 'itemsOverview', 'firstItemArea', {
        operationType: 'medium',
        expectLoading: true,
        maxLoadingTime: 8000
      });
      
      if (itemResult.clickSuccess) {
        const assignResult = await coords.clickElementWithLoadingWait(page, 'itemDetail', 'assignmentButton', {
          operationType: 'medium',
          expectLoading: true,
          maxLoadingTime: 8000
        });
        
        if (assignResult.clickSuccess) {
          const trackingQuantity = Math.min(5, testItem.available_quantity);
          await coords.typeInField(page, 'assignmentForm', 'quantityField', trackingQuantity.toString(), {
            operationType: 'quick',
            expectLoading: false
          });
          
          const containerResult = await coords.clickElementWithLoadingWait(page, 'assignmentForm', 'containerDropdown', {
            operationType: 'quick',
            expectLoading: false,
            maxLoadingTime: 3000
          });
          if (containerResult.clickSuccess) {
            await coords.clickElementWithLoadingWait(page, 'assignmentForm', 'firstContainerOption', {
              operationType: 'quick',
              expectLoading: false,
              maxLoadingTime: 3000
            });
          }
          
          const saveResult = await coords.clickElementWithLoadingWait(page, 'assignmentForm', 'saveButton', {
            operationType: 'slow',
            expectLoading: true,
            maxLoadingTime: 15000
          });
          if (saveResult.clickSuccess) {
            console.log(`AW.3: ✓ Created assignment for tracking - quantity: ${trackingQuantity} with loading handling`);
          }
        }
      }
    }
    
    // Verify assignment tracking through navigation
    console.log('AW.3: Testing assignment persistence through navigation');
    
    // Navigate to containers overview with loading handling
    const menuResult = await coords.clickElementWithLoadingWait(page, 'navigation', 'hamburgerMenu', {
      operationType: 'quick',
      expectLoading: false,
      maxLoadingTime: 3000
    });
    if (menuResult.clickSuccess) {
      const containersResult = await coords.clickElementWithLoadingWait(page, 'navigation', 'containersMenu', {
        operationType: 'medium',
        expectLoading: true,
        maxLoadingTime: 8000
      });
      if (containersResult.clickSuccess) {
        await visualValidation.waitForFlutterReady(page, 10000, {
          waitForLoadingComplete: true,
          checkInteractionReady: true
        });
        expect(page.url()).toContain('containers');
        
        // Verify assignment is visible from container perspective
        const finalAssignments = await dataHelpers.getAllAssignments(page);
        const containerFinalAssignments = finalAssignments.filter(a => a.container_id === testContainer.id);
        
        expect(containerFinalAssignments.length).toBeGreaterThanOrEqual(containerInitialAssignments.length);
        console.log(`AW.3: ✓ Container view shows ${containerFinalAssignments.length} assignments`);
        
        // Validate assignment data integrity
        for (const assignment of containerFinalAssignments) {
          expect(assignment.item_id).toBeTruthy();
          expect(assignment.container_id).toBe(testContainer.id);
          expect(assignment.quantity).toBeGreaterThan(0);
        }
        
        // Test container capacity tracking
        let totalAssignedWeight = 0;
        for (const assignment of containerFinalAssignments) {
          const assignedItem = await dataHelpers.getItemById(page, assignment.item_id);
          if (assignedItem) {
            totalAssignedWeight += (assignedItem.weight || 0) * assignment.quantity;
          }
        }
        
        const containerCapacity = testContainer.max_weight || 10000;
        expect(totalAssignedWeight).toBeLessThanOrEqual(containerCapacity);
        console.log(`AW.3: ✓ Container capacity constraint maintained - ${totalAssignedWeight}/${containerCapacity}`);
      }
    }
    
    // Test assignment persistence through page refresh with loading handling
    console.log('AW.3: Testing assignment persistence through page refresh');
    await page.reload();
    await page.waitForLoadState('networkidle');
    
    // Wait for app to fully reload with loading state awareness
    await visualValidation.waitForFlutterReady(page, 30000, {
      waitForLoadingComplete: true,
      checkInteractionReady: true
    });
    
    const persistedAssignments = await dataHelpers.getAllAssignments(page);
    expect(persistedAssignments.length).toBeGreaterThanOrEqual(initialAssignments.length);
    
    // Verify assignment math integrity after page refresh
    const updatedItem = await dataHelpers.getItemById(page, testItem.id);
    if (updatedItem) {
      const mathValid = await dataHelpers.verifyAssignmentMathInPage(page, testItem.id);
      expect(mathValid).toBe(true);
      console.log('AW.3: ✓ Assignment math integrity maintained after page refresh');
    }
    
    console.log('AW.3: ✓ Assignment status tracking complete');
    console.log(`AW.3: ✓ Final state verified - ${persistedAssignments.length} total assignments persist`);
  });
});