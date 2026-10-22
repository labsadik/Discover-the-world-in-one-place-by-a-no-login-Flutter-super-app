import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';

class ApiException implements Exception {
  const ApiException(this.message);
  final String message;

  @override
  String toString() => message;
}

class ApiService {
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  static const _timeout = Duration(seconds: 18);

  Future<dynamic> _getJson(Uri uri, {required String cacheKey}) async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final response = await _client
          .get(uri, headers: const {'Accept': 'application/json'})
          .timeout(_timeout);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException('The data source returned HTTP ${response.statusCode}.');
      }
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      await prefs.setString('atlas_cache_$cacheKey', jsonEncode(decoded));
      await prefs.setInt('atlas_cache_time_$cacheKey', DateTime.now().millisecondsSinceEpoch);
      return decoded;
    } catch (error) {
      final cached = prefs.getString('atlas_cache_$cacheKey');
      if (cached != null) {
        try {
          return jsonDecode(cached);
        } catch (_) {
          // Ignore invalid cached content and report the network error below.
        }
      }
      if (error is ApiException) rethrow;
      throw const ApiException('Could not reach the public data source. Check your connection and try again.');
    }
  }

  Future<List<Country>> fetchCountries({bool forceRefresh = false}) async {
    final prefs = await SharedPreferences.getInstance();
    if (!forceRefresh) {
      final cachedAt = prefs.getInt('atlas_cache_time_countries');
      final cached = prefs.getString('atlas_cache_countries');
      final isFresh = cachedAt != null &&
          DateTime.now().millisecondsSinceEpoch - cachedAt < const Duration(hours: 24).inMilliseconds;
      if (cached != null && isFresh) {
        try {
          final decoded = jsonDecode(cached) as List<dynamic>;
          return decoded.map((item) => Country.fromJson(asJsonMap(item))).toList()
            ..sort((a, b) => a.name.compareTo(b.name));
        } catch (_) {
          // Refresh from the source if cached data is malformed.
        }
      }
    }

    final data = await _getJson(
      Uri.parse('https://raw.githubusercontent.com/mledoze/countries/master/countries.json'),
      cacheKey: 'countries',
    );
    if (data is! List) throw const ApiException('Country data had an unexpected format.');
    final countries = data
        .map((item) => Country.fromJson(asJsonMap(item)))
        .where((country) => country.name.isNotEmpty && country.code.isNotEmpty)
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    return countries;
  }

  Future<Map<String, dynamic>> _fetchJsonObject(Uri uri, String cacheKey) async {
    final data = await _getJson(uri, cacheKey: cacheKey);
    return asJsonMap(data);
  }

  Future<WeatherSnapshot> fetchWeather(double latitude, double longitude) async {
    final roundedLat = latitude.toStringAsFixed(2);
    final roundedLon = longitude.toStringAsFixed(2);
    final query = <String, String>{
      'latitude': roundedLat,
      'longitude': roundedLon,
      'current': 'temperature_2m,relative_humidity_2m,apparent_temperature,is_day,weather_code,wind_speed_10m',
      'hourly': 'temperature_2m,precipitation_probability',
      'daily': 'weather_code,temperature_2m_max,temperature_2m_min,sunrise,sunset',
      'forecast_days': '7',
      'timezone': 'auto',
    };
    final result = await _fetchJsonObject(
      Uri.https('api.open-meteo.com', '/v1/forecast', query),
      'weather_${roundedLat}__$roundedLon',
    );
    final current = asJsonMap(result['current']);
    final hourly = asJsonMap(result['hourly']);
    final daily = asJsonMap(result['daily']);

    double number(dynamic value, [double fallback = 0]) =>
        value is num ? value.toDouble() : fallback;
    int integer(dynamic value, [int fallback = 0]) =>
        value is num ? value.toInt() : fallback;
    final hourlyTimes = asJsonList(hourly['time']).map((item) => item.toString()).toList();
    final hourlyTemps = asJsonList(hourly['temperature_2m']).map((item) => number(item)).toList();
    final hourlyRain = asJsonList(hourly['precipitation_probability']).map((item) => integer(item)).toList();
    final dates = asJsonList(daily['time']).map((item) => item.toString()).toList();
    final codes = asJsonList(daily['weather_code']);
    final mins = asJsonList(daily['temperature_2m_min']);
    final maxs = asJsonList(daily['temperature_2m_max']);
    final sunrises = asJsonList(daily['sunrise']);
    final sunsets = asJsonList(daily['sunset']);
    final days = <ForecastDay>[];
    for (var i = 0; i < dates.length; i++) {
      days.add(ForecastDay(
        date: dates[i],
        weatherCode: i < codes.length ? integer(codes[i]) : 0,
        minTemp: i < mins.length ? number(mins[i]) : 0,
        maxTemp: i < maxs.length ? number(maxs[i]) : 0,
        sunrise: i < sunrises.length ? sunrises[i].toString() : '',
        sunset: i < sunsets.length ? sunsets[i].toString() : '',
      ));
    }

    double? aqi;
    double? pm25;
    try {
      final air = await _fetchJsonObject(
        Uri.https('air-quality-api.open-meteo.com', '/v1/air-quality', {
          'latitude': roundedLat,
          'longitude': roundedLon,
          'current': 'us_aqi,pm2_5',
          'timezone': 'auto',
        }),
        'air_${roundedLat}__$roundedLon',
      );
      final airCurrent = asJsonMap(air['current']);
      aqi = (airCurrent['us_aqi'] as num?)?.toDouble();
      pm25 = (airCurrent['pm2_5'] as num?)?.toDouble();
    } catch (_) {
      // Weather remains useful even if the separate air-quality service is unavailable.
    }

    return WeatherSnapshot(
      latitude: number(result['latitude'], latitude),
      longitude: number(result['longitude'], longitude),
      timezone: (result['timezone'] ?? 'Local time').toString(),
      updatedAt: (current['time'] ?? '').toString(),
      temperature: number(current['temperature_2m']),
      apparentTemperature: number(current['apparent_temperature']),
      humidity: integer(current['relative_humidity_2m']),
      windSpeed: number(current['wind_speed_10m']),
      weatherCode: integer(current['weather_code']),
      isDay: integer(current['is_day'], 1) == 1,
      hourlyTimes: hourlyTimes,
      hourlyTemps: hourlyTemps,
      hourlyRain: hourlyRain,
      days: days,
      usAqi: aqi,
      pm25: pm25,
    );
  }

  Future<({double latitude, double longitude, String name, String country})> geocodeCity(
    String city,
  ) async {
    final trimmed = city.trim();
    if (trimmed.isEmpty) throw const ApiException('Enter a city name first.');
    final result = await _fetchJsonObject(
      Uri.https('geocoding-api.open-meteo.com', '/v1/search', {
        'name': trimmed,
        'count': '8',
        'language': 'en',
        'format': 'json',
      }),
      'geocode_${trimmed.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_')}',
    );
    final matches = asJsonList(result['results']);
    if (matches.isEmpty) throw ApiException('No matching place found for “$trimmed”.');
    final place = asJsonMap(matches.first);
    return (
      latitude: (place['latitude'] as num).toDouble(),
      longitude: (place['longitude'] as num).toDouble(),
      name: (place['name'] ?? trimmed).toString(),
      country: (place['country'] ?? '').toString(),
    );
  }

  Future<List<Book>> searchBooks(String query) async {
    final trimmed = query.trim().isEmpty ? 'world' : query.trim();
    final data = await _fetchJsonObject(
      Uri.https('openlibrary.org', '/search.json', {
        'q': trimmed,
        'limit': '24',
        'fields': 'key,title,author_name,first_publish_year,cover_i,edition_count,subject',
      }),
      'books_${trimmed.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_')}',
    );
    return asJsonList(data['docs'])
        .map((item) => Book.fromJson(asJsonMap(item)))
        .where((book) => book.key.isNotEmpty && book.title.isNotEmpty)
        .toList();
  }

  Future<List<PhotoItem>> searchCommons(String query) async {
    final trimmed = query.trim().isEmpty ? 'world landmarks' : query.trim();
    final data = await _fetchJsonObject(
      Uri.https('commons.wikimedia.org', '/w/api.php', {
        'action': 'query',
        'generator': 'search',
        'gsrsearch': 'filetype:bitmap $trimmed',
        'gsrnamespace': '6',
        'gsrlimit': '24',
        'prop': 'imageinfo',
        'iiprop': 'url|extmetadata',
        'iiurlwidth': '720',
        'format': 'json',
        'origin': '*',
      }),
      'commons_${trimmed.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_')}',
    );
    final pages = asJsonMap(asJsonMap(data['query'])['pages']);
    final photos = <PhotoItem>[];
    for (final value in pages.values) {
      final photo = PhotoItem.fromCommons(asJsonMap(value));
      if (photo.imageUrl.isNotEmpty) photos.add(photo);
    }
    return photos;
  }

  Future<Map<String, String>> fetchCurrencies() async {
    final data = await _fetchJsonObject(
      Uri.https('api.frankfurter.dev', '/v1/currencies'),
      'currencies',
    );
    return data.map((key, value) => MapEntry(key, value.toString()));
  }

  Future<({String date, Map<String, double> rates})> fetchRates(String base) async {
    final code = base.toUpperCase();
    final data = await _fetchJsonObject(
      Uri.https('api.frankfurter.dev', '/v1/latest', {'base': code}),
      'rates_$code',
    );
    final ratesData = asJsonMap(data['rates']);
    return (
      date: (data['date'] ?? '').toString(),
      rates: ratesData.map((key, value) => MapEntry(
            key,
            value is num ? value.toDouble() : double.tryParse(value.toString()) ?? 0,
          )),
    );
  }

  void dispose() => _client.close();
}