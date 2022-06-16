import 'package:flutter/material.dart';

class Alphabet {
  String letter;
  Color bgColor = Colors.transparent;

  Alphabet({required this.letter});
}

extension ModifedString on String {
  String replacewith(int index, String str) {
    return substring(0, index) + str + substring(index + 1);
  }

  List<Alphabet> toAlphabetList() {
    List<Alphabet> list = [];

    for (var letter in split('')) {
      list.add(Alphabet(letter: letter));
    }

    return list;
  }
}
