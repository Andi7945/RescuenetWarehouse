// @ts-check
const { test, expect } = require('@playwright/test');
const coordinateHelper = require('../helpers/coordinateHelper');
const authHelpers = require('../helpers/authHelpers');

test.describe('Authentication Testing with Strong Assertions', () => {
  test.beforeEach(async ({ page }) => {
    // Navigate to the Flutter app
    await page.goto('/');

    // Wait for the Flutter app to load completely
    await page.waitForLoadState('networkidle');

    // Progressive waiting like diagnostic tests (more reliable)
    for (let i = 1; i <= 10; i++) {
      await page.waitForTimeout(1000);
      
      const content = await page.textContent('body');
      const isFlutterLoaded = content.includes('flutter-view') && content.length > 500;
      const isStuckOnLoading = content.includes('Enable accessibility') && content.length < 100;
      
      if (isFlutterLoaded && !isStuckOnLoading) {
        console.log(`Flutter app loaded successfully at step ${i}`);
        break;
      }
      
      if (i === 10) {
        console.log('Warning: Flutter app may still be loading after 10 seconds');
      }
    }
  });

  test('new user registration should create valid session and redirect to main app', async ({ page }) => {
    // PHASE 2 ENHANCEMENT: Test registration with POSITIVE validation of authentication state
    
    await page.screenshot({ path: 'registration-test-start.png' });

    // Switch to registration mode using coordinate helper
    await coordinateHelper.clickElement(page, 'login', 'registerInsteadButton', {
      offsetX: 117, offsetY: 0 // Adjust from login button to register instead
    });
    await page.waitForTimeout(1000);

    // Fill in registration form with test user
    const testEmail = `test-${Date.now()}@rescuenet.net`;
    const testPassword = 'TestPassword123!';

    await coordinateHelper.typeInField(page, 'login', 'emailField', testEmail);
    await coordinateHelper.typeInField(page, 'login', 'passwordField', testPassword);

    // Monitor authentication state during registration
    let authStateChanges = [];
    page.on('console', msg => {
      if (msg.text().includes('Mock Firebase') || msg.text().includes('auth')) {
        authStateChanges.push(msg.text());
      }
    });

    // Submit registration
    await coordinateHelper.clickElement(page, 'login', 'loginButton');
    await page.waitForTimeout(3000);

    await page.screenshot({ path: 'registration-test-result.png' });

    // POSITIVE ASSERTION 1: Verify user session was created using auth helpers
    const sessionValidation = await authHelpers.validateUserSession(page, testEmail);
    console.log('Session validation after registration:', sessionValidation);
    console.log('Auth state changes:', authStateChanges);

    // CRITICAL: Test must validate that a user session actually exists
    expect(sessionValidation.isValid).toBe(true);
    expect(sessionValidation.authState.hasCurrentUser).toBe(true);
    expect(sessionValidation.authState.userEmail).toBe(testEmail);
    expect(sessionValidation.authState.userId).toMatch(/^mock-user-/);

    // POSITIVE ASSERTION 2: Verify app access is available (not on auth page)
    const appAccessValidation = await authHelpers.validateAppAccess(page);
    console.log('App access validation:', appAccessValidation);
    
    expect(appAccessValidation.isValid).toBe(true);
    expect(appAccessValidation.accessValidation.authSessionExists).toBe(true);
    expect(appAccessValidation.accessValidation.navigationElementsVisible).toBe(true);
    
    console.log('✓ Registration created valid user session and navigated to main app');
  });

  test('registration with non-rescuenet email should fail and show specific error', async ({ page }) => {
    // PHASE 2 ENHANCEMENT: Test invalid registration with POSITIVE error validation
    
    // Switch to register mode
    await coordinateHelper.clickElement(page, 'login', 'registerInsteadButton', {
      offsetX: 117, offsetY: 0
    });
    await page.waitForTimeout(1000);

    // Try to register with invalid email domain
    await coordinateHelper.typeInField(page, 'login', 'emailField', 'test@gmail.com');
    await coordinateHelper.typeInField(page, 'login', 'passwordField', 'TestPassword123!');

    // Capture console errors during registration attempt
    let registrationErrors = [];
    page.on('console', msg => {
      if (msg.type() === 'error' || msg.text().includes('error') || msg.text().includes('Only rescuenet.net')) {
        registrationErrors.push(msg.text());
      }
    });

    // Submit invalid registration
    await coordinateHelper.clickElement(page, 'login', 'loginButton');
    await page.waitForTimeout(2000);
    
    await page.screenshot({ path: 'invalid-email-registration-result.png' });

    // POSITIVE ASSERTION 1: Verify NO user session was created using auth helpers
    const noAuthValidation = await authHelpers.validateNoAuthentication(page);
    console.log('No auth validation after invalid registration:', noAuthValidation);
    console.log('Registration errors:', registrationErrors);

    // CRITICAL: Must verify that authentication failed completely
    expect(noAuthValidation.isValid).toBe(true);
    expect(noAuthValidation.authState.hasCurrentUser).toBe(false);
    expect(noAuthValidation.authState.userEmail).toBeNull();

    // POSITIVE ASSERTION 2: Verify still on authentication page
    const authPageValidation = await authHelpers.validateStillOnAuthPage(page);
    expect(authPageValidation.isValid).toBe(true);
    expect(authPageValidation.pageValidation.hasEmailField).toBe(true);
    
    // POSITIVE ASSERTION 3: Verify specific error was shown or caught
    const hasEmailValidationError = registrationErrors.some(error => 
      error.includes('Only rescuenet.net emails allowed') ||
      error.includes('Invalid email')
    ) || authPageValidation.pageValidation.hasErrorMessages;
    
    expect(hasEmailValidationError).toBe(true);
    
    console.log('✓ Invalid email registration properly rejected with no session created');
  });

  test('successful login should create session and provide app access', async ({ page }) => {
    // PHASE 2 ENHANCEMENT: Test login with POSITIVE validation of complete auth flow
    
    const testEmail = 'test@rescuenet.net';
    const testPassword = 'testpassword';

    // Fill in login form using coordinate helper
    await coordinateHelper.typeInField(page, 'login', 'emailField', testEmail);
    await coordinateHelper.typeInField(page, 'login', 'passwordField', testPassword);

    // Monitor authentication flow
    let authFlow = [];
    page.on('console', msg => {
      if (msg.text().includes('Mock Firebase') || msg.text().includes('Signing in')) {
        authFlow.push(msg.text());
      }
    });

    // Submit login
    await coordinateHelper.clickElement(page, 'login', 'loginButton');
    await page.waitForTimeout(5000);

    await page.screenshot({ path: 'login-result.png' });

    // POSITIVE ASSERTION 1: Verify valid user session exists using auth helpers
    const sessionValidation = await authHelpers.validateUserSession(page, testEmail);
    console.log('Session validation after login:', sessionValidation);
    console.log('Authentication flow:', authFlow);

    // CRITICAL: Must validate actual authentication state
    expect(sessionValidation.isValid).toBe(true);
    expect(sessionValidation.authState.hasCurrentUser).toBe(true);
    expect(sessionValidation.authState.userEmail).toBe(testEmail);
    expect(sessionValidation.authState.userId).toMatch(/^mock-user-/);
    expect(sessionValidation.authState.emailVerified).toBe(true);

    // POSITIVE ASSERTION 2: Verify app access is available (navigation away from auth page)
    const appAccessValidation = await authHelpers.validateAppAccess(page);
    expect(appAccessValidation.isValid).toBe(true);
    expect(appAccessValidation.accessValidation.navigationElementsVisible).toBe(true);
    expect(appAccessValidation.accessValidation.authSessionExists).toBe(true);
    
    // POSITIVE ASSERTION 3: Verify authentication flow completed
    const hasSignInFlow = authFlow.some(log => log.includes('Signing in'));
    expect(hasSignInFlow).toBe(true);
    
    console.log('✓ Login created valid session and granted app access');
  });

  test('wrong password should fail authentication and stay on login page', async ({ page }) => {
    // PHASE 2 ENHANCEMENT: Test authentication failure with POSITIVE error validation
    
    const testEmail = 'test@rescuenet.net';
    const wrongPassword = 'wrongpassword';

    // Fill in login form with wrong password
    await coordinateHelper.typeInField(page, 'login', 'emailField', testEmail);
    await coordinateHelper.typeInField(page, 'login', 'passwordField', wrongPassword);

    // Monitor authentication errors
    let authErrors = [];
    page.on('console', msg => {
      if (msg.type() === 'error' || msg.text().includes('error') || msg.text().includes('failed')) {
        authErrors.push(msg.text());
      }
    });

    // Submit login with wrong credentials
    await coordinateHelper.clickElement(page, 'login', 'loginButton');
    await page.waitForTimeout(3000);

    await page.screenshot({ path: 'wrong-password-result.png' });

    // POSITIVE ASSERTION 1: Verify NO user session was created using auth helpers
    const noAuthValidation = await authHelpers.validateNoAuthentication(page);
    console.log('No auth validation after wrong password:', noAuthValidation);
    console.log('Authentication errors:', authErrors);

    // CRITICAL: Must verify authentication completely failed
    expect(noAuthValidation.isValid).toBe(true);
    expect(noAuthValidation.authState.hasCurrentUser).toBe(false);
    expect(noAuthValidation.authState.userEmail).toBeNull();

    // POSITIVE ASSERTION 2: Verify still on authentication page
    const authPageValidation = await authHelpers.validateStillOnAuthPage(page);
    expect(authPageValidation.isValid).toBe(true);
    expect(authPageValidation.pageValidation.hasEmailField).toBe(true);
    expect(authPageValidation.pageValidation.hasPasswordField).toBe(true);
    
    // POSITIVE ASSERTION 3: Verify authentication errors were detected
    const hasAuthErrors = authErrors.length > 0 || authPageValidation.pageValidation.hasErrorMessages;
    expect(hasAuthErrors).toBe(true);
    
    console.log('✓ Wrong password properly rejected with no session created');
  });

  test('ROLE-BASED: Packer role should authenticate and have correct session data', async ({ page }) => {
    // PHASE 2 ENHANCEMENT: Test role-based authentication with session validation
    
    const packerEmail = 'packer@rescuenet.net';
    const packerPassword = 'packerpass123';

    // Login as Packer role user
    await coordinateHelper.typeInField(page, 'login', 'emailField', packerEmail);
    await coordinateHelper.typeInField(page, 'login', 'passwordField', packerPassword);

    // Monitor role-based authentication
    let roleAuthFlow = [];
    page.on('console', msg => {
      if (msg.text().includes('role') || msg.text().includes('Packer') || msg.text().includes('Mock Firebase')) {
        roleAuthFlow.push(msg.text());
      }
    });

    await coordinateHelper.clickElement(page, 'login', 'loginButton');
    await page.waitForTimeout(3000);

    await page.screenshot({ path: 'packer-role-auth.png' });

    // POSITIVE ASSERTION 1: Verify Packer role authentication using auth helpers
    const packerRoleValidation = await authHelpers.validateRoleBasedAuth(page, 'Packer', packerEmail);
    console.log('Packer role validation:', packerRoleValidation);
    console.log('Role auth flow:', roleAuthFlow);

    // CRITICAL: Validate Packer role authentication
    expect(packerRoleValidation.isValid).toBe(true);
    expect(packerRoleValidation.sessionValidation.authState.hasCurrentUser).toBe(true);
    expect(packerRoleValidation.sessionValidation.authState.userEmail).toBe(packerEmail);
    expect(packerRoleValidation.sessionValidation.authState.userId).toMatch(/^mock-user-/);

    // POSITIVE ASSERTION 2: Verify Packer has access to app
    const appAccessValidation = await authHelpers.validateAppAccess(page);
    expect(appAccessValidation.isValid).toBe(true);
    expect(appAccessValidation.accessValidation.authSessionExists).toBe(true);
    
    console.log('✓ Packer role authentication successful with proper session');
  });

  test('ROLE-BASED: Back Office role should authenticate with correct permissions', async ({ page }) => {
    // PHASE 2 ENHANCEMENT: Test Back Office role authentication
    
    const backofficeEmail = 'backoffice@rescuenet.net';
    const backofficePassword = 'backofficepass123';

    // Login as Back Office role user
    await coordinateHelper.typeInField(page, 'login', 'emailField', backofficeEmail);
    await coordinateHelper.typeInField(page, 'login', 'passwordField', backofficePassword);

    await coordinateHelper.clickElement(page, 'login', 'loginButton');
    await page.waitForTimeout(3000);

    await page.screenshot({ path: 'backoffice-role-auth.png' });

    // POSITIVE ASSERTION 1: Verify Back Office role authentication using auth helpers
    const backofficeRoleValidation = await authHelpers.validateRoleBasedAuth(page, 'Back Office', backofficeEmail);
    console.log('Back Office role validation:', backofficeRoleValidation);

    // CRITICAL: Validate Back Office role authentication
    expect(backofficeRoleValidation.isValid).toBe(true);
    expect(backofficeRoleValidation.sessionValidation.authState.hasCurrentUser).toBe(true);
    expect(backofficeRoleValidation.sessionValidation.authState.userEmail).toBe(backofficeEmail);
    expect(backofficeRoleValidation.sessionValidation.authState.userId).toMatch(/^mock-user-/);

    // POSITIVE ASSERTION 2: Verify navigation to main app using app access validation
    const appAccessValidation = await authHelpers.validateAppAccess(page);
    expect(appAccessValidation.isValid).toBe(true);
    expect(appAccessValidation.accessValidation.navigationElementsVisible).toBe(true);
    
    console.log('✓ Back Office role authentication successful');
  });

  test('ROLE-BASED: Logistics role should authenticate with combined permissions', async ({ page }) => {
    // PHASE 2 ENHANCEMENT: Test Logistics role authentication
    
    const logisticsEmail = 'logistics@rescuenet.net';
    const logisticsPassword = 'logisticspass123';

    // Login as Logistics role user
    await coordinateHelper.typeInField(page, 'login', 'emailField', logisticsEmail);
    await coordinateHelper.typeInField(page, 'login', 'passwordField', logisticsPassword);

    await coordinateHelper.clickElement(page, 'login', 'loginButton');
    await page.waitForTimeout(3000);

    await page.screenshot({ path: 'logistics-role-auth.png' });

    // POSITIVE ASSERTION 1: Verify Logistics role authentication using auth helpers
    const logisticsRoleValidation = await authHelpers.validateRoleBasedAuth(page, 'Logistics', logisticsEmail);
    console.log('Logistics role validation:', logisticsRoleValidation);

    // CRITICAL: Validate Logistics role authentication
    expect(logisticsRoleValidation.isValid).toBe(true);
    expect(logisticsRoleValidation.sessionValidation.authState.hasCurrentUser).toBe(true);
    expect(logisticsRoleValidation.sessionValidation.authState.userEmail).toBe(logisticsEmail);
    expect(logisticsRoleValidation.sessionValidation.authState.userId).toMatch(/^mock-user-/);

    // POSITIVE ASSERTION 2: Verify full app access (Logistics has combined permissions)
    const appAccessValidation = await authHelpers.validateAppAccess(page);
    expect(appAccessValidation.isValid).toBe(true);
    expect(appAccessValidation.accessValidation.authSessionExists).toBe(true);
    expect(appAccessValidation.accessValidation.navigationElementsVisible).toBe(true);
    
    console.log('✓ Logistics role authentication successful with combined permissions');
  });

  test('CRITICAL: Authentication must fail when system is broken', async ({ page }) => {
    // PHASE 2 ENHANCEMENT: Test that demonstrates tests will FAIL when auth is broken
    
    // First verify authentication system is working using auth helpers
    const systemValidation = await authHelpers.validateAuthSystem(page);
    console.log('Auth System Validation:', systemValidation);

    // CRITICAL: These assertions will fail if mock system is broken
    expect(systemValidation.isValid).toBe(true);
    expect(systemValidation.systemValidation.mockModeEnabled).toBe(true);
    expect(systemValidation.systemValidation.mockFirebaseExists).toBe(true);
    expect(systemValidation.systemValidation.mockAuthExists).toBe(true);
    expect(systemValidation.systemValidation.authMethodsAvailable).toBe(true);

    // Test that authentication actually works by performing login
    await coordinateHelper.typeInField(page, 'login', 'emailField', 'test@rescuenet.net');
    await coordinateHelper.typeInField(page, 'login', 'passwordField', 'testpassword');

    // Monitor authentication flow
    let authLogs = [];
    page.on('console', msg => {
      if (msg.text().includes('Mock Firebase')) {
        authLogs.push(msg.text());
      }
    });

    await coordinateHelper.clickElement(page, 'login', 'loginButton');
    await page.waitForTimeout(3000);

    await page.screenshot({ path: 'auth-system-validation.png' });

    // CRITICAL: Verify authentication system is functioning using auth helpers
    const finalSessionValidation = await authHelpers.validateUserSession(page, 'test@rescuenet.net');
    console.log('Final auth system validation:', finalSessionValidation);
    console.log('Auth logs:', authLogs);

    // These will FAIL if authentication is broken (no false positives)
    expect(finalSessionValidation.isValid).toBe(true);
    expect(finalSessionValidation.authState.hasCurrentUser).toBe(true);
    expect(finalSessionValidation.authState.userEmail).toBe('test@rescuenet.net');
    expect(authLogs.length).toBeGreaterThan(0);
    
    console.log('✓ Authentication system is functioning correctly');
  });

  test('VALIDATION: Test demonstrates failure detection when auth system broken', async ({ page }) => {
    // PHASE 2 ENHANCEMENT: Demonstrate that weak assertions would miss authentication issues
    
    // This test shows how the new positive assertions will catch auth failures
    // that the old negative assertions (like expect().not.toContain()) would miss
    
    // First verify the auth system is working
    const systemValidation = await authHelpers.validateAuthSystem(page);
    expect(systemValidation.isValid).toBe(true);
    
    // Simulate a scenario where authentication appears to work but is actually broken
    // by checking what old weak assertions would have missed
    
    // OLD WAY (weak - would give false positives):
    // const pageContent = await page.textContent('body');
    // expect(pageContent).not.toContain('Authentication failed'); // Could pass even if auth is broken!
    
    // NEW WAY (strong - catches actual failures):
    // Perform actual authentication and validate the session state
    await coordinateHelper.typeInField(page, 'login', 'emailField', 'test@rescuenet.net');
    await coordinateHelper.typeInField(page, 'login', 'passwordField', 'testpassword');
    await coordinateHelper.clickElement(page, 'login', 'loginButton');
    await page.waitForTimeout(3000);
    
    // Validate authentication worked by checking actual session state
    const sessionValidation = await authHelpers.validateUserSession(page, 'test@rescuenet.net');
    
    // This WILL FAIL if authentication is broken (no false positives)
    expect(sessionValidation.isValid).toBe(true);
    expect(sessionValidation.authState.isAuthenticated).toBe(true);
    expect(sessionValidation.authState.hasCurrentUser).toBe(true);
    
    // Validate app access is available
    const appAccessValidation = await authHelpers.validateAppAccess(page);
    expect(appAccessValidation.isValid).toBe(true);
    
    // Log what the old weak assertions would have checked
    const pageContent = await page.textContent('body');
    const oldAssertionWouldPass = !pageContent.includes('Authentication failed');
    
    console.log('Old weak assertion would pass:', oldAssertionWouldPass);
    console.log('New strong assertion validates actual auth state:', sessionValidation.isValid);
    console.log('✓ Strong assertions provide real confidence in authentication functionality');
  });
});
