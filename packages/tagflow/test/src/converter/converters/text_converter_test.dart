import 'dart:collection';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tagflow/tagflow.dart';

void main() {
  testWidgets('invokes linkTapCallback when anchor recognizer fires', (
    tester,
  ) async {
    String? tappedUrl;
    LinkedHashMap<String, String>? tappedAttributes;

    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: Tagflow(
            html: '<a href="https://google.com">Google</a>',
            options: TagflowOptions.defaults.copyWith(
              linkTapCallback: (url, attributes) {
                tappedUrl = url;
                tappedAttributes = attributes;
              },
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final linkRichText =
        tester
            .widgetList<RichText>(find.byType(RichText))
            .firstWhere((richText) => richText.text.toPlainText().contains(
              'Google',
            ));

    TapGestureRecognizer? findRecognizer(InlineSpan span) {
      if (span is TextSpan) {
        if ((span.text ?? '').contains('Google') &&
            span.recognizer is TapGestureRecognizer) {
          return span.recognizer! as TapGestureRecognizer;
        }
        for (final child in span.children ?? const <InlineSpan>[]) {
          final recognizer = findRecognizer(child);
          if (recognizer != null) return recognizer;
        }
      }
      return null;
    }

    final recognizer = findRecognizer(linkRichText.text);
    expect(recognizer, isNotNull);

    recognizer!.onTap?.call();
    await tester.pump();

    expect(tappedUrl, 'https://google.com');
    expect(tappedAttributes?['href'], 'https://google.com');
  });
}
