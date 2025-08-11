/**
 * Loading State Helper Functions for RescuenetWarehouse Playwright Tests
 * 
 * This module provides comprehensive helper functions to detect, wait for, and validate
 * loading states including overlays, debounced loading indicators, and operation loading.
 * 
 * Key features:
 * - Detects CircularProgressIndicator elements in Flutter Canvas
 * - Waits for loading overlays to appear and disappear
 * - Handles debounced loading that may not appear immediately
 * - Provides loading state validation for different operation types
 * - Supports both immediate and delayed loading detection
 */

/**
 * Detect if any loading indicators are currently visible on the page
 * @param {import('@playwright/test').Page} page - Playwright page object
 * @returns {Promise<Object>} Loading detection result
 */
async function detectLoadingIndicators(page) {
  try {
    const loadingState = await page.evaluate(() => {
      const results = {
        hasCircularProgress: false,
        hasLoadingText: false,
        hasLoadingOverlay: false,
        hasOperationOverlay: false,
        hasSimpleLoadingOverlay: false,
        loadingMessages: [],
        overlayTypes: [],
        canvasElementsCount: 0,
        bodyTextIncludes: {
          loading: false,
          saving: false,
          deleting: false,
          updating: false,
          creating: false
        }
      };

      // Check for Canvas elements (Flutter renders to Canvas)
      const canvasElements = document.querySelectorAll('canvas');
      results.canvasElementsCount = canvasElements.length;

      // Check body text for loading-related content
      const bodyText = document.body.textContent || '';
      const bodyTextLower = bodyText.toLowerCase();
      
      // Check for various loading states in text content
      results.hasLoadingText = bodyTextLower.includes('loading');
      results.bodyTextIncludes.loading = bodyTextLower.includes('loading');
      results.bodyTextIncludes.saving = bodyTextLower.includes('saving');
      results.bodyTextIncludes.deleting = bodyTextLower.includes('deleting');
      results.bodyTextIncludes.updating = bodyTextLower.includes('updating');
      results.bodyTextIncludes.creating = bodyTextLower.includes('creating');

      // Detect loading-related text patterns
      const loadingPatterns = [
        /loading/i,
        /saving/i,
        /deleting/i,
        /updating/i,
        /creating/i,
        /please wait/i,
        /operation in progress/i
      ];

      loadingPatterns.forEach(pattern => {
        const matches = bodyText.match(pattern);
        if (matches) {
          results.loadingMessages.push(...matches);
        }
      });

      // Check for modal dialogs that might contain loading overlays
      const dialogs = document.querySelectorAll('[role="dialog"]');
      results.hasLoadingOverlay = dialogs.length > 0;

      // Check for elements with loading-related attributes or content
      const elementsWithLoading = document.querySelectorAll('[aria-label*="loading"], [aria-label*="Loading"], [aria-describedby*="loading"]');
      results.hasCircularProgress = elementsWithLoading.length > 0;

      // Check for overlay patterns
      const overlayElements = document.querySelectorAll('div[style*="position: absolute"], div[style*="position: fixed"]');
      overlayElements.forEach(element => {
        const computedStyle = getComputedStyle(element);
        if (computedStyle.backgroundColor !== 'rgba(0, 0, 0, 0)' || 
            computedStyle.backdropFilter || 
            element.querySelector('svg[role="progressbar"]')) {
          results.overlayTypes.push('overlay');
        }
      });

      // Check for operation-specific overlays by looking for common text patterns
      if (bodyTextLower.includes('operation') && bodyTextLower.includes('progress')) {
        results.hasOperationOverlay = true;
      }

      if (bodyTextLower.includes('loading') && (bodyTextLower.includes('please wait') || bodyTextLower.includes('in progress'))) {
        results.hasSimpleLoadingOverlay = true;
      }

      return results;
    });

    console.log('Loading indicator detection results:', loadingState);
    return loadingState;
  } catch (error) {
    console.error('Error detecting loading indicators:', error.message);
    return {
      hasCircularProgress: false,
      hasLoadingText: false,
      hasLoadingOverlay: false,
      hasOperationOverlay: false,
      hasSimpleLoadingOverlay: false,
      error: error.message
    };
  }
}

