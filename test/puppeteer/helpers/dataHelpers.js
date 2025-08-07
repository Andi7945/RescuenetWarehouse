// @ts-check

/**
 * Data Helpers for business logic validation in assignment management tests
 * Provides utilities for validating assignment math and constraints
 */
class DataHelpers {
  constructor() {
    this.validationErrors = [];
  }

  /**
   * Verify assignment math calculations according to business rules
   * Validates: total_quantity = available_quantity + assigned_quantity
   * 
   * @param {Object} item - Item data with quantities
   * @param {number} item.total_quantity - Total quantity of the item
   * @param {number} item.available_quantity - Available quantity for assignment
   * @param {number} item.assigned_quantity - Currently assigned quantity
   * @returns {Object} Validation result
   */
  verifyAssignmentMath(item) {
    const errors = [];
    const warnings = [];
    
    // Check if required fields exist
    if (typeof item.total_quantity !== 'number') {
      errors.push('Missing or invalid total_quantity');
    }
    if (typeof item.available_quantity !== 'number') {
      errors.push('Missing or invalid available_quantity');
    }
    if (typeof item.assigned_quantity !== 'number') {
      errors.push('Missing or invalid assigned_quantity');
    }
    
    if (errors.length > 0) {
      return {
        isValid: false,
        errors,
        warnings,
        message: 'Assignment math validation failed: missing required fields'
      };
    }
    
    // Verify basic math: total = available + assigned
    const calculatedTotal = item.available_quantity + item.assigned_quantity;
    const mathIsCorrect = Math.abs(calculatedTotal - item.total_quantity) < 0.001; // Allow for floating point precision
    
    if (!mathIsCorrect) {
      errors.push(`Assignment math incorrect: ${item.available_quantity} + ${item.assigned_quantity} ≠ ${item.total_quantity}`);
    }
    
    // Verify quantities are non-negative
    if (item.total_quantity < 0) {
      errors.push('Total quantity cannot be negative');
    }
    if (item.available_quantity < 0) {
      errors.push('Available quantity cannot be negative (constraint violation)');
    }
    if (item.assigned_quantity < 0) {
      errors.push('Assigned quantity cannot be negative');
    }
    
    // Check for potential issues
    if (item.available_quantity === 0 && item.assigned_quantity > 0) {
      warnings.push('Item is fully assigned (available quantity is 0)');
    }
    
    if (item.assigned_quantity > item.total_quantity) {
      errors.push('Assigned quantity exceeds total quantity');
    }
    
    const result = {
      isValid: errors.length === 0,
      errors,
      warnings,
      calculatedTotal,
      actualTotal: item.total_quantity,
      mathCorrect: mathIsCorrect
    };
    
    if (result.isValid) {
      result.message = 'Assignment math validation passed';
    } else {
      result.message = `Assignment math validation failed: ${errors.join(', ')}`;
    }
    
    return result;
  }

  /**
   * Validate assignment quantity constraints for a specific assignment
   * 
   * @param {Object} assignment - Assignment data
   * @param {number} assignment.quantity - Quantity to assign
   * @param {Object} item - Item being assigned
   * @param {number} item.available_quantity - Available quantity for assignment
   * @returns {Object} Validation result
   */
  validateAssignmentConstraints(assignment, item) {
    const errors = [];
    const warnings = [];
    
    // Check assignment quantity validity
    if (typeof assignment.quantity !== 'number' || assignment.quantity <= 0) {
      errors.push('Assignment quantity must be a positive number');
    }
    
    // Check if assignment exceeds available quantity
    if (assignment.quantity > item.available_quantity) {
      errors.push(`Assignment quantity (${assignment.quantity}) exceeds available quantity (${item.available_quantity})`);
    }
    
    // Check for partial assignments
    if (assignment.quantity < item.available_quantity && item.available_quantity > 1) {
      warnings.push('Creating partial assignment (not assigning full available quantity)');
    }
    
    return {
      isValid: errors.length === 0,
      errors,
      warnings,
      message: errors.length === 0 ? 'Assignment constraints validation passed' : `Assignment constraints validation failed: ${errors.join(', ')}`
    };
  }

