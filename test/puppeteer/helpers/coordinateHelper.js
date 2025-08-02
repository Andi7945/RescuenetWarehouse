// @ts-check
const fs = require('fs');
const path = require('path');

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
   * Click on an element with retry logic and error handling
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
   * @returns {Promise<boolean>} Success status
   */
  async clickElement(page, section, element, options = {}) {
    const {
      retries = this.defaultRetries,
      delay = this.defaultDelay,
      offsetX = 0,
      offsetY = 0,
      screenshot = true,
      screenshotName = null
    } = options;

    const coords = this.getCoordinates(section, element, { offsetX, offsetY });
    const elementName = `${section}.${element}`;
    
    for (let attempt = 1; attempt <= retries; attempt++) {
      try {
        console.log(`Clicking ${elementName} at (${coords.x}, ${coords.y}) - Attempt ${attempt}/${retries}`);
        
        await page.mouse.click(coords.x, coords.y);
        
        // Small delay to allow UI to respond
        await page.waitForTimeout(delay);
        
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
        
        // Wait before retry
        await page.waitForTimeout(delay * attempt);
      }
    }
    
    return false;
  }

  /**
   * Type text in a field with coordinate-based clicking
   * @param {import('@playwright/test').Page} page - Playwright page object
   * @param {string} section - Coordinate section
   * @param {string} element - Element name
   * @param {string} text - Text to type
   * @param {Object} options - Typing options
   * @param {boolean} options.clearFirst - Clear field before typing
   * @param {number} options.delay - Delay between keystrokes
   * @returns {Promise<boolean>} Success status
   */
  async typeInField(page, section, element, text, options = {}) {
    const { clearFirst = true, delay = 50 } = options;
    
    // First click on the field
    const clickSuccess = await this.clickElement(page, section, element);
    if (!clickSuccess) {
      console.error(`Failed to click field ${section}.${element} before typing`);
      return false;
    }
    
    try {
      if (clearFirst) {
        await page.keyboard.press('Control+a');
        await page.keyboard.press('Delete');
      }
      
      await page.keyboard.type(text, { delay });
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

// Export singleton instance
module.exports = new CoordinateHelper();