// @ts-check
const fs = require('fs');
const path = require('path');
const loadingHelpers = require('./loadingHelpers');

/**
 * Coordinate Helper for robust Flutter web testing
 * Centralizes coordinate management and provides retry logic for clicks
 */
class CoordinateHelper {
  constructor() {
    this.config = this.loadCoordinates();
    this.defaultRetries = 3;
    this.defaultDelay = 100;
  }

  /**
   * Load coordinate configuration from JSON file
   * @returns {Object} Coordinate configuration
   */
  loadCoordinates() {
    try {
      const configPath = path.join(__dirname, '../config/coordinates.json');
      const configData = fs.readFileSync(configPath, 'utf8');
      return JSON.parse(configData);
    } catch (error) {
      console.error('Failed to load coordinate configuration:', error.message);
      throw new Error('Coordinate configuration is required for tests');
    }
  }

  /**
   * Get coordinates for a specific element
   * @param {string} section - The section (e.g., 'login', 'navigation')
   * @param {string} element - The element name (e.g., 'emailField', 'hamburgerMenu')
   * @param {Object} options - Options for coordinate adjustment
   * @param {number} options.offsetX - X offset to apply
   * @param {number} options.offsetY - Y offset to apply
   * @param {string} options.viewport - Viewport size for responsive adjustments
   * @returns {Object} Coordinates {x, y}
   */
  getCoordinates(section, element, options = {}) {
    const { offsetX = 0, offsetY = 0, viewport = 'default' } = options;
    
    if (!this.config[section]) {
      throw new Error(`Coordinate section '${section}' not found in configuration`);
    }
    
    if (!this.config[section][element]) {
      throw new Error(`Element '${element}' not found in section '${section}'`);
    }
    
    const baseCoords = this.config[section][element];
    
    // Apply viewport scaling if needed (future enhancement)
    let scaledCoords = this.applyViewportScaling(baseCoords, viewport);
    
    return {
      x: scaledCoords.x + offsetX,
      y: scaledCoords.y + offsetY
    };
  }

  /**
   * Apply viewport scaling for responsive testing
   * @param {Object} coords - Base coordinates
   * @param {string} viewport - Viewport identifier
   * @returns {Object} Scaled coordinates
   */
  applyViewportScaling(coords, viewport) {
    // For now, return base coordinates
    // Future enhancement: scale coordinates based on viewport size
    return coords;
  }

