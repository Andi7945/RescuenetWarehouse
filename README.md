# Rescuenet Warehouse

An app for planning deployments for the NGO [Rescue Net](https://rescuenet.net/about-us/).

The app is mainly used to have an amount of *items* which are stored and then deployed in different *containers*.


There are different roles:
* Packer
  * Check for each container:
    * Are the items in the container in reality which should be according to the app
    * Are there any dangerous goods/broken equipment
    * Is everything up to date
    * Print different sheets per container when it is ready
* Back Office
  * Adds/modifies items
  * Adds new containers when necessary
* Logistics
  * Both *Packer* and *Back Office* todos
* On Deployment
  * After a deployment not everything can be taken back because of usage/problems with cleaning etc
  * So on the end of a deployment a person can go through the containers and move everything that was used into a different category "used"

## Use Cases:
### Add/edit container
#### Views
* All container overview -> all containers
* Single container edit view -> single container
### Add/edit item metadata
#### Views
* All items overview -> all items
  * Single select: Click card
  * Multi select: Export/Delete possible
  * Import here or somewhere else?
* Single item edit view -> single item -> No Assignments!
### Adjust assignments
#### Item view
* List containers with assignments
* Maybe this needs no assignment?
#### Container view
* List items to assign

## Build
We use [json annotations](https://github.com/google/json_serializable.dart/tree/master/example) to reduce boilerplate code. To generate new files:
- dart run build_runner build

### Build for web
```bash
flutter build web
```

## Testing
We use Playwright for end-to-end testing of the Flutter web app. The tests validate bug fixes and core functionality.

The tests use coordinate-based interaction to work with Flutter's Canvas rendering. Mock Firebase backend is automatically loaded during testing.

### Run Playwright tests
```bash
cd test/puppeteer
npm test
```

### Run tests for specific browser
```bash
cd test/puppeteer
npx playwright test --project=chromium
```

### View test results in browser
```bash
cd test/puppeteer
npx playwright show-report
```

### Test files
- `authentication.spec.js` - Tests registration redirect fix
- `container-persistence.spec.js` - Tests container data persistence fix  
- `item-quantity.spec.js` - Tests item quantity/assignment fixes
- `container-types.spec.js` - Tests container types page and empty weight database persistence
- `integration.spec.js` - Tests combined workflows

### Notes
- Tests run against the real Flutter app with mocked Firebase backend
- Mock Firebase is only loaded when Playwright user agent is detected
- Screenshots are captured at key points for debugging
- Tests use coordinate-based clicking since Flutter uses Canvas rendering

### Import data
```bash
firebase firestore:import --collection-name "items" --project "RescueNet" --csv "~/Documents/Blad1-Table 1.csv" --field-separator ";"
```
