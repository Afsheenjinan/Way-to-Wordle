import 'package:flutter/material.dart';

import 'alphabet.dart';

class Board extends StatelessWidget {
  const Board({Key? key, required this.keys}) : super(key: key);
  final List<List<Alphabet>> keys;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: keys
          .map((row) => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: row.map((e) => _Tile(letter: e.letter, bgColor: e.bgColor)).toList(),
              ))
          .toList(),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({Key? key, this.letter = ' ', this.bgColor = Colors.transparent}) : super(key: key);
  final String letter;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(4),
      height: 36,
      width: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        letter,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }
}
