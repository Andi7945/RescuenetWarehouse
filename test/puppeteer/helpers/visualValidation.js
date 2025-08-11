/**
 * Visual Validation Helper for Flutter Canvas Applications
 * 
 * This module provides enhanced visual testing capabilities for Flutter web apps
 * that render to Canvas, addressing the limitations identified in the test review.
 * 
 * Updated to handle loading states, overlays, and debounced loading indicators.
 */

const fs = require('fs');
const path = require('path');
const loadingHelpers = require('./loadingHelpers');

/**
 * Capture screenshot with standardized naming and validation
 * @param {import('@playwright/test').Page} page 
 * @param {string} testName 
 * @param {string} step 
 * @param {Object} options 
 */
async function captureValidationScreenshot(page, testName, step, options = {}) {
  const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
  const filename = `${testName}-${step}-${timestamp}.png`;
  const screenshotPath = path.join('screenshots', filename);
  
  // Ensure screenshots directory exists
  const screenshotDir = path.dirname(screenshotPath);
  if (!fs.existsSync(screenshotDir)) {
    fs.mkdirSync(screenshotDir, { recursive: true });
  }
  
  const screenshotOptions = {
    path: screenshotPath,
    fullPage: options.fullPage || false,
    ...options
  };
  
  await page.screenshot(screenshotOptions);
  
  // Validate screenshot was created and has content
  const stats = fs.statSync(screenshotPath);
  if (stats.size < 1000) {
    throw new Error(`Screenshot ${filename} is too small (${stats.size} bytes) - may indicate render failure`);
  }
  
  console.log(`✓ Visual validation screenshot captured: ${filename} (${stats.size} bytes)`);
  return screenshotPath;
}

/**
 * Compare page state before and after action using visual validation
 * Enhanced to handle loading states and wait for completion
 * @param {import('@playwright/test').Page} page 
 * @param {string} testName 
 * @param {Function} action 
 * @param {Object} options - Action options
 * @param {string} options.operationType - Type of operation (quick, medium, slow, immediate)
 * @param {boolean} options.expectLoading - Whether loading is expected
 * @param {number} options.maxActionTime - Maximum time for action to complete
 */
async function validateActionWithScreenshots(page, testName, action, options = {}) {
  const {
    operationType = 'medium',
    expectLoading = true,
    maxActionTime = 10000
  } = options;
  
  // Capture before state
  const beforePath = await captureValidationScreenshot(page, testName, 'before-action');
  
  // Perform action with loading handling
  const actionWithLoadingResult = await loadingHelpers.performActionWithLoadingWait(
    page, 
    action, 
    {
      operationType,
      expectLoading,
      maxActionTime,
      actionDescription: testName
    }
  );
  
  // Wait additional time for visual changes to stabilize
  await page.waitForTimeout(500);
  
  // Capture after state
  const afterPath = await captureValidationScreenshot(page, testName, 'after-action');
  
  // Compare file sizes as basic validation
  const beforeStats = fs.statSync(beforePath);
  const afterStats = fs.statSync(afterPath);
  
  const sizeDifference = Math.abs(afterStats.size - beforeStats.size);
  const percentDifference = (sizeDifference / beforeStats.size) * 100;
  
  const visualChanged = percentDifference > 1;
  
  if (visualChanged) {
    console.log(`✓ Visual change detected: ${percentDifference.toFixed(2)}% size difference`);
  } else {
    console.log(`⚠ Minimal visual change: ${percentDifference.toFixed(2)}% size difference`);
  }
  
  return { 
    changed: visualChanged, 
    beforePath, 
    afterPath, 
    actionResult: actionWithLoadingResult.actionResult,
    loadingHandled: actionWithLoadingResult.loadingCycleResult?.cycleComplete || false,
    actionSuccess: actionWithLoadingResult.actionSuccess,
    totalTime: actionWithLoadingResult.totalTime
  };
}

/**
 * Validate Flutter Canvas content by checking for key visual elements
 * @param {import('@playwright/test').Page} page 
 * @param {string} testName 
 */
async function validateFlutterCanvasContent(page, testName) {
  // Check that Flutter app has loaded by looking for Canvas elements
  const canvasElements = await page.$$('canvas');
  
  if (canvasElements.length === 0) {
    throw new Error('No Canvas elements found - Flutter app may not have loaded');
  }
  
  console.log(`✓ Found ${canvasElements.length} Canvas element(s) - Flutter app loaded`);
  
  // Check Canvas dimensions to ensure proper rendering
  const canvasBounds = await canvasElements[0].boundingBox();
  
  if (!canvasBounds || canvasBounds.width < 100 || canvasBounds.height < 100) {
    throw new Error(`Canvas too small (${canvasBounds?.width}x${canvasBounds?.height}) - render issue`);
  }
  
  console.log(`✓ Canvas dimensions valid: ${canvasBounds.width}x${canvasBounds.height}`);
  
  // Capture screenshot for visual validation
  await captureValidationScreenshot(page, testName, 'canvas-validation');
  
  return {
    canvasCount: canvasElements.length,
    canvasDimensions: canvasBounds,
    renderValid: true
  };
}

/**
 * Enhanced state validation using multiple signals
 * @param {import('@playwright/test').Page} page 
 * @param {string} expectedState 
 */
