import 'dart:convert';
import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

class FirebaseRemoteConfigLoader extends AssetLoader {
  FirebaseRemoteConfigLoader({
    required this.remoteConfig,
    required this.buildRemoteConfigStringFromLocale,
  });
  final FirebaseRemoteConfig remoteConfig;
  final String Function(Locale) buildRemoteConfigStringFromLocale;

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async {
    final str =
        remoteConfig.getString(buildRemoteConfigStringFromLocale(locale));
    final map = await compute(jsonDecode, str);
    return map;
  }
}
