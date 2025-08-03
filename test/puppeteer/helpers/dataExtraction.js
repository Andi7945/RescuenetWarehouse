/**
 * Data Extraction Helper Functions for RescuenetWarehouse Playwright Tests
 * 
 * This module provides essential helper functions to extract and validate data
 * from mock repositories, enabling proper business logic testing instead of
 * weak DOM-based assertions.
 * 
 * These functions access mock repository data via the window.mockFirebase object
 * which is initialized when the Flutter app loads in test mode.
 * 
 * Created as part of Phase 1, Step 1.1 of the Test Assertion Improvement Plan.
 */

/**
 * Get mock repositories from the global window object
 * @param {import('@playwright/test').Page} page - Playwright page object
 * @returns {Promise<Object>} Mock repositories object
 */
async function getMockRepositories(page) {
  try {
    const mockData = await page.evaluate(() => {
      if (!window.mockFirebase) {
        throw new Error('Mock Firebase not available - ensure test is running in mock mode');
      }
      
      // Create a fresh firestore instance to get the current mock data
      const firestore = window.mockFirebase.firestore();
      
      // Extract data from each collection
      const extractCollectionData = (collectionName) => {
        const collection = firestore.collection(collectionName);
        const data = {};
        
        // Access the internal _docs map to get all documents
        if (collection._docs) {
          for (const [id, doc] of collection._docs) {
            data[id] = doc._data || {};
          }
        }
        
        return data;
      };
      
      return {
        items: extractCollectionData('items'),
        containers: extractCollectionData('containers'),
        assignments: extractCollectionData('assignments'),
        containerTypes: extractCollectionData('container_types'),
        currentLocations: extractCollectionData('current_locations'),
        moduleDestinations: extractCollectionData('module_destinations')
      };
    });
    
    return mockData;
  } catch (error) {
    console.error('Failed to get mock repositories:', error.message);
    throw new Error(`Mock repositories not available: ${error.message}`);
  }
}

/**
 * Get an item by its ID from mock repository data
 * @param {import('@playwright/test').Page} page - Playwright page object
 * @param {string} itemId - The item ID to search for
 * @returns {Promise<Object|null>} Item object or null if not found
 */
async function getItemById(page, itemId) {
  try {
    if (!itemId || typeof itemId !== 'string') {
      throw new Error('Item ID must be a non-empty string');
    }
    
    const repositories = await getMockRepositories(page);
    
    if (!repositories.items) {
      console.warn('Items repository not found or empty');
      return null;
    }
    
    const item = repositories.items[itemId] || null;
    
    if (item) {
      console.log(`Found item by ID "${itemId}":`, item);
    } else {
      console.log(`Item with ID "${itemId}" not found`);
    }
    
    return item;
  } catch (error) {
    console.error(`Error getting item by ID "${itemId}":`, error.message);
    return null;
  }
}

/**
 * Get an item by its name from mock repository data
 * @param {import('@playwright/test').Page} page - Playwright page object
 * @param {string} itemName - The item name to search for
 * @returns {Promise<Object|null>} Item object or null if not found
 */
async function getItemByName(page, itemName) {
  try {
    if (!itemName || typeof itemName !== 'string') {
      throw new Error('Item name must be a non-empty string');
    }
    
    const repositories = await getMockRepositories(page);
    
    if (!repositories.items) {
      console.warn('Items repository not found or empty');
      return null;
    }
    
    // Search through all items to find one with matching name
    const items = Object.values(repositories.items);
    const item = items.find(item => item.name === itemName) || null;
    
    if (item) {
      console.log(`Found item by name "${itemName}":`, item);
    } else {
      console.log(`Item with name "${itemName}" not found`);
    }
    
    return item;
  } catch (error) {
    console.error(`Error getting item by name "${itemName}":`, error.message);
    return null;
  }
}

/**
 * Get the total count of items in mock repository
 * @param {import('@playwright/test').Page} page - Playwright page object
 * @returns {Promise<number>} Total number of items
 */
