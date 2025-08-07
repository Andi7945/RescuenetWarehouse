// Script to break container creation functionality for testing
// This will be injected into the page to test if container tests can detect broken functionality

window.mockRepositories = window.mockRepositories || {};

// Save the original functionality first
window.mockRepositories.originalContainerCreate = window.mockFirebase?.firestore()?.collection('containers')?.doc;

// Break container creation by making it return null/fail
if (window.mockFirebase && window.mockFirebase.firestore) {
  const originalFirestore = window.mockFirebase.firestore;
  
  window.mockFirebase.firestore = function() {
    const firestore = originalFirestore.call(this);
    const originalCollection = firestore.collection;
    
    firestore.collection = function(name) {
      const collection = originalCollection.call(this, name);
      
      if (name === 'containers') {
        const originalDoc = collection.doc;
        
        collection.doc = function(id) {
          const doc = originalDoc.call(this, id);
          const originalSet = doc.set;
          
          // Break the set method to always fail for new containers
          doc.set = async function(data) {
            console.log('VALIDATION TEST: Container creation BLOCKED by test script');
            // Simulate a failure
            throw new Error('Container creation failed - validation test');
          };
          
          return doc;
        };
      }
      
      return collection;
    };
    
    return firestore;
  };
  
  console.log('VALIDATION TEST: Container creation functionality BROKEN for testing');
}

// Alternative approach - directly break the repository layer if it exists
if (window.mockRepositories) {
  window.mockRepositories.containerRepository = {
    create: () => {
      console.log('VALIDATION TEST: Repository-level container creation BLOCKED');
      return null;
    },
    save: () => {
      console.log('VALIDATION TEST: Repository-level container save BLOCKED');
      return null;
    }
  };
}