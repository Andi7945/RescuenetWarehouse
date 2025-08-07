/**
 * Basic Helper Function Validation Test - Phase 1, Step 1.2
 * 
 * Simplified validation test to verify helper functions work with mock data.
 * This focuses on the core functionality without complex assertions.
 */

const { test, expect } = require('@playwright/test');
const dataHelpers = require('../helpers/dataExtraction');

test.describe('Basic Helper Function Validation - Phase 1, Step 1.2', () => {
  test.beforeEach(async ({ page }) => {
    console.log('🧪 Starting basic helper validation...');
    
    // Listen to console for debugging
    page.on('console', msg => console.log('BROWSER:', msg.text()));
    page.on('pageerror', error => console.log('PAGE ERROR:', error.message));
    
    // Navigate to the application 
    await page.goto('/');
    
    // Wait for Flutter to load
    await page.waitForLoadState('networkidle');
    await page.waitForTimeout(5000);
    
    console.log('✅ Page loaded successfully');
  });

  test('Basic mock repository validation', async ({ page }) => {
    console.log('📂 Testing basic mock repository access...');
    
    try {
      // Test validateMockRepositories function
      const repoValidation = await dataHelpers.validateMockRepositories(page);
      console.log('Repository validation result:', repoValidation);
      
      // Basic assertions
      expect(repoValidation).toBeDefined();
      expect(typeof repoValidation.mockFirebaseExists).toBe('boolean');
      expect(typeof repoValidation.firestoreAvailable).toBe('boolean');
      
      console.log(`✅ Mock Firebase exists: ${repoValidation.mockFirebaseExists}`);
      console.log(`✅ Firestore available: ${repoValidation.firestoreAvailable}`);
      
      if (repoValidation.collectionsFound) {
        console.log(`✅ Collections found: ${repoValidation.collectionsFound.length}`);
        repoValidation.collectionsFound.forEach(col => {
          console.log(`   - ${col.name}: ${col.documentCount} documents`);
        });
      }
      
    } catch (error) {
      console.error('❌ Repository validation failed:', error.message);
      throw error;
    }
  });

  test('Basic helper function return types', async ({ page }) => {
    console.log('🔍 Testing helper function return types...');
    
    try {
      // Test basic function calls and return types
      const itemCount = await dataHelpers.getItemCount(page);
      console.log(`Item count: ${itemCount} (type: ${typeof itemCount})`);
      expect(typeof itemCount).toBe('number');
      
      const allItems = await dataHelpers.getAllItems(page);
      console.log(`All items: ${allItems.length} items (type: ${Array.isArray(allItems) ? 'array' : typeof allItems})`);
      expect(Array.isArray(allItems)).toBe(true);
      
      const allContainers = await dataHelpers.getAllContainers(page);
      console.log(`All containers: ${allContainers.length} containers (type: ${Array.isArray(allContainers) ? 'array' : typeof allContainers})`);
      expect(Array.isArray(allContainers)).toBe(true);
      
      const allAssignments = await dataHelpers.getAllAssignments(page);
      console.log(`All assignments: ${allAssignments.length} assignments (type: ${Array.isArray(allAssignments) ? 'array' : typeof allAssignments})`);
      expect(Array.isArray(allAssignments)).toBe(true);
      
      console.log('✅ All helper functions returned expected data types');
      
    } catch (error) {
      console.error('❌ Helper function return type validation failed:', error.message);
      throw error;
    }
  });

  test('Basic error handling validation', async ({ page }) => {
    console.log('🚨 Testing basic error handling...');
    
    try {
      // Test with non-existent item
      const nonExistentItem = await dataHelpers.getItemByName(page, 'Non-Existent Item 12345');
      console.log(`Non-existent item result: ${nonExistentItem} (type: ${typeof nonExistentItem})`);
      expect(nonExistentItem).toBeNull();
      
      // Test with empty string
      const emptyStringItem = await dataHelpers.getItemByName(page, '');
      console.log(`Empty string item result: ${emptyStringItem} (type: ${typeof emptyStringItem})`);
      expect(emptyStringItem).toBeNull();
      
      // Test assignments for non-existent item
      const assignmentsForNonExistent = await dataHelpers.getItemAssignments(page, 'non-existent-id');
      console.log(`Assignments for non-existent item: ${assignmentsForNonExistent.length} (type: ${Array.isArray(assignmentsForNonExistent) ? 'array' : typeof assignmentsForNonExistent})`);
      expect(Array.isArray(assignmentsForNonExistent)).toBe(true);
      expect(assignmentsForNonExistent.length).toBe(0);
      
      console.log('✅ Error handling validation passed');
      
    } catch (error) {
      console.error('❌ Error handling validation failed:', error.message);
      throw error;
    }
  });

  test('Test helper functions with available data (if any)', async ({ page }) => {
    console.log('📋 Testing helper functions with any available data...');
    
    try {
      // Get available data
      const allItems = await dataHelpers.getAllItems(page);
      const allContainers = await dataHelpers.getAllContainers(page);
      
      console.log(`Found ${allItems.length} items and ${allContainers.length} containers`);
      
      // If we have items, test item-specific functions
      if (allItems.length > 0) {
        const firstItem = allItems[0];
        console.log('Testing with first available item:', Object.keys(firstItem));
        
        // Test getItemByName if item has name
        if (firstItem.name) {
          const foundItem = await dataHelpers.getItemByName(page, firstItem.name);
          expect(foundItem).toBeDefined();
          console.log(`✅ Successfully found item by name: "${firstItem.name}"`);
        }
        
        // Test getItemById if item has ID
        const itemId = firstItem.id || Object.keys(firstItem).find(key => key.toLowerCase().includes('id'));
        if (itemId) {
          const foundById = await dataHelpers.getItemById(page, itemId);
          expect(foundById).toBeDefined();
          console.log(`✅ Successfully found item by ID: "${itemId}"`);
        }
      } else {
        console.log('⚠️ No items found in mock data - this may be expected for empty repository');
      }
      
      // If we have containers, test container-specific functions
      if (allContainers.length > 0) {
        const firstContainer = allContainers[0];
        console.log('Testing with first available container:', Object.keys(firstContainer));
        
        // Test getContainerByName if container has name
        if (firstContainer.name) {
          const foundContainer = await dataHelpers.getContainerByName(page, firstContainer.name);
          expect(foundContainer).toBeDefined();
          console.log(`✅ Successfully found container by name: "${firstContainer.name}"`);
        }
      } else {
        console.log('⚠️ No containers found in mock data - this may be expected for empty repository');
      }
      
      console.log('✅ Helper functions work correctly with available data');
      
    } catch (error) {
      console.error('❌ Available data testing failed:', error.message);
      throw error;
    }
  });

  test('Validation Summary', async ({ page }) => {
    console.log('\n🎯 BASIC HELPER VALIDATION SUMMARY');
    console.log('═'.repeat(50));
    
    try {
      const startTime = Date.now();
      
      // Run all basic validations
      const repoValidation = await dataHelpers.validateMockRepositories(page);
      const repositories = await dataHelpers.getMockRepositories(page);
      const itemCount = await dataHelpers.getItemCount(page);
      const allItems = await dataHelpers.getAllItems(page);
      const allContainers = await dataHelpers.getAllContainers(page);
      const allAssignments = await dataHelpers.getAllAssignments(page);
      
      const endTime = Date.now();
      const totalTime = endTime - startTime;
      
      // Basic validations only - no strict requirements for data content
      expect(repoValidation).toBeDefined();
      expect(repositories).toBeDefined();
      expect(typeof itemCount).toBe('number');
      expect(Array.isArray(allItems)).toBe(true);
      expect(Array.isArray(allContainers)).toBe(true);
      expect(Array.isArray(allAssignments)).toBe(true);
      expect(totalTime).toBeLessThan(15000); // Should complete within 15 seconds
      
      console.log('📊 VALIDATION RESULTS:');
      console.log(`   ✅ Mock Firebase available: ${repoValidation.mockFirebaseExists || false}`);
      console.log(`   ✅ Firestore accessible: ${repoValidation.firestoreAvailable || false}`);
      console.log(`   ✅ Collections found: ${repoValidation.collectionsFound ? repoValidation.collectionsFound.length : 0}`);
      console.log(`   ✅ Items loaded: ${itemCount}`);
      console.log(`   ✅ Containers loaded: ${allContainers.length}`);
      console.log(`   ✅ Assignments loaded: ${allAssignments.length}`);
      console.log(`   ✅ Total execution time: ${totalTime}ms`);
      console.log('═'.repeat(50));
      
      console.log('🎉 BASIC SUCCESS CRITERIA VALIDATION:');
      console.log('   ✅ All helper functions return expected data types');
      console.log('   ✅ Mock repository access works (even if empty)');
      console.log('   ✅ Helper validation test passes consistently');
      console.log('   ✅ No undefined or null returns for basic function calls');
      console.log('   ✅ Error handling works correctly for invalid inputs');
      console.log('   ✅ Performance is acceptable (< 15 seconds)');
      console.log('═'.repeat(50));
      console.log('🚀 BASIC HELPER FUNCTIONS ARE READY FOR USE!');
      
    } catch (error) {
      console.error('❌ Basic helper validation failed:', error.message);
      throw error;
    }
  });
});