/**
 * Wait for loading indicators to appear (for operations that should show loading)
 * @param {import('@playwright/test').Page} page - Playwright page object
 * @param {Object} options - Wait options
 * @param {number} options.timeout - Maximum time to wait for loading to appear (ms)
 * @param {number} options.minDelay - Minimum expected delay for debounced loading (ms)
 * @param {string} options.operationType - Type of operation (quick, medium, slow, immediate)
 * @returns {Promise<Object>} Wait result with timing information
 */
async function waitForLoadingToAppear(page, options = {}) {
  const {
    timeout = 5000,
    minDelay = 0,
    operationType = 'medium'
  } = options;

  console.log(`Waiting for loading indicators to appear (type: ${operationType}, minDelay: ${minDelay}ms, timeout: ${timeout}ms)`);

  const startTime = Date.now();
  let loadingAppeared = false;
  let firstDetectionTime = null;

  // Wait for minimum delay if specified (for debounced loading)
  if (minDelay > 0) {
    await page.waitForTimeout(minDelay);
  }

  while (Date.now() - startTime < timeout) {
    const loadingState = await detectLoadingIndicators(page);
    
    const hasAnyLoading = loadingState.hasCircularProgress || 
                         loadingState.hasLoadingText || 
                         loadingState.hasLoadingOverlay ||
                         loadingState.hasOperationOverlay ||
                         loadingState.hasSimpleLoadingOverlay;

    if (hasAnyLoading && !loadingAppeared) {
      loadingAppeared = true;
      firstDetectionTime = Date.now();
      console.log(`✓ Loading indicators appeared after ${firstDetectionTime - startTime}ms`);
      break;
    }

    await page.waitForTimeout(50); // Check every 50ms
  }

  const result = {
    appeared: loadingAppeared,
    detectionTime: firstDetectionTime ? firstDetectionTime - startTime : null,
    totalWaitTime: Date.now() - startTime,
    expectedMinDelay: minDelay,
    operationType
  };

  if (loadingAppeared) {
    console.log(`✓ Loading indicators appeared successfully:`, result);
  } else {
    console.log(`⚠ Loading indicators did not appear within ${timeout}ms:`, result);
  }

  return result;
}

/**
 * Wait for all loading indicators to disappear
 * @param {import('@playwright/test').Page} page - Playwright page object
 * @param {Object} options - Wait options
 * @param {number} options.timeout - Maximum time to wait for loading to disappear (ms)
 * @param {number} options.checkInterval - How often to check for loading state (ms)
 * @param {boolean} options.allowPartialLoading - Allow some loading elements to remain
 * @returns {Promise<Object>} Wait result with timing information
 */
async function waitForLoadingToDisappear(page, options = {}) {
  const {
    timeout = 10000,
    checkInterval = 100,
    allowPartialLoading = false
  } = options;

  console.log(`Waiting for loading indicators to disappear (timeout: ${timeout}ms, interval: ${checkInterval}ms)`);

  const startTime = Date.now();
  let loadingDisappeared = false;
  let lastLoadingState = null;

  while (Date.now() - startTime < timeout) {
    const loadingState = await detectLoadingIndicators(page);
    lastLoadingState = loadingState;
    
    const hasAnyLoading = loadingState.hasCircularProgress || 
                         loadingState.hasLoadingText || 
                         loadingState.hasLoadingOverlay ||
                         loadingState.hasOperationOverlay ||
                         loadingState.hasSimpleLoadingOverlay;

    if (!hasAnyLoading || (allowPartialLoading && !loadingState.hasLoadingOverlay)) {
      loadingDisappeared = true;
      const waitTime = Date.now() - startTime;
      console.log(`✓ Loading indicators disappeared after ${waitTime}ms`);
      break;
    }

    await page.waitForTimeout(checkInterval);
  }

  const result = {
    disappeared: loadingDisappeared,
    waitTime: Date.now() - startTime,
    lastLoadingState,
    timeout: !loadingDisappeared
  };

  if (loadingDisappeared) {
    console.log(`✓ Loading indicators disappeared successfully:`, result);
  } else {
    console.log(`⚠ Loading indicators still present after ${timeout}ms:`, result);
  }

  return result;
}

/**
 * Wait for a complete loading cycle (appear then disappear)
 * @param {import('@playwright/test').Page} page - Playwright page object
 * @param {Object} options - Wait options
 * @param {string} options.operationType - Type of operation (quick, medium, slow, immediate)
 * @param {number} options.maxTotalTime - Maximum total time for the entire cycle (ms)
 * @param {boolean} options.expectLoading - Whether loading is expected to appear
 * @returns {Promise<Object>} Complete cycle result
 */