async function validateApplicationState(page, expectedState) {
  const validations = {};
  
  // 1. URL validation
  const currentUrl = page.url();
  validations.urlValid = currentUrl && !currentUrl.includes('error');
  
  // 2. Page title validation
  const title = await page.title();
  validations.titleValid = title && title.length > 0;
  
  // 3. Canvas rendering validation
  try {
    const canvasValidation = await validateFlutterCanvasContent(page, 'state-validation');
    validations.canvasValid = canvasValidation.renderValid;
  } catch (error) {
    validations.canvasValid = false;
    validations.canvasError = error.message;
  }
  
  // 4. Content validation (basic check for app structure)
  const bodyContent = await page.textContent('body');
  validations.contentValid = bodyContent && bodyContent.length > 50 && 
                           !bodyContent.includes('Error') && 
                           !bodyContent.includes('undefined');
  
  // 5. Console error check
  let consoleErrors = [];
  page.on('console', msg => {
    if (msg.type() === 'error') {
      consoleErrors.push(msg.text());
    }
  });
  
  validations.consoleClean = consoleErrors.length === 0;
  if (consoleErrors.length > 0) {
    validations.consoleErrors = consoleErrors;
  }
  
  // Overall state assessment
  const criticalValidations = [
    validations.urlValid,
    validations.titleValid,
    validations.canvasValid,
    validations.contentValid
  ];
  
  validations.overallValid = criticalValidations.every(v => v === true);
  
  if (expectedState) {
    validations.stateMatches = currentUrl.includes(expectedState);
  }
  
  console.log(`State Validation Results:`, {
    url: validations.urlValid ? '✓' : '✗',
    title: validations.titleValid ? '✓' : '✗',
    canvas: validations.canvasValid ? '✓' : '✗',
    content: validations.contentValid ? '✓' : '✗',
    console: validations.consoleClean ? '✓' : '✗',
    overall: validations.overallValid ? '✓ VALID' : '✗ INVALID'
  });
  
  return validations;
}

/**
 * Wait for Flutter app to be fully loaded and ready
 * Enhanced to handle new loading states and overlays
 * @param {import('@playwright/test').Page} page 
 * @param {number} timeout 
 * @param {Object} options - Additional options
 * @param {boolean} options.waitForLoadingComplete - Wait for all loading to complete
 * @param {boolean} options.checkInteractionReady - Check if page is ready for interactions
 */
async function waitForFlutterReady(page, timeout = 30000, options = {}) {
  const {
    waitForLoadingComplete = true,
    checkInteractionReady = true
  } = options;
  
  console.log('Waiting for Flutter app to be ready with enhanced loading detection...');
  
  // Use the new comprehensive app ready check
  const readyResult = await loadingHelpers.waitForAppReady(page, {
    timeout,
    checkLoadingState: waitForLoadingComplete
  });
  
  if (!readyResult.isReady) {
    throw new Error(`Flutter app not ready after ${timeout}ms: ${JSON.stringify(readyResult.readinessChecks)}`);
  }
  
  // Additional check for interaction readiness if requested
  if (checkInteractionReady) {
    const interactionReady = await loadingHelpers.waitForInteractionReady(page, {
      timeout: 5000
    });
    
    if (!interactionReady) {
      console.log('⚠ App ready but may have blocking overlays');
    }
  }
  
  console.log('✓ Flutter app is ready for testing');
  return true;
}

/**
 * Wait for action to complete including any loading states
 * @param {import('@playwright/test').Page} page - Playwright page object
 * @param {Function} action - Action to perform
 * @param {Object} options - Wait options
 * @returns {Promise<Object>} Action completion result
 */
async function waitForActionComplete(page, action, options = {}) {
  const {
    operationType = 'medium',
    expectLoading = true,
    maxTime = 10000,
    actionDescription = 'action'
  } = options;
  
  console.log(`Waiting for ${actionDescription} to complete with loading handling`);
  
  return await loadingHelpers.performActionWithLoadingWait(
    page,
    action,
    {
      operationType,
      expectLoading,
      maxActionTime: maxTime,
      actionDescription
    }
  );
}

/**
 * Enhanced application state validation that includes loading state checks
 * @param {import('@playwright/test').Page} page - Playwright page object
 * @param {string} expectedState - Expected application state
 * @param {Object} options - Validation options
 * @returns {Promise<Object>} Enhanced validation results
 */
async function validateApplicationStateWithLoading(page, expectedState, options = {}) {
  const {
    allowLoadingStates = false,
    checkInteractionReady = true
  } = options;
  
  // Get base application state validation
  const baseValidation = await validateApplicationState(page, expectedState);
  
  // Add loading state validation
  const loadingState = await loadingHelpers.detectLoadingIndicators(page);
  const interactionState = checkInteractionReady ? 
    await loadingHelpers.checkForModalLoadingOverlays(page) : 
    { canInteract: true };
  
  const enhancedValidation = {
    ...baseValidation,
    loadingState,
    interactionReady: interactionState.canInteract,
    hasBlockingOverlays: interactionState.hasBlockingOverlay,
    loadingDetected: loadingState.hasLoadingOverlay || loadingState.hasOperationOverlay
  };
  
  // Adjust overall validity based on loading states
  if (!allowLoadingStates && enhancedValidation.loadingDetected) {
    enhancedValidation.overallValid = false;
    console.log('⚠ Application state invalid due to active loading states');
  } else if (!enhancedValidation.interactionReady) {
    enhancedValidation.overallValid = false;
    console.log('⚠ Application state invalid due to blocking overlays');
  }
  
  console.log('Enhanced application state validation:', {
    baseValid: baseValidation.overallValid,
    loadingDetected: enhancedValidation.loadingDetected,
    interactionReady: enhancedValidation.interactionReady,
    finalValid: enhancedValidation.overallValid
  });
  
  return enhancedValidation;
}

module.exports = {
  captureValidationScreenshot,
  validateActionWithScreenshots,
  validateFlutterCanvasContent,
  validateApplicationState,
  validateApplicationStateWithLoading,
  waitForFlutterReady,
  waitForActionComplete
};