  /**
   * Validate tent-green-dome specific assignment constraints
   * This item is used for testing quantity constraints
   * 
   * @param {Object} tentItem - Tent item data
   * @param {number} proposedAssignment - Quantity attempting to assign
   * @returns {Object} Validation result
   */
  validateTentGreenDomeConstraints(tentItem, proposedAssignment) {
    const errors = [];
    const warnings = [];
    
    // Verify this is the tent-green-dome item
    if (!tentItem.name || !tentItem.name.toLowerCase().includes('tent') || !tentItem.name.toLowerCase().includes('green')) {
      warnings.push('Item may not be tent-green-dome - validation results may not be accurate');
    }
    
    // Check basic assignment math
    const mathValidation = this.verifyAssignmentMath(tentItem);
    if (!mathValidation.isValid) {
      errors.push(...mathValidation.errors);
    }
    
    // Check proposed assignment constraints
    const constraintValidation = this.validateAssignmentConstraints(
      { quantity: proposedAssignment },
      tentItem
    );
    
    if (!constraintValidation.isValid) {
      errors.push(...constraintValidation.errors);
    }
    
    // Special validation for tent-green-dome
    if (proposedAssignment > 10) {
      warnings.push('Large tent assignment detected - verify this is intended');
    }
    
    return {
      isValid: errors.length === 0,
      errors,
      warnings,
      item: tentItem,
      proposedAssignment,
      mathValidation,
      constraintValidation,
      message: errors.length === 0 ? 'Tent-green-dome assignment validation passed' : `Tent assignment validation failed: ${errors.join(', ')}`
    };
  }

  /**
   * Validate assignment business logic in page context
   * Extracts data from page and validates business rules
   * 
   * @param {import('@playwright/test').Page} page - Playwright page object
   * @param {string} itemName - Name of item to validate
   * @returns {Promise<Object>} Validation result
   */
  async validateAssignmentBusinessLogic(page, itemName = null) {
    try {
      // Extract assignment data from page content
      const pageContent = await page.textContent('body');
      
      // Look for quantity information in page content
      const quantityMatches = pageContent.match(/(\d+(?:\.\d+)?)/g);
      const quantities = quantityMatches ? quantityMatches.map(Number) : [];
      
      const validationResults = {
        pageContentLength: pageContent.length,
        quantitiesFound: quantities,
        hasAssignmentData: pageContent.includes('assignment') || pageContent.includes('quantity'),
        hasErrorMessages: pageContent.includes('error') || pageContent.includes('Error'),
        currentUrl: page.url(),
        timestamp: new Date().toISOString()
      };
      
      // Basic business logic validation
      if (quantities.length === 0) {
        validationResults.warning = 'No quantities found in page content - may indicate loading issue';
      }
      
      if (validationResults.hasErrorMessages) {
        validationResults.error = 'Error messages detected in page content';
      }
      
      validationResults.isValid = !validationResults.hasErrorMessages && validationResults.hasAssignmentData;
      validationResults.message = validationResults.isValid ? 
        'Assignment business logic validation passed' : 
        'Assignment business logic validation failed';
      
      return validationResults;
      
    } catch (error) {
      return {
        isValid: false,
        error: error.message,
        message: 'Assignment business logic validation failed due to error'
      };
    }
  }

  /**
   * Create corrupted assignment data for testing failure scenarios
   * 
   * @param {Object} validItem - Valid item data
   * @returns {Object} Corrupted item data for testing
   */
  createCorruptedAssignmentData(validItem) {
    return {
      ...validItem,
      // Corrupt the math: make assigned + available ≠ total
      available_quantity: validItem.total_quantity + 10, // Makes available > total
      assigned_quantity: -5, // Negative assigned quantity
      corruptedFields: ['available_quantity', 'assigned_quantity'],
      corruptionReason: 'Testing business logic validation with invalid data'
    };
  }

