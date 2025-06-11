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
        "Name": getOrEmpty(row, 2),
        "Unique Excel ID": getOrEmpty(row, 3),
        "Description": getOrEmpty(row, 4),
        "Amount": getOrEmpty(row, 5),
        "Quantity trainingweekend": getOrEmpty(row, 6),
        "Status trainingweekend": getOrEmpty(row, 7),
        "Status Lebanon - proposal 2020": getOrEmpty(row, 8),
        "Brand": getOrEmpty(row, 9),
        "Supplier": getOrEmpty(row, 10),
        "Value in EUR": getOrEmpty(row, 11),
        "Dangerous good": getOrEmpty(row, 12),
        "Expiring": getOrEmpty(row, 13),
        "Weight [kg]": getOrEmpty(row, 14)
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
with open('rescue-item-import-data-2.csv', newline='') as csvfile:
    spamreader = csv.reader(csvfile, delimiter=';', quotechar='|')
    for row in spamreader:
        counter = counter + 1
        if (counter != 1):
            sys.stdout.write("\rImport line number %d" % counter)
            sys.stdout.flush()
            id = getOrEmpty(row, 3)
            j = {
                "id": id,
                "brand": getOrEmpty(row, 9),
                "description": getOrEmpty(row, 4),
                "expiringDates": [],
                "imagePath": "",
                "isColdChain": False,
                "manufacturer": getOrEmpty(row, 9),
                "name": getOrEmpty(row, 2),
                "notes": withFieldName(str(counter), row),
                "operationalStatus": "deployable",
                "remarks": "",
                "rescueNetId": maxId + counter,
                "signs": [],
                "sku": "",
                "supplier": getOrEmpty(row, 10),
                "totalAmount": getOrNull(row, 5),
                "type": "",
                "value": getOrNull(row, 11),
                "website": "",
                "weight": getOrNull(row, 14),
                "importedFromCsv": True
            }

            doc_ref = db.collection("items").document(id)
            doc_ref.set(j)