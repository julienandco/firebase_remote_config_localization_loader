import 'package:flutter_test/flutter_test.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mocktail/mocktail.dart';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:firebase_remote_config_localization_loader/firebase_remote_config_localization_loader.dart';
import 'package:firebase_remote_config_localization_loader/src/asset_loaders.dart';

class MockRemoteFirebaseConfig extends Mock implements FirebaseRemoteConfig {}

void main() {
  group('Firebase Remote Config Localization Loader Init', () {
    final remoteConfig = MockRemoteFirebaseConfig();
    final faultyRemoteConfig = MockRemoteFirebaseConfig();
    final configData = FirebaseRemoteConfigData(
      remoteConfigInstance: remoteConfig,
      supportedLocales: [const Locale('de'), const Locale('en')],
      buildRemoteConfigStringFromLocale: (locale) =>
          'tran_${locale.languageCode}',
    );
    final faultyConfigData = FirebaseRemoteConfigData(
      remoteConfigInstance: faultyRemoteConfig,
      supportedLocales: [const Locale('de'), const Locale('en')],
      buildRemoteConfigStringFromLocale: (locale) =>
          'tran_${locale.languageCode}',
    );

    setUp(() async {
      when(() => remoteConfig.getString('tran_de')).thenReturn('de');
      when(() => remoteConfig.getString('tran_en')).thenReturn('en');
      when(() => faultyRemoteConfig.getString('tran_de')).thenReturn('de');
      when(() => faultyRemoteConfig.getString('tran_en')).thenReturn('');
    });

    test(
        'should not load the translation files from the remote config if given null config data.',
        () async {
      final loader = FirebaseRemoteConfigLocalizationLoader(
        configData: null,
      );
      await loader.init();
      expect(loader.hasTranslationFileInRemoteConfig, false);
    });
    test(
        'should not load the translation files from the remote config if some locale does not have a stored remote config string.',
        () async {
      final loader = FirebaseRemoteConfigLocalizationLoader(
        configData: faultyConfigData,
      );
      await loader.init();
      expect(loader.hasTranslationFileInRemoteConfig, false);
    });
    test(
        'should load the translation files from the remote config if config data is given and there is a remote config string for every locale.',
        () async {
      final loader = FirebaseRemoteConfigLocalizationLoader(
        configData: configData,
      );
      await loader.init();
      expect(loader.hasTranslationFileInRemoteConfig, true);
    });
  });

  group('Firebase Remote Config Localization Loader', () {
    final remoteConfig = MockRemoteFirebaseConfig();
    final faultyRemoteConfig = MockRemoteFirebaseConfig();

    final configData = FirebaseRemoteConfigData(
      remoteConfigInstance: remoteConfig,
      supportedLocales: [const Locale('de'), const Locale('en')],
      buildRemoteConfigStringFromLocale: (locale) =>
          'tran_${locale.languageCode}',
    );

    final faultyConfigData = FirebaseRemoteConfigData(
      remoteConfigInstance: faultyRemoteConfig,
      supportedLocales: [const Locale('de'), const Locale('en')],
      buildRemoteConfigStringFromLocale: (locale) =>
          'tran_${locale.languageCode}',
    );

    final nullLoader = FirebaseRemoteConfigLocalizationLoader(
      configData: null,
    );

    final faultyLoader = FirebaseRemoteConfigLocalizationLoader(
      configData: faultyConfigData,
    );

    final configLoader = FirebaseRemoteConfigLocalizationLoader(
      configData: configData,
    );

    setUp(() async {
      when(() => remoteConfig.getString('tran_de')).thenReturn('de');
      when(() => remoteConfig.getString('tran_en')).thenReturn('en');
      when(() => faultyRemoteConfig.getString('tran_de')).thenReturn('de');
      when(() => faultyRemoteConfig.getString('tran_en')).thenReturn('');

      await nullLoader.init();
      await faultyLoader.init();
      await configLoader.init();
    });

    test('Loader with null Config Data returns RootBundleAssetLoader.', () {
      expect(nullLoader.assetLoader.runtimeType, RootBundleAssetLoader);
    });

    test('Loader with faulty Config Data returns RootBundleAssetLoader.', () {
      expect(faultyLoader.assetLoader.runtimeType, RootBundleAssetLoader);
    });

    test('Loader with Config Data returns FirebaseRemoteConfigLoader.', () {
      expect(configLoader.assetLoader.runtimeType, FirebaseRemoteConfigLoader);
    });

    test(
        'Loader with Config Data returns FirebaseRemoteConfigLoader with correct RemoteConfig instance.',
        () {
      final firebaseLoader =
          configLoader.assetLoader as FirebaseRemoteConfigLoader;

      expect(firebaseLoader.remoteConfig.hashCode, remoteConfig.hashCode);
    });
  });
}
