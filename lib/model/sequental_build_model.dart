import 'package:flutter/material.dart';

class SequentialBuildModel {
  String? id;
  String? des;
  Color? sequentialBuildColor;

  SequentialBuildModel({
    this.id,
    this.des,
    this.sequentialBuildColor,
  });

  //get Model from json
  factory SequentialBuildModel.fromJson(Map<String, dynamic> json, String id) {
    return SequentialBuildModel(
      id: id,
      des: json['des'],
      sequentialBuildColor: Color(json['sequentialBuildColor']),
    );
  }

  //get json from Model
  Map<String, dynamic> toJson() {
    return {
      'des': des,
      'sequentialBuildColor': sequentialBuildColor!.value,
    };
  }

  Widget squentialBuildWidget(context) {
    return Container(
      color: sequentialBuildColor,
      child:
          GestureDetector(
            onDoubleTap: () {
              //Show alert dialog to change name
              AlertDialog alert = AlertDialog(
                title: Row(
                  children: [
                    const Icon(
                      Icons.change_circle_outlined,
                      color: Colors.black,
                    ),
                    Text("  Change name: $des"),
                  ],
                ),
                content: const SizedBox(
                  height: 200,
                  width: 300,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                    child: TextField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter a new description',
                      ),
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    child: const Text("Abbrechen"),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              );

              // show the dialog
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return alert;
                },
              );
            },
            child: Container(
              width: 50,
              height: 15,
              color: sequentialBuildColor ?? Colors.white,
              child: Column(
                children: [
                  const Text(
                    "Sequential build",
                    style: TextStyle(
                      fontSize: 8,
                    ),
                  ),
                  Text(
                    des ?? "No name",
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}