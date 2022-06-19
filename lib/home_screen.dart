import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wordle_clone/board_layout.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'alphabet.dart';
import 'charts.dart';
import 'keyboard_layout.dart';
import 'statement.dart';
import 'word_5_list.dart';
import 'word_6_list.dart';
import 'word_7_list.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    Key? key,
    required this.pref,
    required this.snapshot,
  }) : super(key: key);
  final Future<SharedPreferences> pref;
  final AsyncSnapshot<SharedPreferences> snapshot;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final RegExp _regAtoZ = RegExp(r'^([A-Z]{1})$');
  final FocusNode _node = FocusNode();
  late List<List<Alphabet>> _list;
  late Set<Alphabet> _bag;
  late Map<int, int> _winMap;
  late int _lostCount, _winCount;

  late int _letterCount, _rowLength;
  late String _currentword, _reference;

  late int _rowIndex, _columnIndex;

  final _isButtonSelected = [true, false, false];

  @override
  void dispose() {
    _node
      ..removeListener(() {})
      ..dispose();
    super.dispose();
  }

  @override
  void initState() {
    _winMap = _decode(widget.snapshot.data?.getString('winCount') ?? _encode({1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0}));
    _winCount = _winMap.keys.reduce((value, element) => value + element);

    _lostCount = widget.snapshot.data?.getInt('lostCount') ?? 0;
    print('_lostCount : $_lostCount');
    print('_winCount : $_winMap');

    _letterCount = _isButtonSelected.indexOf(true) + 5;
    _rowLength = 3;
    _restart();
    super.initState();
  }

  String _encode(Map<int, int> intMap) => jsonEncode(intMap.map((key, value) => MapEntry(key.toString(), value)));
  Map<int, int> _decode(String jsonString) {
    Map<String, dynamic> qwe = jsonDecode(jsonString);
    return qwe.map<int, int>((key, value) => MapEntry(int.parse(key), value));
  }

  void _restart() {
    _rowIndex = 0;
    _columnIndex = 0;
    _bag = {};
    _list = [];

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
    // _list.add(_currentword.toAlphabetList());
    setState(() {
      _currentword = ' ' * _letterCount;
      _list = [..._list, _currentword.toAlphabetList()];
    });
    print(_reference);
  }

  void _onEnter() {
    if (_currentword.contains(' ')) return;
    // if (_rowIndex >= _rowLength) return;

    List<Alphabet> alphabetList = _currentword.toAlphabetList();

    for (int i = 0; i < _letterCount; i++) {
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
        // _list.add(_currentword.toAlphabetList());
        setState(() {
          _list = [..._list, _currentword.toAlphabetList()];
        });
      } else {
        setState(() {
          _lostCount++;
        });
        widget.snapshot.data?.setInt('lostCount', _lostCount);
        showDialog(context: context, builder: (context) => _popupDialog(context), barrierDismissible: false);
      }
    } else {
      _winMap[_rowIndex + 1] = _winMap[_rowIndex + 1]! + 1;
      setState(() {
        _winCount++;
      });
      widget.snapshot.data?.setString('winCount', _encode(_winMap));

      showDialog(context: context, builder: (context) => _popupDialog(context, won: true), barrierDismissible: false);
    }

    _rowIndex += 1;
    _columnIndex = 0;
    setState(() {});
  }

  void _onBackspace() {
    if (_columnIndex <= 0) return;

    _columnIndex -= 1;
    _currentword = _currentword.replacewith(_columnIndex, ' ');
    _list[_rowIndex] = _currentword.toAlphabetList();
    setState(() {});
  }

  void _onAtoZ(String val) {
    if (_columnIndex >= _letterCount) return;
    if (_rowIndex >= _rowLength) return;

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
              PieChart(winCount: _winCount, lostCount: _lostCount, radius: 100),
              const SizedBox(width: 20),
              Column(children: List.generate(6, (index) => Text((index + 1).toString()), growable: false).reversed.toList()),
              const SizedBox(width: 20),
              BarChart(map: _winMap)
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
    // print('build');
    return KeyboardListener(
      focusNode: _node,
      autofocus: true,
      onKeyEvent: _onKeyEvent,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'WORDLE\nin a Minute',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black),
          ),
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
                isSelected: _isButtonSelected,
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
    int oldIndex = _isButtonSelected.indexOf(true);
    if (oldIndex != index) {
      _isButtonSelected[oldIndex] = false;
      _isButtonSelected[index] = true;
      _letterCount = index + 5;
      _restart();
      setState(() {});
    }
  }
}