async function getItemCount(page) {
  try {
    const repositories = await getMockRepositories(page);
    
    if (!repositories.items) {
      console.warn('Items repository not found or empty');
      return 0;
    }
    
    const count = Object.keys(repositories.items).length;
    console.log(`Total item count: ${count}`);
    
    return count;
  } catch (error) {
    console.error('Error getting item count:', error.message);
    return 0;
  }
}

/**
 * Get a container by its ID from mock repository data
 * @param {import('@playwright/test').Page} page - Playwright page object
 * @param {string} containerId - The container ID to search for
 * @returns {Promise<Object|null>} Container object or null if not found
 */
async function getContainerById(page, containerId) {
  try {
    if (!containerId || typeof containerId !== 'string') {
      throw new Error('Container ID must be a non-empty string');
    }
    
    const repositories = await getMockRepositories(page);
    
    if (!repositories.containers) {
      console.warn('Containers repository not found or empty');
      return null;
    }
    
    const container = repositories.containers[containerId] || null;
    
    if (container) {
      console.log(`Found container by ID "${containerId}":`, container);
    } else {
      console.log(`Container with ID "${containerId}" not found`);
    }
    
    return container;
  } catch (error) {
    console.error(`Error getting container by ID "${containerId}":`, error.message);
    return null;
  }
}

/**
 * Get a container by its name from mock repository data (original interface)
 * @param {import('@playwright/test').Page} page - Playwright page object
 * @param {string} containerName - The container name to search for
 * @returns {Promise<Object|null>} Container object or null if not found
 */
async function getContainerByName(page, containerName) {
  try {
    if (!containerName || typeof containerName !== 'string') {
      throw new Error('Container name must be a non-empty string');
    }
    
    const repositories = await getMockRepositories(page);
    
    if (!repositories.containers) {
      console.warn('Containers repository not found or empty');
      return null;
    }
    
    // Search through all containers to find one with matching name
    const containers = Object.values(repositories.containers);
    const container = containers.find(container => container.name === containerName) || null;
    
    if (container) {
      console.log(`Found container by name "${containerName}":`, container);
    } else {
      console.log(`Container with name "${containerName}" not found`);
    }
    
    return container;
  } catch (error) {
    console.error(`Error getting container by name "${containerName}":`, error.message);
    return null;
  }
}

/**
 * Get all assignments for a specific item from mock repository data
 * @param {import('@playwright/test').Page} page - Playwright page object
 * @param {string} itemId - The item ID to get assignments for
 * @returns {Promise<Array>} Array of assignment objects for the item
 */
async function getItemAssignments(page, itemId) {
  try {
    if (!itemId || typeof itemId !== 'string') {
      throw new Error('Item ID must be a non-empty string');
    }
    
    const repositories = await getMockRepositories(page);
    
    if (!repositories.assignments) {
      console.warn('Assignments repository not found or empty');
      return [];
    }
    
    // Filter assignments by itemId
    const assignments = Object.values(repositories.assignments)
      .filter(assignment => assignment.itemId === itemId);
    
    console.log(`Found ${assignments.length} assignments for item "${itemId}":`, assignments);
    
    return assignments;
  } catch (error) {
    console.error(`Error getting assignments for item "${itemId}":`, error.message);
    return [];
  }
}

/**
 * Verify assignment math for an item (total assigned vs available quantity)
 * @param {import('@playwright/test').Page} page - Playwright page object
 * @param {string} itemId - The item ID to verify assignment math for
 * @returns {Promise<Object>} Object containing verification results
 */
