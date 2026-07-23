// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$myProfileHash() => r'8d397f72ae366f8c48107897916915f71ee1b590';

/// See also [myProfile].
@ProviderFor(myProfile)
final myProfileProvider = AutoDisposeFutureProvider<UserProfile>.internal(
  myProfile,
  name: r'myProfileProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$myProfileHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MyProfileRef = AutoDisposeFutureProviderRef<UserProfile>;
String _$preferredRegionsHash() => r'5ef09b62db4a4b2fa056a41545f6c9729f3a593e';

/// See also [preferredRegions].
@ProviderFor(preferredRegions)
final preferredRegionsProvider =
    AutoDisposeFutureProvider<List<PreferredRegion>>.internal(
      preferredRegions,
      name: r'preferredRegionsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$preferredRegionsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PreferredRegionsRef =
    AutoDisposeFutureProviderRef<List<PreferredRegion>>;
String _$defaultPreferredRegionHash() =>
    r'4404ffa2d175dbfcc3e475b82d362d0f95716467';

/// 조과예측 화면이 처음 로드될 때 자동 적용할 기본 선호 지역(있으면).
///
/// Copied from [defaultPreferredRegion].
@ProviderFor(defaultPreferredRegion)
final defaultPreferredRegionProvider =
    AutoDisposeFutureProvider<PreferredRegion?>.internal(
      defaultPreferredRegion,
      name: r'defaultPreferredRegionProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$defaultPreferredRegionHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DefaultPreferredRegionRef =
    AutoDisposeFutureProviderRef<PreferredRegion?>;
String _$profileActionsHash() => r'dfb17ad2949cc2c79063795eaae2b29e5c6032fc';

/// See also [ProfileActions].
@ProviderFor(ProfileActions)
final profileActionsProvider =
    AutoDisposeNotifierProvider<ProfileActions, AsyncValue<void>>.internal(
      ProfileActions.new,
      name: r'profileActionsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$profileActionsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ProfileActions = AutoDisposeNotifier<AsyncValue<void>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
