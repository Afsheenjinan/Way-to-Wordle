import 'dart:math';

import 'package:flutter/material.dart';

import '../models/alphabet.dart';

class Board extends StatelessWidget {
  const Board({Key? key, required this.keys}) : super(key: key);
  final List<List<Alphabet>> keys;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        reverse: true,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: keys
              .map((row) => Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: row.map((e) => _Tile(alphabet: e)).toList(),
                  ))
              .toList(),
        ),
      ),
    );
  }
}

class _Tile extends StatefulWidget {
  const _Tile({Key? key, required this.alphabet}) : super(key: key);
  final Alphabet alphabet;

  @override
  State<_Tile> createState() => _TileState();
}

class _TileState extends State<_Tile> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation _animation;

  @override
  void initState() {
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _animation = Tween(begin: 0.0, end: 2 * pi).animate(CurvedAnimation(parent: _controller, curve: Curves.linear))
      ..addListener(() => setState(() {}));
    super.initState();
  }

  @override
  void dispose() {
    _controller
      ..removeListener(() {})
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.alphabet.rotation) {
      if (_controller.status != AnimationStatus.completed) {
        _controller.forward();

        if (_controller.value > 0.25 && _controller.value < 0.75) _controller.forward(from: 0.75);
      }
    } else {
      _controller.reset();
    }
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()
        ..setEntry(3, 2, -0.002)
        ..rotateY(_animation.value),
      child: Container(
        constraints: const BoxConstraints(minHeight: 36, minWidth: 36),
        margin: const EdgeInsets.all(5),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _animation.value > 3 * pi / 2 ? widget.alphabet.bgColor : Colors.transparent,
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(widget.alphabet.letter, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
