
import 'package:flutter/material.dart';

class SignesModel {
  List<int> _selected = [];
  List<int> get selected => _selected;
  List<String> signes = [
    "DGcompressedgasses2.png",
    "coldchain.png",
    "DGcompressedgasses.png",
  ];

  Widget getSigne(int index) {
    return Image.asset("assets/signes/${signes[index]}");
  }

  Widget horizontalSelection(){
    ScrollController scrollController = ScrollController();
    return StatefulBuilder(builder: (context, setState)
    {
      return Scrollbar(
        controller: scrollController,
        child: SingleChildScrollView(
          controller: scrollController,
          scrollDirection: Axis.horizontal,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: List.generate(signes.length, (index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (_selected.contains(index)) {
                        _selected.remove(index);
                      } else {
                        _selected.add(index);
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(3.0),
                    width: 40,
                    height: 40,
                    //border if selected
                    decoration: _selected.contains(index) ? BoxDecoration(
                      border: Border.all(
                        color: Colors.blue,
                        width: 2,
                      ),
                    ) : null,
                    child: getSigne(index),
                  ),
                );
              }),
            ),
          ),
        ),
      );
    }
    );

  }
}