async function verifyAssignmentMath(page, itemId) {
  try {
    if (!itemId || typeof itemId !== 'string') {
      throw new Error('Item ID must be a non-empty string');
    }
    
    // Get the item details
    const item = await getItemById(page, itemId);
    if (!item) {
      return {
        valid: false,
        error: `Item with ID "${itemId}" not found`,
        itemId: itemId
      };
    }
    
    // Get all assignments for this item
    const assignments = await getItemAssignments(page, itemId);
    
    // Calculate total assigned quantity
    const totalAssigned = assignments.reduce((sum, assignment) => {
      const count = parseInt(assignment.count) || 0;
      return sum + count;
    }, 0);
    
    // Get total available quantity from item
    const totalAvailable = parseInt(item.totalAmount) || 0;
    
    // Verify the math
    const isValid = totalAssigned <= totalAvailable;
    const remainingQuantity = totalAvailable - totalAssigned;
    
    const result = {
      valid: isValid,
      itemId: itemId,
      itemName: item.name,
      totalAvailable: totalAvailable,
      totalAssigned: totalAssigned,
      remainingQuantity: remainingQuantity,
      assignmentCount: assignments.length,
      assignments: assignments,
      error: isValid ? null : `Over-assigned: ${totalAssigned} assigned but only ${totalAvailable} available`
    };
    
    console.log(`Assignment math verification for item "${itemId}":`, result);
    
    return result;
  } catch (error) {
    console.error(`Error verifying assignment math for item "${itemId}":`, error.message);
    return {
      valid: false,
      error: error.message,
      itemId: itemId
    };
  }
}

/**
 * Get all containers from mock repository data
 * @param {import('@playwright/test').Page} page - Playwright page object
 * @returns {Promise<Array>} Array of all container objects
 */
async function getAllContainers(page) {
  try {
    const repositories = await getMockRepositories(page);
    
    if (!repositories.containers) {
      console.warn('Containers repository not found or empty');
      return [];
    }
    
    const containers = Object.values(repositories.containers);
    console.log(`Retrieved ${containers.length} containers from mock repository`);
    
    return containers;
  } catch (error) {
    console.error('Error getting all containers:', error.message);
    return [];
  }
}

/**
 * Get all items from mock repository data
 * @param {import('@playwright/test').Page} page - Playwright page object
 * @returns {Promise<Array>} Array of all item objects
 */
async function getAllItems(page) {
  try {
    const repositories = await getMockRepositories(page);
    
    if (!repositories.items) {
      console.warn('Items repository not found or empty');
      return [];
    }
    
    const items = Object.values(repositories.items);
    console.log(`Retrieved ${items.length} items from mock repository`);
    
    return items;
  } catch (error) {
    console.error('Error getting all items:', error.message);
    return [];
  }
}

/**
 * Get all assignments from mock repository data
 * @param {import('@playwright/test').Page} page - Playwright page object
 * @returns {Promise<Array>} Array of all assignment objects
 */
async function getAllAssignments(page) {
  try {
    const repositories = await getMockRepositories(page);
    
    if (!repositories.assignments) {
      console.warn('Assignments repository not found or empty');
      return [];
    }
    
    const assignments = Object.values(repositories.assignments);
    console.log(`Retrieved ${assignments.length} assignments from mock repository`);
    
    return assignments;
  } catch (error) {
    console.error('Error getting all assignments:', error.message);
    return [];
  }
}

/**
 * Get the total count of containers in mock repository
 * @param {import('@playwright/test').Page} page - Playwright page object
 * @returns {Promise<number>} Total number of containers
 */
async function getContainerCount(page) {
  try {
    const repositories = await getMockRepositories(page);
    
    if (!repositories.containers) {
      console.warn('Containers repository not found or empty');
      return 0;
    }
    
    const count = Object.keys(repositories.containers).length;
    console.log(`Total container count: ${count}`);
    
    return count;
  } catch (error) {
    console.error('Error getting container count:', error.message);
    return 0;
  }
}

/**
 * Get all container names from mock repository data
 * @param {import('@playwright/test').Page} page - Playwright page object
 * @returns {Promise<Array<string>>} Array of container names
 */
