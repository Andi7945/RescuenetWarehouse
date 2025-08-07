const dataHelpers = require('./helpers/dataHelpers');

console.log('=== Assignment Failure Detection Test ===');
console.log('Testing that our validation logic properly detects broken assignment functionality\n');

// Test 1: Validate normal assignment math works
console.log('TEST 1: Normal assignment math validation');
const normalItem = {
  name: 'normal-item',
  total_quantity: 100,
  assigned_quantity: 30,
  available_quantity: 70
};

const normalResult = dataHelpers.verifyAssignmentMath(normalItem);
dataHelpers.logValidationResult(normalResult, 'Normal Assignment');
console.log('Expected: PASS | Actual:', normalResult.isValid ? 'PASS' : 'FAIL');

// Test 2: Break assignment math (quantities don't add up)
console.log('\nTEST 2: Broken assignment math detection');
const brokenMathItem = {
  name: 'broken-math-item',
  total_quantity: 100,
  assigned_quantity: 30,
  available_quantity: 80  // 30 + 80 = 110 ≠ 100
};

const brokenMathResult = dataHelpers.verifyAssignmentMath(brokenMathItem);
dataHelpers.logValidationResult(brokenMathResult, 'Broken Math');
console.log('Expected: FAIL | Actual:', brokenMathResult.isValid ? 'PASS' : 'FAIL');

// Test 3: Break constraint validation (allow over-assignment)
console.log('\nTEST 3: Broken constraint validation');
const normalConstraintItem = {
  name: 'constraint-test-item',
  total_quantity: 50,
  assigned_quantity: 10,
  available_quantity: 40
};

// This should fail - trying to assign more than available
const overAssignment = { quantity: 100 }; // More than 40 available
const brokenConstraintResult = dataHelpers.validateAssignmentConstraints(overAssignment, normalConstraintItem);
dataHelpers.logValidationResult(brokenConstraintResult, 'Over-assignment');
console.log('Expected: FAIL | Actual:', brokenConstraintResult.isValid ? 'PASS' : 'FAIL');

// Test 4: Test tent-green-dome specific constraints
console.log('\nTEST 4: Tent-green-dome constraint enforcement');
const tentItem = {
  name: 'tent-green-dome',
  total_quantity: 50,
  assigned_quantity: 15,
  available_quantity: 35
};

// Valid tent assignment
const validTentAssignment = 20;
const validTentResult = dataHelpers.validateTentGreenDomeConstraints(tentItem, validTentAssignment);
dataHelpers.logValidationResult(validTentResult, 'Valid Tent Assignment');
console.log('Expected: PASS | Actual:', validTentResult.isValid ? 'PASS' : 'FAIL');

// Invalid tent assignment (exceeds available)
const invalidTentAssignment = 50; // More than 35 available
const invalidTentResult = dataHelpers.validateTentGreenDomeConstraints(tentItem, invalidTentAssignment);
dataHelpers.logValidationResult(invalidTentResult, 'Invalid Tent Assignment');
console.log('Expected: FAIL | Actual:', invalidTentResult.isValid ? 'PASS' : 'FAIL');

// Test 5: Simulate corrupted repository data
console.log('\nTEST 5: Corrupted repository data detection');
const validItemForCorruption = dataHelpers.generateValidTestItem('test-item', 100, 25);
const corruptedItem = dataHelpers.createCorruptedAssignmentData(validItemForCorruption);
const corruptionResult = dataHelpers.verifyAssignmentMath(corruptedItem);
dataHelpers.logValidationResult(corruptionResult, 'Corrupted Data');
console.log('Expected: FAIL | Actual:', corruptionResult.isValid ? 'PASS' : 'FAIL');

// Test 6: Edge cases
console.log('\nTEST 6: Edge case handling');

// Zero quantities (should be valid)
const zeroItem = {
  name: 'zero-item',
  total_quantity: 0,
  assigned_quantity: 0,
  available_quantity: 0
};
const zeroResult = dataHelpers.verifyAssignmentMath(zeroItem);
dataHelpers.logValidationResult(zeroResult, 'Zero Quantities');
console.log('Expected: PASS | Actual:', zeroResult.isValid ? 'PASS' : 'FAIL');

// Negative quantities (should fail)
const negativeItem = {
  name: 'negative-item',
  total_quantity: 100,
  assigned_quantity: -10,
  available_quantity: 110
};
const negativeResult = dataHelpers.verifyAssignmentMath(negativeItem);
dataHelpers.logValidationResult(negativeResult, 'Negative Quantities');
console.log('Expected: FAIL | Actual:', negativeResult.isValid ? 'PASS' : 'FAIL');

// Summary
console.log('\n=== TEST RESULTS SUMMARY ===');
const expectedResults = [
  { name: 'Normal Assignment', expected: true, actual: normalResult.isValid },
  { name: 'Broken Math Detection', expected: false, actual: brokenMathResult.isValid },
  { name: 'Over-assignment Detection', expected: false, actual: brokenConstraintResult.isValid },
  { name: 'Valid Tent Assignment', expected: true, actual: validTentResult.isValid },
  { name: 'Invalid Tent Assignment', expected: false, actual: invalidTentResult.isValid },
  { name: 'Corrupted Data Detection', expected: false, actual: corruptionResult.isValid },
  { name: 'Zero Quantities', expected: true, actual: zeroResult.isValid },
  { name: 'Negative Quantities', expected: false, actual: negativeResult.isValid }
];

let allTestsCorrect = true;
for (const test of expectedResults) {
  const correct = test.expected === test.actual;
  const status = correct ? '✅' : '❌';
  console.log(`${status} ${test.name}: Expected ${test.expected}, Got ${test.actual}`);
  if (!correct) allTestsCorrect = false;
}

console.log('\n=== VALIDATION SUMMARY ===');
if (allTestsCorrect) {
  console.log('🎉 ALL FAILURE DETECTION TESTS PASSED');
  console.log('✅ Assignment validation logic correctly detects both valid and invalid scenarios');
  console.log('✅ Business logic failures are properly caught');
  console.log('✅ Constraint violations are rejected');
  console.log('✅ Edge cases are handled appropriately');
} else {
  console.log('❌ SOME FAILURE DETECTION TESTS FAILED');
  console.log('⚠️  Assignment validation logic may have issues');
}

// Exit with appropriate code
process.exit(allTestsCorrect ? 0 : 1);