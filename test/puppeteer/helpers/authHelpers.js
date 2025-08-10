/**
 * Authentication Helper Functions for RescuenetWarehouse Playwright Tests
 * 
 * This module provides authentication-specific helper functions to validate
 * user sessions, role-based access, and authentication state rather than
 * relying on weak DOM-based assertions.
 * 
 * Created as part of Phase 2, Step 2.1 of the Test Assertion Improvement Plan.
 */

/**
 * Get current authentication state from mock Firebase
 * @param {import('@playwright/test').Page} page - Playwright page object
 * @returns {Promise<Object>} Authentication state object
 */
async function getAuthenticationState(page) {
  try {
    const authState = await page.evaluate(() => {
      console.log('=== GETTING AUTH STATE ===');
      console.log('window.mockFirebase exists:', !!window.mockFirebase);
      console.log('window.MOCK_FIREBASE_MODE:', window.MOCK_FIREBASE_MODE);
      
      if (!window.mockFirebase) {
        throw new Error('Mock Firebase not available - ensure test is running in mock mode');
      }
      
      const auth = window.mockFirebase.auth();
      console.log('auth object:', auth);
      console.log('auth.currentUser:', auth?.currentUser);
      
      const currentUser = auth?.currentUser;
      
      if (currentUser) {
        console.log('Current user details:', {
          uid: currentUser.uid,
          email: currentUser.email,
          displayName: currentUser.displayName,
          emailVerified: currentUser.emailVerified
        });
      }
      
      return {
        isAuthenticated: !!currentUser,
        hasCurrentUser: !!currentUser,
        userEmail: currentUser?.email || null,
        userId: currentUser?.uid || null,
        emailVerified: currentUser?.emailVerified || false,
        displayName: currentUser?.displayName || null,
        creationTime: currentUser?.metadata?.creationTime || null,
        lastSignInTime: currentUser?.metadata?.lastSignInTime || null,
        authReady: !!auth,
        mockModeEnabled: window.MOCK_FIREBASE_MODE === true
      };
    });
    
    console.log('=== FINAL AUTH STATE ===', authState);
    return authState;
  } catch (error) {
    console.error('Failed to get authentication state:', error.message);
    return {
      isAuthenticated: false,
      hasCurrentUser: false,
      error: error.message,
      authReady: false,
      mockModeEnabled: false
    };
  }
}

/**
 * Validate user session exists and is valid
 * @param {import('@playwright/test').Page} page - Playwright page object
 * @param {string} expectedEmail - Expected user email
 * @returns {Promise<Object>} Session validation result
 */
async function validateUserSession(page, expectedEmail = null) {
  try {
    const authState = await getAuthenticationState(page);
    const validationResult = {
      isValid: false,
      authState,
      errors: [],
      warnings: []
    };
    
    // Check basic authentication requirements
    if (!authState.authReady) {
      validationResult.errors.push('Authentication system not ready');
    }
    
    if (!authState.mockModeEnabled) {
      validationResult.errors.push('Mock Firebase mode not enabled');
    }
    
    if (!authState.isAuthenticated) {
      validationResult.errors.push('User is not authenticated');
    }
    
    if (!authState.hasCurrentUser) {
      validationResult.errors.push('No current user session found');
    }
    
    if (!authState.userId || (!authState.userId.startsWith('mock-user-') && !authState.userId.startsWith('test_user_'))) {
      validationResult.errors.push('Invalid or missing user ID');
    }
    
    // Check email if provided
    if (expectedEmail && authState.userEmail !== expectedEmail) {
      validationResult.errors.push(`Email mismatch: expected ${expectedEmail}, got ${authState.userEmail}`);
    }
    
    // Email verification check
    if (!authState.emailVerified) {
      validationResult.warnings.push('User email not verified');
    }
    
    validationResult.isValid = validationResult.errors.length === 0;
    validationResult.message = validationResult.isValid 
      ? 'User session validation passed' 
      : `User session validation failed: ${validationResult.errors.join(', ')}`;
    
    console.log('User session validation result:', validationResult);
    return validationResult;
  } catch (error) {
    console.error('Error validating user session:', error.message);
    return {
      isValid: false,
      error: error.message,
      message: 'User session validation failed due to error'
    };
  }
}

