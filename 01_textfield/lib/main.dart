import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TheExcitingFlutterShow Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'TheExcitingFlutterShow (EP 01)'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final _undoController = UndoHistoryController();
  late final _editingController = CustomEditingController(
    pattern: RegExp(r"\Flutter"),
    customStyle: const TextStyle(
      color: Color(0xff0367d7),
      fontWeight: FontWeight.bold,
    ),
  );

  TextStyle? get enabledStyle => Theme.of(context).textTheme.bodyMedium;
  TextStyle? get disabledStyle =>
      Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey);

  @override
  void initState() {
    super.initState();
    // Future.microtask(() {
    //   _controller.setStyle(Theme.of(context).textTheme.headlineMedium!.copyWith(
    //         color: const Color(0xfff9a602),
    //         fontWeight: FontWeight.bold,
    //       ));
    // });
  }

  @override
  void dispose() {
    _undoController.dispose();
    _editingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _editingController,
              undoController: _undoController,
              maxLines: 4,
              decoration: const InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.blueAccent,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.blueAccent,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ValueListenableBuilder<UndoHistoryValue>(
              valueListenable: _undoController,
              builder: (context, value, _) {
                if (value == UndoHistoryValue.empty) return const SizedBox();
                return Row(
                  children: [
                    TextButton(
                      child: Text(
                        'Undo',
                        style: value.canUndo ? enabledStyle : disabledStyle,
                      ),
                      onPressed: () {
                        _undoController.undo();
                      },
                    ),
                    TextButton(
                      child: Text(
                        'Redo',
                        style: value.canRedo ? enabledStyle : disabledStyle,
                      ),
                      onPressed: () {
                        _undoController.redo();
                      },
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

///A [TextEditingController] that applies [customStyle] to [pattern]
///wherever it appears in [TextEditingController.text].
class CustomEditingController extends TextEditingController {
  final RegExp pattern;
  late TextStyle? _customStyle;

  CustomEditingController({
    required this.pattern,
    TextStyle? customStyle,
  }) : _customStyle = customStyle;

  void setStyle(TextStyle style) {
    _customStyle = style;
  }

  /// Builds [TextSpan] from current editing value.
  ///
  /// By default makes text in composing range appear as underlined. Descendants
  /// can override this method to customize appearance of text.
  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    assert(!value.composing.isValid ||
        !withComposing ||
        value.isComposingRangeValid);
    // If the composing range is out of range for the current text, ignore it to
    // preserve the tree integrity, otherwise in release mode a RangeError will
    // be thrown and this EditableText will be built with a broken subtree.
    final bool composingRegionOutOfRange =
        !value.isComposingRangeValid || !withComposing;

    if (composingRegionOutOfRange) {
      final matches = pattern.allMatches(text).toList();

      if (matches.isNotEmpty) {
        List<TextSpan> children = [
          TextSpan(text: text.substring(0, matches.first.start))
        ];

        for (int i = 0; i < matches.length; i++) {
          final match = matches[i];
          children.add(TextSpan(
            style: style?.merge(_customStyle),
            text: text.substring(match.start, match.end),
          ));
          if (i + 1 <= matches.length - 1) {
            children.add(TextSpan(
              text: text.substring(match.end, matches[i + 1].start),
            ));
          } else {
            children.add(TextSpan(
              text: text.substring(match.end),
            ));
          }
        }

        return TextSpan(style: style, children: children);
      }

      return TextSpan(style: style, text: text);
    }

    final TextStyle composingStyle =
        style?.merge(const TextStyle(decoration: TextDecoration.underline)) ??
            const TextStyle(decoration: TextDecoration.underline);

    return TextSpan(
      style: style,
      children: <TextSpan>[
        TextSpan(text: value.composing.textBefore(value.text)),
        TextSpan(
          style: composingStyle,
          text: value.composing.textInside(value.text),
        ),
        TextSpan(text: value.composing.textAfter(value.text)),
      ],
    );
  }
}
