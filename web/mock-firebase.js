// Mock Firebase implementation for testing
window.mockFirebaseEnabled = true;

// Mock Firebase Auth
class MockUser {
  constructor(email, userData = null) {
    if (userData) {
      this.uid = userData.uid;
      this.email = userData.email;
      this.displayName = userData.displayName;
      this.role = userData.role;
      this.permissions = userData.permissions;
    } else {
      this.uid = 'mock-user-' + Date.now();
      this.email = email;
      this.displayName = null;
    }
    this.emailVerified = true;
    this.metadata = {
      creationTime: userData?.created_at || new Date().toISOString(),
      lastSignInTime: new Date().toISOString()
    };
  }
}

class MockAuth {
  constructor() {
    this.currentUser = null;
    this._listeners = [];
    this._authCalls = [];  // Track auth method calls for debugging
    this._testUsers = [
      {
        uid: "test_user_packer_001",
        email: "packer.test@rescuenet.net",
        password: "testpassword",
        displayName: "Test Packer User",
        role: "Packer",
        permissions: ["containers:read", "containers:verify", "items:read", "assignments:read", "pdf:generate"],
        created_at: "2024-01-01T10:00:00Z"
      },
      {
        uid: "test_user_backoffice_001", 
        email: "backoffice.test@rescuenet.net",
        password: "testpassword",
        displayName: "Test Back Office User",
        role: "Back Office",
        permissions: ["items:read", "items:create", "items:update", "items:delete", "containers:read", "containers:create", "containers:update", "assignments:read", "assignments:create", "assignments:update", "assignments:delete", "export:csv", "export:pdf", "import:csv"],
        created_at: "2024-01-01T10:00:00Z"
      },
      {
        uid: "test_user_logistics_001",
        email: "logistics.test@rescuenet.net", 
        password: "logisticspass123",
        displayName: "Test Logistics User",
        role: "Logistics",
        permissions: ["items:read", "items:create", "items:update", "items:delete", "containers:read", "containers:create", "containers:update", "containers:delete", "containers:verify", "assignments:read", "assignments:create", "assignments:update", "assignments:delete", "reference_data:manage", "export:csv", "export:pdf", "import:csv", "pdf:generate", "reports:generate"],
        created_at: "2024-01-01T10:00:00Z"
      },
      {
        uid: "test_user_deployment_001",
        email: "deployment.test@rescuenet.net",
        password: "deploymentpass123", 
        displayName: "Test On Deployment User",
        role: "On Deployment",
        permissions: ["items:read", "items:mark_used", "containers:read", "assignments:read", "work_logs:create", "deployment:update_status"],
        created_at: "2024-01-01T10:00:00Z"
      },
      {
        uid: "mock-user-legacy",
        email: "test@rescuenet.net",
        password: "testpassword",
        displayName: "Legacy Test User",
        role: "Back Office",
        permissions: [],
        created_at: "2024-01-01T10:00:00Z"
      }
    ];
  }

  onAuthStateChanged(callback) {
    this._listeners.push(callback);
    // Simulate initial state
    setTimeout(() => callback(this.currentUser), 100);
    return () => {
      const index = this._listeners.indexOf(callback);
      if (index > -1) this._listeners.splice(index, 1);
    };
  }

  async signInWithEmailAndPassword(email, password) {
    this._authCalls.push({ method: 'signInWithEmailAndPassword', email, password, timestamp: Date.now() });
    console.log('=== MOCK FIREBASE SIGN IN ATTEMPT ===');
    console.log('Email:', email);
    console.log('Password:', password);
    console.log('Available test users:', this._testUsers.map(u => ({ email: u.email, password: u.password })));
    
    // Simulate network delay
    await new Promise(resolve => setTimeout(resolve, 500));
    
    // Find test user by email and password
    const testUser = this._testUsers.find(user => user.email === email && user.password === password);
    console.log('Found matching user:', testUser ? 'YES' : 'NO');
    
    if (!testUser) {
      console.error('LOGIN FAILED: Invalid email or password');
      console.log('Tried:', email, '/', password);
      console.log('Available:', this._testUsers.map(u => `${u.email}/${u.password}`));
      throw new Error('Invalid email or password');
    }
    
    this.currentUser = new MockUser(email, testUser);
    console.log('Created user object:', this.currentUser);
    console.log('Current user UID:', this.currentUser.uid);
    console.log('Current user email:', this.currentUser.email);
    
    this._notifyListeners();
    console.log('Notified', this._listeners.length, 'auth state listeners');
    
    console.log('=== SIGN IN SUCCESS ===');
    return {
      user: this.currentUser,
      operationType: 'signIn'
    };
  }

  // Debug method to check auth calls
  getAuthCalls() {
    return this._authCalls;
  }

