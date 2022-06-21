import 'dart:convert';

import 'package:flutter/material.dart';

class Alphabet {
  String letter;
  Color bgColor = Colors.transparent;
  bool rotation = false;

  Alphabet({required this.letter});

  @override
  toString() => letter;
}

extension ModifedString on String {
  String replacewith(int index, String str) => substring(0, index) + str + substring(index + 1);
  List<Alphabet> toAlphabetList() => split('').map((e) => Alphabet(letter: e)).toList(growable: false);
}

String encode(Map<int, int> intMap) => jsonEncode(intMap.map((key, value) => MapEntry(key.toString(), value)));
Map<int, int> decode(String jsonString) {
  Map<String, dynamic> qwe = jsonDecode(jsonString);
  return qwe.map<int, int>((key, value) => MapEntry(int.parse(key), value));
}
