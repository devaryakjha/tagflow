import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

const SetEquality<String> _stringSetEquality = SetEquality<String>();

/// Runtime behavior for unsupported content.
enum TagflowUnsupportedBehavior {
  /// Leave unsupported or rejected content out of the document.
  drop,

  /// Keep an unsupported placeholder node where the content was.
  preservePlaceholder,
}

/// Source URL categories evaluated by the content policy.
enum TagflowResourceType {
  /// A URL with no particular use.
  generic,

  /// The target of a link.
  link,

  /// The source of an image.
  image,
}

/// Reasons a tag decision may be rejected.
enum TagflowTagDecisionReason {
  /// The tag is in `blockedTags`.
  blockedTag,

  /// `allowedTags` is set and does not contain the tag.
  notInAllowlist,
}

/// Content policy limits an adapter can hit while adapting input.
enum TagflowContentLimit {
  /// The input nests deeper than [TagflowContentPolicy.maxDepth].
  maxDepth,

  /// The input has more nodes than [TagflowContentPolicy.maxNodes].
  maxNodes,
}

/// Reasons a URL decision may be rejected.
enum TagflowUrlDecisionReason {
  /// The URL could not be parsed.
  malformedUrl,

  /// The URL is relative and the policy does not allow relative URLs.
  relativeUrlNotAllowed,

  /// The URL scheme is not in `allowedSchemes`.
  disallowedScheme,

  /// The URL is a `data:` URL and the policy does not allow them.
  dataUrlNotAllowed,

  /// The URL is a remote image and the policy does not allow them.
  remoteImagesDisabled,

  /// The URL is scheme-relative (`//host/path`), or a relative image URL,
  /// and the policy has no [TagflowContentPolicy.baseUrl] to resolve it
  /// against.
  missingBaseUrl,
}

/// Result of a tag policy check.
@immutable
final class TagflowTagPolicyDecision {
  /// Creates an allowed tag decision.
  const TagflowTagPolicyDecision.allow(this.tag)
    : isAllowed = true,
      reason = null;

  /// Creates a rejected tag decision.
  const TagflowTagPolicyDecision.disallow(this.tag, this.reason)
    : isAllowed = false;

  /// Whether the tag is allowed.
  final bool isAllowed;

  /// Normalized tag name.
  final String tag;

  /// Rejection reason when disallowed.
  final TagflowTagDecisionReason? reason;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is TagflowTagPolicyDecision &&
            other.isAllowed == isAllowed &&
            other.tag == tag &&
            other.reason == reason;
  }

  @override
  int get hashCode => Object.hash(isAllowed, tag, reason);
}

/// Result of a URL policy check.
@immutable
final class TagflowUrlPolicyDecision {
  /// Creates an allowed URL decision.
  const TagflowUrlPolicyDecision.allow([this.uri])
    : isAllowed = true,
      reason = null;

  /// Creates a rejected URL decision.
  const TagflowUrlPolicyDecision.disallow(this.reason)
    : isAllowed = false,
      uri = null;

  /// Whether the URL is allowed.
  final bool isAllowed;

  /// Parsed URI when allowed.
  final Uri? uri;

  /// Rejection reason when disallowed.
  final TagflowUrlDecisionReason? reason;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is TagflowUrlPolicyDecision &&
            other.isAllowed == isAllowed &&
            other.uri == uri &&
            other.reason == reason;
  }

  @override
  int get hashCode => Object.hash(isAllowed, uri, reason);
}

/// Safe default content policy contract for adapters.
@immutable
final class TagflowContentPolicy {
  /// Creates a content policy.
  const TagflowContentPolicy({
    this.allowRemoteImages = true,
    this.allowDataImages = false,
    this.allowRelativeUrls = true,
    this.allowedSchemes = _defaultAllowedSchemes,
    this.allowedTags,
    this.blockedTags = _defaultBlockedTags,
    this.unsupportedBehavior = TagflowUnsupportedBehavior.drop,
    this.maxDepth = defaultMaxDepth,
    this.maxNodes = defaultMaxNodes,
    this.allowInlineStyles = true,
    this.baseUrl,
  }) : assert(maxDepth > 0, 'maxDepth must be positive'),
       assert(maxNodes > 0, 'maxNodes must be positive');

