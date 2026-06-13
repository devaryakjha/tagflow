import 'package:flutter_test/flutter_test.dart';
import 'package:tagflow/legacy.dart';

void main() {
  group('TagflowContentPolicy', () {
    test('defaults block executable tags', () {
      expect(
        TagflowContentPolicy.defaults.decideTag('script').isAllowed,
        isFalse,
      );
      expect(
        TagflowContentPolicy.defaults.decideTag('iframe').isAllowed,
        isFalse,
      );
      expect(TagflowContentPolicy.defaults.decideTag('p').isAllowed, isTrue);
    });

    test('defaults reject unsafe urls', () {
      expect(
        TagflowContentPolicy.defaults.decideUrl(
          'javascript:alert(1)',
          resourceType: TagflowResourceType.link,
        ),
        const TagflowUrlPolicyDecision.disallow(
          TagflowUrlDecisionReason.disallowedScheme,
        ),
      );
      expect(
        TagflowContentPolicy.defaults.decideUrl(
          'data:text/html;base64,PHNjcmlwdD4=',
          resourceType: TagflowResourceType.link,
        ),
        const TagflowUrlPolicyDecision.disallow(
          TagflowUrlDecisionReason.dataUrlNotAllowed,
        ),
      );
    });

    test('uses explicit image resource rules', () {
      const policy = TagflowContentPolicy(
        allowRemoteImages: false,
        allowDataImages: true,
      );

      expect(
        policy.decideUrl(
          'https://example.com/image.png',
          resourceType: TagflowResourceType.image,
        ),
        const TagflowUrlPolicyDecision.disallow(
          TagflowUrlDecisionReason.remoteImagesDisabled,
        ),
      );
      expect(
        policy
            .decideUrl(
              'data:image/png;base64,AAAA',
              resourceType: TagflowResourceType.image,
            )
            .isAllowed,
        isTrue,
      );
    });

    test('supports custom allowlists and unsupported behavior', () {
      const policy = TagflowContentPolicy(
        allowedTags: {'p', 'strong'},
        unsupportedBehavior: TagflowUnsupportedBehavior.preservePlaceholder,
      );

      expect(policy.decideTag('strong').isAllowed, isTrue);
      expect(policy.decideTag('table').isAllowed, isFalse);
      expect(
        policy.unsupportedBehavior,
        TagflowUnsupportedBehavior.preservePlaceholder,
      );
    });
  });
}
