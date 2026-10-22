import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api_service.dart';
import 'models.dart';

class AppStore extends ChangeNotifier {
  AppStore._();

  static final AppStore instance = AppStore._();

  final ApiService api = ApiService();
  SharedPreferences? _prefs;

  ThemeMode themeMode = ThemeMode.system;
  List<Country> countries = const [];
  bool countriesLoading = false;
  String? countriesError;
  final Set<String> favoriteCountryCodes = {};
  final Map<String, String> readingStatuses = {};
  final Map<String, Book> savedBooks = {};
  final Map<String, PhotoItem> savedPhotos = {};
  int bestQuizScore = 0;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    final theme = _prefs?.getString('theme_mode') ?? 'system';
    themeMode = switch (theme) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    favoriteCountryCodes.addAll(_prefs?.getStringList('favorite_countries') ?? const []);
    bestQuizScore = _prefs?.getInt('best_quiz_score') ?? 0;

    try {
      final booksRaw = _prefs?.getString('saved_books') ?? '{}';
      final booksJson = jsonDecode(booksRaw);
      if (booksJson is Map) {
        for (final entry in booksJson.entries) {
          final value = entry.value;
          if (value is Map) {
            final map = value.map((key, value) => MapEntry(key.toString(), value));
            savedBooks[entry.key.toString()] = Book.fromSavedJson(map);
          }
        }
      }
      final statusesRaw = _prefs?.getString('reading_statuses') ?? '{}';
      final statusesJson = jsonDecode(statusesRaw);
      if (statusesJson is Map) {
        readingStatuses.addAll(statusesJson.map(
          (key, value) => MapEntry(key.toString(), value.toString()),
        ));
      }
      final photosRaw = _prefs?.getString('saved_photos') ?? '{}';
      final photosJson = jsonDecode(photosRaw);
      if (photosJson is Map) {
        for (final entry in photosJson.entries) {
          final value = entry.value;
          if (value is Map) {
            final map = value.map((key, value) => MapEntry(key.toString(), value));
            savedPhotos[entry.key.toString()] = PhotoItem.fromSavedJson(map);
          }
        }
      }
    } catch (_) {
      // A corrupt local preference should not stop the app from opening.
    }
  }

  Future<void> setThemeMode(ThemeMode value) async {
    themeMode = value;
    notifyListeners();
    await _prefs?.setString('theme_mode', switch (value) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      _ => 'system',
    });
  }

  Future<void> loadCountries({bool forceRefresh = false}) async {
    if (countriesLoading || (countries.isNotEmpty && !forceRefresh)) return;
    countriesLoading = true;
    countriesError = null;
    notifyListeners();
    try {
      countries = await api.fetchCountries(forceRefresh: forceRefresh);
    } catch (error) {
      countriesError = error.toString();
    } finally {
      countriesLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleCountryFavorite(Country country) async {
    if (favoriteCountryCodes.contains(country.code)) {
      favoriteCountryCodes.remove(country.code);
    } else {
      favoriteCountryCodes.add(country.code);
    }
    notifyListeners();
    await _prefs?.setStringList('favorite_countries', favoriteCountryCodes.toList());
  }

  Future<void> setBookStatus(Book book, String? status) async {
    if (status == null) {
      readingStatuses.remove(book.key);
      savedBooks.remove(book.key);
    } else {
      readingStatuses[book.key] = status;
      savedBooks[book.key] = book;
    }
    notifyListeners();
    await _prefs?.setString(
      'reading_statuses',
      jsonEncode(readingStatuses),
    );
    await _prefs?.setString(
      'saved_books',
      jsonEncode(savedBooks.map((key, value) => MapEntry(key, value.toJson()))),
    );
  }

  Future<void> togglePhotoSaved(PhotoItem photo) async {
    if (savedPhotos.containsKey(photo.id)) {
      savedPhotos.remove(photo.id);
    } else {
      savedPhotos[photo.id] = photo;
    }
    notifyListeners();
    await _prefs?.setString(
      'saved_photos',
      jsonEncode(savedPhotos.map((key, value) => MapEntry(key, value.toJson()))),
    );
  }

  Future<void> updateBestQuizScore(int score) async {
    if (score <= bestQuizScore) return;
    bestQuizScore = score;
    notifyListeners();
    await _prefs?.setInt('best_quiz_score', score);
  }
}