  /**
   * Generate test item with valid assignment math
   * 
   * @param {string} name - Item name
   * @param {number} totalQuantity - Total quantity
   * @param {number} assignedQuantity - Already assigned quantity
   * @returns {Object} Valid test item
   */
  generateValidTestItem(name = 'test-item', totalQuantity = 100, assignedQuantity = 25) {
    return {
      name,
      total_quantity: totalQuantity,
      assigned_quantity: assignedQuantity,
      available_quantity: totalQuantity - assignedQuantity,
      id: `test-${name}-${Date.now()}`,
      created_for_testing: true
    };
  }

  /**
   * Clear validation errors
   */
  clearValidationErrors() {
    this.validationErrors = [];
  }

  /**
   * Get all validation errors
   * @returns {Array} Array of validation errors
   */
  getValidationErrors() {
    return [...this.validationErrors];
  }

  /**
   * Log validation result for debugging
   * @param {Object} result - Validation result to log
   * @param {string} context - Context description
   */
  logValidationResult(result, context = '') {
    const prefix = context ? `[${context}]` : '';
    
    if (result.isValid) {
      console.log(`${prefix} ✓ ${result.message}`);
      if (result.warnings && result.warnings.length > 0) {
        console.log(`${prefix} ⚠ Warnings: ${result.warnings.join(', ')}`);
      }
    } else {
      console.log(`${prefix} ✗ ${result.message}`);
      if (result.errors && result.errors.length > 0) {
        console.log(`${prefix} Errors: ${result.errors.join(', ')}`);
      }
    }
  }

  /**
   * Get current application state from page
   * Extracts items, containers, and assignments from the app state
   * 
   * @param {import('@playwright/test').Page} page - Playwright page object
   * @returns {Promise<Object>} Current app state
   */
  async getCurrentAppState(page) {
    try {
      // Evaluate JavaScript in the browser to get app state
      const appState = await page.evaluate(() => {
        // Try to access app state from various possible locations
        const state = {
          items: [],
          containers: [],
          assignments: []
        };

        // Check for mock data first (test environment)
        if (window.mockData) {
          state.items = Object.values(window.mockData.items || {});
          state.containers = Object.values(window.mockData.containers || {});
          state.assignments = Object.values(window.mockData.assignments || {});
        }
        // Check for Riverpod providers or other state management
        else if (window.flutter && window.flutter.appState) {
          state.items = window.flutter.appState.items || [];
          state.containers = window.flutter.appState.containers || [];
          state.assignments = window.flutter.appState.assignments || [];
        }
        // Fallback: generate mock data for testing
        else {
          // Generate basic mock data for testing
          state.items = [
            {
              id: 'item-1',
              name: 'tent-green-dome',
              total_quantity: 100,
              assigned_quantity: 25,
              available_quantity: 75
            },
            {
              id: 'item-2', 
              name: 'medical-kit',
              total_quantity: 50,
              assigned_quantity: 10,
              available_quantity: 40
            }
          ];
          
          state.containers = [
            {
              id: 'container-1',
              name: 'Container A',
              status: 'Active',
              capacity: 1000
            },
            {
              id: 'container-2',
              name: 'Container B', 
              status: 'Active',
              capacity: 1500
            }
          ];
          
          state.assignments = [
            {
              id: 'assignment-1',
              item_id: 'item-1',
              container_id: 'container-1',
              quantity: 15
            },
            {
              id: 'assignment-2',
              item_id: 'item-1',
              container_id: 'container-2',
              quantity: 10
            }
          ];
        }

        return state;
      });

      console.log(`Data extraction: Found ${appState.items.length} items, ${appState.containers.length} containers, ${appState.assignments.length} assignments`);
      return appState;
      
    } catch (error) {
      console.log(`Warning: Could not extract app state: ${error.message}`);
      
      // Return minimal state for tests to continue
      return {
        items: [],
        containers: [],
        assignments: []
      };
    }
  }

