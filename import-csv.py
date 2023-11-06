import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore#
from google.cloud.firestore_v1.base_query import FieldFilter

import uuid
import json
import sys

cred = credentials.Certificate('./rescuenet-7733b-1b5f2b853c4e.json')

app = firebase_admin.initialize_app(cred)

db = firestore.client()

def getOrEmpty(row, field):
    if len(row) > field:
        return row[field]
    return ""

def getOrNull(row, field):
    if len(row) > field:
        try:
            return int(row[field])
        except ValueError:
            return 0
    return 0

def withFieldName(counter, row):
    return str({
        "line number": counter,
        "Category": getOrEmpty(row, 0),
        "Subcategory": getOrEmpty(row, 1),
        "Item": getOrEmpty(row, 2),
        "Remarks": getOrEmpty(row, 3),
        "Quantity for deployment": getOrEmpty(row, 4),
        "Quantity trainingweekend": getOrEmpty(row, 5),
        "Status trainingweekend": getOrEmpty(row, 6),
        "Status Lebanon - proposal 2020": getOrEmpty(row, 7),
        "Source": getOrEmpty(row, 8),
        "Where to buy": getOrEmpty(row, 9),
        "Price each": getOrEmpty(row, 10),
        "Dangerous good": getOrEmpty(row, 11),
        "Expiring": getOrEmpty(row, 12),
        "Weight [kg]": getOrEmpty(row, 13),
        "Where to keep during deployment": getOrEmpty(row, 14),
        "Current location": getOrEmpty(row, 15),
        "QTY": getOrEmpty(row, 16)
    })

docs = (
    db.collection("items")
    .where(filter=FieldFilter("importedFromCsv", "==", True))
    .stream()
)

deleteCounter = 0

for doc in docs:
    deleteCounter = deleteCounter + 1
    doc.reference.delete()
    sys.stdout.write("\rDeleted %d documents with importedFromCsv" % deleteCounter)
    sys.stdout.flush()

sys.stdout.write("\n")

maxId = 0
maxRef = db.collection('items').order_by('rescueNetId', direction=firestore.Query.DESCENDING).limit(1).get()
if len(maxRef) >= 1:
    maxId = maxRef[0].get("rescueNetId")

print("Highest id : " + str(maxId))
counter = 0

import csv
with open('rescue-item-import-data.csv', newline='') as csvfile:
    spamreader = csv.reader(csvfile, delimiter=';', quotechar='|')
    for row in spamreader:
        counter = counter + 1
        if (counter != 1):
            sys.stdout.write("\rImport line number %d" % counter)
            sys.stdout.flush()
            id = str(uuid.uuid4())
            j = {
                "id": id,
                "brand": getOrEmpty(row, 8),
                "description": "",
                "expiringDates": [],
                "imagePath": "",
                "isColdChain": False,
                "manufacturer": getOrEmpty(row, 8),
                "name": getOrEmpty(row, 2),
                "notes": withFieldName(str(counter), row),
                "operationalStatus": "deployable",
                "remarks": getOrEmpty(row, 3),
                "rescueNetId": maxId + counter,
                "signs": [],
                "sku": "",
                "supplier": "",
                "totalAmount": getOrNull(row, 4),
                "type": "",
                "value": getOrNull(row, 10),
                "website": getOrEmpty(row, 9),
                "weight": getOrNull(row, 13),
                "importedFromCsv": True
            }

            doc_ref = db.collection("items").document(id)
            doc_ref.set(j)