  /// Default for [maxDepth].
  static const int defaultMaxDepth = 128;

  /// Default for [maxNodes].
  static const int defaultMaxNodes = 50000;

  /// Default runtime content policy.
  static const TagflowContentPolicy defaults = TagflowContentPolicy();

  /// Allowed URI schemes when a scheme is present.
  static const Set<String> _defaultAllowedSchemes = {'http', 'https', 'mailto'};

  /// HTML-like tags that are always rejected by default.
  static const Set<String> _defaultBlockedTags = {
    'script',
    'style',
    'iframe',
    'object',
    'embed',
    'form',
    'input',
    'button',
    'textarea',
  };

  /// Whether remote image resources are allowed.
  final bool allowRemoteImages;

  /// Whether `data:image/*` URLs are allowed for image resources.
  final bool allowDataImages;

  /// Whether relative URLs are allowed.
  final bool allowRelativeUrls;

  /// Absolute URL that relative and scheme-relative URLs resolve against,
  /// such as the address the content was loaded from.
  ///
  /// With a base URL, a relative URL is resolved first and the result is
  /// checked like any absolute URL, so it must use an allowed scheme.
  ///
  /// Without one, scheme-relative URLs (`//host/path`) and relative image
  /// URLs are rejected with [TagflowUrlDecisionReason.missingBaseUrl], since
  /// there is nothing to resolve them against. Relative link URLs are kept
  /// as written and passed to the app's link callback unchanged.
  ///
  /// [allowRelativeUrls] still applies: when it is `false`, relative URLs
  /// are rejected whether or not a base URL is set.
  final Uri? baseUrl;

  /// Explicitly allowed URI schemes.
  final Set<String> allowedSchemes;

  /// Source tags to allow, or `null` to allow every tag that is not in
  /// [blockedTags].
  ///
  /// An empty set allows no tags at all, so a list built from configuration
  /// that comes out empty fails closed.
  final Set<String>? allowedTags;

  /// Explicit source tag denylist.
  final Set<String> blockedTags;

  /// Behavior for unsupported content.
  final TagflowUnsupportedBehavior unsupportedBehavior;

  /// Deepest element nesting an adapter keeps, counting top-level nodes as
  /// depth 1.
  ///
  /// Content nested deeper is cut off. Under
  /// [TagflowUnsupportedBehavior.drop] it is removed; under
  /// [TagflowUnsupportedBehavior.preservePlaceholder] one unsupported node
  /// marks where it was. Adapting never throws because of this limit.
  final int maxDepth;

  /// Whether adapters keep a safe subset of inline styling, such as the
  /// HTML `style` attribute.
  ///
  /// Only `color`, `background-color`, `text-align`, `font-weight`,
  /// `font-style`, `text-decoration` and `font-size` are read; every other
  /// property is ignored. Set to `false` to ignore inline styles entirely.
  final bool allowInlineStyles;

  /// Most nodes an adapter produces for one document, counted in document
  /// order.
  ///
  /// Content after the limit is cut off and follows [unsupportedBehavior] the
  /// same way as [maxDepth]. Adapting never throws because of this limit.
  final int maxNodes;

  /// Evaluates whether [tag] is allowed by this policy.
  TagflowTagPolicyDecision decideTag(String tag) {
    final normalizedTag = tag.trim().toLowerCase();

    if (blockedTags.contains(normalizedTag)) {
      return TagflowTagPolicyDecision.disallow(
        normalizedTag,
        TagflowTagDecisionReason.blockedTag,
      );
    }

    final allowed = allowedTags;
    if (allowed != null && !allowed.contains(normalizedTag)) {
      return TagflowTagPolicyDecision.disallow(
        normalizedTag,
        TagflowTagDecisionReason.notInAllowlist,
      );
    }

    return TagflowTagPolicyDecision.allow(normalizedTag);
  }

