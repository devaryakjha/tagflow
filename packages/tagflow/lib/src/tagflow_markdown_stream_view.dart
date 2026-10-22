import 'package:flutter/widgets.dart';
import 'package:tagflow/src/adapters/markdown_stream.dart';
import 'package:tagflow/src/render/render.dart';
import 'package:tagflow/src/style/theme.dart';
import 'package:tagflow/src/tagflow_options.dart';
import 'package:tagflow/src/tagflow_widget.dart';

/// Renders the current document of a [TagflowMarkdownStream] and rebuilds as
/// chunks arrive.
///
/// Rendering goes through [Tagflow.document], which keys every node by its
/// id, so blocks that are already complete keep their widget state while the
/// tail of the answer grows.
class TagflowMarkdownStreamView extends StatelessWidget {
  /// Creates a view of [stream].
  const TagflowMarkdownStreamView({
    required this.stream,
    this.theme,
    this.registry,
    this.viewOptions,
    super.key,
  });

  /// The stream to render. The caller owns it and disposes it.
  final TagflowMarkdownStream stream;

  /// Custom theme passed to [Tagflow.document].
  final TagflowTheme? theme;

  /// Component registry passed to [Tagflow.document].
  final TagflowComponentRegistry? registry;

  /// Runtime view options passed to [Tagflow.document].
  final TagflowViewOptions? viewOptions;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: stream,
      builder: (context, _) => Tagflow.document(
        stream.document,
        theme: theme,
        registry: registry,
        viewOptions: viewOptions,
      ),
    );
  }
}
