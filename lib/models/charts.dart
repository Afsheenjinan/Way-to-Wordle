import 'dart:math';

import 'package:flutter/material.dart';

class PieChart extends StatelessWidget {
  const PieChart({Key? key, required int winCount, required int lostCount, required double radius})
      : _winCount = winCount,
        _lostCount = lostCount,
        _radius = radius,
        super(key: key);

  final int _winCount;
  final int _lostCount;
  final double _radius;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Stack(alignment: Alignment.center, children: [
        Container(
          height: _radius,
          width: _radius,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: SweepGradient(
                colors: [Colors.green.shade700, Colors.green.shade100],
                stops: [_winCount / (_winCount + _lostCount), _winCount / (_winCount + _lostCount)],
                transform: const GradientRotation(-pi / 2)),
          ),
        ),
        Container(
            alignment: Alignment.center,
            height: _radius - 20,
            width: _radius - 20,
            decoration: BoxDecoration(
              // border: Border.all(color: Colors.grey),
              color: Theme.of(context).dialogBackgroundColor,
              shape: BoxShape.circle,
            ),
            child: Text(
              '${(_winCount / (_winCount + _lostCount) * 100).toStringAsFixed(1)} %',
              style: const TextStyle(fontWeight: FontWeight.bold),
            )),
      ]),
    );
  }
}

class BarChart extends StatelessWidget {
  const BarChart({
    Key? key,
    required Map<int, int> map,
  })  : _winMap = map,
        super(key: key);

  final Map<int, int> _winMap;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      // Column(children: List.generate(6, (index) => Text((index + 1).toString()), growable: false).reversed.toList(growable: false))
      child: SizedBox(
        child: Column(
          children: List.generate(6, (index) {
            int len = _winMap[index + 1]!;
            int maxValue = _winMap.values.reduce(max);
            int flexValue = maxValue - len;
            return Row(
              children: [
                Text(_winMap.keys.elementAt(index).toString()),
                const SizedBox(width: 10),
                Flexible(
                  flex: len,
                  child: Container(
                    height: 10,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: Colors.blue[300], borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(width: 10),
                Text(len.toString()),
                if (flexValue > 0) Spacer(flex: flexValue),
              ],
            );
          }, growable: false)
              .reversed
              .toList(),
        ),
      ),
    );
  }
}
