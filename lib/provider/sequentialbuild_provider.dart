import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../model/sequental_build_model.dart';

class SequentialBuildProvider extends ChangeNotifier {
  static const String _firebasePath = 'sequentialBuild';
  List<SequentialBuildModel> _sequentialBuildModel = [];
  int? _currentIndex = 0;
  int? get currentIndex => _currentIndex;
  List<int> newSequentialBuildModelIds = [];

  String? getID(){
    if(_currentIndex == null){
      return null;
    }
    return _sequentialBuildModel[_currentIndex!].id;
  }

  List<SequentialBuildModel> get sequentialBuildModels => _sequentialBuildModel;

  //horizontall scroll view to select one
  Widget horizontalSelection() {
    ScrollController scrollController = ScrollController();
    return StatefulBuilder(builder: (context, setState) {
      return Scrollbar(
        controller: scrollController,
        child: SingleChildScrollView(
          controller: scrollController,
          scrollDirection: Axis.horizontal,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: List.generate(_sequentialBuildModel.length, (index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (_currentIndex == index) {
                        _currentIndex = null;
                      } else {
                        _currentIndex = index;
                      }
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: _sequentialBuildModel[index].sequentialBuildColor,
                      //border if selected
                      border: _currentIndex == index
                          ? Border.all(
                              color: Colors.black,
                              width: 2,
                            )
                          : null,
                    ),
                    padding: const EdgeInsets.all(8.0),
                    margin: const EdgeInsets.all(4.0),
                    width: 70,
                    height: 40,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Sequential build",
                            style: TextStyle(
                              fontSize: 6,
                            ),
                          ),
                          Text(
                            _sequentialBuildModel[index].des!,
                            style: const TextStyle(
                              //color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      );
    });
  }

  Future<void> getSequentialBuildModelFromFB() async {
    final QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await FirebaseFirestore.instance.collection(_firebasePath).get();
    _sequentialBuildModel = querySnapshot.docs
        .map((QueryDocumentSnapshot<Map<String, dynamic>> e) =>
            SequentialBuildModel.fromJson(e.data(), e.id))
        .toList();
    notifyListeners();
  }

  //listen to the changes in the firebase
  void listenToSequentialBuildModelFromFB() {
    FirebaseFirestore.instance
        .collection(_firebasePath)
        .snapshots()
        .listen((QuerySnapshot<Map<String, dynamic>> querySnapshot) {
      _sequentialBuildModel = querySnapshot.docs
          .map((QueryDocumentSnapshot<Map<String, dynamic>> e) =>
              SequentialBuildModel.fromJson(e.data(), e.id))
          .toList();
      print("BMF from Firebase: ${_sequentialBuildModel.length}");
      notifyListeners();
    });
  }

  Future<void> addSequentialBuildModelToFB(
      SequentialBuildModel sequentialBuildModel) async {
    final DocumentReference<Map<String, dynamic>> documentReference =
        await FirebaseFirestore.instance
            .collection(_firebasePath)
            .add(sequentialBuildModel.toJson());
    _sequentialBuildModel.add(SequentialBuildModel.fromJson(
        sequentialBuildModel.toJson(), documentReference.id));
  }

  //update the item in the firebase
  Future<void> updateSequentialBuildModelInFB(
      SequentialBuildModel sequentialBuildModel) async {
    await FirebaseFirestore.instance
        .collection(_firebasePath)
        .doc(sequentialBuildModel.id)
        .update(sequentialBuildModel.toJson());
  }
}
