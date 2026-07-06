// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prediction_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$predictionHash() => r'5e6800e9554b1d7c4accaf85d1a8f98f2962a85a';

/// See also [prediction].
@ProviderFor(prediction)
final predictionProvider = AutoDisposeFutureProvider<PredictionResult>.internal(
  prediction,
  name: r'predictionProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$predictionHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PredictionRef = AutoDisposeFutureProviderRef<PredictionResult>;
String _$locationSearchHash() => r'b19e9c68aa7828bb41ad6209d77266aa748c118d';

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

/// See also [locationSearch].
@ProviderFor(locationSearch)
const locationSearchProvider = LocationSearchFamily();

/// See also [locationSearch].
class LocationSearchFamily extends Family<AsyncValue<List<LocationState>>> {
  /// See also [locationSearch].
  const LocationSearchFamily();

  /// See also [locationSearch].
  LocationSearchProvider call(String query) {
    return LocationSearchProvider(query);
  }

  @override
  LocationSearchProvider getProviderOverride(
    covariant LocationSearchProvider provider,
  ) {
    return call(provider.query);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'locationSearchProvider';
}

/// See also [locationSearch].
class LocationSearchProvider
    extends AutoDisposeFutureProvider<List<LocationState>> {
  /// See also [locationSearch].
  LocationSearchProvider(String query)
    : this._internal(
        (ref) => locationSearch(ref as LocationSearchRef, query),
        from: locationSearchProvider,
        name: r'locationSearchProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$locationSearchHash,
        dependencies: LocationSearchFamily._dependencies,
        allTransitiveDependencies:
            LocationSearchFamily._allTransitiveDependencies,
        query: query,
      );

  LocationSearchProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.query,
  }) : super.internal();

  final String query;

  @override
  Override overrideWith(
    FutureOr<List<LocationState>> Function(LocationSearchRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: LocationSearchProvider._internal(
        (ref) => create(ref as LocationSearchRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        query: query,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<LocationState>> createElement() {
    return _LocationSearchProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is LocationSearchProvider && other.query == query;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, query.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin LocationSearchRef on AutoDisposeFutureProviderRef<List<LocationState>> {
  /// The parameter `query` of this provider.
  String get query;
}

class _LocationSearchProviderElement
    extends AutoDisposeFutureProviderElement<List<LocationState>>
    with LocationSearchRef {
  _LocationSearchProviderElement(super.provider);

  @override
  String get query => (origin as LocationSearchProvider).query;
}

String _$selectedLocationHash() => r'70089a40e295052a344ca9f8434999cfb49ffc17';

/// See also [SelectedLocation].
@ProviderFor(SelectedLocation)
final selectedLocationProvider =
    AutoDisposeNotifierProvider<SelectedLocation, LocationState?>.internal(
      SelectedLocation.new,
      name: r'selectedLocationProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$selectedLocationHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SelectedLocation = AutoDisposeNotifier<LocationState?>;
String _$selectedDateHash() => r'3d09875b46096499b963f2f58f372e58c537f139';

/// See also [SelectedDate].
@ProviderFor(SelectedDate)
final selectedDateProvider =
    AutoDisposeNotifierProvider<SelectedDate, DateTime>.internal(
      SelectedDate.new,
      name: r'selectedDateProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$selectedDateHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SelectedDate = AutoDisposeNotifier<DateTime>;
String _$selectedFishHash() => r'06be4477acffefbca01636212b45843c19515ee1';

/// See also [SelectedFish].
@ProviderFor(SelectedFish)
final selectedFishProvider =
    AutoDisposeNotifierProvider<SelectedFish, FishSpecies?>.internal(
      SelectedFish.new,
      name: r'selectedFishProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$selectedFishHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SelectedFish = AutoDisposeNotifier<FishSpecies?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
