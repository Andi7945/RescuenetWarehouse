// @ts-check
const { test, expect } = require('@playwright/test');
const coordinateHelper = require('../helpers/coordinateHelper');
const authHelpers = require('../helpers/authHelpers');
const visualValidation = require('../helpers/visualValidation');
const loadingHelpers = require('../helpers/loadingHelpers');

test.describe('Authentication Workflows - Core Scenarios', () => {
    let sharedPage;

    // test.beforeAll(async ({ browser }) => {
    //     // Create shared browser context for efficiency
    //     const context = await browser.newContext();
    //     sharedPage = await context.newPage();
    //
    //     // Initial app load and Flutter initialization
    //     await sharedPage.goto('/');
    //     await sharedPage.waitForLoadState('networkidle');
    //
    //     // Progressive loading verification
    //     for (let i = 1; i <= 8; i++) {
    //         await sharedPage.waitForTimeout(1000);
    //         const content = await sharedPage.textContent('body');
    //         const isLoaded = content.includes('flutter-view') && content.length > 500;
    //         if (isLoaded) break;
    //     }
    // });

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

        // Login credentials with loading awareness
        await coordinateHelper.typeInField(page, 'login', 'emailField', testEmail, {
            operationType: 'quick',
            expectLoading: false
        });
        await coordinateHelper.typeInField(page, 'login', 'passwordField', testPassword, {
            operationType: 'quick',
            expectLoading: false
        });

        // Submit login with loading handling
        const loginResult = await coordinateHelper.clickElementWithLoadingWait(page, 'login', 'loginButton', {
            operationType: 'medium',
            expectLoading: true,
            maxLoadingTime: 10000
        });
        expect(loginResult.clickSuccess).toBe(true);

        // Is logged in
        const currentUrl = page.url();
        expect(currentUrl).toContain('containerWithContent');
    });

    test('2. Invalid credentials are rejected', async ({ page }) => {
        const testEmail = 'test@rescuenet.net';
        const wrongPassword = 'wrongpassword';

        // Invalid login attempt
        await coordinateHelper.typeInField(page, 'login', 'emailField', testEmail);
        await coordinateHelper.typeInField(page, 'login', 'passwordField', wrongPassword);
        await coordinateHelper.clickElement(page, 'login', 'loginButton');
        await page.waitForTimeout(2000);

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
        // Switch to registration mode
        await coordinateHelper.clickElement(page, 'login', 'registerInsteadButton', {
            offsetX: 117, offsetY: 0
        });
        await page.waitForTimeout(1000);

        // Valid registration
        const testEmail = `test-${Date.now()}@rescuenet.net`;
        const testPassword = 'TestPassword123!';

        await coordinateHelper.typeInField(page, 'login', 'emailField', testEmail);
        await coordinateHelper.typeInField(page, 'login', 'passwordField', testPassword);
        await coordinateHelper.clickElement(page, 'login', 'loginButton');
        await page.waitForTimeout(3000);

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
        // Switch to registration mode
        await coordinateHelper.clickElement(page, 'login', 'registerInsteadButton', {
            offsetX: 117, offsetY: 0
        });
        await page.waitForTimeout(1000);

        // Invalid email domain
        await coordinateHelper.typeInField(page, 'login', 'emailField', 'test@gmail.com');
        await coordinateHelper.typeInField(page, 'login', 'passwordField', 'TestPassword123!');
        await coordinateHelper.clickElement(page, 'login', 'loginButton');
        await page.waitForTimeout(2000);

        // Verify registration rejected
        const noAuthValidation = await authHelpers.validateNoAuthentication(page);
        expect(noAuthValidation.isValid).toBe(true);
        expect(noAuthValidation.authState.hasCurrentUser).toBe(false);

        // Verify still on auth page
        const authPageValidation = await authHelpers.validateStillOnAuthPage(page);
        expect(authPageValidation.isValid).toBe(true);
    });

    test.afterAll(async () => {
        if (sharedPage) {
            await sharedPage.close();
        }
    });
});