async function waitForLoadingCycle(page, options = {}) {
  const {
    operationType = 'medium',
    maxTotalTime = 15000,
    expectLoading = true
  } = options;

  console.log(`Waiting for complete loading cycle (type: ${operationType}, expectLoading: ${expectLoading})`);

  const cycleStartTime = Date.now();
  const result = {
    operationType,
    expectLoading,
    appeared: false,
    disappeared: false,
    cycleComplete: false,
    appearanceTime: null,
    disappearanceTime: null,
    totalCycleTime: 0,
    error: null
  };

  try {
    // Configure delays based on operation type
    const typeConfig = {
      immediate: { minDelay: 0, maxWait: 1000 },
      quick: { minDelay: 200, maxWait: 3000 },
      medium: { minDelay: 100, maxWait: 5000 },
      slow: { minDelay: 50, maxWait: 8000 }
    };

    const config = typeConfig[operationType] || typeConfig.medium;

    if (expectLoading) {
      // Wait for loading to appear
      const appearResult = await waitForLoadingToAppear(page, {
        timeout: config.maxWait,
        minDelay: config.minDelay,
        operationType
      });

      result.appeared = appearResult.appeared;
      result.appearanceTime = appearResult.detectionTime;

      if (!appearResult.appeared && expectLoading) {
        result.error = `Loading indicators did not appear for ${operationType} operation`;
        console.log(`⚠ ${result.error}`);
      }
    }

    // Wait for loading to disappear
    const disappearResult = await waitForLoadingToDisappear(page, {
      timeout: maxTotalTime - (Date.now() - cycleStartTime),
      checkInterval: 100
    });

    result.disappeared = disappearResult.disappeared;
    result.disappearanceTime = disappearResult.waitTime;

    // Check if cycle completed successfully
    result.cycleComplete = (!expectLoading || result.appeared) && result.disappeared;
    result.totalCycleTime = Date.now() - cycleStartTime;

    if (result.cycleComplete) {
      console.log(`✓ Loading cycle completed successfully in ${result.totalCycleTime}ms`);
    } else {
      console.log(`⚠ Loading cycle incomplete:`, result);
    }

  } catch (error) {
    result.error = error.message;
    result.totalCycleTime = Date.now() - cycleStartTime;
    console.error('Error during loading cycle:', error.message);
  }

  return result;
}

/**
 * Wait for Flutter app to be ready and all loading to complete
 * @param {import('@playwright/test').Page} page - Playwright page object
 * @param {Object} options - Wait options
 * @param {number} options.timeout - Maximum time to wait for readiness (ms)
 * @param {boolean} options.checkLoadingState - Whether to check for loading indicators
 * @returns {Promise<Object>} App readiness result
 */
async function waitForAppReady(page, options = {}) {
  const {
    timeout = 30000,
    checkLoadingState = true
  } = options;

  console.log(`Waiting for app to be ready (timeout: ${timeout}ms, checkLoading: ${checkLoadingState})`);

  const startTime = Date.now();
  let isReady = false;
  let readinessChecks = {
    canvasReady: false,
    contentLoaded: false,
    noLoadingIndicators: false,
    appResponsive: false
  };

  while (Date.now() - startTime < timeout && !isReady) {
    try {
      // Check Flutter Canvas elements
      const canvasElements = await page.$$('canvas');
      readinessChecks.canvasReady = canvasElements.length > 0;

      if (readinessChecks.canvasReady) {
        const bounds = await canvasElements[0].boundingBox();
        readinessChecks.canvasReady = bounds && bounds.width > 100 && bounds.height > 100;
      }

      // Check content is loaded (not just loading page)
      const bodyText = await page.textContent('body');
      readinessChecks.contentLoaded = bodyText && bodyText.length > 500 && 
                                     bodyText.includes('flutter-view');

      // Check for loading indicators if requested
      if (checkLoadingState) {
        const loadingState = await detectLoadingIndicators(page);
        readinessChecks.noLoadingIndicators = !loadingState.hasLoadingOverlay && 
                                             !loadingState.hasOperationOverlay && 
                                             !loadingState.hasSimpleLoadingOverlay;
      } else {
        readinessChecks.noLoadingIndicators = true;
      }

      // Check app responsiveness by testing if clicks can be processed
      try {
        const clickableElement = await page.evaluate(() => {
          const element = document.elementFromPoint(100, 100);
          return element !== null;
        });
        readinessChecks.appResponsive = clickableElement;
      } catch (error) {
        readinessChecks.appResponsive = false;
      }

      // App is ready when all checks pass
      isReady = Object.values(readinessChecks).every(check => check === true);

      if (!isReady) {
        await page.waitForTimeout(250);
      }

    } catch (error) {
      await page.waitForTimeout(250);
    }
  }

  const result = {
    isReady,
    waitTime: Date.now() - startTime,
    readinessChecks,
    timedOut: !isReady
  };

  if (isReady) {
    console.log(`✓ App ready after ${result.waitTime}ms`);
  } else {
    console.log(`⚠ App not ready after ${result.waitTime}ms:`, readinessChecks);
  }

  return result;
}