async function getAllContainerNames(page) {
  try {
    const repositories = await getMockRepositories(page);
    
    if (!repositories.containers) {
      console.warn('Containers repository not found or empty');
      return [];
    }
    
    const containers = Object.values(repositories.containers);
    const names = containers.map(container => container.name).filter(name => name);
    console.log(`Retrieved ${names.length} container names: ${names.join(', ')}`);
    
    return names;
  } catch (error) {
    console.error('Error getting container names:', error.message);
    return [];
  }
}

/**
 * Check if a container exists by name
 * @param {import('@playwright/test').Page} page - Playwright page object
 * @param {string} containerName - The container name to check
 * @returns {Promise<boolean>} True if container exists, false otherwise
 */
async function containerExists(page, containerName) {
  try {
    if (!containerName || typeof containerName !== 'string') {
      return false;
    }
    
    const container = await getContainerByName(page, containerName);
    const exists = container !== null;
    
    console.log(`Container "${containerName}" exists: ${exists}`);
    return exists;
  } catch (error) {
    console.error(`Error checking if container "${containerName}" exists:`, error.message);
    return false;
  }
}

/**
 * Get a container by name with additional result metadata
 * @param {import('@playwright/test').Page} page - Playwright page object
 * @param {string} containerName - The container name to search for
 * @returns {Promise<Object>} Container object with found flag and metadata
 */
async function getContainerByNameExtended(page, containerName) {
  try {
    if (!containerName || typeof containerName !== 'string') {
      return { found: false, name: containerName, error: 'Invalid container name' };
    }
    
    const repositories = await getMockRepositories(page);
    
    if (!repositories.containers) {
      return { found: false, name: containerName, error: 'Containers repository not available' };
    }
    
    // Search through all containers to find one with matching name
    const containers = Object.values(repositories.containers);
    const container = containers.find(container => container.name === containerName);
    
    if (container) {
      console.log(`Found container by name "${containerName}":`, container);
      
      // Add calculated fields and metadata
      const result = {
        found: true,
        ...container,
        // Calculate capacity percentage if weight data is available
        capacity_percentage: calculateCapacityPercentage(container),
        // Add current weight field mapping
        current_weight: container.current_weight || container.currentWeight || 0,
        capacity_weight: container.capacity_weight || container.maxWeight || container.capacity || 100
      };
      
      return result;
    } else {
      console.log(`Container with name "${containerName}" not found`);
      return { found: false, name: containerName, error: 'Container not found' };
    }
  } catch (error) {
    console.error(`Error getting container by name "${containerName}":`, error.message);
    return { found: false, name: containerName, error: error.message };
  }
}

/**
 * Calculate capacity percentage for a container
 * @param {Object} container - Container object
 * @returns {number|null} Capacity percentage or null if calculation not possible
 */
function calculateCapacityPercentage(container) {
  try {
    const currentWeight = container.current_weight || container.currentWeight || 0;
    const maxWeight = container.capacity_weight || container.maxWeight || container.capacity;
    
    if (maxWeight && maxWeight > 0) {
      const percentage = Math.round((currentWeight / maxWeight) * 100);
      return Math.min(100, Math.max(0, percentage)); // Clamp between 0-100
    }
    
    return null;
  } catch (error) {
    console.error('Error calculating capacity percentage:', error.message);
    return null;
  }
}

/**
 * Validate container capacity calculations
 * @param {Object} containerData - Container data object
 * @returns {Object} Validation results
 */