  /// Evaluates whether [rawUrl] is allowed by this policy.
  TagflowUrlPolicyDecision decideUrl(
    String rawUrl, {
    TagflowResourceType resourceType = TagflowResourceType.generic,
  }) {
    final normalizedUrl = rawUrl.trim();
    final uri = Uri.tryParse(normalizedUrl);

    if (uri == null || normalizedUrl.isEmpty) {
      return const TagflowUrlPolicyDecision.disallow(
        TagflowUrlDecisionReason.malformedUrl,
      );
    }

    if (!uri.hasScheme) {
      if (!allowRelativeUrls) {
        return const TagflowUrlPolicyDecision.disallow(
          TagflowUrlDecisionReason.relativeUrlNotAllowed,
        );
      }
      final base = baseUrl;
      if (base != null && base.hasScheme) {
        return _decideAbsolute(
          base.resolveUri(uri),
          normalizedUrl,
          resourceType,
        );
      }
      // A scheme-relative URL names another host, so it cannot be kept as a
      // relative path, and a relative image has nothing to load from.
      if (uri.hasAuthority || resourceType == TagflowResourceType.image) {
        return const TagflowUrlPolicyDecision.disallow(
          TagflowUrlDecisionReason.missingBaseUrl,
        );
      }
      return TagflowUrlPolicyDecision.allow(uri);
    }

    return _decideAbsolute(uri, normalizedUrl, resourceType);
  }

  TagflowUrlPolicyDecision _decideAbsolute(
    Uri uri,
    String normalizedUrl,
    TagflowResourceType resourceType,
  ) {
    final normalizedScheme = uri.scheme.toLowerCase();

    if (normalizedScheme == 'data') {
      if (resourceType == TagflowResourceType.image &&
          allowDataImages &&
          normalizedUrl.toLowerCase().startsWith('data:image/')) {
        return TagflowUrlPolicyDecision.allow(uri);
      }

      return const TagflowUrlPolicyDecision.disallow(
        TagflowUrlDecisionReason.dataUrlNotAllowed,
      );
    }

    if (resourceType == TagflowResourceType.image &&
        !allowRemoteImages &&
        (normalizedScheme == 'http' || normalizedScheme == 'https')) {
      return const TagflowUrlPolicyDecision.disallow(
        TagflowUrlDecisionReason.remoteImagesDisabled,
      );
    }

    if (!allowedSchemes.contains(normalizedScheme)) {
      return const TagflowUrlPolicyDecision.disallow(
        TagflowUrlDecisionReason.disallowedScheme,
      );
    }

    return TagflowUrlPolicyDecision.allow(uri);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is TagflowContentPolicy &&
            other.allowRemoteImages == allowRemoteImages &&
            other.allowDataImages == allowDataImages &&
            other.allowRelativeUrls == allowRelativeUrls &&
            _stringSetEquality.equals(other.allowedSchemes, allowedSchemes) &&
            _nullableSetEquals(other.allowedTags, allowedTags) &&
            _stringSetEquality.equals(other.blockedTags, blockedTags) &&
            other.unsupportedBehavior == unsupportedBehavior &&
            other.maxDepth == maxDepth &&
            other.maxNodes == maxNodes &&
            other.allowInlineStyles == allowInlineStyles &&
            other.baseUrl == baseUrl;
  }

  @override
  int get hashCode => Object.hash(
    allowRemoteImages,
    allowDataImages,
    allowRelativeUrls,
    _stringSetEquality.hash(allowedSchemes),
    allowedTags == null ? null : _stringSetEquality.hash(allowedTags),
    _stringSetEquality.hash(blockedTags),
    unsupportedBehavior,
    maxDepth,
    maxNodes,
    allowInlineStyles,
    baseUrl,
  );
}

bool _nullableSetEquals(Set<String>? a, Set<String>? b) {
  if (a == null || b == null) return a == b;
  return _stringSetEquality.equals(a, b);
}
