// Quick diagnostic script to understand auth test failures
const { test, expect } = require('@playwright/test');

test('Diagnostic: Check mock Firebase and Flutter app loading', async ({ page }) => {
  console.log('🔍 DIAGNOSTIC: Starting Flutter and mock Firebase investigation');
  
  // Navigate and wait
  await page.goto('/');
  await page.waitForLoadState('networkidle');
  
  // Wait progressively like the auth tests
  for (let i = 1; i <= 5; i++) {
    await page.waitForTimeout(1000);
    
    const content = await page.textContent('body');
    console.log(`Step ${i}: Body content length: ${content.length}`);
    console.log(`Step ${i}: Contains flutter-view: ${content.includes('flutter-view')}`);
    console.log(`Step ${i}: Contains accessibility: ${content.includes('Enable accessibility')}`);
    
    if (i === 1) {
      console.log(`Step ${i}: Body preview: ${content.substring(0, 200)}...`);
    }
    
    const isFlutterLoaded = content.includes('flutter-view') && content.length > 500;
    const isStuckOnLoading = content.includes('Enable accessibility') && content.length < 100;
    
    if (isFlutterLoaded && !isStuckOnLoading) {
      console.log(`✅ Flutter app loaded successfully at step ${i}`);
      break;
    }
    
    if (i === 5) {
      console.log('⚠️ Flutter app may still be loading after 5 seconds');
    }
  }
  
  await page.screenshot({ path: 'diagnostic-flutter-loading.png' });
  
  // Check mock Firebase status
  const mockStatus = await page.evaluate(() => {
    return {
      mockModeEnabled: window.MOCK_FIREBASE_MODE,
      mockFirebaseExists: !!window.mockFirebase,
      mockAuthExists: !!window.mockFirebase?.auth,
      userAgent: navigator.userAgent,
      location: window.location.href,
      
      // Try to get an auth instance
      authInstance: (() => {
        try {
          const auth = window.mockFirebase?.auth();
          return {
            exists: !!auth,
            hasCurrentUser: !!auth?.currentUser,
            canSignIn: typeof auth?.signInWithEmailAndPassword === 'function'
          };
        } catch (e) {
          return { error: e.message };
        }
      })()
    };
  });
  
  console.log('🔍 Mock Firebase Status:', JSON.stringify(mockStatus, null, 2));
  
  // Check if we can see login elements
  const loginElements = await page.evaluate(() => {
    const body = document.body.textContent || '';
    return {
      hasEmail: body.includes('Email'),
      hasPassword: body.includes('Password'),
      hasLogin: body.includes('Login'),
      bodyPreview: body.substring(0, 500)
    };
  });
  
  console.log('🔍 Login Elements:', JSON.stringify(loginElements, null, 2));
  
  // Try to find email field using the coordinate helper method
  const emailFieldExists = await page.evaluate(() => {
    // Check if element exists at login email coordinates
    const element = document.elementFromPoint(640, 285);
    return {
      elementExists: !!element,
      elementTag: element?.tagName,
      elementType: element?.type,
      elementPlaceholder: element?.placeholder
    };
  });
  
  console.log('🔍 Email Field at (640, 285):', JSON.stringify(emailFieldExists, null, 2));
  
  // Basic assertion - the diagnostic should be able to run
  expect(mockStatus.mockModeEnabled).toBe(true);
  expect(mockStatus.mockFirebaseExists).toBe(true);
  
  console.log('✅ Diagnostic completed');
});