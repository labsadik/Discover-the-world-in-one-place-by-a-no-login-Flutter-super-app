# AtlasFlow 🌍

**Discover the world, in one place.** AtlasFlow is a no-login Flutter super-app that brings country facts, live weather, travel-photo discovery, book search, currency conversion and country quizzes together in one responsive experience.

## Features

- **Home dashboard:** animated hero, global country search and shortcuts into each module.
- **World Atlas:** real country records; flags, capitals, regions, population, area, currency, languages, time zones, borders, and side-by-side country comparison.
- **Weather Center:** search any city or optionally use device location; current conditions, feels-like temperature, humidity, wind, hourly outlook, 7-day forecast, sunrise/sunset and air quality when available.
- **Visual Discovery:** search Wikimedia Commons for real travel, landscape and architecture images; show creator and licence metadata where available.
- **Open Library:** book/author/topic search, cover art, publication year, subjects, edition count, and a local “Want to read / Reading / Finished” list.
- **Currency converter:** reference exchange rates with source date and conversion; not a guaranteed live trading quote.
- **Country quiz:** flag quiz generated from fetched country data; best score is stored locally.
- **Saved space:** favourite countries, books and images stored on this device.
- **Personalization:** Light, Dark and System themes; responsive layouts for narrow and wide screens.
- **No account, no private backend, no API keys.** Internet access is required for fresh public data. Cached responses may be shown if a source is temporarily unavailable.

## Public data sources

- **Country dataset:** [mledoze/countries](https://github.com/mledoze/countries), fetched from its public raw JSON file. Records are real but update when the upstream dataset changes; this is not a live political feed.
- **Weather and geocoding:** [Open-Meteo](https://open-meteo.com/). The free API is for non-commercial use and requires attribution; see [terms](https://open-meteo.com/en/terms).
- **Air quality:** [Open-Meteo Air Quality API](https://open-meteo.com/en/docs/air-quality-api). AQI may be unavailable for some places.
- **Books and covers:** [Open Library API](https://openlibrary.org/developers/api). Respect its rate limits. Not every title can be read or downloaded for free.
- **Photos and metadata:** [Wikimedia Commons / MediaWiki APIs](https://www.mediawiki.org/wiki/Wikimedia_APIs). Each image can have a different licence; verify the linked file page before reuse.
- **Reference exchange rates:** [Frankfurter](https://frankfurter.dev/). These are working-day reference observations, not a transaction quote.

Public access does not mean unlimited or unrestricted reuse. This app caches politely, exposes source context, and keeps available image-licence information with saved items. Review upstream terms before any commercial distribution.

## Requirements

- Flutter stable with Dart 3.9 or newer
- Android Studio / Android SDK for Android builds, or Chrome for web builds
- Internet for network-backed features

## Run in VS Code

1. Clone the repository https://github.com/WorkRCS/AtlasFlow.git and open the folder in VS Code.
2. Open the integrated terminal in the repository root.
3. Run these commands:

    flutter pub get

    flutter run -d chrome

The repository includes Flutter web entry files. Use flutter devices to view available targets.

### Run on Android (one-time platform setup)

If your clone does not yet have an Android runner, create it once:

    flutter create --platforms=android .

For current-location weather, add these lines inside the top-level manifest element (before the application element) in android/app/src/main/AndroidManifest.xml:

    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />

Location is optional: the app asks only after the user taps **Use my current location**, and city search works without it. For iOS builds, generate the runner with flutter create --platforms=ios . and add an NSLocationWhenInUseUsageDescription entry to ios/Runner/Info.plist.

Then run:

    flutter pub get
    flutter run

## Quality checks

    flutter analyze
    flutter test
    flutter build web

GitHub Actions runs analysis, tests and a web build. Automated CI does not replace testing on real devices before publishing.

## Privacy

There is no account or app-owned backend. Favourites, reading status, saved images, theme choice and best quiz score are stored locally. Searching for a book, city or image sends the relevant query to the public provider. Location access is optional.

## Current scope and limitations

- Network data depends on third-party availability; cached responses are fallbacks, not guaranteed current values.
- Weather forecasts and air quality are informational, not emergency guidance.
- Frankfurter rates are reference rates, not financial advice.
- Reading/download options depend on each book's rights and Open Library availability.
- Image reuse is governed by each Wikimedia file's licence and attribution requirements.
- Build and test on the actual target device before public release.
