const dataHelpers = require('./helpers/dataHelpers');

console.log('=== Assignment Math Validation Test ===');

// Test tent-green-dome constraints
const tentItem = {
  name: 'tent-green-dome',
  total_quantity: 100,
  assigned_quantity: 25,
  available_quantity: 75
};

console.log('Testing valid tent assignment math:');
const validResult = dataHelpers.verifyAssignmentMath(tentItem);
dataHelpers.logValidationResult(validResult, 'Valid Tent Math');

console.log('\nTesting tent constraint validation:');
const constraintResult = dataHelpers.validateTentGreenDomeConstraints(tentItem, 35);
dataHelpers.logValidationResult(constraintResult, 'Tent Constraints');

console.log('\nTesting invalid assignment (exceeds available):');
const invalidConstraint = dataHelpers.validateTentGreenDomeConstraints(tentItem, 100);
dataHelpers.logValidationResult(invalidConstraint, 'Invalid Tent Assignment');

console.log('\nTesting corrupted assignment data:');
const corruptedItem = dataHelpers.createCorruptedAssignmentData(tentItem);
const corruptedResult = dataHelpers.verifyAssignmentMath(corruptedItem);
dataHelpers.logValidationResult(corruptedResult, 'Corrupted Data Detection');

console.log('\n=== Assignment Constraint Enforcement Test ===');
const validAssignment = { quantity: 25 };
const invalidAssignment = { quantity: 999 };

const validConstraintTest = dataHelpers.validateAssignmentConstraints(validAssignment, tentItem);
dataHelpers.logValidationResult(validConstraintTest, 'Valid Assignment Constraint');

const invalidConstraintTest = dataHelpers.validateAssignmentConstraints(invalidAssignment, tentItem);
dataHelpers.logValidationResult(invalidConstraintTest, 'Invalid Assignment Constraint');

console.log('\n=== Test Summary ===');
console.log('✓ Valid tent assignment math:', validResult.isValid);
console.log('✓ Tent constraint validation works:', constraintResult.isValid);
console.log('✓ Invalid assignment rejected:', !invalidConstraint.isValid);
console.log('✓ Corrupted data detected:', !corruptedResult.isValid);
console.log('✓ Valid constraint accepted:', validConstraintTest.isValid);
console.log('✓ Invalid constraint rejected:', !invalidConstraintTest.isValid);

const allTestsPassed = validResult.isValid && constraintResult.isValid && !invalidConstraint.isValid && 
                      !corruptedResult.isValid && validConstraintTest.isValid && !invalidConstraintTest.isValid;

console.log('\n' + (allTestsPassed ? '✅ ALL ASSIGNMENT VALIDATION TESTS PASSED' : '❌ SOME TESTS FAILED'));

// Return exit code based on test results
process.exit(allTestsPassed ? 0 : 1);