/**
 * Validate that user is NOT authenticated (for failed login tests)
 * @param {import('@playwright/test').Page} page - Playwright page object
 * @returns {Promise<Object>} Validation result confirming no authentication
 */
async function validateNoAuthentication(page) {
  try {
    const authState = await getAuthenticationState(page);
    const validationResult = {
      isValid: false,
      authState,
      errors: [],
      warnings: []
    };
    
    // For failed auth tests, we want to confirm NO authentication
    if (authState.isAuthenticated) {
      validationResult.errors.push('User is authenticated (should not be)');
    }
    
    if (authState.hasCurrentUser) {
      validationResult.errors.push('Current user session exists (should not exist)');
    }
    
    if (authState.userEmail) {
      validationResult.errors.push(`User email found (${authState.userEmail}) when none should exist`);
    }
    
    if (authState.userId) {
      validationResult.errors.push(`User ID found (${authState.userId}) when none should exist`);
    }
    
    // Check that auth system is ready (should be available even if not authenticated)
    if (!authState.authReady) {
      validationResult.warnings.push('Authentication system not ready');
    }
    
    if (!authState.mockModeEnabled) {
      validationResult.warnings.push('Mock Firebase mode not enabled');
    }
    
    validationResult.isValid = validationResult.errors.length === 0;
    validationResult.message = validationResult.isValid 
      ? 'No authentication validation passed (correctly not authenticated)' 
      : `No authentication validation failed: ${validationResult.errors.join(', ')}`;
    
    console.log('No authentication validation result:', validationResult);
    return validationResult;
  } catch (error) {
    console.error('Error validating no authentication:', error.message);
    return {
      isValid: false,
      error: error.message,
      message: 'No authentication validation failed due to error'
    };
  }
}

/**
 * Validate role-based authentication for specific user types
 * @param {import('@playwright/test').Page} page - Playwright page object
 * @param {string} expectedRole - Expected user role (Packer, Back Office, Logistics, etc.)
 * @param {string} expectedEmail - Expected user email
 * @returns {Promise<Object>} Role validation result
 */
async function validateRoleBasedAuth(page, expectedRole, expectedEmail) {
  try {
    // First validate basic authentication
    const sessionValidation = await validateUserSession(page, expectedEmail);
    
    if (!sessionValidation.isValid) {
      return {
        isValid: false,
        errors: [`Basic authentication failed: ${sessionValidation.message}`],
        sessionValidation
      };
    }
    
    const roleValidation = {
      isValid: false,
      role: expectedRole,
      email: expectedEmail,
      sessionValidation,
      errors: [],
      warnings: []
    };
    
    // Role-specific email validation
    const emailDomain = expectedEmail.split('@')[1];
    if (emailDomain !== 'rescuenet.net') {
      roleValidation.errors.push(`Invalid email domain for role ${expectedRole}: expected rescuenet.net, got ${emailDomain}`);
    }
    
    // Role-specific email prefix validation
    const emailPrefix = expectedEmail.split('@')[0].toLowerCase();
    const expectedPrefixes = {
      'Packer': ['packer'],
      'Back Office': ['backoffice', 'back-office', 'office'],
      'Logistics': ['logistics'],
      'On Deployment': ['deployment', 'field']
    };
    
    if (expectedPrefixes[expectedRole]) {
      const validPrefixes = expectedPrefixes[expectedRole];
      const hasValidPrefix = validPrefixes.some(prefix => emailPrefix.includes(prefix));
      
      if (!hasValidPrefix) {
        roleValidation.warnings.push(`Email prefix "${emailPrefix}" may not match role ${expectedRole} (expected one of: ${validPrefixes.join(', ')})`);
      }
    }
    
    // Check if authenticated user can access app (basic functionality test)
    const appAccessValidation = await validateAppAccess(page);
    if (!appAccessValidation.isValid) {
      roleValidation.errors.push(`App access validation failed: ${appAccessValidation.message}`);
    }
    
    roleValidation.isValid = roleValidation.errors.length === 0;
    roleValidation.message = roleValidation.isValid 
      ? `Role-based authentication validation passed for ${expectedRole}` 
      : `Role-based authentication validation failed for ${expectedRole}: ${roleValidation.errors.join(', ')}`;
    
    console.log(`Role-based auth validation for ${expectedRole}:`, roleValidation);
    return roleValidation;
  } catch (error) {
    console.error(`Error validating role-based auth for ${expectedRole}:`, error.message);
    return {
      isValid: false,
      error: error.message,
      message: `Role-based authentication validation failed for ${expectedRole} due to error`
    };
  }
}