function validateContainerCapacity(containerData) {
  try {
    if (!containerData) {
      return {
        valid: false,
        error: 'No container data provided',
        calculation_correct: false
      };
    }
    
    const currentWeight = containerData.current_weight || 0;
    const capacityWeight = containerData.capacity_weight || 0;
    const actualPercentage = containerData.capacity_percentage;
    
    if (capacityWeight <= 0) {
      return {
        valid: false,
        error: 'Invalid capacity weight',
        calculation_correct: false,
        current_weight: currentWeight,
        capacity_weight: capacityWeight
      };
    }
    
    // Calculate expected percentage
    const expectedPercentage = (currentWeight / capacityWeight) * 100;
    const roundedExpected = Math.round(expectedPercentage);
    
    // Check if calculation is correct (allowing for rounding)
    const calculationCorrect = actualPercentage === null || 
                              Math.abs(actualPercentage - roundedExpected) <= 1;
    
    // Check capacity constraints
    const withinCapacity = currentWeight <= capacityWeight;
    
    return {
      valid: calculationCorrect && withinCapacity,
      calculation_correct: calculationCorrect,
      within_capacity: withinCapacity,
      current_weight: currentWeight,
      capacity_weight: capacityWeight,
      actual_percentage: actualPercentage,
      expected_percentage: expectedPercentage,
      rounded_expected: roundedExpected,
      error: !calculationCorrect ? 'Capacity percentage calculation incorrect' :
             !withinCapacity ? 'Current weight exceeds capacity' : null
    };
  } catch (error) {
    console.error('Error validating container capacity:', error.message);
    return {
      valid: false,
      error: error.message,
      calculation_correct: false
    };
  }
}

/**
 * Validate that mock repositories are available and properly initialized
 * @param {import('@playwright/test').Page} page - Playwright page object
 * @returns {Promise<Object>} Validation results
 */
async function validateMockRepositories(page) {
  try {
    const validation = await page.evaluate(() => {
      const results = {
        mockFirebaseExists: !!window.mockFirebase,
        mockModeEnabled: window.MOCK_FIREBASE_MODE === true,
        firestoreAvailable: false,
        collectionsFound: [],
        errors: []
      };
      
      if (window.mockFirebase) {
        try {
          const firestore = window.mockFirebase.firestore();
          results.firestoreAvailable = true;
          
          // Check for expected collections
          const expectedCollections = ['items', 'containers', 'assignments', 'container_types'];
          
          for (const collectionName of expectedCollections) {
            try {
              const collection = firestore.collection(collectionName);
              if (collection && collection._docs && collection._docs.size > 0) {
                results.collectionsFound.push({
                  name: collectionName,
                  documentCount: collection._docs.size
                });
              }
            } catch (error) {
              results.errors.push(`Error checking collection ${collectionName}: ${error.message}`);
            }
          }
        } catch (error) {
          results.errors.push(`Firestore initialization error: ${error.message}`);
        }
      } else {
        results.errors.push('Mock Firebase not found on window object');
      }
      
      return results;
    });
    
    console.log('Mock repositories validation:', validation);
    
    // Enhanced validation results for helper validation test compatibility
    return {
      valid: validation.mockFirebaseExists && validation.firestoreAvailable && validation.collectionsFound.length > 0,
      mockRepositoriesExists: validation.mockFirebaseExists,
      itemRepositoryExists: validation.collectionsFound.some(c => c.name === 'items'),
      containerRepositoryExists: validation.collectionsFound.some(c => c.name === 'containers'),
      assignmentRepositoryExists: validation.collectionsFound.some(c => c.name === 'assignments'),
      allRepositoriesAvailable: validation.collectionsFound.length >= 3,
      ...validation
    };
  } catch (error) {
    console.error('Error validating mock repositories:', error.message);
    return {
      valid: false,
      error: error.message,
      mockRepositoriesExists: false,
      itemRepositoryExists: false,
      containerRepositoryExists: false,
      assignmentRepositoryExists: false,
      allRepositoriesAvailable: false
    };
  }
}

/**
 * Validate test data is available and accessible
 * @param {import('@playwright/test').Page} page - Playwright page object
 * @returns {Promise<Object>} Test data validation results
 */
async function validateTestData(page) {
  try {
    const repositories = await getMockRepositories(page);
    
    const itemCount = repositories.items ? Object.keys(repositories.items).length : 0;
    const containerCount = repositories.containers ? Object.keys(repositories.containers).length : 0;
    const assignmentCount = repositories.assignments ? Object.keys(repositories.assignments).length : 0;
    
    const errors = [];
    
    if (itemCount === 0) {
      errors.push('No items found in test data');
    }
    
    if (containerCount === 0) {
      errors.push('No containers found in test data');
    }
    
    return {
      itemCount,
      containerCount,
      assignmentCount,
      errors,
      valid: errors.length === 0 && itemCount > 0 && containerCount > 0
    };
  } catch (error) {
    console.error('Error validating test data:', error.message);
    return {
      itemCount: 0,
      containerCount: 0,
      assignmentCount: 0,
      errors: [error.message],
      valid: false
    };
  }
}

