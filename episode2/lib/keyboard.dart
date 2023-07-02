import 'package:episode2/custom_editing_controller.dart';
import 'package:flutter/material.dart';

class Keyboard extends StatefulWidget {
  final CustomTextEditingController controller;
  final FocusNode focusNode;

  const Keyboard({
    super.key,
    required this.controller,
    required this.focusNode,
  });

  @override
  State<Keyboard> createState() => _KeyboardState();
}

class _KeyboardState extends State<Keyboard> {
  CustomTextEditingController get _controller => widget.controller;

  static const List<List<String>> _letterRows = [
    ['q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p'],
    ['a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l'],
    ['z', 'x', 'c', 'v', 'b', 'n', 'm'],
  ];

  static const List<List<String>> _numberAndSpecialCharacterRows = [
    ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'],
    ['-', '/', ':', ';', '(', ')', r'$', '&', '@', '"'],
    ['.', ',', '?', '!', "'", '+', '%'],
  ];

  late List<List<String>> _keyRows = _letterRows;

  bool _showingLetters = true;

  void _toggleShowingLetters() {
    setState(() {
      _showingLetters = !_showingLetters;
      if (_showingLetters) {
        _keyRows = _letterRows
            .map((e) => e
                .map((e) => _capsLockActive ? e.toUpperCase() : e.toLowerCase())
                .toList())
            .toList();
      } else {
        _keyRows = _numberAndSpecialCharacterRows;
      }
    });
  }

  bool _capsLockActive = false;

  void _toggleCapsLock() {
    setState(() {
      _capsLockActive = !_capsLockActive;

      if (_showingLetters) {
        _keyRows = _letterRows
            .map((e) => e
                .map((e) => _capsLockActive ? e.toUpperCase() : e.toLowerCase())
                .toList())
            .toList();
      }
    });
  }

  void _addChar(String char) {
    if (!widget.focusNode.hasFocus) {
      widget.focusNode.requestFocus();
    }
    final text = _controller.text += char;
    _controller.selection = TextSelection.fromPosition(
      TextPosition(offset: text.length),
    );
  }

  void _addSuggestion(String suggestion) {
    if (suggestion.isEmpty) return;
    final lastText = _controller.text.split(' ').last;

    final text =
        _controller.text += '${suggestion.substring(lastText.length)} ';
    _controller.selection = TextSelection.fromPosition(
      TextPosition(offset: text.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<String>>(
        valueListenable: _controller.multiSuggestionNotifier,
        builder: (context, data, __) {
          List<String> suggestions = data;
          if (suggestions.isEmpty) {
            suggestions = List.generate(3, (index) => '');
          }
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4) +
                const EdgeInsets.only(bottom: 24),
            color: const Color.fromRGBO(43, 43, 43, 1),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    for (int i = 0; i < suggestions.length; i++)
                      _SuggestedText(
                        key: ValueKey(
                          'SuggestedText at position $i: ${suggestions[i]}',
                        ),
                        data: suggestions[i],
                        onTap: _addSuggestion,
                        withSeparator: suggestions[i].isNotEmpty &&
                            i != suggestions.length - 1,
                      ),
                  ],
                ),
                for (final row in _keyRows.sublist(0, 2)) ...{
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (int i = 0; i < row.length; i++)
                          _KeyWidget(
                            key: ValueKey('Key->${row[i]}'),
                            data: row[i],
                            showMargin: i != row.length - 1,
                            onTap: _addChar,
                          ),
                      ],
                    ),
                  ),
                },
                Row(
                  children: [
                    _CapsLockKey(
                      key: const ValueKey("capslock"),
                      active: _capsLockActive,
                      onTap: _toggleCapsLock,
                    ),
                    const Spacer(),
                    for (final row in _keyRows.last) ...{
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (int i = 0; i < row.length; i++)
                            _KeyWidget(
                              key: ValueKey('Key->${row[i]}'),
                              data: row[i],
                              onTap: _addChar,
                            ),
                        ],
                      ),
                    },
                    const Spacer(),
                    _BackSpace(
                      key: const ValueKey('backspace'),
                      onTap: () {
                        if (_controller.text.isNotEmpty) {
                          String text = _controller.text;
                          final length = text.length;
                          text = _controller.text =
                              text.replaceRange(length - 1, null, '');
                          _controller.selection = TextSelection.fromPosition(
                            TextPosition(offset: text.length),
                          );
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _KeyWidget(
                      fontSize: 14,
                      data: _showingLetters ? '123' : 'ABC',
                      onTap: (_) => _toggleShowingLetters(),
                    ),
                    const SizedBox(width: 12),
                    _SpaceBar(
                      key: const ValueKey('spacebar'),
                      onTap: () {
                        _addChar(' ');
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        });
  }
}

class _SuggestedText extends StatelessWidget {
  final String data;
  final Function(String) onTap;
  final bool withSeparator;

  const _SuggestedText({
    super.key,
    required this.data,
    required this.onTap,
    this.withSeparator = true,
  });

  @override
  Widget build(BuildContext context) {
    final button = TextButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.resolveWith(
          (states) {
            if (states.contains(MaterialState.pressed)) {
              return const Color.fromRGBO(251, 250, 250, 1);
            }
            return Colors.transparent;
          },
        ),
        fixedSize: MaterialStateProperty.resolveWith(
          (states) => Size(MediaQuery.of(context).size.width * .28, 40),
        ),
      ),
      onPressed: () => onTap(data),
      child: Text(
        data,
        style: const TextStyle(color: Colors.white),
      ),
    );
    if (withSeparator) {
      return Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          button,
          const SizedBox(
            height: 40,
            child: VerticalDivider(
              indent: 8,
              endIndent: 8,
              color: Color.fromRGBO(251, 250, 250, 1),
            ),
          ),
        ],
      );
    }
    return button;
  }
}

