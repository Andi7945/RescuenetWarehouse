// Script to restore container creation functionality after testing
// This restores the original functionality

if (window.mockRepositories && window.mockRepositories.originalContainerCreate) {
  // Restore original functionality
  const firestore = window.mockFirebase.firestore();
  const containers = firestore.collection('containers');
  containers.doc = window.mockRepositories.originalContainerCreate;
  
  console.log('VALIDATION TEST: Container creation functionality RESTORED');
}

// Remove the broken repository override
if (window.mockRepositories && window.mockRepositories.containerRepository) {
  delete window.mockRepositories.containerRepository;
  console.log('VALIDATION TEST: Repository overrides REMOVED');
}