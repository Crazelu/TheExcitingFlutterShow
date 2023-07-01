import 'package:episode2/custom_editing_controller.dart';
import 'package:flutter/material.dart';

class InlineDemoPage extends StatefulWidget {
  const InlineDemoPage({super.key});

  @override
  State<InlineDemoPage> createState() => _InlineDemoPageState();
}

class _InlineDemoPageState extends State<InlineDemoPage> {
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
        title: const Text('Autocomplete Inline Demo'),
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
