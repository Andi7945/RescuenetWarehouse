// @ts-check
const { test, expect } = require('@playwright/test');

test.describe('Diagnostic Loading Tests', () => {
  test('D01: Basic Page Load Verification', async ({ page }) => {
    // Navigate to the Flutter app
    await page.goto('/');
    
    // Take immediate screenshot
    await page.screenshot({ path: 'diagnostic-immediate.png' });
    
    // Wait for network idle
    await page.waitForLoadState('networkidle');
    await page.screenshot({ path: 'diagnostic-network-idle.png' });
    
    // Check what we have
    const pageContent = await page.textContent('body');
    console.log(`Page content length: ${pageContent.length}`);
    console.log(`Page content preview: ${pageContent.substring(0, 200)}`);
    
    // Check for accessibility button (sign of stuck loading)
    const hasAccessibilityButton = pageContent.includes('Enable accessibility');
    console.log(`Has accessibility button: ${hasAccessibilityButton}`);
    
    // Check for Flutter elements
    const flutterElements = await page.locator('flutter-view').count();
    const canvasElements = await page.locator('canvas').count();
    console.log(`Flutter views: ${flutterElements}, Canvas elements: ${canvasElements}`);
    
    // Basic assertion: page should load something
    expect(pageContent.length).toBeGreaterThan(10);
  });

  test('D02: Mock Firebase Detection Test', async ({ page }) => {
    // Navigate to the Flutter app
    await page.goto('/');
    await page.waitForLoadState('networkidle');
    await page.waitForTimeout(2000);
    
    // Check mock Firebase status
    const mockStatus = await page.evaluate(() => {
      return {
        mockModeEnabled: window.MOCK_FIREBASE_MODE,
        mockFirebaseExists: !!window.mockFirebase,
        mockAuthExists: !!window.mockFirebase?.auth,
        mockFirestoreExists: !!window.mockFirebase?.firestore,
        userAgent: navigator.userAgent,
        hostname: window.location.hostname,
        searchParams: window.location.search
      };
    });
    
    console.log('Mock Firebase Status:', JSON.stringify(mockStatus, null, 2));
    
    await page.screenshot({ path: 'diagnostic-mock-status.png' });
    
    // Verify mock Firebase is working
    expect(mockStatus.mockModeEnabled).toBe(true);
    expect(mockStatus.mockFirebaseExists).toBe(true);
  });

  test('D03: Flutter App State Detection', async ({ page }) => {
    // Navigate and wait
    await page.goto('/');
    await page.waitForLoadState('networkidle');
    
    // Wait for Flutter to potentially initialize
    await page.waitForTimeout(5000);
    
    // Check Flutter app state
    const flutterState = await page.evaluate(() => {
      return {
        flutterViewCount: document.querySelectorAll('flutter-view').length,
        canvasCount: document.querySelectorAll('canvas').length,
        hasFlutterBootstrap: !!window.flutter,
        hasFlutterApp: !!window.flutter?.app,
        documentReadyState: document.readyState,
        bodyClassList: document.body.className,
        bodyChildren: document.body.children.length
      };
    });
    
    console.log('Flutter State:', JSON.stringify(flutterState, null, 2));
    
    await page.screenshot({ path: 'diagnostic-flutter-state.png' });
    
    // At minimum, Flutter should create some elements
    expect(flutterState.flutterViewCount + flutterState.canvasCount).toBeGreaterThan(0);
  });

  test('D04: Progressive Loading Test', async ({ page }) => {
    // Monitor console logs
    page.on('console', msg => console.log('BROWSER:', msg.text()));
    page.on('pageerror', error => console.log('PAGE ERROR:', error.message));
    
    await page.goto('/');
    await page.screenshot({ path: 'diagnostic-step1-goto.png' });
    
    await page.waitForLoadState('networkidle');
    await page.screenshot({ path: 'diagnostic-step2-networkidle.png' });
    
    // Wait progressively and check state
    for (let i = 1; i <= 10; i++) {
      await page.waitForTimeout(1000);
      
      const content = await page.textContent('body');
      const isStuck = content.includes('Enable accessibility') && content.length < 50;
      
      console.log(`Step ${i}: Content length=${content.length}, Stuck=${isStuck}`);
      
      if (!isStuck) {
        await page.screenshot({ path: `diagnostic-step${i+2}-progress.png` });
        console.log(`App loaded at step ${i}`);
        break;
      }
      
      if (i === 10) {
        await page.screenshot({ path: 'diagnostic-step12-final-stuck.png' });
        throw new Error('App appears stuck in loading state');
      }
    }
  });

  test('D05: Login Process Test', async ({ page }) => {
    // Monitor console
    page.on('console', msg => console.log('BROWSER:', msg.text()));
    page.on('pageerror', error => console.log('PAGE ERROR:', error.message));
    
    await page.goto('/');
    await page.waitForLoadState('networkidle');
    await page.waitForTimeout(5000);
    
    await page.screenshot({ path: 'diagnostic-before-login.png' });
    
    const contentBefore = await page.textContent('body');
    console.log(`Content before login: length=${contentBefore.length}`);
    
    // If we're stuck on accessibility screen, we can't proceed
    if (contentBefore.includes('Enable accessibility') && contentBefore.length < 100) {
      console.log('STUCK: App is showing only accessibility button');
      await page.screenshot({ path: 'diagnostic-stuck-accessibility.png' });
      
      // Try to force refresh
      await page.reload();
      await page.waitForLoadState('networkidle');
      await page.waitForTimeout(3000);
      
      const contentAfterReload = await page.textContent('body');
      console.log(`Content after reload: length=${contentAfterReload.length}`);
      await page.screenshot({ path: 'diagnostic-after-reload.png' });
      
      // Basic assertion that reload at least loads the page
      expect(contentAfterReload.length).toBeGreaterThan(10);
      return;
    }
    
    // Try login if app seems loaded
    try {
      await page.mouse.click(640, 285); // Email field
      await page.keyboard.type('test@rescuenet.net');
      
      await page.mouse.click(640, 330); // Password field  
      await page.keyboard.type('testpassword');
      
      await page.mouse.click(487, 393); // Login button
      
      await page.waitForTimeout(5000);
      await page.screenshot({ path: 'diagnostic-after-login.png' });
      
      const contentAfter = await page.textContent('body');
      console.log(`Content after login: length=${contentAfter.length}`);
      
      // Login should change page content
      expect(contentAfter).not.toBe(contentBefore);
    } catch (error) {
      console.log('Login failed:', error.message);
      await page.screenshot({ path: 'diagnostic-login-failed.png' });
      throw error;
    }
  });
});