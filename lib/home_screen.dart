import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wordle_clone/board_layout.dart';

import 'alphabet.dart';
import 'charts.dart';
import 'keyboard_layout.dart';
import 'statement.dart';
import 'word_5_list.dart';
import 'word_6_list.dart';
import 'word_7_list.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final RegExp _regAtoZ = RegExp(r'^([A-Z]{1})$');
  final FocusNode _node = FocusNode();
  late List<List<Alphabet>> _list;
  late Set<Alphabet> _bag;
  late Map<int, int> _winMap;

  late int _winCount, _lostCount, _totalPlayed;
  late int _letterCount, _rowLength;
  late String _currentword, _reference;

  late int _rowIndex, _columnIndex;

  final isButtonSelected = [true, false, false];

  @override
  void dispose() {
    _node
      ..removeListener(() {})
      ..dispose();
    super.dispose();
  }

  @override
  void initState() {
    _winMap = {1: 7, 2: 5, 3: 3, 4: 8, 5: 15, 6: 14};
    _winCount = _winMap.keys.reduce((value, element) => value + element);
    _lostCount = 46;
    _totalPlayed = _winCount + _lostCount;

    _letterCount = isButtonSelected.indexOf(true) + 5;
    _rowLength = 1;

    _restart();
    super.initState();
  }

  void _restart() {
    _rowIndex = 0;
    _columnIndex = 0;
    _bag = {};
    _list = [];
    // if (_list.isNotEmpty) _list.clear();
    // if (_bag.isNotEmpty) _bag.clear();
    switch (_letterCount) {
      case 5:
        _reference = $5letterWords.elementAt(Random().nextInt($5letterWords.length));
        break;
      case 6:
        _reference = $6letterWords.elementAt(Random().nextInt($6letterWords.length));
        break;
      case 7:
        _reference = $7letterWords.elementAt(Random().nextInt($7letterWords.length));
        break;
      default:
    }
    _currentword = ' ' * _letterCount;
    _list.add(_currentword.toAlphabetList());
    setState(() {});

    print(_reference);
  }

  void _onEnter() {
    if (_currentword.contains(' ')) return;
    print(_rowIndex);
    // if (_rowIndex >= _rowLength) return;

    List<Alphabet> alphabetList = _currentword.toAlphabetList();

    for (var i = 0; i < _letterCount; i++) {
      if (_currentword[i] == _reference[i]) {
        alphabetList[i].bgColor = Colors.green;
        _bag.add(alphabetList[i]);
      } else if (_reference.contains(_currentword[i])) {
        alphabetList[i].bgColor = Colors.yellow;
        _bag.add(alphabetList[i]);
      } else {
        alphabetList[i].bgColor = Colors.grey;
      }

      final Alphabet tileInBag = _bag.firstWhere((e) => e.letter == _currentword[i], orElse: () => Alphabet(letter: ' '));

      if (tileInBag.bgColor != Colors.green) {
        _bag.removeWhere((e) => tileInBag.letter == e.letter);
        _bag.add(alphabetList[i]);
      }
    }
    _list[_rowIndex] = alphabetList;

    if (_currentword != _reference) {
      _currentword = ' ' * _letterCount;
      if (_rowIndex < _rowLength - 1) {
        _list.add(_currentword.toAlphabetList());
      } else {
        _lostCount += 1;
        showDialog(context: context, builder: (context) => _popupDialog(context), barrierDismissible: false);
      }
    } else {
      showDialog(context: context, builder: (context) => _popupDialog(context, won: true), barrierDismissible: false);
    }
    setState(() {});

    _rowIndex += 1;
    _columnIndex = 0;
  }

  void _onBackspace() {
    if (_columnIndex <= 0) return;

    setState(() {
      _columnIndex -= 1;
      _currentword = _currentword.replacewith(_columnIndex, ' ');
      _list[_rowIndex] = _currentword.toAlphabetList();
    });
  }

  void _onAtoZ(String val) {
    if (_columnIndex >= _letterCount) return;
    if (_rowIndex > 5) return;

    _currentword = _currentword.replacewith(_columnIndex, val);
    _list[_rowIndex] = _currentword.toAlphabetList();
    _columnIndex += 1;
    setState(() {});
  }

  void _onKeyEvent(KeyEvent event) {
    if (event is KeyUpEvent) {
      LogicalKeyboardKey logicalKeyboardKey = event.logicalKey;
      if (logicalKeyboardKey == LogicalKeyboardKey.enter) {
        _onEnter();
      } else if (logicalKeyboardKey == LogicalKeyboardKey.backspace) {
        _onBackspace();
      } else {
        if (_regAtoZ.hasMatch(logicalKeyboardKey.keyLabel)) _onAtoZ(logicalKeyboardKey.keyLabel);
      }
    }
    // return KeyEventResult.handled;
  }

  Widget _popupDialog(BuildContext context, {bool won = false}) {
    return AlertDialog(
      elevation: 32,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          won ? Text('${winCommands.elementAt(Random().nextInt(winCommands.length))} !') : const Text('You Can do Better !'),
          const Divider(height: 24),
          // const SizedBox(height: 10),
          Row(
            children: [
              PieChart(winCount: _winCount, totalPlayed: _totalPlayed, radius: 100),
              const SizedBox(width: 20),
              Column(children: List.generate(6, (index) => Text((index + 1).toString()), growable: false).reversed.toList()),
              const SizedBox(width: 20),
              SizedBox(
                width: 150,
                child: Column(
                  children: List.generate(6, (index) {
                    int len = _winMap[index + 1]!;
                    int maxValue = _winMap.values.reduce(max);
                    int flexValue = maxValue - len;
                    return Row(
                      children: [
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
              )
            ],
          ),
          const Divider(),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            _restart();
          },
          child: Text(won ? 'New Game' : 'Try Again'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _node,
      autofocus: true,
      onKeyEvent: _onKeyEvent,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('WORDLE in a Minute'),
          actions: [
            IconButton(
                onPressed: _restart,
                icon: const Icon(
                  Icons.restart_alt_rounded,
                  color: Colors.orange,
                  size: 32,
                )),
            const SizedBox(width: 10)
          ],
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ToggleButtons(
                fillColor: Colors.transparent,
                borderRadius: BorderRadius.circular(5.0),
                constraints: const BoxConstraints(minHeight: 24.0, minWidth: 72, maxWidth: 120),
                onPressed: _changeDifficulty,
                isSelected: isButtonSelected,
                children: const [Text('5 Letters'), Text('6 Letters'), Text('7 Letters')],
              ),
              const Spacer(),
              Board(keys: _list),
              const Spacer(),
              Keyboard(onEnter: _onEnter, onDelete: _onBackspace, onKey: _onAtoZ, scrabbleTiles: _bag),
            ],
          ),
        ),
      ),
    );
  }

  void _changeDifficulty(index) {
    int oldIndex = isButtonSelected.indexOf(true);
    if (oldIndex != index) {
      isButtonSelected[oldIndex] = false;
      isButtonSelected[index] = true;
      _letterCount = index + 5;
      print(_letterCount);
      _restart();
      setState(() {});
    }
  }
}
