import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tagflow/tagflow.dart';
import 'package:tagflow_example/widgets/gallery_scaffold.dart';

const _answer = '''
## Why patches beat re-rendering

When a model streams an answer, every token changes the text. Tagflow keeps
**finished blocks** as they are and only patches the tail, so:

1. Paragraphs that are done keep their widget state.
2. Lists grow item by item.
3. Code fences stay code while they are open.

```dart
final stream = TagflowMarkdownStream();
await stream.addStream(tokens);
```

| Block      | Patched while streaming |
| ---------- | ----------------------- |
| Finished   | No                      |
| Last block | Yes                     |

> The token stream on this screen is simulated. Nothing leaves the device.
''';

/// Splits [text] into word-sized tokens, keeping whitespace, the way a
/// language model streams an answer.
List<String> tokenize(String text) {
  return RegExp(
    r'\s+|[^\s]{1,6}',
  ).allMatches(text).map((match) => match.group(0)!).toList(growable: false);
}

class StreamingExample extends StatefulWidget {
  const StreamingExample({super.key});

  @override
  State<StreamingExample> createState() => _StreamingExampleState();
}

class _StreamingExampleState extends State<StreamingExample> {
  static final _tokens = tokenize(_answer);

  late TagflowMarkdownStream _stream;
  Timer? _timer;
  int _received = 0;

  @override
  void initState() {
    super.initState();
    _start();
  }

  void _start() {
    _stream = TagflowMarkdownStream(id: 'streamed-answer');
    _received = 0;
    _timer = Timer.periodic(const Duration(milliseconds: 25), (_) {
      if (_received == _tokens.length) {
        _stop();
        setState(_stream.close);
        return;
      }
      _stream.add(_tokens[_received]);
      setState(() => _received++);
    });
  }

  void _stop() {
    _timer?.cancel();
    _timer = null;
  }

  void _replay() {
    _stop();
    final previous = _stream;
    setState(_start);
    previous.dispose();
  }

  void _finish() {
    _stop();
    final rest = _tokens.skip(_received).join();
    setState(() {
      if (rest.isNotEmpty) _stream.add(rest);
      _stream.close();
      _received = _tokens.length;
    });
  }

  @override
  void dispose() {
    _stop();
    _stream.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final streaming = _timer != null;
    return GalleryScaffold(
      title: 'Live streaming',
      description:
          'A simulated token stream fed into TagflowMarkdownStream and '
          'rendered by TagflowMarkdownStreamView. Finished blocks are never '
          'parsed again.',
      actions: [
        FilledButton.icon(
          key: const ValueKey('streaming-replay'),
          onPressed: _replay,
          icon: const Icon(Icons.replay),
          label: const Text('Replay'),
        ),
        OutlinedButton(
          key: const ValueKey('streaming-finish'),
          onPressed: streaming ? _finish : null,
          child: const Text('Finish now'),
        ),
      ],
      children: [
        Text(
          streaming
              ? 'Streaming: $_received of ${_tokens.length} tokens'
              : 'Done: ${_tokens.length} tokens, '
                    '${_stream.document.children.length} blocks',
          key: const ValueKey('streaming-status'),
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 16),
        TagflowMarkdownStreamView(stream: _stream),
      ],
    );
  }
}
