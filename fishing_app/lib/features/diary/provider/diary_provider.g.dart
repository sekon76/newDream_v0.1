// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diary_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$diariesHash() => r'4c0da23b523d1b1875a8e3f6684befc072647b54';

/// See also [diaries].
@ProviderFor(diaries)
final diariesProvider = AutoDisposeFutureProvider<List<Diary>>.internal(
  diaries,
  name: r'diariesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$diariesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DiariesRef = AutoDisposeFutureProviderRef<List<Diary>>;
String _$diaryActionsHash() => r'b4bdf6ccc4a3a1fc45c622f295ff75a00cc95343';

/// See also [DiaryActions].
@ProviderFor(DiaryActions)
final diaryActionsProvider =
    AutoDisposeNotifierProvider<DiaryActions, AsyncValue<void>>.internal(
      DiaryActions.new,
      name: r'diaryActionsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$diaryActionsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$DiaryActions = AutoDisposeNotifier<AsyncValue<void>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
