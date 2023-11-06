# Rescuenet Warehouse

An app for planning deployments for the NGO [Rescue Net](https://rescuenet.net/about-us/).


### Build
We use [json annotations](https://github.com/google/json_serializable.dart/tree/master/example) to reduce boilerplate code. To generate new files:
- dart run build_runner build

### Import data
```bash
firebase firestore:import --collection-name "items" --project "RescueNet" --csv "~/Documents/Blad1-Table 1.csv" --field-separator ";"
```