  async createUserWithEmailAndPassword(email, password) {
    console.log('Mock Firebase: Creating user', email);
    
    // Simulate network delay
    await new Promise(resolve => setTimeout(resolve, 500));
    
    // Mock validation
    if (!email.includes('@rescuenet.net')) {
      throw new Error('Only rescuenet.net emails allowed');
    }
    
    if (password.length < 6) {
      throw new Error('Password too short');
    }
    
    this.currentUser = new MockUser(email);
    this._notifyListeners();
    
    return {
      user: this.currentUser,
      operationType: 'signIn'
    };
  }

  async sendPasswordResetEmail(email) {
    console.log('Mock Firebase: Sending password reset', email);
    await new Promise(resolve => setTimeout(resolve, 300));
    return true;
  }

  async signOut() {
    console.log('Mock Firebase: Signing out');
    this.currentUser = null;
    this._notifyListeners();
  }

  _notifyListeners() {
    this._listeners.forEach(callback => {
      setTimeout(() => callback(this.currentUser), 0);
    });
  }

  get authStateChanges() {
    return {
      listen: this.onAuthStateChanged.bind(this)
    };
  }
}

// Mock Firestore
class MockDocumentReference {
  constructor(id, data = {}) {
    this.id = id;
    this._data = data;
  }

  async set(data) {
    console.log('Mock Firestore: Setting document', this.id, data);
    this._data = { ...data, id: this.id };
    await new Promise(resolve => setTimeout(resolve, 100));
    return true;
  }

  async get() {
    console.log('Mock Firestore: Getting document', this.id);
    await new Promise(resolve => setTimeout(resolve, 100));
    return {
      id: this.id,
      data: () => this._data,
      exists: Object.keys(this._data).length > 0
    };
  }

  async delete() {
    console.log('Mock Firestore: Deleting document', this.id);
    this._data = {};
    await new Promise(resolve => setTimeout(resolve, 100));
    return true;
  }
}

class MockCollectionReference {
  constructor(name) {
    this.name = name;
    this._docs = new Map();
    this._listeners = [];
  }

  doc(id) {
    if (!id) {
      id = 'auto-' + Date.now() + '-' + Math.random().toString(36).substr(2, 9);
    }
    
    if (!this._docs.has(id)) {
      this._docs.set(id, new MockDocumentReference(id));
    }
    
    return this._docs.get(id);
  }

  snapshots() {
    return {
      listen: (callback, errorCallback) => {
        console.log('Mock Firestore: Listening to collection', this.name);
        
        const listener = { callback, errorCallback };
        this._listeners.push(listener);
        
        // Initial callback with current data
        setTimeout(() => {
          const docs = Array.from(this._docs.values()).map(doc => ({
            id: doc.id,
            data: () => doc._data
          }));
          callback({ docs });
        }, 100);
        
        // Return unsubscribe function
        return () => {
          const index = this._listeners.indexOf(listener);
          if (index > -1) this._listeners.splice(index, 1);
        };
      }
    };
  }
}

class MockFirestore {
  constructor() {
    this._collections = new Map();
  }

  collection(name) {
    if (!this._collections.has(name)) {
      this._collections.set(name, new MockCollectionReference(name));
    }
    return this._collections.get(name);
  }

  async runTransaction(updateFunction) {
    console.log('Mock Firestore: Running transaction');
    await new Promise(resolve => setTimeout(resolve, 100));
    return await updateFunction({});
  }
}

// Mock Firebase Storage
class MockStorageReference {
  constructor(path) {
    this.fullPath = path;
  }

  async put(file) {
    console.log('Mock Storage: Uploading file', this.fullPath);
    await new Promise(resolve => setTimeout(resolve, 500));
    return {
      ref: this,
      metadata: { name: this.fullPath, size: file.size }
    };
  }

  async getDownloadURL() {
    console.log('Mock Storage: Getting download URL', this.fullPath);
    await new Promise(resolve => setTimeout(resolve, 200));
    return `https://mock-storage.firebase.com/${this.fullPath}`;
  }
}

class MockStorage {
  ref(path) {
    return new MockStorageReference(path);
  }
}

// Mock Firebase App
class MockFirebaseApp {
  constructor() {
    this.name = 'mock-app';
    this.options = {
      apiKey: 'mock-api-key',
      authDomain: 'mock.firebaseapp.com',
      projectId: 'mock-project'
    };
  }
}

