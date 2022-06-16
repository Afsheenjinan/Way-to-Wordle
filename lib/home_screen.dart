import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wordle_clone/board_layout.dart';

import 'alphabet.dart';
import 'keyboard_layout.dart';
import 'word_list.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<List<Alphabet>> _list = [];
  final Set<Alphabet> bag = {};
  final String _reference = fiveLetterWords[Random().nextInt(fiveLetterWords.length)];
  String _currentword = '     ';

  int rowIndex = 0, columnIndex = 0;

  @override
  void initState() {
    _list.add(_currentword.toAlphabetList());
    super.initState();
  }

  void _onEnter() {
    if (_currentword.contains(' ')) return;

    if (rowIndex > 5) return;

    List<Alphabet> alphabetList = _currentword.toAlphabetList();

    for (var i = 0; i < _reference.length; i++) {
      if (_currentword[i] == _reference[i]) {
        alphabetList[i].bgColor = Colors.green;
        bag.add(alphabetList[i]);
      } else if (_reference.contains(_currentword[i])) {
        alphabetList[i].bgColor = Colors.yellow;
        bag.add(alphabetList[i]);
      } else {
        alphabetList[i].bgColor = Colors.grey;
      }

      final Alphabet tileInBag = bag.firstWhere((e) => e.letter == _currentword[i], orElse: () => Alphabet(letter: ' '));

      if (tileInBag.bgColor != Colors.green) {
        bag.removeWhere((e) => tileInBag.letter == e.letter);
        bag.add(alphabetList[i]);
      }
    }
    setState(() {
      _list[rowIndex] = alphabetList;
      if (_currentword != _reference) {
        _currentword = '     ';
        if (rowIndex < 5) _list.add(_currentword.toAlphabetList());
      } else {}
    });

    rowIndex += 1;
    columnIndex = 0;
  }

  void _onBackspace() {
    if (columnIndex <= 0) return;

    setState(() {
      columnIndex -= 1;
      _currentword = _currentword.replacewith(columnIndex, ' ');
      _list[rowIndex] = _currentword.toAlphabetList();
    });
  }

  void _onKey(String val) {
    if (columnIndex >= _currentword.length) return;
    if (rowIndex > 5) return;

    setState(() {
      _currentword = _currentword.replacewith(columnIndex, val);
      _list[rowIndex] = _currentword.toAlphabetList();
      columnIndex += 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: FocusNode(),
      autofocus: true,
      onKeyEvent: _onKeyEvent,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('WORDLE in a Minute'),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Spacer(),
              Board(keys: _list),
              const Spacer(),
              Keyboard(onEnter: _onEnter, onDelete: _onBackspace, onKey: _onKey, scrabbleTiles: bag),
            ],
          ),
        ),
      ),
    );
  }

  KeyEventResult _onKeyEvent(event) {
    if (event is KeyUpEvent) {
      if (event.logicalKey == LogicalKeyboardKey.enter) {
        _onEnter;
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.backspace) {
        _onBackspace;
        return KeyEventResult.handled;
      } else {
        _onKey(event.logicalKey.keyLabel);
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }
}