class _SpaceBar extends StatelessWidget {
  final VoidCallback onTap;
  const _SpaceBar({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        width: MediaQuery.of(context).size.width * .8,
        decoration: BoxDecoration(
          color: const Color.fromRGBO(106, 106, 106, 1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Center(
          child: Text(
            "space",
            style: TextStyle(
              color: Color.fromRGBO(251, 250, 250, 1),
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }
}

class _KeyWidget extends StatelessWidget {
  final String data;
  final Function(String) onTap;
  final bool showMargin;
  final double fontSize;

  const _KeyWidget({
    super.key,
    required this.data,
    required this.onTap,
    this.showMargin = true,
    this.fontSize = 19.5,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(data),
      child: Container(
        height: 40,
        width: 34,
        margin: showMargin ? const EdgeInsets.only(right: 4) : EdgeInsets.zero,
        decoration: BoxDecoration(
          color: const Color.fromRGBO(106, 106, 106, 1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: Text(
            data,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color.fromRGBO(251, 250, 250, 1),
              fontSize: fontSize,
            ),
          ),
        ),
      ),
    );
  }
}

class _BackSpace extends StatelessWidget {
  final VoidCallback onTap;
  const _BackSpace({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 42,
        width: 40,
        padding: const EdgeInsets.all(6),
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: const Color.fromRGBO(70, 70, 70, 1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Icon(
          Icons.backspace_outlined,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }
}

class _CapsLockKey extends StatelessWidget {
  final bool active;
  final VoidCallback onTap;

  const _CapsLockKey({
    super.key,
    required this.active,
    required this.onTap,
  });

  Color get _activeColor => const Color.fromRGBO(213, 212, 212, 1);
  Color get _inactiveColor => const Color.fromRGBO(70, 70, 70, 1);

  String get _image => "assets/${active ? 'shift_filled' : 'shift'}.png";

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 42,
        width: 40,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: active ? _activeColor : _inactiveColor,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Image.asset(
          _image,
          color: active ? Colors.black : Colors.white,
          height: 12,
          width: 12,
        ),
      ),
    );
  }
}
