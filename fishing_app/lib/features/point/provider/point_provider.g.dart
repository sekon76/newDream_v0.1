// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'point_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$pointsHash() => r'14b04e8121127cd38bb83825e85fd349acfebc58';

/// See also [points].
@ProviderFor(points)
final pointsProvider = AutoDisposeFutureProvider<List<FishingPoint>>.internal(
  points,
  name: r'pointsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$pointsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PointsRef = AutoDisposeFutureProviderRef<List<FishingPoint>>;
String _$pointDetailHash() => r'b552e55d42ad785e49da6033d050d2deb76b442d';

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

/// See also [pointDetail].
@ProviderFor(pointDetail)
const pointDetailProvider = PointDetailFamily();

/// See also [pointDetail].
class PointDetailFamily extends Family<AsyncValue<FishingPoint>> {
  /// See also [pointDetail].
  const PointDetailFamily();

  /// See also [pointDetail].
  PointDetailProvider call(int pointId) {
    return PointDetailProvider(pointId);
  }

  @override
  PointDetailProvider getProviderOverride(
    covariant PointDetailProvider provider,
  ) {
    return call(provider.pointId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'pointDetailProvider';
}

/// See also [pointDetail].
class PointDetailProvider extends AutoDisposeFutureProvider<FishingPoint> {
  /// See also [pointDetail].
  PointDetailProvider(int pointId)
    : this._internal(
        (ref) => pointDetail(ref as PointDetailRef, pointId),
        from: pointDetailProvider,
        name: r'pointDetailProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$pointDetailHash,
        dependencies: PointDetailFamily._dependencies,
        allTransitiveDependencies: PointDetailFamily._allTransitiveDependencies,
        pointId: pointId,
      );

  PointDetailProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.pointId,
  }) : super.internal();

  final int pointId;

  @override
  Override overrideWith(
    FutureOr<FishingPoint> Function(PointDetailRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PointDetailProvider._internal(
        (ref) => create(ref as PointDetailRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        pointId: pointId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<FishingPoint> createElement() {
    return _PointDetailProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PointDetailProvider && other.pointId == pointId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, pointId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PointDetailRef on AutoDisposeFutureProviderRef<FishingPoint> {
  /// The parameter `pointId` of this provider.
  int get pointId;
}

class _PointDetailProviderElement
    extends AutoDisposeFutureProviderElement<FishingPoint>
    with PointDetailRef {
  _PointDetailProviderElement(super.provider);

  @override
  int get pointId => (origin as PointDetailProvider).pointId;
}

String _$pointVisitsHash() => r'2293e97cc6e4f35879b0c84c42605137b8112bff';

/// See also [pointVisits].
@ProviderFor(pointVisits)
const pointVisitsProvider = PointVisitsFamily();

/// See also [pointVisits].
class PointVisitsFamily extends Family<AsyncValue<List<PointVisit>>> {
  /// See also [pointVisits].
  const PointVisitsFamily();

  /// See also [pointVisits].
  PointVisitsProvider call(int pointId) {
    return PointVisitsProvider(pointId);
  }

  @override
  PointVisitsProvider getProviderOverride(
    covariant PointVisitsProvider provider,
  ) {
    return call(provider.pointId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'pointVisitsProvider';
}

/// See also [pointVisits].
class PointVisitsProvider extends AutoDisposeFutureProvider<List<PointVisit>> {
  /// See also [pointVisits].
  PointVisitsProvider(int pointId)
    : this._internal(
        (ref) => pointVisits(ref as PointVisitsRef, pointId),
        from: pointVisitsProvider,
        name: r'pointVisitsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$pointVisitsHash,
        dependencies: PointVisitsFamily._dependencies,
        allTransitiveDependencies: PointVisitsFamily._allTransitiveDependencies,
        pointId: pointId,
      );

  PointVisitsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.pointId,
  }) : super.internal();

  final int pointId;

  @override
  Override overrideWith(
    FutureOr<List<PointVisit>> Function(PointVisitsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PointVisitsProvider._internal(
        (ref) => create(ref as PointVisitsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        pointId: pointId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<PointVisit>> createElement() {
    return _PointVisitsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PointVisitsProvider && other.pointId == pointId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, pointId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PointVisitsRef on AutoDisposeFutureProviderRef<List<PointVisit>> {
  /// The parameter `pointId` of this provider.
  int get pointId;
}

class _PointVisitsProviderElement
    extends AutoDisposeFutureProviderElement<List<PointVisit>>
    with PointVisitsRef {
  _PointVisitsProviderElement(super.provider);

  @override
  int get pointId => (origin as PointVisitsProvider).pointId;
}

String _$pointActionsHash() => r'e74ed100ecae48fe23b2a18d37fb39ff3c6f7586';

/// See also [PointActions].
@ProviderFor(PointActions)
final pointActionsProvider =
    AutoDisposeNotifierProvider<PointActions, AsyncValue<void>>.internal(
      PointActions.new,
      name: r'pointActionsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$pointActionsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$PointActions = AutoDisposeNotifier<AsyncValue<void>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
