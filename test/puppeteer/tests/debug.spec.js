// @ts-check
const { test, expect } = require('@playwright/test');

test.describe('Debug Flutter App Loading', () => {
  test('check what appears on the page', async ({ page }) => {
    // Navigate to the app with mock Firebase
    await page.goto('/?mock=true');
    
    // Wait for the page to load
    await page.waitForLoadState('networkidle');
    
    // Take a screenshot to see what's rendered
    await page.screenshot({ path: 'debug-flutter-app.png' });
    
    // Get page title
    const title = await page.title();
    console.log('Page title:', title);
    
    // Get all text content on the page
    const bodyText = await page.textContent('body');
    console.log('Body text:', bodyText);
    
    // Check for common Flutter loading indicators
    const flutterAppPresent = await page.locator('flutter-view, flt-scene-host, canvas').count();
    console.log('Flutter elements found:', flutterAppPresent);
    
    // Wait a bit more for Flutter to initialize
    await page.waitForTimeout(5000);
    
    // Check again after waiting
    const bodyTextAfterWait = await page.textContent('body');
    console.log('Body text after wait:', bodyTextAfterWait);
    
    // Take another screenshot
    await page.screenshot({ path: 'debug-flutter-app-after-wait.png' });
    
    // Look for any button or input elements
    const buttons = await page.locator('button').count();
    const inputs = await page.locator('input').count();
    const clickableElements = await page.locator('[role="button"], flt-semantics[role="button"]').count();
    
    console.log('Buttons found:', buttons);
    console.log('Inputs found:', inputs);
    console.log('Clickable elements found:', clickableElements);
    
    // Try to find any text that might be the login button
    const allText = await page.evaluate(() => {
      const walker = document.createTreeWalker(
        document.body,
        NodeFilter.SHOW_TEXT,
        null,
        false
      );
      const textNodes = [];
      let node;
      while (node = walker.nextNode()) {
        if (node.textContent.trim()) {
          textNodes.push(node.textContent.trim());
        }
      }
      return textNodes;
    });
    
    console.log('All text nodes found:', allText);
    
    // This test should always pass - we just want to see what's on the page
    expect(true).toBe(true);
  });
});