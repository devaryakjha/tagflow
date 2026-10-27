// Fix tests for lib/fix_data.yaml. Each call below has its migrated form in
// tagflow.dart.expect; run `dart fix --compare-to-golden` in this folder.

import 'package:flutter/widgets.dart' hide ErrorWidgetBuilder;
import 'package:tagflow/tagflow.dart';

void main() {
  // Changes made in 1.0.0-beta.1.

  // Default constructor.
  const Tagflow(html: '<p>Hello</p>');
  Tagflow(html: '<p>Hello</p>', key: UniqueKey());
  Tagflow(html: '<p>Hello</p>', options: const TagflowOptions(debug: true));

  // options: parameters.
  Tagflow.html(
    html: '<p>Hello</p>',
    options: const TagflowOptions(enableImageCache: false),
  );
  Tagflow.document(
    TagflowDocument(id: 'doc', children: const []),
    options: const TagflowOptions(),
  );
  const TagflowHtmlAdapter().parse(
    '<p>Hello</p>',
    options: const TagflowOptions(maxImageWidth: 320),
  );

  // An options variable migrates along with its initializer.
  final options = TagflowOptions(linkTapCallback: (url, attributes) {});
  Tagflow.html(html: '<p>Hello</p>', options: options);

  // TagflowScope.
  TagflowScope(options: options, child: const SizedBox());

  // renderBoundary has no TagflowViewOptions equivalent, so this call is left
  // for a manual migration.
  const TagflowOptions(
    renderBoundary: TagflowRenderBoundary.comment(start: 'start'),
  );

  // ErrorWidgetBuilder.
  ErrorWidgetBuilder? errorBuilder;
  Tagflow.html(html: '<p>Hello</p>', errorBuilder: errorBuilder!);
}
