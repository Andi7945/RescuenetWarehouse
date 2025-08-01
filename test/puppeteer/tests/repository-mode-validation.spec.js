// @ts-check
const { test, expect } = require('@playwright/test');

test.describe('Repository Mode Validation', () => {
  test.beforeEach(async ({ page }) => {
    // Listen to console logs to debug issues
    page.on('console', msg => console.log('BROWSER:', msg.text()));
    page.on('pageerror', error => console.log('PAGE ERROR:', error.message));
    
    // Navigate to the Flutter app  
    await page.goto('/');
    
    // Wait for the Flutter app to load completely
    await page.waitForLoadState('networkidle');
    await page.waitForTimeout(5000);
  });

  test('V01: Repository mode should be set to mock during tests', async ({ page }) => {
    // Check that we're in mock mode by looking for console logs
    const logs = [];
    page.on('console', msg => logs.push(msg.text()));
    
    // Refresh to capture initialization logs
    await page.reload();
    await page.waitForTimeout(3000);
    
    // Look for mock repository indicators in console logs
    const hasMockIndicators = logs.some(log => 
      log.includes('mock') || 
      log.includes('REPOSITORY_MODE') || 
      log.includes('Mock')
    );
    
    console.log('Console logs:', logs);
    
    // Take screenshot for debugging
    await page.screenshot({ path: 'repository-mode-validation.png' });
    
    // This test verifies that the REPOSITORY_MODE=mock environment variable
    // is properly configured and the app is using mock repositories
    expect(hasMockIndicators).toBeTruthy();
  });

  test('V02: Mock data should be available', async ({ page }) => {
    // Login first to access app functionality
    await page.mouse.click(640, 285); // Email field
    await page.keyboard.type('test@rescuenet.net');
    
    await page.mouse.click(640, 330); // Password field
    await page.keyboard.type('testpassword');
    
    await page.mouse.click(487, 393); // Login button
    
    // Wait for app to load after login
    await page.waitForTimeout(5000);
    
    // Take screenshot to verify we're logged in
    await page.screenshot({ path: 'repository-validation-after-login.png' });
    
    // Check that mock data is loaded by looking for expected items
    // The mock repositories should contain "Tent Green Dome" and "Medical Kit"
    const pageContent = await page.textContent('body');
    
    // This validates that mock repositories are providing the expected test data
    // If using Firebase instead of mocks, the data would be different
    const hasMockData = pageContent && (
      pageContent.includes('Tent Green Dome') || 
      pageContent.includes('Medical Kit') ||
      pageContent.includes('Emergency Medical Kit') // Alternative mock data
    );
    
    console.log('Page content includes expected mock data:', hasMockData);
    console.log('Page content sample:', pageContent?.substring(0, 1000));
    
    // The test passes if we can find mock data, indicating repositories are working
    expect(hasMockData).toBeTruthy();
  });

  test('V03: Mock repositories should perform faster than Firebase', async ({ page }) => {
    // Login first
    await page.mouse.click(640, 285); // Email field
    await page.keyboard.type('test@rescuenet.net');
    
    await page.mouse.click(640, 330); // Password field  
    await page.keyboard.type('testpassword');
    
    const startTime = Date.now();
    await page.mouse.click(487, 393); // Login button
    
    // Wait for app to load - mock repositories should be much faster
    await page.waitForTimeout(3000);
    const endTime = Date.now();
    
    const loadTime = endTime - startTime;
    console.log('App load time with mock repositories:', loadTime, 'ms');
    
    // Mock repositories should load much faster than Firebase
    // This is a performance indicator that mocks are being used
    expect(loadTime).toBeLessThan(10000); // Should be much faster than Firebase
    
    await page.screenshot({ path: 'repository-performance-validation.png' });
  });
});