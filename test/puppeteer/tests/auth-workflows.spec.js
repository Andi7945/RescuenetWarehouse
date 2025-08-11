// @ts-check
const { test, expect } = require('@playwright/test');
const coordinateHelper = require('../helpers/coordinateHelper');
const authHelpers = require('../helpers/authHelpers');
const loadingHelpers = require('../helpers/loadingHelpers');
const visualValidation = require('../helpers/visualValidation');

test.describe('Authentication Workflows - Core Scenarios', () => {
  let sharedPage;

  test.beforeAll(async ({ browser }) => {
    // Create shared browser context for efficiency
    const context = await browser.newContext();
    sharedPage = await context.newPage();

    // Initial app load and Flutter initialization
    await sharedPage.goto('/');
    await sharedPage.waitForLoadState('networkidle');

    // Progressive loading verification
    for (let i = 1; i <= 8; i++) {
      await sharedPage.waitForTimeout(1000);
      const content = await sharedPage.textContent('body');
      const isLoaded = content.includes('flutter-view') && content.length > 500;
      if (isLoaded) break;
    }
  });

  test.beforeEach(async ({ page }) => {
    // Refresh page state for each test with enhanced loading handling
    await page.goto('/');
    await page.waitForLoadState('networkidle');
    
    // Wait for Flutter app to be ready with loading state awareness
    await visualValidation.waitForFlutterReady(page, 30000, {
      waitForLoadingComplete: true,
      checkInteractionReady: true
    });
    
    console.log('✓ Test setup complete - page ready for authentication test');
  });

  test('1. Valid login creates authenticated session', async ({ page }) => {
    const testEmail = 'backoffice.test@rescuenet.net';
    const testPassword = 'testpassword';

    // Enable console logging
    page.on('console', msg => {
      console.log(`[PAGE LOG ${msg.type()}]:`, msg.text());
    });

    // Check initial state
    console.log('=== CHECKING INITIAL MOCK FIREBASE STATE ===');
    const initialAuth = await authHelpers.getAuthenticationState(page);
    console.log('Initial auth state:', initialAuth);

    // Login credentials with loading awareness
    console.log('=== TYPING LOGIN CREDENTIALS ===');
    await coordinateHelper.typeInField(page, 'login', 'emailField', testEmail, {
      operationType: 'quick',
      expectLoading: false
    });
    await coordinateHelper.typeInField(page, 'login', 'passwordField', testPassword, {
      operationType: 'quick',
      expectLoading: false
    });

    // Submit login with loading handling
    console.log('=== CLICKING LOGIN BUTTON ===');
    const loginClickResult = await coordinateHelper.clickElementWithLoadingWait(page, 'login', 'loginButton', {
      operationType: 'medium',
      expectLoading: true,
      maxLoadingTime: 10000
    });
    
    expect(loginClickResult.clickSuccess).toBe(true);
    console.log('✓ Login click completed with loading handling');
    
    console.log('=== CHECKING FINAL AUTH STATE ===');

    // Check if auth methods were called
    const authCalls = await page.evaluate(() => {
      if (window.mockFirebase && window.mockFirebase.auth().getAuthCalls) {
        return window.mockFirebase.auth().getAuthCalls();
      }
      return [];
    });
    console.log('Auth calls made:', authCalls);

    // Validate authentication session
    const sessionValidation = await authHelpers.validateUserSession(page, testEmail);
    expect(sessionValidation.isValid).toBe(true);
    expect(sessionValidation.authState.hasCurrentUser).toBe(true);
    expect(sessionValidation.authState.userEmail).toBe(testEmail);
    expect(sessionValidation.authState.userId).toMatch(/^(mock-user-|test_user_)/);

    // Validate app access
    const appAccess = await authHelpers.validateAppAccess(page);
    expect(appAccess.isValid).toBe(true);
    expect(appAccess.accessValidation.authSessionExists).toBe(true);
  });

  test('2. Invalid credentials are rejected', async ({ page }) => {
    const testEmail = 'test@rescuenet.net';
    const wrongPassword = 'wrongpassword';

    // Invalid login attempt with loading handling
    await coordinateHelper.typeInField(page, 'login', 'emailField', testEmail, {
      operationType: 'quick',
      expectLoading: false
    });
    await coordinateHelper.typeInField(page, 'login', 'passwordField', wrongPassword, {
      operationType: 'quick',
      expectLoading: false
    });
    
    // Click login and wait for loading (even failed auth may show loading)
    const loginClickResult = await coordinateHelper.clickElementWithLoadingWait(page, 'login', 'loginButton', {
      operationType: 'medium',
      expectLoading: false, // Failed auth may not show loading or show very briefly
      maxLoadingTime: 5000
    });
    
    expect(loginClickResult.clickSuccess).toBe(true);
    
    // Wait for any error states or transitions to complete
    await loadingHelpers.smartWaitForLoadingComplete(page, {
      timeout: 3000,
      maxRetries: 2
    });

    // Verify authentication failed
    const noAuthValidation = await authHelpers.validateNoAuthentication(page);
    expect(noAuthValidation.isValid).toBe(true);
    expect(noAuthValidation.authState.hasCurrentUser).toBe(false);
    expect(noAuthValidation.authState.userEmail).toBeNull();

    // Verify still on auth page
    const authPageValidation = await authHelpers.validateStillOnAuthPage(page);
    expect(authPageValidation.isValid).toBe(true);
    expect(authPageValidation.pageValidation.hasEmailField).toBe(true);
  });

  test('3. User registration with email validation', async ({ page }) => {
    // Switch to registration mode with loading handling
    const registerClickResult = await coordinateHelper.clickElementWithLoadingWait(page, 'login', 'registerInsteadButton', {
      offsetX: 117, 
      offsetY: 0,
      operationType: 'quick',
      expectLoading: false,
      maxLoadingTime: 2000
    });
    expect(registerClickResult.clickSuccess).toBe(true);

    // Valid registration with loading awareness
    const testEmail = `test-${Date.now()}@rescuenet.net`;
    const testPassword = 'TestPassword123!';

    await coordinateHelper.typeInField(page, 'login', 'emailField', testEmail, {
      operationType: 'quick',
      expectLoading: false
    });
    await coordinateHelper.typeInField(page, 'login', 'passwordField', testPassword, {
      operationType: 'quick',
      expectLoading: false
    });
    
    // Submit registration with loading handling
    const registrationResult = await coordinateHelper.clickElementWithLoadingWait(page, 'login', 'loginButton', {
      operationType: 'medium',
      expectLoading: true,
      maxLoadingTime: 8000
    });
    expect(registrationResult.clickSuccess).toBe(true);

    // Verify successful registration and session creation
    const sessionValidation = await authHelpers.validateUserSession(page, testEmail);
    expect(sessionValidation.isValid).toBe(true);
    expect(sessionValidation.authState.hasCurrentUser).toBe(true);
    expect(sessionValidation.authState.userEmail).toBe(testEmail);

    // Verify app access granted
    const appAccess = await authHelpers.validateAppAccess(page);
    expect(appAccess.isValid).toBe(true);
    expect(appAccess.accessValidation.navigationElementsVisible).toBe(true);
  });

  test('4. Invalid email domain registration fails', async ({ page }) => {
    // Switch to registration mode with loading handling
    const registerClickResult = await coordinateHelper.clickElementWithLoadingWait(page, 'login', 'registerInsteadButton', {
      offsetX: 117, 
      offsetY: 0,
      operationType: 'quick',
      expectLoading: false,
      maxLoadingTime: 2000
    });
    expect(registerClickResult.clickSuccess).toBe(true);

    // Invalid email domain with loading awareness
    await coordinateHelper.typeInField(page, 'login', 'emailField', 'test@gmail.com', {
      operationType: 'quick',
      expectLoading: false
    });
    await coordinateHelper.typeInField(page, 'login', 'passwordField', 'TestPassword123!', {
      operationType: 'quick',
      expectLoading: false
    });
    
    // Submit invalid registration (may briefly show loading)
    const invalidRegResult = await coordinateHelper.clickElementWithLoadingWait(page, 'login', 'loginButton', {
      operationType: 'medium',
      expectLoading: false, // Invalid operations may not show loading or show very briefly
      maxLoadingTime: 5000
    });
    expect(invalidRegResult.clickSuccess).toBe(true);
    
    // Wait for any error handling to complete
    await loadingHelpers.smartWaitForLoadingComplete(page, {
      timeout: 3000
    });

    // Verify registration rejected
    const noAuthValidation = await authHelpers.validateNoAuthentication(page);
    expect(noAuthValidation.isValid).toBe(true);
    expect(noAuthValidation.authState.hasCurrentUser).toBe(false);

    // Verify still on auth page
    const authPageValidation = await authHelpers.validateStillOnAuthPage(page);
    expect(authPageValidation.isValid).toBe(true);
  });

  test('5. Role-based access control - Packer role', async ({ page }) => {
    const packerEmail = 'packer@rescuenet.net';
    const packerPassword = 'packerpass123';

    // Login as Packer with loading handling
    await coordinateHelper.typeInField(page, 'login', 'emailField', packerEmail, {
      operationType: 'quick',
      expectLoading: false
    });
    await coordinateHelper.typeInField(page, 'login', 'passwordField', packerPassword, {
      operationType: 'quick',
      expectLoading: false
    });
    
    const packerLoginResult = await coordinateHelper.clickElementWithLoadingWait(page, 'login', 'loginButton', {
      operationType: 'medium',
      expectLoading: true,
      maxLoadingTime: 8000
    });
    expect(packerLoginResult.clickSuccess).toBe(true);

    // Validate Packer role authentication
    const packerRoleValidation = await authHelpers.validateRoleBasedAuth(page, 'Packer', packerEmail);
    expect(packerRoleValidation.isValid).toBe(true);
    expect(packerRoleValidation.sessionValidation.authState.hasCurrentUser).toBe(true);
    expect(packerRoleValidation.sessionValidation.authState.userEmail).toBe(packerEmail);

    // Verify app access for Packer role
    const appAccess = await authHelpers.validateAppAccess(page);
    expect(appAccess.isValid).toBe(true);
    expect(appAccess.accessValidation.authSessionExists).toBe(true);
  });

  test('6. Logistics role - Combined permissions validation', async ({ page }) => {
    const logisticsEmail = 'logistics@rescuenet.net';
    const logisticsPassword = 'logisticspass123';

    // Login as Logistics with loading handling
    await coordinateHelper.typeInField(page, 'login', 'emailField', logisticsEmail, {
      operationType: 'quick',
      expectLoading: false
    });
    await coordinateHelper.typeInField(page, 'login', 'passwordField', logisticsPassword, {
      operationType: 'quick',
      expectLoading: false
    });
    
    const logisticsLoginResult = await coordinateHelper.clickElementWithLoadingWait(page, 'login', 'loginButton', {
      operationType: 'medium',
      expectLoading: true,
      maxLoadingTime: 8000
    });
    expect(logisticsLoginResult.clickSuccess).toBe(true);

    // Validate Logistics role authentication
    const logisticsRoleValidation = await authHelpers.validateRoleBasedAuth(page, 'Logistics', logisticsEmail);
    expect(logisticsRoleValidation.isValid).toBe(true);
    expect(logisticsRoleValidation.sessionValidation.authState.hasCurrentUser).toBe(true);
    expect(logisticsRoleValidation.sessionValidation.authState.userEmail).toBe(logisticsEmail);

    // Verify full app access (combined permissions)
    const appAccess = await authHelpers.validateAppAccess(page);
    expect(appAccess.isValid).toBe(true);
    expect(appAccess.accessValidation.authSessionExists).toBe(true);
    expect(appAccess.accessValidation.navigationElementsVisible).toBe(true);
  });

  test.afterAll(async () => {
    if (sharedPage) {
      await sharedPage.close();
    }
  });
});
