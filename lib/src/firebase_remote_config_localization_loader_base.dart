import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:firebase_remote_config_localization_loader/src/asset_loaders.dart';
import 'package:flutter/material.dart';

class FirebaseRemoteConfigData {
  ///
  /// The [FirebaseRemoteConfig] instance your app uses.
  final FirebaseRemoteConfig remoteConfigInstance;

  ///
  /// A list of the [Locale]s supported by your app.
  final List<Locale> supportedLocales;

  ///
  /// A function that returns the name of the translation file stored in your
  /// [FirebaseRemoteConfig] instance for a given locale.
  final String Function(Locale) buildRemoteConfigStringFromLocale;

  const FirebaseRemoteConfigData({
    required this.remoteConfigInstance,
    required this.supportedLocales,
    required this.buildRemoteConfigStringFromLocale,
  });
}

class FirebaseRemoteConfigLocalizationLoader {
  FirebaseRemoteConfigLocalizationLoader({
    required this.fallbackAssetPath,
    this.configData,
  });

  ///
  /// Information about the [FirebaseRemoteConfig] instance your app uses.
  /// If null, the [FirebaseRemoteConfigLocalizationLoader] will not use
  /// [FirebaseRemoteConfig] for localization, but will load the translation
  /// files with a [RootBundleAssetLoader].
  final FirebaseRemoteConfigData? configData;

  ///
  /// The path to the default translation file stored in your app's assets.
  final String fallbackAssetPath;

  bool _hasTranslationFileInRemoteConfig = true;

  Future<void> init() async {
    if (configData == null) {
      _hasTranslationFileInRemoteConfig = false;
      return;
    }
    for (var locale in configData!.supportedLocales) {
      final str = configData!.remoteConfigInstance
          .getString(configData!.buildRemoteConfigStringFromLocale(locale));
      if (str.isEmpty) {
        // abort as soon as you cannot find a translation file in the remote
        // config for a locale.
        _hasTranslationFileInRemoteConfig = false;
        return;
      }
    }
    // if you get here, all translation files are in the remote config.
  }

  String get path => _hasTranslationFileInRemoteConfig ? '.' : assetPath;
  String get assetPath => fallbackAssetPath;
  dynamic get assetLoader =>
      _hasTranslationFileInRemoteConfig && configData != null
          ? FirebaseRemoteConfigLoader(
              remoteConfig: configData!.remoteConfigInstance,
              buildRemoteConfigStringFromLocale:
                  configData!.buildRemoteConfigStringFromLocale,
            )
          : const RootBundleAssetLoader();

  @visibleForTesting
  bool get hasTranslationFileInRemoteConfig =>
      _hasTranslationFileInRemoteConfig;
}