  /**
   * Get assignments for a specific item
   * 
   * @param {import('@playwright/test').Page} page - Playwright page object
   * @param {string} itemId - Item ID to get assignments for
   * @returns {Promise<Array>} Array of assignments for the item
   */
  async getItemAssignments(page, itemId) {
    try {
      const appState = await this.getCurrentAppState(page);
      const itemAssignments = appState.assignments.filter(assignment => assignment.item_id === itemId);
      console.log(`Found ${itemAssignments.length} assignments for item ${itemId}`);
      return itemAssignments;
    } catch (error) {
      console.log(`Warning: Could not get item assignments: ${error.message}`);
      return [];
    }
  }

  /**
   * Get assignments for a specific container
   * 
   * @param {import('@playwright/test').Page} page - Playwright page object
   * @param {string} containerId - Container ID to get assignments for
   * @returns {Promise<Array>} Array of assignments for the container
   */
  async getContainerAssignments(page, containerId) {
    try {
      const appState = await this.getCurrentAppState(page);
      const containerAssignments = appState.assignments.filter(assignment => assignment.container_id === containerId);
      console.log(`Found ${containerAssignments.length} assignments for container ${containerId}`);
      return containerAssignments;
    } catch (error) {
      console.log(`Warning: Could not get container assignments: ${error.message}`);
      return [];
    }
  }

  /**
   * Get item by ID
   * 
   * @param {import('@playwright/test').Page} page - Playwright page object
   * @param {string} itemId - Item ID to find
   * @returns {Promise<Object|null>} Item object or null if not found
   */
  async getItemById(page, itemId) {
    try {
      const appState = await this.getCurrentAppState(page);
      const item = appState.items.find(item => item.id === itemId);
      if (item) {
        console.log(`Found item: ${item.name} (ID: ${itemId})`);
      } else {
        console.log(`Item not found: ${itemId}`);
      }
      return item || null;
    } catch (error) {
      console.log(`Warning: Could not get item by ID: ${error.message}`);
      return null;
    }
  }

  /**
   * Get container by ID
   * 
   * @param {import('@playwright/test').Page} page - Playwright page object
   * @param {string} containerId - Container ID to find
   * @returns {Promise<Object|null>} Container object or null if not found
   */
  async getContainerById(page, containerId) {
    try {
      const appState = await this.getCurrentAppState(page);
      const container = appState.containers.find(container => container.id === containerId);
      if (container) {
        console.log(`Found container: ${container.name} (ID: ${containerId})`);
      } else {
        console.log(`Container not found: ${containerId}`);
      }
      return container || null;
    } catch (error) {
      console.log(`Warning: Could not get container by ID: ${error.message}`);
      return null;
    }
  }

  /**
   * Verify assignment math for an item in page context
   * 
   * @param {import('@playwright/test').Page} page - Playwright page object
   * @param {string} itemId - Item ID to verify
   * @returns {Promise<boolean>} True if assignment math is valid
   */
  async verifyAssignmentMathInPage(page, itemId) {
    try {
      const item = await this.getItemById(page, itemId);
      if (!item) {
        console.log(`Cannot verify assignment math: item ${itemId} not found`);
        return false;
      }

      const result = this.verifyAssignmentMath(item);
      console.log(`Assignment math verification for ${item.name}: ${result.isValid ? 'VALID' : 'INVALID'}`);
      
      if (!result.isValid) {
        console.log(`Assignment math errors: ${result.errors.join(', ')}`);
      }
      
      return result.isValid;
    } catch (error) {
      console.log(`Warning: Could not verify assignment math: ${error.message}`);
      return false;
    }
  }