/**
 * Check if user is authenticated (stub for now)
 * @param {import('@playwright/test').Page} page - Playwright page object
 * @returns {Promise<boolean>} Authentication status
 */
async function isUserAuthenticated(page) {
  try {
    const authStatus = await page.evaluate(() => {
      // Check for auth indicators in the app
      return window.mockFirebase ? true : false;
    });
    
    return authStatus;
  } catch (error) {
    console.error('Error checking authentication status:', error.message);
    return false;
  }
}

/**
 * Get current user information (stub for now)
 * @param {import('@playwright/test').Page} page - Playwright page object
 * @returns {Promise<Object|null>} Current user object or null
 */
async function getCurrentUser(page) {
  try {
    const user = await page.evaluate(() => {
      // Mock user for testing
      if (window.mockFirebase) {
        return {
          email: 'test@rescuenet.net',
          role: 'logistics',
          authenticated: true
        };
      }
      return null;
    });
    
    return user;
  } catch (error) {
    console.error('Error getting current user:', error.message);
    return null;
  }
}

/**
 * Verify that an item exists in the mock repository
 * @param {import('@playwright/test').Page} page - Playwright page object
 * @param {string} itemName - The item name to verify
 * @returns {Promise<boolean>} True if item exists, false otherwise
 */
async function verifyItemExists(page, itemName) {
  try {
    const item = await getItemByName(page, itemName);
    return item !== null;
  } catch (error) {
    console.error(`Error verifying item exists "${itemName}":`, error.message);
    return false;
  }
}

/**
 * Validate item creation by checking count increase and item existence
 * @param {import('@playwright/test').Page} page - Playwright page object
 * @param {number} initialCount - Initial item count before creation
 * @param {string} itemName - Name of the item that should have been created
 * @returns {Promise<Object>} Validation results
 */
async function validateItemCreation(page, initialCount, itemName) {
  try {
    const finalCount = await getItemCount(page);
    const itemExists = await verifyItemExists(page, itemName);
    const countIncreased = finalCount > initialCount;
    
    const result = {
      success: countIncreased && itemExists,
      countIncreased: countIncreased,
      itemExists: itemExists,
      initialCount: initialCount,
      finalCount: finalCount,
      itemName: itemName
    };
    
    console.log(`Item creation validation for "${itemName}":`, result);
    return result;
  } catch (error) {
    console.error(`Error validating item creation for "${itemName}":`, error.message);
    return {
      success: false,
      error: error.message,
      itemName: itemName
    };
  }
}

/**
 * Validate persistence by reloading page and checking if item still exists
 * @param {import('@playwright/test').Page} page - Playwright page object
 * @param {string} itemName - Name of the item to check persistence for
 * @returns {Promise<boolean>} True if item persists after reload
 */
async function validatePersistence(page, itemName) {
  try {
    // Reload the page
    await page.reload({ waitUntil: 'networkidle' });
    await page.waitForTimeout(2000); // Allow time for Flutter to initialize
    
    // Check if item still exists
    const itemExists = await verifyItemExists(page, itemName);
    
    console.log(`Persistence validation for "${itemName}": ${itemExists ? 'PASSED' : 'FAILED'}`);
    return itemExists;
  } catch (error) {
    console.error(`Error validating persistence for "${itemName}":`, error.message);
    return false;
  }
}

/**
 * Validate filter results by checking filtered data
 * @param {import('@playwright/test').Page} page - Playwright page object
 * @param {string} filterField - Field to filter by (location, dangerous_goods, status)
 * @param {string} filterValue - Value to filter by
 * @returns {Promise<Object>} Filter validation results
 */
