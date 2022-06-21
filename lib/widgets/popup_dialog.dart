import 'dart:math';

import 'package:flutter/material.dart';

import '../data/statement.dart';
import '../models/alphabet.dart';
import '../models/charts.dart';

Widget popupDialog(
  BuildContext context, {
  required int letterCount,
  required int winCount,
  required int lostCount,
  required int streak,
  required int maxStreak,
  required Map<int, int> winMap,
  required VoidCallback action,
  required List<List<Alphabet>> list,
  String reference = '',
  bool won = false,
}) {
  return AlertDialog(
    scrollable: true,
    title: Center(child: Text('$letterCount Letter Words')),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Divider(height: 8),
        won ? Text('${winCommands.elementAt(Random().nextInt(winCommands.length))} !') : const Text('You Can do Better !'),
        const Divider(height: 8),
        // const SizedBox(height: 10),
        SingleChildScrollView(scrollDirection: Axis.horizontal, child: showFinalBoard(keys: list)),
        const Divider(height: 8),
        if (reference.isNotEmpty) Text(reference, style: const TextStyle(letterSpacing: 5, color: Colors.red, fontWeight: FontWeight.w600)),
        if (reference.isNotEmpty) const Divider(height: 8),
        Flexible(
          child: SingleChildScrollView(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                PieChart(winCount: winCount, lostCount: lostCount, radius: 100),
                const SizedBox(width: 20),
                const SizedBox(width: 20),
                BarChart(map: winMap)
              ],
            ),
          ),
        ),
        const Divider(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [Text('Lost - $lostCount'), Text('Wins - $winCount')],
        ),
        const Divider(height: 8),
        Text('Streak - $streak [  Max: $maxStreak  ]'),
        const Divider(height: 8),
      ],
    ),
    actions: <Widget>[
      TextButton(
        onPressed: () {
          Navigator.of(context).pop();
          action();
        },
        child: Text(won ? 'New Game' : 'Try Again'),
      ),
    ],
  );
}

Widget showFinalBoard({required List<List<Alphabet>> keys}) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: keys
        .map((row) => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: row.map((e) {
                return Container(
                  height: 24,
                  width: 24,
                  margin: const EdgeInsets.all(5),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: e.bgColor, borderRadius: BorderRadius.circular(5)),
                  child: Text(e.letter, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                );
              }).toList(),
            ))
        .toList(),
  );
}
