import 'package:episode2/custom_editing_controller.dart';
import 'package:episode2/keyboard.dart';
import 'package:flutter/material.dart';

class KeyboardDemoPage extends StatefulWidget {
  const KeyboardDemoPage({super.key});

  @override
  State<KeyboardDemoPage> createState() => _KeyboardDemoPageState();
}

class _KeyboardDemoPageState extends State<KeyboardDemoPage> {
  final _controller = CustomTextEditingController(showInlineSuggestions: false);
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Autocomplete Keyboard Demo'),
      ),
      body: GestureDetector(
        onHorizontalDragEnd: (_) {
          _controller.acceptSuggestion();
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                focusNode: _focusNode,
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
              ),
            ),
            const Spacer(),
            Keyboard(
              controller: _controller,
              focusNode: _focusNode,
            ),
          ],
        ),
      ),
    );
  }
}
