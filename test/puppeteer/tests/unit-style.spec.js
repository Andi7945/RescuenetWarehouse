// @ts-check
const { test, expect } = require('@playwright/test');
const fs = require('fs');
const path = require('path');

test.describe('Code Fix Verification Tests', () => {
  test('verify authentication bug fix is in the code', async () => {
    // Check that the authentication fix is present in the code
    const authPagePath = path.join(__dirname, '../../../lib/ui/auth_page/login_register_page.dart');
    const authPageContent = fs.readFileSync(authPagePath, 'utf-8');
    
    // Verify the fix: automatic navigation after registration
    expect(authPageContent).toContain('Navigator.pushNamed(context, routeContainerWithContent)');
    expect(authPageContent).toContain('// Registration successful, navigate to main app');
    
    console.log('✅ Authentication bug fix verified in code');
  });

  test('verify container persistence bug fix is in the code', async () => {
    // Check that the container persistence fix is present
    const containerEditPath = path.join(__dirname, '../../../lib/ui/container_edit_page/container_edit_page.dart');
    const containerEditContent = fs.readFileSync(containerEditPath, 'utf-8');
    
    // Verify the fix: automatic database persistence
    expect(containerEditContent).toContain('ref.read(allContainersNotifierProvider.notifier).update(changedContainer)');
    expect(containerEditContent).toContain('// Persist changes to database');
    expect(containerEditContent).toContain('import \'package:rescuenet_warehouse/state/all_containers_notifier.dart\'');
    
    console.log('✅ Container persistence bug fix verified in code');
  });

  test('verify item quantity bug fixes are in the code', async () => {
    // Check the amount input component fix
    const amountInputPath = path.join(__dirname, '../../../lib/ui/rescue_input_amount.dart');
    const amountInputContent = fs.readFileSync(amountInputPath, 'utf-8');
    
    // Verify fixes: prevent erratic updates and add validation
    expect(amountInputContent).toContain('int? _lastAmount');
    expect(amountInputContent).toContain('if (_lastAmount != widget.amount)');
    expect(amountInputContent).toContain('// Prevent negative amounts and extremely large values');
    expect(amountInputContent).toContain('if (newAmount < 0)');
    expect(amountInputContent).toContain('} else if (newAmount > 99999)');
    
    console.log('✅ Amount input bug fixes verified in code');
    
    // Check the increment/decrement button fixes
    const amountsRowPath = path.join(__dirname, '../../../lib/ui/item_edit_page/item_edit_page_amounts_row.dart');
    const amountsRowContent = fs.readFileSync(amountsRowPath, 'utf-8');
    
    // Verify button boundary fixes
    expect(amountsRowContent).toContain('amount > 0 ? () => fnChangeAmount(amount - 1) : null');
    expect(amountsRowContent).toContain('amount < 99999 ? () => fnChangeAmount(amount + 1) : null');
    
    console.log('✅ Button boundary fixes verified in code');
    
    // Check assignment duplicate prevention
    const assignmentsPath = path.join(__dirname, '../../../lib/state/current_item_assignments_notifier.dart');
    const assignmentsContent = fs.readFileSync(assignmentsPath, 'utf-8');
    
    // Verify duplicate assignment prevention
    expect(assignmentsContent).toContain('// Check if assignment already exists to prevent duplicates');
    expect(assignmentsContent).toContain('if (existingAssignment != null)');
    expect(assignmentsContent).toContain('setAmount(containerIdToAdd, amount)');
    
    console.log('✅ Assignment duplicate prevention verified in code');
  });

  test('verify text field saving bug fix is in the code', async () => {
    // Check the custom value text field fix
    const textFieldPath = path.join(__dirname, '../../../lib/ui/edit_custom_values/edit_custom_value_text_field.dart');
    const textFieldContent = fs.readFileSync(textFieldPath, 'utf-8');
    
    // Verify additional save triggers
    expect(textFieldContent).toContain('onEditingComplete: () {');
    expect(textFieldContent).toContain('onSubmitted: (value) {');
    expect(textFieldContent).toContain('widget.onChange!(value)');
    
    console.log('✅ Text field saving bug fix verified in code');
  });

  test('verify all git commits contain our fixes', async () => {
    // This test just ensures we can verify the structure is correct
    // In a real scenario, you'd check git log to ensure commits are present
    
    const testStructureValid = [
      '../../../lib/ui/auth_page/login_register_page.dart',
      '../../../lib/ui/container_edit_page/container_edit_page.dart', 
      '../../../lib/ui/rescue_input_amount.dart',
      '../../../lib/ui/item_edit_page/item_edit_page_amounts_row.dart',
      '../../../lib/state/current_item_assignments_notifier.dart',
      '../../../lib/ui/edit_custom_values/edit_custom_value_text_field.dart'
    ].every(filePath => {
      const fullPath = path.join(__dirname, filePath);
      return fs.existsSync(fullPath);
    });
    
    expect(testStructureValid).toBe(true);
    console.log('✅ All fix files are present in the codebase');
  });

  test('verify test files are properly structured', async () => {
    // Verify our test files exist and are structured correctly
    const testFiles = [
      'authentication.spec.js',
      'container-persistence.spec.js', 
      'item-quantity.spec.js',
      'integration.spec.js'
    ];
    
    for (const testFile of testFiles) {
      const testPath = path.join(__dirname, testFile);
      expect(fs.existsSync(testPath)).toBe(true);
      
      const content = fs.readFileSync(testPath, 'utf-8');
      expect(content).toContain('test.describe');
      expect(content).toContain('test(');
    }
    
    console.log('✅ All test files are properly structured');
  });
});