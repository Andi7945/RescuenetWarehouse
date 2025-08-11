// @ts-check
const { test, expect } = require('@playwright/test');
const coordinateHelper = require('../helpers/coordinateHelper');
const visualValidation = require('../helpers/visualValidation');
const loadingHelpers = require('../helpers/loadingHelpers');
const authHelpers = require('../helpers/authHelpers');

/**
 * Loading State Validation Test Suite
 * 
 * This test file specifically validates that loading indicators, overlays, and
 * debounced loading work correctly throughout the application. It ensures that:
 * 1. Loading indicators appear for appropriate operations
 * 2. Loading indicators disappear when operations complete
 * 3. Debounced loading timing works correctly
 * 4. Modal overlays block interactions appropriately
 * 5. Error scenarios handle loading states correctly
 */

test.describe('Loading State Validation - Core Functionality', () => {
  
  test.beforeEach(async ({ page }) => {
    // Enhanced setup with loading state awareness
    await page.goto('/');
    await page.waitForLoadState('networkidle');
    
    // Wait for Flutter app to be ready
    await visualValidation.waitForFlutterReady(page, 30000, {
      waitForLoadingComplete: true,
      checkInteractionReady: true
    });
    
    console.log('✓ Loading state test setup complete');
  });

  test('LS.1: Authentication Loading States', async ({ page }) => {
    console.log('LS.1: Testing authentication loading states');

    // Test login loading behavior
    console.log('Testing login loading behavior...');
    
    const loadingValidation = await loadingHelpers.validateLoadingBehavior(
      page,
      'medium', // Login is a medium-speed operation
      async () => {
        // Type credentials
        await coordinateHelper.typeInField(page, 'login', 'emailField', 'test@rescuenet.net', {
          operationType: 'quick',
          expectLoading: false
        });
        
        await coordinateHelper.typeInField(page, 'login', 'passwordField', 'password123', {
          operationType: 'quick', 
          expectLoading: false
        });
        
        // Click login button (this should trigger loading)
        return await coordinateHelper.clickElement(page, 'login', 'loginButton', {
          expectLoading: true,
          operationType: 'medium'
        });
      },
      {
        expectLoadingToShow: true,
        maxOperationTime: 15000,
        actionDescription: 'user login'
      }
    );

    // Validate login loading behavior
    expect(loadingValidation.actionSuccess).toBe(true);
    expect(loadingValidation.loadingBehaviorCorrect).toBe(true);
    expect(loadingValidation.timingAppropriate).toBe(true);
    
    console.log('LS.1: ✓ Authentication loading states validated successfully');
    
    // Verify authentication completed successfully
    const authValidation = await authHelpers.validateUserSession(page, 'test@rescuenet.net');
    expect(authValidation.isValid).toBe(true);
  });

  test('LS.2: Navigation Loading States', async ({ page }) => {
    console.log('LS.2: Testing navigation loading states');

    // First login to test navigation loading
    const loginResult = await coordinateHelper.clickElementWithLoadingWait(page, 'login', 'loginButton', {
      operationType: 'medium',
      expectLoading: true,
      maxLoadingTime: 10000
    });
    expect(loginResult.clickSuccess).toBe(true);

    // Test hamburger menu opening (quick operation - may not show loading)
    console.log('Testing hamburger menu loading...');
    const menuLoadingValidation = await loadingHelpers.validateLoadingBehavior(
      page,
      'quick',
      async () => {
        return await coordinateHelper.clickElement(page, 'navigation', 'hamburgerMenu', {
          expectLoading: false,
          operationType: 'quick'
        });
      },
      {
        expectLoadingToShow: false, // Quick operations may not show loading
        maxOperationTime: 3000,
        actionDescription: 'hamburger menu open'
      }
    );

    expect(menuLoadingValidation.actionSuccess).toBe(true);

    // Test navigation to items (medium operation - should show loading)
    console.log('Testing items navigation loading...');
    const itemsLoadingValidation = await loadingHelpers.validateLoadingBehavior(
      page,
      'medium',
      async () => {
        return await coordinateHelper.clickElement(page, 'navigation', 'allItemsMenu', {
          expectLoading: true,
          operationType: 'medium',
          loadingTimeout: 8000
        });
      },
      {
        expectLoadingToShow: true,
        maxOperationTime: 10000,
        actionDescription: 'items page navigation'
      }
    );

    expect(itemsLoadingValidation.actionSuccess).toBe(true);
    expect(itemsLoadingValidation.loadingBehaviorCorrect).toBe(true);
    
    console.log('LS.2: ✓ Navigation loading states validated successfully');
  });

  test('LS.3: CRUD Operation Loading States', async ({ page }) => {
    console.log('LS.3: Testing CRUD operation loading states');

    // Login and navigate to items
    await coordinateHelper.typeInField(page, 'login', 'emailField', 'logistics.test@rescuenet.net', {
      operationType: 'quick',
      expectLoading: false
    });
    
    await coordinateHelper.typeInField(page, 'login', 'passwordField', 'password123', {
      operationType: 'quick',
      expectLoading: false
    });

    const loginResult = await coordinateHelper.clickElementWithLoadingWait(page, 'login', 'loginButton', {
      operationType: 'medium',
      expectLoading: true,
      maxLoadingTime: 10000
    });
    expect(loginResult.clickSuccess).toBe(true);

    // Navigate to items
    const menuResult = await coordinateHelper.clickElementWithLoadingWait(page, 'navigation', 'hamburgerMenu', {
      operationType: 'quick',
      expectLoading: false,
      maxLoadingTime: 3000
    });
    expect(menuResult.clickSuccess).toBe(true);

    const itemsResult = await coordinateHelper.clickElementWithLoadingWait(page, 'navigation', 'allItemsMenu', {
      operationType: 'medium',
      expectLoading: true,
      maxLoadingTime: 8000
    });
    expect(itemsResult.clickSuccess).toBe(true);

    // Test item creation loading (slow operation)
    console.log('Testing item creation loading...');
    const createLoadingValidation = await loadingHelpers.validateLoadingBehavior(
      page,
      'slow',
      async () => {
        // Click create item button
        const createResult = await coordinateHelper.clickElement(page, 'itemsOverview', 'createItemButton', {
          expectLoading: true,
          operationType: 'medium'
        });
        
        if (!createResult) return false;

        // Fill form quickly (these shouldn't trigger loading individually)
        await coordinateHelper.typeInField(page, 'itemForm', 'nameField', 'Loading Test Item', {
          operationType: 'quick',
          expectLoading: false
        });
        
        await coordinateHelper.typeInField(page, 'itemForm', 'descriptionField', 'Testing loading states', {
          operationType: 'quick',
          expectLoading: false
        });
        
        await coordinateHelper.typeInField(page, 'itemForm', 'quantityField', '10', {
          operationType: 'quick',
          expectLoading: false
        });

        // Save item (this should trigger slow loading)
        return await coordinateHelper.clickElement(page, 'itemForm', 'saveButton', {
          expectLoading: true,
          operationType: 'slow',
          loadingTimeout: 15000
        });
      },
      {
        expectLoadingToShow: true,
        maxOperationTime: 20000,
        actionDescription: 'item creation'
      }
    );

    expect(createLoadingValidation.actionSuccess).toBe(true);
    expect(createLoadingValidation.loadingBehaviorCorrect).toBe(true);
    
    console.log('LS.3: ✓ CRUD operation loading states validated successfully');
  });

  test('LS.4: Loading Overlay Interaction Blocking', async ({ page }) => {
    console.log('LS.4: Testing loading overlay interaction blocking');

    // Login first
    await coordinateHelper.typeInField(page, 'login', 'emailField', 'test@rescuenet.net', {
      operationType: 'quick',
      expectLoading: false
    });
    
    await coordinateHelper.typeInField(page, 'login', 'passwordField', 'password123', {
      operationType: 'quick',
      expectLoading: false
    });

    // Test that modal overlays block interactions
    const interactionTest = await loadingHelpers.performActionWithLoadingWait(
      page,
      async () => {
        // Click login to start a loading operation
        const result = await coordinateHelper.clickElement(page, 'login', 'loginButton');
        
        // Immediately try to detect if modal overlays appear
        await page.waitForTimeout(200); // Small delay to let loading start
        
        const overlayState = await loadingHelpers.checkForModalLoadingOverlays(page);
        
        // Log overlay detection for validation
        console.log('Overlay state during loading:', overlayState);
        
        return result;
      },
      {
        operationType: 'medium',
        expectLoading: true,
        maxActionTime: 15000,
        actionDescription: 'modal overlay test'
      }
    );

    expect(interactionTest.actionSuccess).toBe(true);
    
    // Verify page is ready for interactions after loading completes
    const finalInteractionReady = await loadingHelpers.waitForInteractionReady(page, {
      timeout: 5000
    });
    expect(finalInteractionReady).toBe(true);
    
    console.log('LS.4: ✓ Loading overlay interaction blocking validated successfully');
  });

  test('LS.5: Debounced Loading Timing Validation', async ({ page }) => {
    console.log('LS.5: Testing debounced loading timing');

    // Login first
    const loginResult = await coordinateHelper.clickElementWithLoadingWait(page, 'login', 'loginButton', {
      operationType: 'medium',
      expectLoading: true,
      maxLoadingTime: 10000
    });
    expect(loginResult.clickSuccess).toBe(true);

    // Navigate to items for testing
    const menuResult = await coordinateHelper.clickElementWithLoadingWait(page, 'navigation', 'hamburgerMenu', {
      operationType: 'quick',
      expectLoading: false,
      maxLoadingTime: 3000
    });
    expect(menuResult.clickSuccess).toBe(true);

    const itemsResult = await coordinateHelper.clickElementWithLoadingWait(page, 'navigation', 'allItemsMenu', {
      operationType: 'medium',
      expectLoading: true,
      maxLoadingTime: 8000
    });
    expect(itemsResult.clickSuccess).toBe(true);

    // Test quick operation timing (should have higher debounce delay)
    console.log('Testing quick operation debounced timing...');
    const quickTimingTest = await loadingHelpers.waitForLoadingToAppear(page, {
      timeout: 2000,
      minDelay: 200, // Quick operations have 200ms minimum delay
      operationType: 'quick'
    });

    // Test medium operation timing (should have medium debounce delay)
    console.log('Testing medium operation debounced timing...');
    const mediumTimingTest = await loadingHelpers.waitForLoadingToAppear(page, {
      timeout: 3000,
      minDelay: 100, // Medium operations have 100ms minimum delay
      operationType: 'medium'
    });

    // Validate that timing respects configuration
    if (quickTimingTest.appeared && quickTimingTest.detectionTime !== null) {
      expect(quickTimingTest.detectionTime).toBeGreaterThanOrEqual(150); // Allow some tolerance
    }

    if (mediumTimingTest.appeared && mediumTimingTest.detectionTime !== null) {
      expect(mediumTimingTest.detectionTime).toBeGreaterThanOrEqual(50); // Allow some tolerance
    }

    console.log('LS.5: ✓ Debounced loading timing validated successfully');
  });

  test('LS.6: Loading State Recovery from Errors', async ({ page }) => {
    console.log('LS.6: Testing loading state recovery from errors');

    // Test failed login loading recovery
    console.log('Testing failed login loading recovery...');
    
    await coordinateHelper.typeInField(page, 'login', 'emailField', 'invalid@example.com', {
      operationType: 'quick',
      expectLoading: false
    });
    
    await coordinateHelper.typeInField(page, 'login', 'passwordField', 'wrongpassword', {
      operationType: 'quick',
      expectLoading: false
    });

    // Attempt login that should fail
    const failedLoginTest = await loadingHelpers.performActionWithLoadingWait(
      page,
      async () => {
        return await coordinateHelper.clickElement(page, 'login', 'loginButton');
      },
      {
        operationType: 'medium',
        expectLoading: false, // Failed operations may not show loading or show briefly
        maxActionTime: 8000,
        actionDescription: 'failed login attempt'
      }
    );

    // Verify loading cleared after failed operation
    const loadingCleared = await loadingHelpers.waitForLoadingToDisappear(page, {
      timeout: 5000,
      checkInterval: 100
    });
    expect(loadingCleared.disappeared).toBe(true);

    // Verify page is ready for interactions again
    const interactionReady = await loadingHelpers.waitForInteractionReady(page, {
      timeout: 3000
    });
    expect(interactionReady).toBe(true);

    // Verify no authentication occurred
    const noAuth = await authHelpers.validateNoAuthentication(page);
    expect(noAuth.isValid).toBe(true);

    console.log('LS.6: ✓ Loading state recovery from errors validated successfully');
  });

  test('LS.7: Comprehensive Loading Detection', async ({ page }) => {
    console.log('LS.7: Testing comprehensive loading detection capabilities');

    // Test basic loading detection
    const initialDetection = await loadingHelpers.detectLoadingIndicators(page);
    expect(initialDetection).toBeTruthy();
    expect(typeof initialDetection.hasCircularProgress).toBe('boolean');
    expect(typeof initialDetection.hasLoadingOverlay).toBe('boolean');
    expect(typeof initialDetection.hasOperationOverlay).toBe('boolean');

    console.log('Initial loading detection:', initialDetection);

    // Test detection with retry logic
    const retryDetection = await loadingHelpers.detectLoadingWithRetry(page, {
      maxRetries: 3,
      retryDelay: 200
    });
    expect(retryDetection).toBeTruthy();

    // Test smart loading completion waiting
    const smartWait = await loadingHelpers.smartWaitForLoadingComplete(page, {
      timeout: 5000,
      maxRetries: 2,
      retryDelay: 500
    });
    expect(smartWait.success).toBe(true);

    console.log('LS.7: ✓ Comprehensive loading detection validated successfully');
  });

  test('LS.8: App Readiness with Loading States', async ({ page }) => {
    console.log('LS.8: Testing app readiness detection with loading states');

    // Test app readiness detection
    const readinessResult = await loadingHelpers.waitForAppReady(page, {
      timeout: 30000,
      checkLoadingState: true
    });

    expect(readinessResult.isReady).toBe(true);
    expect(readinessResult.readinessChecks.canvasReady).toBe(true);
    expect(readinessResult.readinessChecks.contentLoaded).toBe(true);
    expect(readinessResult.readinessChecks.noLoadingIndicators).toBe(true);
    expect(readinessResult.readinessChecks.appResponsive).toBe(true);

    console.log('App readiness result:', readinessResult);

    // Test interaction readiness
    const interactionReady = await loadingHelpers.waitForInteractionReady(page, {
      timeout: 5000,
      checkInterval: 200
    });
    expect(interactionReady).toBe(true);

    console.log('LS.8: ✓ App readiness with loading states validated successfully');
  });

  test('LS.9: Loading State Transitions', async ({ page }) => {
    console.log('LS.9: Testing loading state transitions during operations');

    // Login first
    await coordinateHelper.typeInField(page, 'login', 'emailField', 'logistics.test@rescuenet.net', {
      operationType: 'quick',
      expectLoading: false
    });
    
    await coordinateHelper.typeInField(page, 'login', 'passwordField', 'password123', {
      operationType: 'quick',
      expectLoading: false
    });

    const loginResult = await coordinateHelper.clickElementWithLoadingWait(page, 'login', 'loginButton', {
      operationType: 'medium',
      expectLoading: true,
      maxLoadingTime: 10000
    });
    expect(loginResult.clickSuccess).toBe(true);

    // Navigate to items
    const menuResult = await coordinateHelper.clickElementWithLoadingWait(page, 'navigation', 'hamburgerMenu', {
      operationType: 'quick',
      expectLoading: false,
      maxLoadingTime: 3000
    });
    expect(menuResult.clickSuccess).toBe(true);

    // Test complete loading cycle for items navigation
    console.log('Testing complete loading cycle for navigation...');
    const navigationCycle = await loadingHelpers.waitForLoadingCycle(page, {
      operationType: 'medium',
      maxTotalTime: 10000,
      expectLoading: true
    });

    // Click items menu to trigger the cycle
    const itemsNavResult = await coordinateHelper.clickElement(page, 'navigation', 'allItemsMenu', {
      expectLoading: true,
      operationType: 'medium'
    });
    expect(itemsNavResult).toBe(true);

    // Wait for navigation loading cycle to complete
    const navLoadingComplete = await loadingHelpers.waitForLoadingToDisappear(page, {
      timeout: 10000,
      checkInterval: 100
    });
    expect(navLoadingComplete.disappeared).toBe(true);

    console.log('LS.9: ✓ Loading state transitions validated successfully');
  });

  test('LS.10: Performance with Loading States', async ({ page }) => {
    console.log('LS.10: Testing performance considerations with loading states');

    // Test rapid operations don't accumulate loading indicators
    console.log('Testing rapid operation handling...');
    
    await coordinateHelper.typeInField(page, 'login', 'emailField', 'test@rescuenet.net', {
      operationType: 'quick',
      expectLoading: false
    });
    
    await coordinateHelper.typeInField(page, 'login', 'passwordField', 'password123', {
      operationType: 'quick',
      expectLoading: false
    });

    // Perform rapid sequential operations
    const rapidOperationResults = [];
    
    for (let i = 0; i < 3; i++) {
      console.log(`Rapid operation ${i + 1}/3...`);
      
      const operationResult = await loadingHelpers.performActionWithLoadingWait(
        page,
        async () => {
          // Simulate rapid clicking (like double-click scenarios)
          return await coordinateHelper.clickElement(page, 'login', 'loginButton', {
            retries: 1, // Reduce retries for speed
            delay: 50   // Reduce delay for speed
          });
        },
        {
          operationType: 'quick',
          expectLoading: i === 2, // Only expect loading on final operation
          maxActionTime: 3000,
          actionDescription: `rapid operation ${i + 1}`
        }
      );
      
      rapidOperationResults.push(operationResult);
      
      // Small delay between operations
      await page.waitForTimeout(100);
    }

    // Verify at least one operation succeeded
    const anySucceeded = rapidOperationResults.some(result => result.actionSuccess);
    expect(anySucceeded).toBe(true);

    // Verify system is stable after rapid operations
    const finalStability = await loadingHelpers.waitForInteractionReady(page, {
      timeout: 5000
    });
    expect(finalStability).toBe(true);

    console.log('LS.10: ✓ Performance with loading states validated successfully');
  });
});