/**
 * Validate that authenticated user has access to app functionality
 * @param {import('@playwright/test').Page} page - Playwright page object
 * @returns {Promise<Object>} App access validation result
 */
async function validateAppAccess(page) {
  try {
    const accessValidation = await page.evaluate(() => {
      const results = {
        authSessionExists: !!window.mockFirebase?.auth()?.currentUser,
        hamburgerMenuAccessible: false,
        navigationElementsVisible: false,
        flutterAppLoaded: false,
        errors: []
      };
      
      // Check if hamburger menu area is accessible (indicates main app loaded)
      try {
        const menuArea = document.elementFromPoint(27, 27);
        results.hamburgerMenuAccessible = !!menuArea;
      } catch (error) {
        results.errors.push(`Hamburger menu check failed: ${error.message}`);
      }
      
      // Check if Flutter app is loaded
      const body = document.body;
      if (body) {
        const bodyContent = body.textContent || '';
        results.flutterAppLoaded = bodyContent.includes('flutter-view') && bodyContent.length > 500;
        
        // Check for auth page elements (should NOT be present if authenticated)
        const hasAuthElements = bodyContent.includes('Email') && bodyContent.includes('Password') && bodyContent.includes('Login');
        results.navigationElementsVisible = !hasAuthElements;
      }
      
      return results;
    });
    
    const validationResult = {
      isValid: false,
      accessValidation,
      errors: [],
      warnings: []
    };
    
    // Validate access requirements
    if (!accessValidation.authSessionExists) {
      validationResult.errors.push('No authentication session found');
    }
    
    if (!accessValidation.flutterAppLoaded) {
      validationResult.errors.push('Flutter app not properly loaded');
    }
    
    if (!accessValidation.navigationElementsVisible) {
      validationResult.warnings.push('Still showing authentication page elements');
    }
    
    if (!accessValidation.hamburgerMenuAccessible) {
      validationResult.warnings.push('Hamburger menu not accessible');
    }
    
    if (accessValidation.errors.length > 0) {
      validationResult.errors.push(...accessValidation.errors);
    }
    
    validationResult.isValid = validationResult.errors.length === 0;
    validationResult.message = validationResult.isValid 
      ? 'App access validation passed' 
      : `App access validation failed: ${validationResult.errors.join(', ')}`;
    
    console.log('App access validation result:', validationResult);
    return validationResult;
  } catch (error) {
    console.error('Error validating app access:', error.message);
    return {
      isValid: false,
      error: error.message,
      message: 'App access validation failed due to error'
    };
  }
}

/**
 * Validate that app is still showing authentication page (for failed auth tests)
 * @param {import('@playwright/test').Page} page - Playwright page object
 * @returns {Promise<Object>} Auth page validation result
 */