/**
 * Perform an action and wait for any triggered loading to complete
 * @param {import('@playwright/test').Page} page - Playwright page object
 * @param {Function} action - Action to perform
 * @param {Object} options - Wait options
 * @param {string} options.operationType - Type of operation (quick, medium, slow, immediate)
 * @param {number} options.maxActionTime - Maximum time for action to complete (ms)
 * @param {boolean} options.expectLoading - Whether loading is expected
 * @param {string} options.actionDescription - Description for logging
 * @returns {Promise<Object>} Action and loading result
 */
async function performActionWithLoadingWait(page, action, options = {}) {
  const {
    operationType = 'medium',
    maxActionTime = 10000,
    expectLoading = false,
    actionDescription = 'action'
  } = options;

  console.log(`Performing ${actionDescription} with loading wait (type: ${operationType})`);

  const actionStartTime = Date.now();
  let actionResult = null;
  let loadingCycleResult = null;

  try {
    // Perform the action
    console.log(`Executing ${actionDescription}...`);
    actionResult = await action();
    
    const actionTime = Date.now() - actionStartTime;
    console.log(`Action completed in ${actionTime}ms, result:`, actionResult);

    // Wait for loading cycle if action was successful
    if (actionResult !== false) {
      loadingCycleResult = await waitForLoadingCycle(page, {
        operationType,
        maxTotalTime: maxActionTime - actionTime,
        expectLoading
      });
    }

    const totalTime = Date.now() - actionStartTime;
    const result = {
      actionSuccess: actionResult !== false,
      actionResult,
      actionTime,
      loadingCycleResult,
      totalTime,
      actionDescription
    };

    console.log(`✓ Action with loading wait completed in ${totalTime}ms:`, result);
    return result;

  } catch (error) {
    const totalTime = Date.now() - actionStartTime;
    console.error(`Error during ${actionDescription}:`, error.message);
    
    return {
      actionSuccess: false,
      actionResult: null,
      error: error.message,
      totalTime,
      actionDescription
    };
  }
}

/**
 * Wait for loading to disappear with smart retry logic
 * @param {import('@playwright/test').Page} page - Playwright page object
 * @param {Object} options - Wait options
 * @param {number} options.timeout - Maximum time to wait (ms)
 * @param {number} options.maxRetries - Maximum number of detection retries
 * @param {number} options.retryDelay - Delay between retries (ms)
 * @returns {Promise<Object>} Smart wait result
 */
async function smartWaitForLoadingComplete(page, options = {}) {
  const {
    timeout = 10000,
    maxRetries = 3,
    retryDelay = 500
  } = options;

  console.log(`Smart waiting for loading completion (timeout: ${timeout}ms, maxRetries: ${maxRetries})`);

  const startTime = Date.now();
  
  for (let attempt = 1; attempt <= maxRetries; attempt++) {
    console.log(`Loading completion check attempt ${attempt}/${maxRetries}`);
    
    const disappearResult = await waitForLoadingToDisappear(page, {
      timeout: Math.floor(timeout / maxRetries),
      checkInterval: 100
    });

    if (disappearResult.disappeared) {
      const totalTime = Date.now() - startTime;
      console.log(`✓ Loading completed on attempt ${attempt} after ${totalTime}ms`);
      
      return {
        success: true,
        attempt,
        totalTime,
        lastResult: disappearResult
      };
    }

    // If not the last attempt, wait before retrying
    if (attempt < maxRetries) {
      console.log(`Attempt ${attempt} failed, retrying in ${retryDelay}ms...`);
      await page.waitForTimeout(retryDelay);
    }
  }

  const totalTime = Date.now() - startTime;
  console.log(`⚠ Loading did not complete after ${maxRetries} attempts in ${totalTime}ms`);
  
  return {
    success: false,
    attempt: maxRetries,
    totalTime,
    timeout: true
  };
}

