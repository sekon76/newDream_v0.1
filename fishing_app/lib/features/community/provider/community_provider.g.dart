// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'community_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$communityPostDetailHash() =>
    r'66caad18e67b7ddaa63fda28ddccb6eb2c35a13a';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [communityPostDetail].
@ProviderFor(communityPostDetail)
const communityPostDetailProvider = CommunityPostDetailFamily();

/// See also [communityPostDetail].
class CommunityPostDetailFamily
    extends Family<AsyncValue<CommunityPostDetail>> {
  /// See also [communityPostDetail].
  const CommunityPostDetailFamily();

  /// See also [communityPostDetail].
  CommunityPostDetailProvider call(int visitId) {
    return CommunityPostDetailProvider(visitId);
  }

  @override
  CommunityPostDetailProvider getProviderOverride(
    covariant CommunityPostDetailProvider provider,
  ) {
    return call(provider.visitId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'communityPostDetailProvider';
}

/// See also [communityPostDetail].
class CommunityPostDetailProvider
    extends AutoDisposeFutureProvider<CommunityPostDetail> {
  /// See also [communityPostDetail].
  CommunityPostDetailProvider(int visitId)
    : this._internal(
        (ref) => communityPostDetail(ref as CommunityPostDetailRef, visitId),
        from: communityPostDetailProvider,
        name: r'communityPostDetailProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$communityPostDetailHash,
        dependencies: CommunityPostDetailFamily._dependencies,
        allTransitiveDependencies:
            CommunityPostDetailFamily._allTransitiveDependencies,
        visitId: visitId,
      );

  CommunityPostDetailProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.visitId,
  }) : super.internal();

  final int visitId;

  @override
  Override overrideWith(
    FutureOr<CommunityPostDetail> Function(CommunityPostDetailRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CommunityPostDetailProvider._internal(
        (ref) => create(ref as CommunityPostDetailRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        visitId: visitId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<CommunityPostDetail> createElement() {
    return _CommunityPostDetailProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CommunityPostDetailProvider && other.visitId == visitId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, visitId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CommunityPostDetailRef
    on AutoDisposeFutureProviderRef<CommunityPostDetail> {
  /// The parameter `visitId` of this provider.
  int get visitId;
}

class _CommunityPostDetailProviderElement
    extends AutoDisposeFutureProviderElement<CommunityPostDetail>
    with CommunityPostDetailRef {
  _CommunityPostDetailProviderElement(super.provider);

  @override
  int get visitId => (origin as CommunityPostDetailProvider).visitId;
}

String _$communityCommentsHash() => r'eb0904afa4be7b650430c15124fef40a2f99e8a8';

/// See also [communityComments].
@ProviderFor(communityComments)
const communityCommentsProvider = CommunityCommentsFamily();

/// See also [communityComments].
class CommunityCommentsFamily
    extends Family<AsyncValue<List<CommunityComment>>> {
  /// See also [communityComments].
  const CommunityCommentsFamily();

  /// See also [communityComments].
  CommunityCommentsProvider call(int visitId) {
    return CommunityCommentsProvider(visitId);
  }

  @override
  CommunityCommentsProvider getProviderOverride(
    covariant CommunityCommentsProvider provider,
  ) {
    return call(provider.visitId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'communityCommentsProvider';
}

/// See also [communityComments].
class CommunityCommentsProvider
    extends AutoDisposeFutureProvider<List<CommunityComment>> {
  /// See also [communityComments].
  CommunityCommentsProvider(int visitId)
    : this._internal(
        (ref) => communityComments(ref as CommunityCommentsRef, visitId),
        from: communityCommentsProvider,
        name: r'communityCommentsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$communityCommentsHash,
        dependencies: CommunityCommentsFamily._dependencies,
        allTransitiveDependencies:
            CommunityCommentsFamily._allTransitiveDependencies,
        visitId: visitId,
      );

  CommunityCommentsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.visitId,
  }) : super.internal();

  final int visitId;

  @override
  Override overrideWith(
    FutureOr<List<CommunityComment>> Function(CommunityCommentsRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CommunityCommentsProvider._internal(
        (ref) => create(ref as CommunityCommentsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        visitId: visitId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<CommunityComment>> createElement() {
    return _CommunityCommentsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CommunityCommentsProvider && other.visitId == visitId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, visitId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CommunityCommentsRef
    on AutoDisposeFutureProviderRef<List<CommunityComment>> {
  /// The parameter `visitId` of this provider.
  int get visitId;
}

class _CommunityCommentsProviderElement
    extends AutoDisposeFutureProviderElement<List<CommunityComment>>
    with CommunityCommentsRef {
  _CommunityCommentsProviderElement(super.provider);

  @override
  int get visitId => (origin as CommunityCommentsProvider).visitId;
}

String _$communityFeedHash() => r'fde7f91931eb88f7d0264bed0b50438d4e2a9209';

/// See also [CommunityFeed].
@ProviderFor(CommunityFeed)
final communityFeedProvider =
    AutoDisposeAsyncNotifierProvider<
      CommunityFeed,
      List<CommunityPost>
    >.internal(
      CommunityFeed.new,
      name: r'communityFeedProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$communityFeedHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CommunityFeed = AutoDisposeAsyncNotifier<List<CommunityPost>>;
String _$communityDetailLikeActionsHash() =>
    r'23eedbc6fea61f92c7548ce94e6ca3ead44aac36';

/// See also [CommunityDetailLikeActions].
@ProviderFor(CommunityDetailLikeActions)
final communityDetailLikeActionsProvider =
    AutoDisposeNotifierProvider<
      CommunityDetailLikeActions,
      AsyncValue<void>
    >.internal(
      CommunityDetailLikeActions.new,
      name: r'communityDetailLikeActionsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$communityDetailLikeActionsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CommunityDetailLikeActions = AutoDisposeNotifier<AsyncValue<void>>;
String _$communityCommentActionsHash() =>
    r'2deaa5206fe04198cb893b22b11065c4d081cc16';

/// See also [CommunityCommentActions].
@ProviderFor(CommunityCommentActions)
final communityCommentActionsProvider =
    AutoDisposeNotifierProvider<
      CommunityCommentActions,
      AsyncValue<void>
    >.internal(
      CommunityCommentActions.new,
      name: r'communityCommentActionsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$communityCommentActionsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CommunityCommentActions = AutoDisposeNotifier<AsyncValue<void>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
