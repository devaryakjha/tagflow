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

    group('relative URLs', () {
      const noBase = TagflowContentPolicy.defaults;
      final withBase = TagflowContentPolicy(
        baseUrl: Uri.parse('https://example.com/docs/page.html'),
      );

      TagflowUrlPolicyDecision decide(
        TagflowContentPolicy policy,
        String url,
        TagflowResourceType type,
      ) {
        return policy.decideUrl(url, resourceType: type);
      }

      test('should reject scheme-relative URLs without a base', () {
        for (final type in TagflowResourceType.values) {
          expect(
            decide(noBase, '//evil.example/x', type),
            const TagflowUrlPolicyDecision.disallow(
              TagflowUrlDecisionReason.missingBaseUrl,
            ),
          );
        }
      });

      test('should reject relative images without a base', () {
        expect(
          decide(noBase, 'img/logo.png', TagflowResourceType.image),
          const TagflowUrlPolicyDecision.disallow(
            TagflowUrlDecisionReason.missingBaseUrl,
          ),
        );
      });

      test('should keep relative links as written without a base', () {
        expect(
          decide(noBase, '../guide#intro', TagflowResourceType.link),
          TagflowUrlPolicyDecision.allow(Uri.parse('../guide#intro')),
        );
      });

      test('should resolve relative URLs against the base', () {
        expect(
          decide(withBase, 'img/logo.png', TagflowResourceType.image),
          TagflowUrlPolicyDecision.allow(
            Uri.parse('https://example.com/docs/img/logo.png'),
          ),
        );
        expect(
          decide(withBase, '/about', TagflowResourceType.link),
          TagflowUrlPolicyDecision.allow(
            Uri.parse('https://example.com/about'),
          ),
        );
      });

      test('should resolve scheme-relative URLs with the base scheme', () {
        expect(
          decide(withBase, '//cdn.example/a.png', TagflowResourceType.image),
          TagflowUrlPolicyDecision.allow(
            Uri.parse('https://cdn.example/a.png'),
          ),
        );
      });

      test('should check resolved URLs against the allowed schemes', () {
        final ftpBase = TagflowContentPolicy(
          baseUrl: Uri.parse('ftp://files.example/'),
        );

        expect(
          decide(ftpBase, 'notes.txt', TagflowResourceType.link),
          const TagflowUrlPolicyDecision.disallow(
            TagflowUrlDecisionReason.disallowedScheme,
          ),
        );
      });

      test('should apply image rules to resolved URLs', () {
        final policy = TagflowContentPolicy(
          baseUrl: Uri.parse('https://example.com/'),
          allowRemoteImages: false,
        );

        expect(
          decide(policy, 'logo.png', TagflowResourceType.image),
          const TagflowUrlPolicyDecision.disallow(
            TagflowUrlDecisionReason.remoteImagesDisabled,
          ),
        );
      });

      test('should reject relative URLs when they are not allowed', () {
        final policy = TagflowContentPolicy(
          baseUrl: Uri.parse('https://example.com/'),
          allowRelativeUrls: false,
        );

        expect(
          decide(policy, 'page', TagflowResourceType.link),
          const TagflowUrlPolicyDecision.disallow(
            TagflowUrlDecisionReason.relativeUrlNotAllowed,
          ),
        );
      });

      test('should compare policies by base URL', () {
        expect(
          TagflowContentPolicy(baseUrl: Uri.parse('https://a.example/')),
          TagflowContentPolicy(baseUrl: Uri.parse('https://a.example/')),
        );
        expect(
          TagflowContentPolicy(baseUrl: Uri.parse('https://a.example/')),
          isNot(TagflowContentPolicy(baseUrl: Uri.parse('https://b.example/'))),
        );
      });

      test('should resolve image sources in the HTML adapter', () {
        final document = TagflowHtmlAdapter(
          policy: withBase,
        ).parse('<p><img src="img/a.png" alt="A"><a href="next">Next</a></p>');
        final paragraph = document.children.single;

        expect(
          paragraph.children.first.url,
          Uri.parse('https://example.com/docs/img/a.png'),
        );
        expect(
          paragraph.children.last.url,
          Uri.parse('https://example.com/docs/next'),
        );
      });
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

    test('should allow every unblocked tag when allowedTags is null', () {
      const policy = TagflowContentPolicy.defaults;

      expect(policy.allowedTags, isNull);
      expect(policy.decideTag('section').isAllowed, isTrue);
      expect(policy.decideTag('script').isAllowed, isFalse);
    });

    test('should allow no tags when allowedTags is empty', () {
      const policy = TagflowContentPolicy(allowedTags: {});
      final decision = policy.decideTag('p');

      expect(decision.isAllowed, isFalse);
      expect(decision.reason, TagflowTagDecisionReason.notInAllowlist);
    });

    test('should tell a null allowlist from an empty one in equality', () {
      expect(
        TagflowContentPolicy.defaults,
        isNot(const TagflowContentPolicy(allowedTags: {})),
      );
      expect(
        const TagflowContentPolicy(allowedTags: {'p'}),
        const TagflowContentPolicy(allowedTags: {'p'}),
      );
    });
  });
}