// Global mock Firebase object  
window.mockFirebase = {
  auth: () => window._mockAuthInstance || new MockAuth(),
  firestore: () => window._mockFirestoreInstance || new MockFirestore(),
  storage: () => window._mockStorageInstance || new MockStorage(),
  initializeApp: (config) => {
    console.log('Mock Firebase: Initializing app', config);
    return new MockFirebaseApp();
  },
  apps: [],
  // Mock specific collections for the app
  createMockData: () => {
    const firestore = new MockFirestore();
    
    // Create some mock containers
    const containers = firestore.collection('containers');
    containers.doc('container-1')._data = {
      id: 'container-1',
      number: 1,
      name: 'Genset 1',
      description: 'Generator container',
      typeId: 'type-1',
      sequentialBuild: 'firstBuild',
      moduleDestinationId: 'dest-1',
      currentLocationId: 'loc-1',
      isReady: false,
      toDeploy: false
    };
    
    containers.doc('container-2')._data = {
      id: 'container-2',
      number: 2,
      name: 'Medical Supplies',
      description: 'Medical equipment container',
      typeId: 'type-2',
      sequentialBuild: 'preBuild',
      moduleDestinationId: 'dest-2',
      currentLocationId: 'loc-2',
      isReady: true,
      toDeploy: false
    };
    
    // Create mock container types
    const containerTypes = firestore.collection('container_types');
    containerTypes.doc('type-1')._data = {
      id: 'type-1',
      name: 'Euro Crate',
      imagePath: 'images/euro_crate.png',
      emptyWeight: 5.5,
      measurements: '60x40x32'
    };
    
    containerTypes.doc('type-2')._data = {
      id: 'type-2',
      name: 'Euro Crate High',
      imagePath: 'images/euro_crate.png',
      emptyWeight: 7.2,
      measurements: '60x40x64'
    };
    
    // Create mock items including tent
    const items = firestore.collection('items');
    items.doc('item-42649')._data = {
      id: 'item-42649',
      name: 'Tent Green Dome',
      rescueNetId: 42649,
      weight: 2.5,
      totalAmount: 10,
      description: 'Green dome tent for 2 people'
    };
    
    items.doc('item-12345')._data = {
      id: 'item-12345',
      name: 'Medical Kit',
      rescueNetId: 12345,
      weight: 1.8,
      totalAmount: 25,
      description: 'Basic medical supply kit'
    };
    
    // Create mock assignments
    const assignments = firestore.collection('assignments');
    assignments.doc('assign-1')._data = {
      id: 'assign-1',
      itemId: 'item-42649',
      containerId: 'container-1',
      count: 3
    };
    
    // Create mock module destinations
    const moduleDestinations = firestore.collection('module_destinations');
    moduleDestinations.doc('dest-1')._data = {
      id: 'dest-1',
      name: 'Base Camp'
    };
    
    moduleDestinations.doc('dest-2')._data = {
      id: 'dest-2',
      name: 'Medical Station'
    };
    
    // Create mock current locations
    const currentLocations = firestore.collection('current_locations');
    currentLocations.doc('loc-1')._data = {
      id: 'loc-1',
      name: 'Warehouse A'
    };
    
    currentLocations.doc('loc-2')._data = {
      id: 'loc-2',
      name: 'Warehouse B'
    };
    
    console.log('Mock Firebase: Created mock data');
    return firestore;
  }
};

// Override Firebase if in test mode (set by index.html)
const isTestMode = window.MOCK_FIREBASE_MODE === true;

if (isTestMode) {
  console.log('Mock Firebase: Test mode detected, using mock implementation');
  console.log('User Agent:', navigator.userAgent);
  console.log('Location:', window.location.href);
  
  // Create auth instance that will be reused
  const mockAuthInstance = new MockAuth();
  const mockFirestoreInstance = new MockFirestore();
  const mockStorageInstance = new MockStorage();
  
  // Override global Firebase completely - no real Firebase calls
  window.firebase = window.mockFirebase;
  
  // Override Flutter Firebase Web plugin more aggressively
  window.flutterfire_web = {
    auth: () => mockAuthInstance,
    firestore: () => mockFirestoreInstance, 
    storage: () => mockStorageInstance
  };
  
  // Override common Firebase Web SDK patterns
  if (typeof window.firebase === 'undefined') {
    window.firebase = window.mockFirebase;
  }
  
  // Intercept any Firebase imports/requires
  if (typeof window.require !== 'undefined') {
    const originalRequire = window.require;
    window.require = function(module) {
      if (module === 'firebase/auth' || module === 'firebase/app' || module === 'firebase/firestore') {
        console.log('Mock Firebase: Intercepted require for', module);
        return window.mockFirebase;
      }
      return originalRequire.apply(this, arguments);
    };
  }
  
  // Initialize mock data
  window.mockFirebase.createMockData();
  
  // Set up global instances for reuse
  window._mockAuthInstance = mockAuthInstance;
  window._mockFirestoreInstance = mockFirestoreInstance;
  window._mockStorageInstance = mockStorageInstance;
  
  // Log that we're in mock mode
  console.log('Mock Firebase: All Firebase services are now mocked');
  console.log('Mock Firebase: No real API calls will be made');
  console.log('Mock Firebase: Auth instance created:', mockAuthInstance);
}