async function validateStillOnAuthPage(page) {
  try {
    const pageValidation = await page.evaluate(() => {
      const body = document.body;
      const bodyContent = body ? (body.textContent || '') : '';
      
      return {
        hasEmailField: bodyContent.includes('Email'),
        hasPasswordField: bodyContent.includes('Password'),
        hasLoginButton: bodyContent.includes('Login'),
        bodyContentLength: bodyContent.length,
        hasErrorMessages: bodyContent.includes('error') || bodyContent.includes('Error') || bodyContent.includes('failed'),
        currentUrl: window.location.href
      };
    });
    
    const validationResult = {
      isValid: false,
      pageValidation,
      errors: [],
      warnings: []
    };
    
    // For failed auth, we want to confirm we're still on auth page
    if (!pageValidation.hasEmailField) {
      validationResult.errors.push('Email field not found (should be on auth page)');
    }
    
    if (!pageValidation.hasPasswordField) {
      validationResult.errors.push('Password field not found (should be on auth page)');
    }
    
    if (!pageValidation.hasLoginButton) {
      validationResult.errors.push('Login button not found (should be on auth page)');
    }
    
    if (pageValidation.bodyContentLength < 100) {
      validationResult.warnings.push('Page content seems too short - may indicate loading issue');
    }
    
    validationResult.isValid = validationResult.errors.length === 0;
    validationResult.message = validationResult.isValid 
      ? 'Auth page validation passed (correctly still on authentication page)' 
      : `Auth page validation failed: ${validationResult.errors.join(', ')}`;
    
    console.log('Auth page validation result:', validationResult);
    return validationResult;
  } catch (error) {
    console.error('Error validating auth page:', error.message);
    return {
      isValid: false,
      error: error.message,
      message: 'Auth page validation failed due to error'
    };
  }
}

/**
 * Comprehensive authentication system validation
 * Verifies that the mock authentication system is working properly
 * @param {import('@playwright/test').Page} page - Playwright page object
 * @returns {Promise<Object>} System validation result
 */
async function validateAuthSystem(page) {
  try {
    const systemValidation = await page.evaluate(() => {
      const results = {
        mockModeEnabled: window.MOCK_FIREBASE_MODE === true,
        mockFirebaseExists: !!window.mockFirebase,
        mockAuthExists: false,
        authMethodsAvailable: false,
        systemReady: false,
        errors: []
      };
      
      if (window.mockFirebase) {
        try {
          const auth = window.mockFirebase.auth();
          results.mockAuthExists = !!auth;
          
          if (auth) {
            // Check if key auth methods are available
            results.authMethodsAvailable = typeof auth.signInWithEmailAndPassword === 'function' &&
                                         typeof auth.createUserWithEmailAndPassword === 'function' &&
                                         typeof auth.signOut === 'function';
          }
        } catch (error) {
          results.errors.push(`Auth initialization error: ${error.message}`);
        }
      }
      
      results.systemReady = results.mockModeEnabled && results.mockFirebaseExists && 
                           results.mockAuthExists && results.authMethodsAvailable;
      
      return results;
    });
    
    const validationResult = {
      isValid: false,
      systemValidation,
      errors: [],
      warnings: []
    };
    
    // Check system requirements
    if (!systemValidation.mockModeEnabled) {
      validationResult.errors.push('Mock Firebase mode not enabled');
    }
    
    if (!systemValidation.mockFirebaseExists) {
      validationResult.errors.push('Mock Firebase not available on window object');
    }
    
    if (!systemValidation.mockAuthExists) {
      validationResult.errors.push('Mock Auth not available');
    }
    
    if (!systemValidation.authMethodsAvailable) {
      validationResult.errors.push('Authentication methods not available');
    }
    
    if (systemValidation.errors.length > 0) {
      validationResult.errors.push(...systemValidation.errors);
    }
    
    validationResult.isValid = validationResult.errors.length === 0;
    validationResult.message = validationResult.isValid 
      ? 'Authentication system validation passed' 
      : `Authentication system validation failed: ${validationResult.errors.join(', ')}`;
    
    console.log('Auth system validation result:', validationResult);
    return validationResult;
  } catch (error) {
    console.error('Error validating auth system:', error.message);
    return {
      isValid: false,
      error: error.message,
      message: 'Auth system validation failed due to error'
    };
  }
}

// Export all functions
module.exports = {
  getAuthenticationState,
  validateUserSession,
  validateNoAuthentication,
  validateRoleBasedAuth,
  validateAppAccess,
  validateStillOnAuthPage,
  validateAuthSystem
};