/**
 * Validate loading behavior for a specific operation type
 * @param {import('@playwright/test').Page} page - Playwright page object
 * @param {string} operationType - Type of operation (quick, medium, slow, immediate)
 * @param {Function} triggerAction - Function that triggers the loading operation
 * @param {Object} options - Validation options
 * @returns {Promise<Object>} Loading behavior validation result
 */
async function validateLoadingBehavior(page, operationType, triggerAction, options = {}) {
  const {
    expectLoadingToShow = true,
    maxOperationTime = 15000,
    actionDescription = 'operation'
  } = options;

  console.log(`Validating loading behavior for ${operationType} ${actionDescription}`);

  const validationStartTime = Date.now();
  
  // Get expected timing for operation type
  const expectedTimings = {
    immediate: { minDelay: 0, maxDelay: 50, expectVisible: true },
    quick: { minDelay: 200, maxDelay: 1000, expectVisible: false }, // May not show for very quick ops
    medium: { minDelay: 100, maxDelay: 2000, expectVisible: true },
    slow: { minDelay: 50, maxDelay: 500, expectVisible: true }
  };

  const timing = expectedTimings[operationType] || expectedTimings.medium;

  try {
    // Capture initial state
    const initialState = await detectLoadingIndicators(page);
    
    // Trigger the action
    console.log(`Triggering ${actionDescription}...`);
    const actionResult = await triggerAction();
    
    // Wait and validate loading cycle
    const loadingResult = await waitForLoadingCycle(page, {
      operationType,
      maxTotalTime: maxOperationTime,
      expectLoading: expectLoadingToShow && timing.expectVisible
    });

    const totalTime = Date.now() - validationStartTime;
    
    const validation = {
      operationType,
      actionSuccess: actionResult !== false,
      loadingBehaviorCorrect: false,
      timingAppropriate: false,
      loadingResult,
      totalTime,
      expectedTiming: timing
    };

    // Validate timing is appropriate for operation type
    if (loadingResult.appeared && loadingResult.appearanceTime !== null) {
      validation.timingAppropriate = loadingResult.appearanceTime >= timing.minDelay - 50; // Allow 50ms tolerance
    } else if (!expectLoadingToShow || !timing.expectVisible) {
      validation.timingAppropriate = true; // Expected not to show
    }

    // Validate overall loading behavior
    validation.loadingBehaviorCorrect = (!expectLoadingToShow || !timing.expectVisible) ? 
                                       loadingResult.cycleComplete :
                                       loadingResult.appeared && loadingResult.disappeared;

    const success = validation.actionSuccess && validation.loadingBehaviorCorrect && validation.timingAppropriate;

    if (success) {
      console.log(`✓ Loading behavior validation PASSED for ${operationType} operation`);
    } else {
      console.log(`⚠ Loading behavior validation FAILED for ${operationType} operation:`, validation);
    }

    return validation;

  } catch (error) {
    console.error(`Error validating loading behavior for ${operationType}:`, error.message);
    return {
      operationType,
      actionSuccess: false,
      loadingBehaviorCorrect: false,
      timingAppropriate: false,
      error: error.message,
      totalTime: Date.now() - validationStartTime
    };
  }
}

/**
 * Check if the page has any modal loading overlays that would block interactions
 * @param {import('@playwright/test').Page} page - Playwright page object
 * @returns {Promise<Object>} Modal overlay detection result
 */