  /**
   * Click on an element with retry logic, error handling, and loading state management
   * @param {import('@playwright/test').Page} page - Playwright page object
   * @param {string} section - Coordinate section
   * @param {string} element - Element name
   * @param {Object} options - Click options
   * @param {number} options.retries - Number of retry attempts
   * @param {number} options.delay - Delay between retries (ms)
   * @param {number} options.offsetX - X coordinate offset
   * @param {number} options.offsetY - Y coordinate offset
   * @param {boolean} options.screenshot - Take screenshot on failure
   * @param {string} options.screenshotName - Custom screenshot name
   * @param {boolean} options.waitForInteractionReady - Wait for page to be ready before clicking
   * @param {string} options.operationType - Expected operation type (quick, medium, slow, immediate)
   * @param {boolean} options.expectLoading - Whether click should trigger loading
   * @param {number} options.loadingTimeout - Max time to wait for loading cycle
   * @returns {Promise<boolean>} Success status
   */
  async clickElement(page, section, element, options = {}) {
    const {
      retries = this.defaultRetries,
      delay = this.defaultDelay,
      offsetX = 0,
      offsetY = 0,
      screenshot = true,
      screenshotName = null,
      waitForInteractionReady = true,
      operationType = 'medium',
      expectLoading = false,
      loadingTimeout = 10000
    } = options;

    const coords = this.getCoordinates(section, element, { offsetX, offsetY });
    const elementName = `${section}.${element}`;
    
    // Wait for page to be ready for interactions
    if (waitForInteractionReady) {
      const interactionReady = await loadingHelpers.waitForInteractionReady(page, { timeout: 5000 });
      if (!interactionReady) {
        console.log(`⚠ Page may not be ready for interactions, proceeding with click on ${elementName}`);
      }
    }
    
    for (let attempt = 1; attempt <= retries; attempt++) {
      try {
        console.log(`Clicking ${elementName} at (${coords.x}, ${coords.y}) - Attempt ${attempt}/${retries}`);
        
        // Perform the click
        await page.mouse.click(coords.x, coords.y);
        
        // Handle loading states if expected
        if (expectLoading && operationType) {
          console.log(`Waiting for loading cycle after clicking ${elementName}...`);
          
          const loadingResult = await loadingHelpers.waitForLoadingCycle(page, {
            operationType,
            maxTotalTime: loadingTimeout,
            expectLoading: true
          });
          
          if (!loadingResult.cycleComplete) {
            console.log(`⚠ Loading cycle incomplete for ${elementName}:`, loadingResult);
          } else {
            console.log(`✓ Loading cycle completed for ${elementName}`);
          }
        } else {
          // Standard delay for non-loading operations
          await page.waitForTimeout(delay);
        }
        
        console.log(`✓ Successfully clicked ${elementName}`);
        return true;
        
      } catch (error) {
        console.log(`✗ Click attempt ${attempt} failed for ${elementName}: ${error.message}`);
        
        if (attempt === retries) {
          // Final attempt failed - take screenshot if enabled
          if (screenshot) {
            const filename = screenshotName || `click-failure-${section}-${element}.png`;
            await page.screenshot({ path: filename });
            console.log(`Screenshot saved: ${filename}`);
          }
          
          console.error(`Failed to click ${elementName} after ${retries} attempts`);
          return false;
        }
        
        // Wait before retry, also ensure page is ready
        await page.waitForTimeout(delay * attempt);
        if (waitForInteractionReady) {
          await loadingHelpers.waitForInteractionReady(page, { timeout: 2000 });
        }
      }
    }
    
    return false;
  }

  /**
   * Type text in a field with coordinate-based clicking and loading state handling
   * @param {import('@playwright/test').Page} page - Playwright page object
   * @param {string} section - Coordinate section
   * @param {string} element - Element name
   * @param {string} text - Text to type
   * @param {Object} options - Typing options
   * @param {boolean} options.clearFirst - Clear field before typing
   * @param {number} options.delay - Delay between keystrokes
   * @param {boolean} options.waitForInteractionReady - Wait for page ready before typing
   * @param {string} options.operationType - Expected operation type for loading
   * @param {boolean} options.expectLoading - Whether typing should trigger loading
   * @returns {Promise<boolean>} Success status
   */
  async typeInField(page, section, element, text, options = {}) {
    const { 
      clearFirst = true, 
      delay = 50,
      waitForInteractionReady = true,
      operationType = 'quick',
      expectLoading = false
    } = options;
    
    // First click on the field with loading handling
    const clickSuccess = await this.clickElement(page, section, element, {
      waitForInteractionReady,
      operationType,
      expectLoading: false // Field clicks usually don't trigger loading
    });
    
    if (!clickSuccess) {
      console.error(`Failed to click field ${section}.${element} before typing`);
      return false;
    }
    
    try {
      // Wait a moment for field to be focused
      await page.waitForTimeout(100);
      
      if (clearFirst) {
        await page.keyboard.press('Control+a');
        await page.keyboard.press('Delete');
        await page.waitForTimeout(50);
      }
      
      // Type the text
      await page.keyboard.type(text, { delay });
      
      // Handle loading if expected (e.g., autocomplete, validation)
      if (expectLoading) {
        console.log(`Waiting for loading after typing in ${section}.${element}...`);
        
        const loadingResult = await loadingHelpers.waitForLoadingCycle(page, {
          operationType,
          maxTotalTime: 5000,
          expectLoading: true
        });
        
        if (!loadingResult.cycleComplete) {
          console.log(`⚠ Loading cycle incomplete after typing in ${section}.${element}`);
        }
      }
      
      console.log(`✓ Successfully typed "${text}" in ${section}.${element}`);
      return true;
      
    } catch (error) {
      console.error(`Failed to type in ${section}.${element}: ${error.message}`);
      return false;
    }
  }

