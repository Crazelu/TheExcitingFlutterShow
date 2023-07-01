import 'dart:async' show Timer;
import 'package:episode2/trie.dart';
import 'package:episode2/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Autocomplete Demo',
      theme: ThemeData(
        primarySwatch: Colors.grey,
      ),
      home: const MyHomePage(title: 'Autocomplete Demo'),
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
  final _controller = CustomTextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: GestureDetector(
        onHorizontalDragEnd: (_) {
          _controller.acceptSuggestion();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ValueListenableBuilder(
                    valueListenable: _controller.suggestionNotifier,
                    builder: (context, _, __) {
                      return TextField(
                        cursorColor: Colors.black26,
                        controller: _controller,
                        maxLines: 14,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.grey.shade400,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.grey.shade400,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ),
                      );
                    }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

///Custom text editing controller that attaches a listener
///to its value for autocomplete suggestions.
///
///It's responsible for painting suggestions and exposes
///[acceptSuggestion] for callers to add the
///current suggestion to [text] value.
class CustomTextEditingController extends TextEditingController {
  CustomTextEditingController() {
    _prepareTrie();
    addListener(_listener);
  }

  Timer? _timer;

  final _trie = Trie();

  ///Load words from story.txt into trie after
  ///cleaning out empty spaces, new lines and
  ///other special characters.
  void _prepareTrie() async {
    String text = await rootBundle.loadString("assets/story.txt");

    List<String> split = text.split('\n');
    text = split.join(' ');
    split = text.split('--');
    text = split.join(' ');
    split = text.split(' ');

    final uniqueWords = {...split};

    for (var text in uniqueWords) {
      final cleanText = Util.clean(text);
      if (cleanText.isNotEmpty) {
        _trie.insert(cleanText);
      }
    }
  }

  ///Notifier for any available autocomplete suggestion.
  ValueNotifier<String?> get suggestionNotifier => _suggestionNotifier;
  final ValueNotifier<String?> _suggestionNotifier = ValueNotifier(null);

  ///Appends suggested suffix to [text] and
  ///clears [suggestionNotifier]'s value.
  void acceptSuggestion() {
    final suggestion = _suggestionNotifier.value ?? "";
    text += suggestion;
    _suggestionNotifier.value = null;
    selection = TextSelection.fromPosition(
      TextPosition(offset: text.length),
    );
  }

  ///Listener attached to this [TextEditingController] to
  ///find autocomplete suggestions when user pauses typing.
  void _listener() {
    _suggestionNotifier.value = null;
    _timer?.cancel();
    _timer = Timer(
      const Duration(milliseconds: 500),
      () {
        if (text.isNotEmpty) {
          final lastText = text.split(' ').last;
          if (lastText.isNotEmpty) {
            final suggestions = _trie.autoComplete(
              prefix: lastText.toLowerCase(),
            );

            if (suggestions.isNotEmpty) {
              _suggestionNotifier.value =
                  suggestions.first.substring(lastText.length);
            } else {
              _suggestionNotifier.value = null;
            }
          }
          _timer?.cancel();
        }
      },
    );
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
      if (_suggestionNotifier.value != null) {
        List<TextSpan> children = [
          TextSpan(text: text),
          TextSpan(
            text: _suggestionNotifier.value,
            style: style?.merge(
              TextStyle(color: style.color?.withOpacity(.3)),
            ),
          ),
        ];

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

  @override
  void dispose() {
    removeListener(_listener);
    _timer?.cancel();
    _suggestionNotifier.dispose();
    super.dispose();
  }
}
