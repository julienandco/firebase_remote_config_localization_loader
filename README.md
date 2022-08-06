# [packageName]

## Features

Lets you easily set up the internationalization of your app with files that are stored in FirebaseRemoteConfig.

## Getting started

* Make sure you are using [Easy Localization](https://pub.dev/packages/easy_localization) to internationalize your app, as this pacakge provides an AssetLoader instance, which is defined in the Easy Localization package.

## Usage

* Add the following code to the ```main.dart``` of your application:

```dart
...
final supportedLocales = [const Locale('de'), const Locale('en')]; // Add your supported locales here

final localizationLoader =
    FirebaseRemoteConfigLocalizationLoader(configData: 
        FirebaseRemoteConfigData(
        remoteConfigInstance: FirebaseRemoteConfig.instance,
        supportedLocales: supportedLocales,
        buildRemoteConfigStringFromLocale: (locale) => // Add your custom implementation here
            'tran_${locale.languageCode}',
        );
    );
await localizationLoader.init();

runApp(
    EasyLocalization(
        path: '<your_path_to_the_local_translation_files>',
        assetLoader: localizationLoader.assetLoader,
        supportedLocales: supportedLocales,
        fallbackLocale: const Locale('de'),
        saveLocale: true,
        useFallbackTranslations: true,
        useOnlyLangCode: true,
        child: const App(),
    ),
);
...
```

## Additional information

Feel free to contact me if you have any questions, open some Pull Requests, or want to contribute to this package.