  /**
   * Get timeout value from configuration
   * @param {string} timeoutName - Timeout identifier
   * @returns {number} Timeout in milliseconds
   */
  getTimeout(timeoutName) {
    return this.config.timeouts[timeoutName] || 1000;
  }

  /**
   * Log coordinate information for debugging
   * @param {string} section - Coordinate section
   * @param {string} element - Element name
   */
  logCoordinates(section, element) {
    try {
      const coords = this.getCoordinates(section, element);
      console.log(`Coordinates for ${section}.${element}: (${coords.x}, ${coords.y})`);
    } catch (error) {
      console.error(`Failed to get coordinates for ${section}.${element}: ${error.message}`);
    }
  }

  /**
   * Validate all coordinates in configuration
   * @returns {Object} Validation results
   */
  validateConfiguration() {
    const issues = [];
    const sections = Object.keys(this.config);
    
    sections.forEach(section => {
      if (typeof this.config[section] === 'object' && this.config[section] !== null) {
        const elements = Object.keys(this.config[section]);
        
        elements.forEach(element => {
          const coords = this.config[section][element];
          
          if (typeof coords === 'object' && coords.hasOwnProperty('x') && coords.hasOwnProperty('y')) {
            if (typeof coords.x !== 'number' || typeof coords.y !== 'number') {
              issues.push(`Invalid coordinate format in ${section}.${element}`);
            }
            if (coords.x < 0 || coords.y < 0) {
              issues.push(`Negative coordinates in ${section}.${element}`);
            }
          } else if (section !== 'viewports' && section !== 'timeouts') {
            issues.push(`Missing x,y coordinates in ${section}.${element}`);
          }
        });
      }
    });
    
    return {
      isValid: issues.length === 0,
      issues: issues,
      sectionsCount: sections.length,
      summary: `Validated ${sections.length} sections with ${issues.length} issues`
    };
  }
}

  /**
   * Click element and wait for loading to complete with smart detection
   * @param {import('@playwright/test').Page} page - Playwright page object
   * @param {string} section - Coordinate section
   * @param {string} element - Element name
   * @param {Object} options - Click and loading options
   * @returns {Promise<Object>} Click and loading result
   */
  async clickElementWithLoadingWait(page, section, element, options = {}) {
    const {
      operationType = 'medium',
      expectLoading = true,
      maxLoadingTime = 10000,
      ...clickOptions
    } = options;
    
    const elementName = `${section}.${element}`;
    console.log(`Clicking ${elementName} with loading wait (type: ${operationType})`);
    
    // Perform click with loading handling built-in
    const clickSuccess = await this.clickElement(page, section, element, {
      ...clickOptions,
      expectLoading,
      operationType,
      loadingTimeout: maxLoadingTime
    });
    
    return {
      clickSuccess,
      element: elementName,
      operationType,
      expectLoading
    };
  }
  
  /**
   * Wait for page to be ready for interactions before proceeding
   * @param {import('@playwright/test').Page} page - Playwright page object
   * @param {Object} options - Wait options
   * @returns {Promise<boolean>} Ready status
   */
  async waitForPageReady(page, options = {}) {
    const { timeout = 10000 } = options;
    
    console.log('Waiting for page to be ready for interactions...');
    
    const readyResult = await loadingHelpers.waitForAppReady(page, {
      timeout,
      checkLoadingState: true
    });
    
    if (readyResult.isReady) {
      const interactionReady = await loadingHelpers.waitForInteractionReady(page, {
        timeout: 5000
      });
      
      if (interactionReady) {
        console.log('✓ Page ready for interactions');
        return true;
      } else {
        console.log('⚠ Page loaded but may have blocking overlays');
        return false;
      }
    } else {
      console.log('⚠ Page not ready within timeout');
      return false;
    }
  }
}

// Export singleton instance
module.exports = new CoordinateHelper();