/**
 * Visual Validation Helper for Flutter Canvas Applications
 * 
 * This module provides enhanced visual testing capabilities for Flutter web apps
 * that render to Canvas, addressing the limitations identified in the test review.
 */

const fs = require('fs');
const path = require('path');

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
 * @param {import('@playwright/test').Page} page 
 * @param {string} testName 
 * @param {Function} action 
 */
async function validateActionWithScreenshots(page, testName, action) {
  // Capture before state
  const beforePath = await captureValidationScreenshot(page, testName, 'before-action');
  
  // Perform action
  const actionResult = await action();
  
  // Wait for any visual changes to complete
  await page.waitForTimeout(1000);
  
  // Capture after state
  const afterPath = await captureValidationScreenshot(page, testName, 'after-action');
  
  // Compare file sizes as basic validation
  const beforeStats = fs.statSync(beforePath);
  const afterStats = fs.statSync(afterPath);
  
  const sizeDifference = Math.abs(afterStats.size - beforeStats.size);
  const percentDifference = (sizeDifference / beforeStats.size) * 100;
  
  if (percentDifference > 1) {
    console.log(`✓ Visual change detected: ${percentDifference.toFixed(2)}% size difference`);
    return { changed: true, beforePath, afterPath, actionResult };
  } else {
    console.log(`⚠ Minimal visual change: ${percentDifference.toFixed(2)}% size difference`);
    return { changed: false, beforePath, afterPath, actionResult };
  }
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
 * @param {import('@playwright/test').Page} page 
 * @param {number} timeout 
 */
async function waitForFlutterReady(page, timeout = 30000) {
  console.log('Waiting for Flutter app to be ready...');
  
  const startTime = Date.now();
  
  while (Date.now() - startTime < timeout) {
    try {
      // Check for Flutter-specific indicators
      const canvasElements = await page.$$('canvas');
      
      if (canvasElements.length > 0) {
        // Check if Canvas has proper dimensions
        const bounds = await canvasElements[0].boundingBox();
        
        if (bounds && bounds.width > 100 && bounds.height > 100) {
          // Additional check - ensure no loading indicators
          const bodyText = await page.textContent('body');
          
          if (bodyText && !bodyText.includes('Loading') && !bodyText.includes('loading')) {
            console.log('✓ Flutter app is ready');
            return true;
          }
        }
      }
      
      await page.waitForTimeout(500);
    } catch (error) {
      // Continue waiting
      await page.waitForTimeout(500);
    }
  }
  
  throw new Error(`Flutter app not ready after ${timeout}ms`);
}

module.exports = {
  captureValidationScreenshot,
  validateActionWithScreenshots,
  validateFlutterCanvasContent,
  validateApplicationState,
  waitForFlutterReady
};