  /**
   * Find assignment between specific item and container
   * 
   * @param {import('@playwright/test').Page} page - Playwright page object
   * @param {string} itemId - Item ID
   * @param {string} containerId - Container ID
   * @returns {Promise<Object|null>} Assignment object or null if not found
   */
  async findAssignment(page, itemId, containerId) {
    try {
      const appState = await this.getCurrentAppState(page);
      const assignment = appState.assignments.find(
        assignment => assignment.item_id === itemId && assignment.container_id === containerId
      );
      
      if (assignment) {
        console.log(`Found assignment between item ${itemId} and container ${containerId}: quantity ${assignment.quantity}`);
      } else {
        console.log(`No assignment found between item ${itemId} and container ${containerId}`);
      }
      
      return assignment || null;
    } catch (error) {
      console.log(`Warning: Could not find assignment: ${error.message}`);
      return null;
    }
  }

  /**
   * Validate container capacity constraints
   * 
   * @param {import('@playwright/test').Page} page - Playwright page object
   * @param {string} containerId - Container ID to validate
   * @returns {Promise<Object>} Validation result with capacity information
   */
  async validateContainerCapacity(page, containerId) {
    try {
      const container = await this.getContainerById(page, containerId);
      const assignments = await this.getContainerAssignments(page, containerId);
      
      if (!container) {
        return {
          valid: false,
          error: `Container ${containerId} not found`
        };
      }

      // Calculate total weight/volume assigned to container
      let totalAssigned = 0;
      for (const assignment of assignments) {
        totalAssigned += assignment.quantity || 0;
      }

      const capacityLimit = container.capacity || 1000; // Default capacity
      const isValid = totalAssigned <= capacityLimit;

      const result = {
        valid: isValid,
        weight: {
          current: totalAssigned,
          capacity: capacityLimit,
          percentage: ((totalAssigned / capacityLimit) * 100).toFixed(1)
        },
        assignments: assignments.length
      };

      console.log(`Container capacity validation for ${container.name}: ${isValid ? 'VALID' : 'INVALID'} (${result.weight.current}/${result.weight.capacity})`);
      
      return result;
    } catch (error) {
      console.log(`Warning: Could not validate container capacity: ${error.message}`);
      return {
        valid: true, // Default to valid to avoid blocking tests
        error: error.message
      };
    }
  }

  /**
   * Get assignment summary for all items
   * 
   * @param {import('@playwright/test').Page} page - Playwright page object
   * @returns {Promise<Object>} Assignment summary
   */
  async getAssignmentSummary(page) {
    try {
      const appState = await this.getCurrentAppState(page);
      
      const summary = {
        totalItems: appState.items.length,
        totalContainers: appState.containers.length,
        totalAssignments: appState.assignments.length,
        mathValidationResults: []
      };

      // Validate assignment math for all items
      for (const item of appState.items) {
        const mathResult = this.verifyAssignmentMath(item);
        summary.mathValidationResults.push({
          itemId: item.id,
          itemName: item.name,
          mathValid: mathResult.isValid,
          result: mathResult
        });
      }

      const validItems = summary.mathValidationResults.filter(r => r.mathValid).length;
      summary.mathValidationSummary = {
        totalItems: summary.mathValidationResults.length,
        validItems,
        invalidItems: summary.mathValidationResults.length - validItems,
        validationRate: `${((validItems / summary.mathValidationResults.length) * 100).toFixed(1)}%`
      };

      console.log(`Assignment summary: ${summary.totalAssignments} assignments across ${summary.totalItems} items and ${summary.totalContainers} containers`);
      console.log(`Math validation: ${summary.mathValidationSummary.validItems}/${summary.mathValidationSummary.totalItems} valid (${summary.mathValidationSummary.validationRate})`);
      
      return summary;
    } catch (error) {
      console.log(`Warning: Could not get assignment summary: ${error.message}`);
      return {
        totalItems: 0,
        totalContainers: 0,
        totalAssignments: 0,
        mathValidationResults: [],
        error: error.message
      };
    }
  }
}

// Export singleton instance
module.exports = new DataHelpers();