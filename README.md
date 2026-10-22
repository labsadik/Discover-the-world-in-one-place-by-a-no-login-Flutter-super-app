# AtlasFlow 🌍

**Discover the world, in one place.** AtlasFlow is a no-login Flutter super-app concept that brings country facts, live weather, travel-photo discovery, open-library search, currency conversion, and country quizzes together in one responsive experience.

## Goals

- No account, password, API key, or private backend required.
- Real public data from unauthenticated APIs; network access is needed for fresh results.
- Light, dark, and system themes.
- Responsive phone, tablet, and desktop layouts.
- Local favourites and reading lists.
- Smooth, restrained animations, helpful loading states, and graceful error handling.
- Clear source attribution and API usage limits respected.

## Modules

- **Home:** global dashboard, daily discovery, quick links, weather snapshot.
- **World Atlas:** search/filter countries; capital, flag, region, population, area, currency, languages, time zones, borders, and country comparison/detail.
- **Weather:** city search, current conditions, hourly and 7-day forecasts, sunrise/sunset, wind and humidity. Location access is optional; search a city instead.
- **Travel & Visual Discovery:** search Wikimedia Commons for real destination, landscape, and architecture imagery with available attribution/license metadata.
- **Open Library:** search books and authors, cover art, details, and locally saved reading lists. Reading/download links only appear where the source provides them.
- **Currency:** latest available reference exchange rates and conversion; the timestamp/source is shown and rates are not represented as guaranteed real-time trading prices.
- **Learn:** country/flag/capital quizzes generated from fetched country data, with local scores.
- **Saved:** favourite countries/places/books and reading status stored on this device.
- **Settings:** Light, Dark, or System theme; local preferences.

## Public data sources

- [REST Countries](https://restcountries.com/) — country facts and flags. Please follow service availability and usage guidance.
- [Open-Meteo](https://open-meteo.com/) — geocoding and weather. Its free API is for non-commercial use and requires attribution; review [terms](https://open-meteo.com/en/terms) before redistributing or commercial use.
- [Open Library](https://openlibrary.org/developers/api) — book catalogue and cover images. Respect API rate limits and cache responses.
- [Wikimedia Commons / MediaWiki APIs](https://www.mediawiki.org/wiki/Wikimedia_APIs) — images and metadata. File licences differ; show attribution and licence details when available.
- [Frankfurter](https://www.frankfurter.app/) — reference exchange rates. Rates may have a publication delay and are not financial advice.

Public does not mean unlimited or unrestricted. AtlasFlow should display source/update details, cache politely, use fallbacks on network failure, and preserve per-item image attribution/license links. Check each provider's current terms before a public or commercial release.

## Development

This repository is being scaffolded as a Flutter project. Install the stable Flutter SDK and a supported platform toolchain first, then run:

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

To choose a target, use `flutter devices` and e.g. `flutter run -d chrome` for web or `flutter run -d <device-id>` for a connected mobile device.

If Flutter reports that a platform runner is missing for your target, generate that runner once from the project root with `flutter create --platforms=android,ios,web,windows,macos,linux .` (omit platforms you do not need), then rerun the commands above. Platform build tooling and signing requirements depend on your machine.

## Privacy & permissions

There is no account or app-owned backend. Saved items and preferences are stored locally. Location is optional and only used to request weather for the device coordinates; users can deny it and search by city. Network providers may receive the queries needed to serve their APIs.

## Status

The source tree is under active initial scaffolding. Verify `flutter analyze`, automated tests, API availability, and target-device builds locally before treating any release as production-ready.
