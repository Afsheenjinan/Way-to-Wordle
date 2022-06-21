import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/alphabet.dart';
import 'layouts/board_layout.dart';
import 'layouts/keyboard_layout.dart';

import 'data/word_5_list.dart';
import 'data/word_6_list.dart';
import 'data/word_7_list.dart';
import 'widgets/popup_dialog.dart';

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
  late int _lostCount, _winCount, _streak, _maxStreak;

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
    _letterCount = _isButtonSelected.indexOf(true) + 5;
    _rowLength = 6;

    _restart();
    super.initState();
  }

  void _restart() {
    _rowIndex = 0;
    _columnIndex = 0;
    _bag = {};
    _list = [];

    _winMap = decode(widget.snapshot.data?.getString('winCount $_letterCount') ?? encode({1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0}));
    _winCount = _winMap.values.reduce((value, element) => value + element);
    _lostCount = widget.snapshot.data?.getInt('lostCount $_letterCount') ?? 0;

    _streak = widget.snapshot.data?.getInt('streak $_letterCount') ?? 0;
    _maxStreak = widget.snapshot.data?.getInt('maxStreak $_letterCount') ?? 0;

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
    // print(_reference);
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

      alphabetList[i].rotation = true;

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
        setState(() => _lostCount++);
        widget.snapshot.data?.setInt('lostCount $_letterCount', _lostCount);
        if (_streak > _maxStreak) _maxStreak = _streak;
        _streak = 0;
        widget.snapshot.data?.setInt('streak $_letterCount', _streak);
        widget.snapshot.data?.setInt('maxStreak $_letterCount', _maxStreak);
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) => popupDialog(context,
              letterCount: _letterCount,
              lostCount: _lostCount,
              winCount: _winCount,
              streak: _streak,
              maxStreak: _maxStreak,
              winMap: _winMap,
              list: _list,
              reference: _reference,
              action: _restart),
        );
      }
    } else {
      _winMap[_rowIndex + 1] = _winMap[_rowIndex + 1]! + 1;
      setState(() => _winCount++);
      widget.snapshot.data?.setString('winCount $_letterCount', encode(_winMap));
      _streak++;
      if (_streak > _maxStreak) _maxStreak = _streak;
      widget.snapshot.data?.setInt('streak $_letterCount', _streak);
      widget.snapshot.data?.setInt('maxStreak $_letterCount', _maxStreak);

      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => popupDialog(
          context,
          letterCount: _letterCount,
          lostCount: _lostCount,
          winCount: _winCount,
          streak: _streak,
          maxStreak: _maxStreak,
          winMap: _winMap,
          list: _list,
          won: true,
          action: _restart,
        ),
      );
    }

    _rowIndex++;
    _columnIndex = 0;
    setState(() {});
  }

  void _onBackspace() {
    if (_columnIndex <= 0) return;
    _columnIndex--;
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

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _node,
      autofocus: true,
      onKeyEvent: _onKeyEvent,
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Guess The Word', textAlign: TextAlign.center),
            actions: [
              IconButton(onPressed: _restart, icon: const Icon(Icons.restart_alt_rounded, color: Colors.orange, size: 32)),
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
                const SizedBox(height: 20),
                ToggleButtons(
                  fillColor: Colors.transparent,
                  borderRadius: BorderRadius.circular(5.0),
                  constraints: const BoxConstraints(minHeight: 24.0, minWidth: 72, maxWidth: 120),
                  onPressed: _changeDifficulty,
                  isSelected: _isButtonSelected,
                  children: const [Text('5 Letters'), Text('6 Letters'), Text('7 Letters')],
                ),
                const SizedBox(height: 20),

                Expanded(child: Board(keys: _list)),
                // const Spacer(),
                Keyboard(onEnter: _onEnter, onDelete: _onBackspace, onKey: _onAtoZ, scrabbleTiles: _bag),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
