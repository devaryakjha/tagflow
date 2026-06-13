import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

const SetEquality<String> _stringSetEquality = SetEquality<String>();

/// Runtime behavior for unsupported content.
enum TagflowUnsupportedBehavior { drop, preservePlaceholder }

/// Source URL categories evaluated by the content policy.
enum TagflowResourceType { generic, link, image }

/// Reasons a tag decision may be rejected.
enum TagflowTagDecisionReason { blockedTag, notInAllowlist }

/// Reasons a URL decision may be rejected.
enum TagflowUrlDecisionReason {
  malformedUrl,
  relativeUrlNotAllowed,
  disallowedScheme,
  dataUrlNotAllowed,
  remoteImagesDisabled,
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
    this.allowedTags = const {},
    this.blockedTags = _defaultBlockedTags,
    this.unsupportedBehavior = TagflowUnsupportedBehavior.drop,
  });

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

  /// Explicitly allowed URI schemes.
  final Set<String> allowedSchemes;

  /// Optional source tag allowlist.
  final Set<String> allowedTags;

  /// Explicit source tag denylist.
  final Set<String> blockedTags;

  /// Behavior for unsupported content.
  final TagflowUnsupportedBehavior unsupportedBehavior;

  /// Evaluates whether [tag] is allowed by this policy.
  TagflowTagPolicyDecision decideTag(String tag) {
    final normalizedTag = tag.trim().toLowerCase();

    if (blockedTags.contains(normalizedTag)) {
      return TagflowTagPolicyDecision.disallow(
        normalizedTag,
        TagflowTagDecisionReason.blockedTag,
      );
    }

    if (allowedTags.isNotEmpty && !allowedTags.contains(normalizedTag)) {
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
      return allowRelativeUrls
          ? TagflowUrlPolicyDecision.allow(uri)
          : const TagflowUrlPolicyDecision.disallow(
              TagflowUrlDecisionReason.relativeUrlNotAllowed,
            );
    }

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
            _stringSetEquality.equals(other.allowedTags, allowedTags) &&
            _stringSetEquality.equals(other.blockedTags, blockedTags) &&
            other.unsupportedBehavior == unsupportedBehavior;
  }

  @override
  int get hashCode => Object.hash(
    allowRemoteImages,
    allowDataImages,
    allowRelativeUrls,
    _stringSetEquality.hash(allowedSchemes),
    _stringSetEquality.hash(allowedTags),
    _stringSetEquality.hash(blockedTags),
    unsupportedBehavior,
  );
}
