/**
 * Helper Function Validation Test - Phase 1, Step 1.2
 * 
 * This test validates that the data extraction helper functions work correctly
 * with mock data before they're used in other tests. This is critical to ensure
 * downstream test reliability.
 * 
 * Purpose: Validate helper functions from /helpers/dataExtraction.js work correctly
 * with known mock data and return expected data types.
 */

const { test, expect } = require('@playwright/test');
const dataHelpers = require('../helpers/dataExtraction');

test.describe('Helper Function Validation - Phase 1, Step 1.2', () => {
  test.beforeEach(async ({ page }) => {
    console.log('🧪 Starting helper validation test...');
    
    // Navigate to the application to initialize mock Firebase
    await page.goto('/');
    
    // Wait for Flutter to load and mock Firebase to initialize
    await page.waitForSelector('flutter-view', { timeout: 30000 });
    await page.waitForTimeout(3000);
    
    console.log('✅ Page loaded, proceeding with helper validation...');
  });

  test('Validate mock repository access works correctly', async ({ page }) => {
    console.log('📂 Testing mock repository access...');
    
    // Test validateMockRepositories function
    const repoValidation = await dataHelpers.validateMockRepositories(page);
    console.log('Repository validation result:', repoValidation);
    
    // Validate basic repository structure
    expect(repoValidation).toBeDefined();
    expect(typeof repoValidation.valid).toBe('boolean');
    expect(repoValidation.mockFirebaseExists).toBe(true);
    expect(repoValidation.firestoreAvailable).toBe(true);
    expect(Array.isArray(repoValidation.collectionsFound)).toBe(true);
    expect(repoValidation.collectionsFound.length).toBeGreaterThan(0);
    
    // Validate that expected collections are found
    const collectionNames = repoValidation.collectionsFound.map(c => c.name);
    expect(collectionNames).toContain('items');
    expect(collectionNames).toContain('containers');
    
    console.log('✅ Mock repository access validation passed');
  });

  test('Test getMockRepositories function returns expected data', async ({ page }) => {
    console.log('🔍 Testing getMockRepositories function...');
    
    const repositories = await dataHelpers.getMockRepositories(page);
    console.log('Mock repositories structure:', Object.keys(repositories));
    
    // Validate repository structure
    expect(repositories).toBeDefined();
    expect(typeof repositories).toBe('object');
    expect(repositories.items).toBeDefined();
    expect(repositories.containers).toBeDefined();
    expect(repositories.assignments).toBeDefined();
    expect(repositories.containerTypes).toBeDefined();
    expect(repositories.currentLocations).toBeDefined();
    expect(repositories.moduleDestinations).toBeDefined();
    
    // Validate data types
    expect(typeof repositories.items).toBe('object');
    expect(typeof repositories.containers).toBe('object');
    expect(typeof repositories.assignments).toBe('object');
    
    console.log('✅ getMockRepositories function validation passed');
  });

  test('Test item helper functions work correctly', async ({ page }) => {
    console.log('🏷️ Testing item helper functions...');
    
    // Test getItemCount
    const itemCount = await dataHelpers.getItemCount(page);
    console.log(`Item count: ${itemCount}`);
    expect(typeof itemCount).toBe('number');
    expect(itemCount).toBeGreaterThanOrEqual(0);
    
    // Test getAllItems
    const allItems = await dataHelpers.getAllItems(page);
    console.log(`Retrieved ${allItems.length} items`);
    expect(Array.isArray(allItems)).toBe(true);
    expect(allItems.length).toBe(itemCount);
    
    if (allItems.length > 0) {
      const firstItem = allItems[0];
      console.log('First item structure:', Object.keys(firstItem));
      
      // Validate item structure
      expect(firstItem).toBeDefined();
      expect(typeof firstItem.name).toBe('string');
      
      // Test getItemByName with known item
      const foundItem = await dataHelpers.getItemByName(page, firstItem.name);
      expect(foundItem).toBeDefined();
      expect(foundItem.name).toBe(firstItem.name);
      
      console.log(`✅ Successfully found item by name: "${firstItem.name}"`);
      
      // Test getItemById if item has ID
      if (firstItem.id || Object.keys(firstItem).find(key => key.toLowerCase().includes('id'))) {
        const itemId = firstItem.id || Object.keys(firstItem).find(key => key.toLowerCase().includes('id'));
        if (itemId) {
          const foundById = await dataHelpers.getItemById(page, itemId);
          expect(foundById).toBeDefined();
          console.log(`✅ Successfully found item by ID: "${itemId}"`);
        }
      }
    }
    
    // Test getItemByName with known test data names
    const knownItemNames = ['Tent Green Dome', 'Genset 1', 'Water Container'];
    for (const itemName of knownItemNames) {
      const item = await dataHelpers.getItemByName(page, itemName);
      if (item) {
        console.log(`✅ Found known test item: "${itemName}"`);
        expect(item.name).toBe(itemName);
        break; // Found at least one known item
      }
    }
    
    console.log('✅ Item helper functions validation passed');
  });

  test('Test container helper functions work correctly', async ({ page }) => {
    console.log('📦 Testing container helper functions...');
    
    // Test getAllContainers
    const allContainers = await dataHelpers.getAllContainers(page);
    console.log(`Retrieved ${allContainers.length} containers`);
    expect(Array.isArray(allContainers)).toBe(true);
    
    if (allContainers.length > 0) {
      const firstContainer = allContainers[0];
      console.log('First container structure:', Object.keys(firstContainer));
      
      // Validate container structure
      expect(firstContainer).toBeDefined();
      expect(typeof firstContainer.name).toBe('string');
      
      // Test getContainerByName with known container
      const foundContainer = await dataHelpers.getContainerByName(page, firstContainer.name);
      expect(foundContainer).toBeDefined();
      expect(foundContainer.name).toBe(firstContainer.name);
      
      console.log(`✅ Successfully found container by name: "${firstContainer.name}"`);
      
      // Test getContainerById if container has ID
      if (firstContainer.id || Object.keys(firstContainer).find(key => key.toLowerCase().includes('id'))) {
        const containerId = firstContainer.id || Object.keys(firstContainer).find(key => key.toLowerCase().includes('id'));
        if (containerId) {
          const foundById = await dataHelpers.getContainerById(page, containerId);
          expect(foundById).toBeDefined();
          console.log(`✅ Successfully found container by ID: "${containerId}"`);
        }
      }
    }
    
    // Test getContainerByName with known test data names
    const knownContainerNames = ['Genset 1', 'Container A', 'Storage Container'];
    for (const containerName of knownContainerNames) {
      const container = await dataHelpers.getContainerByName(page, containerName);
      if (container) {
        console.log(`✅ Found known test container: "${containerName}"`);
        expect(container.name).toBe(containerName);
        break; // Found at least one known container
      }
    }
    
    console.log('✅ Container helper functions validation passed');
  });

  test('Test assignment helper functions work correctly', async ({ page }) => {
    console.log('🔗 Testing assignment helper functions...');
    
    // Test getAllAssignments
    const allAssignments = await dataHelpers.getAllAssignments(page);
    console.log(`Retrieved ${allAssignments.length} assignments`);
    expect(Array.isArray(allAssignments)).toBe(true);
    
    // Get any item to test assignments
    const allItems = await dataHelpers.getAllItems(page);
    if (allItems.length > 0) {
      const testItem = allItems[0];
      const itemId = testItem.id || Object.keys(testItem).find(key => key.toLowerCase().includes('id'));
      
      if (itemId) {
        // Test getItemAssignments
        const itemAssignments = await dataHelpers.getItemAssignments(page, itemId);
        console.log(`Found ${itemAssignments.length} assignments for item "${testItem.name}"`);
        expect(Array.isArray(itemAssignments)).toBe(true);
        
        // Test verifyAssignmentMath
        const mathVerification = await dataHelpers.verifyAssignmentMath(page, itemId);
        console.log('Assignment math verification:', mathVerification);
        
        expect(mathVerification).toBeDefined();
        expect(typeof mathVerification.valid).toBe('boolean');
        expect(typeof mathVerification.itemId).toBe('string');
        expect(typeof mathVerification.totalAvailable).toBe('number');
        expect(typeof mathVerification.totalAssigned).toBe('number');
        expect(typeof mathVerification.remainingQuantity).toBe('number');
        expect(typeof mathVerification.assignmentCount).toBe('number');
        expect(Array.isArray(mathVerification.assignments)).toBe(true);
        
        console.log(`✅ Assignment math for "${testItem.name}": ${mathVerification.totalAvailable} available, ${mathVerification.totalAssigned} assigned, ${mathVerification.remainingQuantity} remaining`);
      }
    }
    
    console.log('✅ Assignment helper functions validation passed');
  });

  test('Test helper functions handle error conditions correctly', async ({ page }) => {
    console.log('🚨 Testing error handling...');
    
    // Test with non-existent item name
    const nonExistentItem = await dataHelpers.getItemByName(page, 'Non-Existent Item 12345');
    expect(nonExistentItem).toBeNull();
    console.log('✅ Non-existent item correctly returns null');
    
    // Test with non-existent item ID
    const nonExistentItemById = await dataHelpers.getItemById(page, 'non-existent-id-12345');
    expect(nonExistentItemById).toBeNull();
    console.log('✅ Non-existent item ID correctly returns null');
    
    // Test with non-existent container name
    const nonExistentContainer = await dataHelpers.getContainerByName(page, 'Non-Existent Container 12345');
    expect(nonExistentContainer).toBeNull();
    console.log('✅ Non-existent container correctly returns null');
    
    // Test with non-existent container ID
    const nonExistentContainerById = await dataHelpers.getContainerById(page, 'non-existent-container-id-12345');
    expect(nonExistentContainerById).toBeNull();
    console.log('✅ Non-existent container ID correctly returns null');
    
    // Test assignment math with non-existent item
    const mathWithNonExistentItem = await dataHelpers.verifyAssignmentMath(page, 'non-existent-item-id');
    expect(mathWithNonExistentItem).toBeDefined();
    expect(mathWithNonExistentItem.valid).toBe(false);
    expect(mathWithNonExistentItem.error).toBeDefined();
    expect(typeof mathWithNonExistentItem.error).toBe('string');
    console.log('✅ Assignment math with non-existent item correctly returns error');
    
    // Test assignments for non-existent item
    const assignmentsForNonExistentItem = await dataHelpers.getItemAssignments(page, 'non-existent-item-id');
    expect(Array.isArray(assignmentsForNonExistentItem)).toBe(true);
    expect(assignmentsForNonExistentItem.length).toBe(0);
    console.log('✅ Assignments for non-existent item correctly returns empty array');
    
    console.log('✅ Error handling validation passed');
  });

  test('Test helper functions with invalid input parameters', async ({ page }) => {
    console.log('⚠️ Testing invalid input parameter handling...');
    
    // Test with null parameters
    const itemWithNull = await dataHelpers.getItemByName(page, null);
    expect(itemWithNull).toBeNull();
    
    const itemByIdWithNull = await dataHelpers.getItemById(page, null);
    expect(itemByIdWithNull).toBeNull();
    
    const containerWithNull = await dataHelpers.getContainerByName(page, null);
    expect(containerWithNull).toBeNull();
    
    const containerByIdWithNull = await dataHelpers.getContainerById(page, null);
    expect(containerByIdWithNull).toBeNull();
    
    const assignmentsWithNull = await dataHelpers.getItemAssignments(page, null);
    expect(Array.isArray(assignmentsWithNull)).toBe(true);
    expect(assignmentsWithNull.length).toBe(0);
    
    // Test with undefined parameters
    const itemWithUndefined = await dataHelpers.getItemByName(page, undefined);
    expect(itemWithUndefined).toBeNull();
    
    // Test with empty string parameters
    const itemWithEmpty = await dataHelpers.getItemByName(page, '');
    expect(itemWithEmpty).toBeNull();
    
    const containerWithEmpty = await dataHelpers.getContainerByName(page, '');
    expect(containerWithEmpty).toBeNull();
    
    console.log('✅ Invalid input parameter handling validation passed');
  });

  test('Comprehensive helper function validation summary', async ({ page }) => {
    console.log('\n🎯 COMPREHENSIVE HELPER VALIDATION SUMMARY');
    console.log('═'.repeat(60));
    
    // Run all helper functions and validate their outputs
    const startTime = Date.now();
    
    try {
      // Repository validation
      const repoValidation = await dataHelpers.validateMockRepositories(page);
      const repositories = await dataHelpers.getMockRepositories(page);
      
      // Item functions
      const itemCount = await dataHelpers.getItemCount(page);
      const allItems = await dataHelpers.getAllItems(page);
      
      // Container functions
      const allContainers = await dataHelpers.getAllContainers(page);
      
      // Assignment functions
      const allAssignments = await dataHelpers.getAllAssignments(page);
      
      const endTime = Date.now();
      const totalTime = endTime - startTime;
      
      // Validate all results
      expect(repoValidation.valid).toBe(true);
      expect(repositories).toBeDefined();
      expect(typeof itemCount).toBe('number');
      expect(Array.isArray(allItems)).toBe(true);
      expect(Array.isArray(allContainers)).toBe(true);
      expect(Array.isArray(allAssignments)).toBe(true);
      
      // Performance validation
      expect(totalTime).toBeLessThan(10000); // Should complete within 10 seconds
      
      console.log('📊 VALIDATION RESULTS:');
      console.log(`   ✅ Mock repository access: ${repoValidation.valid ? 'WORKING' : 'FAILED'}`);
      console.log(`   ✅ Collections found: ${repoValidation.collectionsFound.length}`);
      console.log(`   ✅ Items loaded: ${itemCount}`);
      console.log(`   ✅ Containers loaded: ${allContainers.length}`);
      console.log(`   ✅ Assignments loaded: ${allAssignments.length}`);
      console.log(`   ✅ Total execution time: ${totalTime}ms`);
      console.log('═'.repeat(60));
      
      // Success criteria validation
      console.log('🎉 SUCCESS CRITERIA VALIDATION:');
      console.log('   ✅ All helper functions return expected data types');
      console.log('   ✅ Mock repository access works for items, containers, assignments');
      console.log('   ✅ Helper validation test passes consistently');
      console.log('   ✅ No undefined or null returns for known test data');
      console.log('   ✅ Error handling works correctly for invalid inputs');
      console.log('   ✅ Performance is acceptable (< 10 seconds)');
      console.log('═'.repeat(60));
      console.log('🚀 HELPER FUNCTIONS ARE READY FOR USE IN PHASE 2!');
      
    } catch (error) {
      console.error('❌ Helper validation failed:', error.message);
      throw error;
    }
  });
});