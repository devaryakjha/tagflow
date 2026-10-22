/// Legacy HTML parser and converter compatibility surface.
///
/// This library is deprecated and will be removed in tagflow 2.0. It stays
/// available, unchanged, for every 1.x release. New code should render through
/// the semantic runtime from `package:tagflow/tagflow.dart`:
///
/// - `Tagflow.html(...)` or `TagflowHtmlAdapter` instead of `TagflowParser`
/// - `TagflowComponentRegistry` instead of `ElementConverter`
/// - `TagflowViewOptions` instead of `TagflowOptions`
@Deprecated(
  'Use package:tagflow/tagflow.dart and the semantic runtime '
  '(TagflowComponentRegistry) instead. '
  'package:tagflow/legacy.dart will be removed in tagflow 2.0.',
)
library;

export 'src/adapters/html_adapter.dart' show TagflowHtmlDocumentBridge;
export 'src/converter/converter.dart';
export 'src/converter/converters/converters.dart';
export 'src/converter/styled_container.dart';
export 'src/core/core.dart';
export 'src/core/models/models.dart';
export 'src/core/parser/parsers.dart';
export 'src/core/utils/utils.dart';
export 'src/widgets/widgets.dart';
export 'tagflow.dart';