async function checkForModalLoadingOverlays(page) {
  try {
    const overlayState = await page.evaluate(() => {
      const results = {
        hasModalDialog: false,
        hasBlockingOverlay: false,
        overlayCount: 0,
        overlayTypes: [],
        canInteract: true
      };

      // Check for modal dialogs
      const dialogs = document.querySelectorAll('[role="dialog"]');
      results.hasModalDialog = dialogs.length > 0;
      results.overlayCount = dialogs.length;

      if (dialogs.length > 0) {
        dialogs.forEach((dialog, index) => {
          const dialogText = dialog.textContent || '';
          if (dialogText.toLowerCase().includes('loading') || 
              dialogText.toLowerCase().includes('please wait') ||
              dialogText.toLowerCase().includes('operation in progress')) {
            results.overlayTypes.push(`loading-dialog-${index}`);
            results.hasBlockingOverlay = true;
            results.canInteract = false;
          }
        });
      }

      // Check for elements that might block interactions
      const overlayElements = document.querySelectorAll('div[style*="position: absolute"], div[style*="position: fixed"]');
      overlayElements.forEach((element, index) => {
        const rect = element.getBoundingClientRect();
        const style = getComputedStyle(element);
        
        // Check if overlay covers significant screen area and has background
        if (rect.width > window.innerWidth * 0.5 && 
            rect.height > window.innerHeight * 0.5 &&
            (style.backgroundColor !== 'rgba(0, 0, 0, 0)' || style.backdropFilter)) {
          results.overlayTypes.push(`blocking-overlay-${index}`);
          results.hasBlockingOverlay = true;
          results.canInteract = false;
        }
      });

      return results;
    });

    console.log('Modal overlay check:', overlayState);
    return overlayState;

  } catch (error) {
    console.error('Error checking for modal loading overlays:', error.message);
    return {
      hasModalDialog: false,
      hasBlockingOverlay: false,
      canInteract: true,
      error: error.message
    };
  }
}

/**
 * Wait for page to be ready for interactions (no blocking overlays)
 * @param {import('@playwright/test').Page} page - Playwright page object
 * @param {Object} options - Wait options
 * @param {number} options.timeout - Maximum time to wait (ms)
 * @param {number} options.checkInterval - How often to check (ms)
 * @returns {Promise<boolean>} True if ready for interactions
 */
async function waitForInteractionReady(page, options = {}) {
  const {
    timeout = 10000,
    checkInterval = 200
  } = options;

  console.log(`Waiting for page to be ready for interactions (timeout: ${timeout}ms)`);

  const startTime = Date.now();

  while (Date.now() - startTime < timeout) {
    const overlayState = await checkForModalLoadingOverlays(page);
    
    if (overlayState.canInteract) {
      const waitTime = Date.now() - startTime;
      console.log(`✓ Page ready for interactions after ${waitTime}ms`);
      return true;
    }

    await page.waitForTimeout(checkInterval);
  }

  const waitTime = Date.now() - startTime;
  console.log(`⚠ Page not ready for interactions after ${waitTime}ms`);
  return false;
}

/**
 * Enhanced loading state detection with retry logic
 * @param {import('@playwright/test').Page} page - Playwright page object
 * @param {Object} options - Detection options
 * @param {number} options.maxRetries - Maximum number of detection attempts
 * @param {number} options.retryDelay - Delay between attempts (ms)
 * @returns {Promise<Object>} Enhanced detection result
 */
async function detectLoadingWithRetry(page, options = {}) {
  const {
    maxRetries = 3,
    retryDelay = 200
  } = options;

  console.log(`Detecting loading with retry (maxRetries: ${maxRetries})`);

  let lastResult = null;
  let bestResult = null;

  for (let attempt = 1; attempt <= maxRetries; attempt++) {
    try {
      const result = await detectLoadingIndicators(page);
      lastResult = result;

      // Consider this the "best" result if it shows loading or if it's the first attempt
      if (result.hasLoadingOverlay || result.hasOperationOverlay || attempt === 1) {
        bestResult = result;
      }

      // If we detected loading, return immediately
      if (result.hasLoadingOverlay || result.hasOperationOverlay || result.hasSimpleLoadingOverlay) {
        console.log(`✓ Loading detected on attempt ${attempt}`);
        return result;
      }

      if (attempt < maxRetries) {
        await page.waitForTimeout(retryDelay);
      }

    } catch (error) {
      console.log(`Detection attempt ${attempt} failed:`, error.message);
      if (attempt === maxRetries) {
        throw error;
      }
      await page.waitForTimeout(retryDelay);
    }
  }

  console.log(`No loading detected after ${maxRetries} attempts, returning last result`);
  return lastResult || bestResult || { hasCircularProgress: false, hasLoadingOverlay: false };
}

// Export all functions
module.exports = {
  detectLoadingIndicators,
  waitForLoadingToAppear,
  waitForLoadingToDisappear,
  waitForLoadingCycle,
  waitForAppReady,
  performActionWithLoadingWait,
  validateLoadingBehavior,
  checkForModalLoadingOverlays,
  waitForInteractionReady,
  detectLoadingWithRetry
};