async function validateFilterResults(page, filterField, filterValue) {
  try {
    const allItems = await getAllItems(page);
    
    // Filter items based on the specified field and value
    let filteredItems = [];
    
    switch (filterField) {
      case 'location':
        filteredItems = allItems.filter(item => item.location === filterValue);
        break;
      case 'dangerous_goods':
        filteredItems = allItems.filter(item => item.dangerous_goods === filterValue);
        break;
      case 'status':
        if (filterValue === 'available') {
          filteredItems = allItems.filter(item => {
            const totalAmount = parseInt(item.totalAmount) || 0;
            const assignedAmount = parseInt(item.assignedAmount) || 0;
            return (totalAmount - assignedAmount) > 0;
          });
        } else {
          filteredItems = allItems.filter(item => item.status === filterValue);
        }
        break;
      default:
        console.warn(`Unknown filter field: ${filterField}`);
        return {
          visibleItems: 0,
          totalItems: allItems.length,
          filteredItems: [],
          error: `Unknown filter field: ${filterField}`
        };
    }
    
    const result = {
      visibleItems: filteredItems.length,
      totalItems: allItems.length,
      filteredItems: filteredItems,
      filterField: filterField,
      filterValue: filterValue
    };
    
    console.log(`Filter validation (${filterField}=${filterValue}):`, result);
    return result;
  } catch (error) {
    console.error(`Error validating filter results (${filterField}=${filterValue}):`, error.message);
    return {
      visibleItems: 0,
      totalItems: 0,
      filteredItems: [],
      error: error.message
    };
  }
}

/**
 * Validate dangerous goods classification for an item
 * @param {import('@playwright/test').Page} page - Playwright page object
 * @param {string} itemId - Item ID to check
 * @param {string} expectedClass - Expected dangerous goods class
 * @returns {Promise<boolean>} True if classification matches expected
 */
async function validateDangerousGoodsClass(page, itemId, expectedClass) {
  try {
    const item = await getItemById(page, itemId);
    if (!item) {
      console.log(`Item with ID "${itemId}" not found for DG validation`);
      return false;
    }
    
    const actualClass = item.dangerous_goods || 'None';
    const matches = actualClass === expectedClass;
    
    console.log(`DG validation for item "${itemId}": expected "${expectedClass}", actual "${actualClass}", matches: ${matches}`);
    return matches;
  } catch (error) {
    console.error(`Error validating dangerous goods class for "${itemId}":`, error.message);
    return false;
  }
}

// Export all functions
module.exports = {
  // Core data extraction functions
  getItemById,
  getItemByName,
  getItemCount,
  getContainerById,
  getContainerByName,
  getItemAssignments,
  verifyAssignmentMath,
  
  // Container-specific helper functions
  getContainerCount,
  getAllContainerNames,
  containerExists,
  getContainerByNameExtended,
  validateContainerCapacity,
  
  // Additional helper functions
  getAllContainers,
  getAllItems,
  getAllAssignments,
  getMockRepositories,
  validateMockRepositories,
  validateTestData,
  isUserAuthenticated,
  getCurrentUser,
  
  // Business logic validation functions for item management tests
  verifyItemExists,
  validateItemCreation,
  validatePersistence,
  validateFilterResults,
  validateDangerousGoodsClass,
  
  // Core application state functions
  getCurrentAppState
};

/**
 * Get the current application state with all entities
 * @param {import('@playwright/test').Page} page - Playwright page object
 * @returns {Promise<Object>} Current application state
 */
async function getCurrentAppState(page) {
  try {
    const [items, containers, assignments] = await Promise.all([
      getAllItems(page),
      getAllContainers(page),
      getAllAssignments(page)
    ]);
    
    return {
      items,
      containers,
      assignments,
      timestamp: new Date().toISOString()
    };
  } catch (error) {
    console.error('Error getting current app state:', error);
    throw error;
  }
}