import 'dart:convert';

Map<String, dynamic> asJsonMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return value.map((key, value) => MapEntry(key.toString(), value));
  return <String, dynamic>{};
}

List<dynamic> asJsonList(dynamic value) => value is List ? value : const <dynamic>[];

String cleanHtml(String value) => value
    .replaceAll(RegExp(r'<[^>]*>'), ' ')
    .replaceAll('&amp;', '&')
    .replaceAll('&quot;', '"')
    .replaceAll('&#39;', "'")
    .replaceAll('&lt;', '<')
    .replaceAll('&gt;', '>')
    .replaceAll(RegExp(r'\s+'), ' ')
    .trim();

class Country {
  const Country({
    required this.name,
    required this.officialName,
    required this.code,
    required this.region,
    required this.subregion,
    required this.population,
    required this.area,
    required this.capitals,
    required this.flagUrl,
    required this.languages,
    required this.currencyNames,
    required this.currencyCodes,
    required this.timezones,
    required this.borders,
    this.translatedNames = const {},
  });

  final String name;
  final String officialName;
  final String code;
  final String region;
  final String subregion;
  final int population;
  final double area;
  final List<String> capitals;
  final String flagUrl;
  final List<String> languages;
  final List<String> currencyNames;
  final List<String> currencyCodes;
  final List<String> timezones;
  final List<String> borders;
  final Map<String, String> translatedNames;
  String localizedName(String languageCode) {
    final translated = translatedNames[languageCode];
    if (translated != null && translated.isNotEmpty) return translated;
    if (languageCode == 'bn') return const {'IN':'ভারত','BD':'বাংলাদেশ','US':'মার্কিন যুক্তরাষ্ট্র','GB':'যুক্তরাজ্য','CN':'চীন','JP':'জাপান','RU':'রাশিয়া','IR':'ইরান','SA':'সৌদি আরব','AE':'সংযুক্ত আরব আমিরাত','PK':'পাকিস্তান','NP':'নেপাল','LK':'শ্রীলঙ্কা','BR':'ব্রাজিল','FR':'ফ্রান্স','DE':'জার্মানি','CA':'কানাডা','AU':'অস্ট্রেলিয়া','KR':'দক্ষিণ কোরিয়া','IT':'ইতালি','ES':'স্পেন','EG':'মিশর','ZA':'দক্ষিণ আফ্রিকা','ID':'ইন্দোনেশিয়া','MX':'মেক্সিকো','TH':'থাইল্যান্ড','TR':'তুরস্ক','SG':'সিঙ্গাপুর','MY':'মালয়েশিয়া','AF':'আফগানিস্তান','UA':'ইউক্রেন','CH':'সুইজারল্যান্ড','NZ':'নিউজিল্যান্ড','NG':'নাইজেরিয়া','KE':'কেনিয়া','AR':'আর্জেন্টিনা','SE':'সুইডেন','NO':'নরওয়ে','FI':'ফিনল্যান্ড','PL':'পোল্যান্ড','PT':'পর্তুগাল','GR':'গ্রিস','IQ':'ইরাক','IL':'ইসরায়েল','QA':'কাতার','KW':'কুয়েত','OM':'ওমান','MM':'মিয়ানমার','VN':'ভিয়েতনাম','PH':'ফিলিপাইন','ET':'ইথিওপিয়া','MA':'মরক্কো'}[code] ?? name;
    if (languageCode == 'hi') return const {'IN':'भारत','BD':'बांग्लादेश','US':'संयुक्त राज्य अमेरिका','GB':'यूनाइटेड किंगडम','CN':'चीन','JP':'जापान','RU':'रूस','IR':'ईरान','SA':'सऊदी अरब','AE':'संयुक्त अरब अमीरात','PK':'पाकिस्तान','NP':'नेपाल','LK':'श्रीलंका','BR':'ब्राज़ील','FR':'फ़्रांस','DE':'जर्मनी','CA':'कनाडा','AU':'ऑस्ट्रेलिया','KR':'दक्षिण कोरिया','IT':'इटली','ES':'स्पेन','EG':'मिस्र','ZA':'दक्षिण अफ्रीका','ID':'इंडोनेशिया','MX':'मेक्सिको','TH':'थाईलैंड','TR':'तुर्की','SG':'सिंगापुर','MY':'मलेशिया','AF':'अफ़ग़ानिस्तान','UA':'यूक्रेन','CH':'स्विट्ज़रलैंड','NZ':'न्यूज़ीलैंड','NG':'नाइजीरिया','KE':'केन्या','AR':'अर्जेंटीना','SE':'स्वीडन','NO':'नॉर्वे','FI':'फ़िनलैंड','PL':'पोलैंड','PT':'पुर्तगाल','GR':'ग्रीस','IQ':'इराक','IL':'इज़राइल','QA':'क़तर','KW':'कुवैत','OM':'ओमान','MM':'म्यांमार','VN':'वियतनाम','PH':'फ़िलिपींस','ET':'इथियोपिया','MA':'मोरक्को'}[code] ?? name;
    return name;
  }

  String get capital => capitals.isEmpty ? 'Not listed' : capitals.first;
  String get currencyLabel => currencyNames.isEmpty
      ? (currencyCodes.isEmpty ? 'Not listed' : currencyCodes.join(', '))
      : currencyNames.join(', ');
  String get flagEmoji {
    if (code.length != 2) return '🌐';
    final upper = code.toUpperCase();
    final points = upper.codeUnits.map((unit) => 0x1F1E6 + unit - 0x41).toList();
    return String.fromCharCodes(points);
  }

  factory Country.fromJson(Map<String, dynamic> json) {
    final nameData = asJsonMap(json['name']);
    final flagData = asJsonMap(json['flags']);
    final currencyData = asJsonMap(json['currencies']);
    final languageData = asJsonMap(json['languages']);
    final translationData = asJsonMap(json['translations']);
    const translationKeys = {'ar':'ara','fa':'per','ru':'rus','zh':'zho','ja':'jpn','hi':'hin'};
    final translatedNames = <String, String>{};
    for (final entry in translationKeys.entries) {
      final translated = asJsonMap(translationData[entry.value])['common'];
      if (translated is String && translated.isNotEmpty) translatedNames[entry.key] = translated;
    }

    return Country(
      name: (nameData['common'] ?? json['name'] ?? 'Unknown').toString(),
      officialName: (nameData['official'] ?? nameData['common'] ?? 'Unknown').toString(),
      code: (json['cca2'] ?? json['alpha2Code'] ?? '').toString().toUpperCase(),
      region: (json['region'] ?? 'Other').toString().isEmpty
          ? 'Other'
          : (json['region'] ?? 'Other').toString(),
      subregion: (json['subregion'] ?? '').toString(),
      population: (json['population'] is num) ? (json['population'] as num).toInt() : 0,
      area: (json['area'] is num) ? (json['area'] as num).toDouble() : 0,
      capitals: asJsonList(json['capital']).map((item) => item.toString()).toList(),
      flagUrl: (flagData['png'] ?? flagData['svg'] ?? '').toString(),
      languages: languageData.values.map((item) => item.toString()).toList(),
      currencyNames: currencyData.values
          .map((item) => asJsonMap(item)['name']?.toString() ?? '')
          .where((value) => value.isNotEmpty)
          .toList(),
      currencyCodes: currencyData.keys.toList(),
      timezones: asJsonList(json['timezones']).map((item) => item.toString()).toList(),
      borders: asJsonList(json['borders']).map((item) => item.toString()).toList(),
      translatedNames: translatedNames,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'officialName': officialName,
        'code': code,
        'region': region,
        'subregion': subregion,
        'population': population,
        'area': area,
        'capitals': capitals,
        'flagUrl': flagUrl,
        'languages': languages,
        'currencyNames': currencyNames,
        'currencyCodes': currencyCodes,
        'timezones': timezones,
        'borders': borders,
        'translatedNames': translatedNames,
      };

  factory Country.fromSavedJson(Map<String, dynamic> json) => Country(
        name: (json['name'] ?? 'Unknown').toString(),
        officialName: (json['officialName'] ?? json['name'] ?? 'Unknown').toString(),
        code: (json['code'] ?? '').toString(),
        region: (json['region'] ?? 'Other').toString(),
        subregion: (json['subregion'] ?? '').toString(),
        population: (json['population'] as num?)?.toInt() ?? 0,
        area: (json['area'] as num?)?.toDouble() ?? 0,
        capitals: asJsonList(json['capitals']).map((item) => item.toString()).toList(),
        flagUrl: (json['flagUrl'] ?? '').toString(),
        languages: asJsonList(json['languages']).map((item) => item.toString()).toList(),
        currencyNames: asJsonList(json['currencyNames']).map((item) => item.toString()).toList(),
        currencyCodes: asJsonList(json['currencyCodes']).map((item) => item.toString()).toList(),
        timezones: asJsonList(json['timezones']).map((item) => item.toString()).toList(),
        borders: asJsonList(json['borders']).map((item) => item.toString()).toList(),
        translatedNames: asJsonMap(json['translatedNames']).map((key, value) => MapEntry(key.toString(), value.toString())),
      );

  String toSavedString() => jsonEncode(toJson());
}

class Book {
  const Book({
    required this.key,
    required this.title,
    required this.authors,
    required this.firstPublishYear,
    required this.coverId,
    required this.editionCount,
    required this.subjects,
  });

  final String key;
  final String title;
  final List<String> authors;
  final int? firstPublishYear;
  final int? coverId;
  final int editionCount;
  final List<String> subjects;

  String get authorLabel => authors.isEmpty ? 'Author not listed' : authors.take(3).join(', ');
  String get coverUrl => coverId == null
      ? ''
      : 'https://covers.openlibrary.org/b/id/$coverId-M.jpg';

  factory Book.fromJson(Map<String, dynamic> json) => Book(
        key: (json['key'] ?? '').toString(),
        title: (json['title'] ?? 'Untitled').toString(),
        authors: asJsonList(json['author_name']).map((item) => item.toString()).toList(),
        firstPublishYear: (json['first_publish_year'] as num?)?.toInt(),
        coverId: (json['cover_i'] as num?)?.toInt(),
        editionCount: (json['edition_count'] as num?)?.toInt() ?? 0,
        subjects: asJsonList(json['subject']).take(6).map((item) => item.toString()).toList(),
      );

  factory Book.fromSavedJson(Map<String, dynamic> json) => Book(
        key: (json['key'] ?? '').toString(),
        title: (json['title'] ?? 'Untitled').toString(),
        authors: asJsonList(json['authors']).map((item) => item.toString()).toList(),
        firstPublishYear: (json['firstPublishYear'] as num?)?.toInt(),
        coverId: (json['coverId'] as num?)?.toInt(),
        editionCount: (json['editionCount'] as num?)?.toInt() ?? 0,
        subjects: asJsonList(json['subjects']).map((item) => item.toString()).toList(),
      );

  Map<String, dynamic> toJson() => {
        'key': key,
        'title': title,
        'authors': authors,
        'firstPublishYear': firstPublishYear,
        'coverId': coverId,
        'editionCount': editionCount,
        'subjects': subjects,
      };
}

class PhotoItem {
  const PhotoItem({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.pageUrl,
    required this.artist,
    required this.license,
    required this.licenseUrl,
  });

  final String id;
  final String title;
  final String imageUrl;
  final String pageUrl;
  final String artist;
  final String license;
  final String licenseUrl;

  factory PhotoItem.fromCommons(Map<String, dynamic> json) {
    final imageInfo = asJsonList(json['imageinfo']);
    final info = imageInfo.isEmpty ? <String, dynamic>{} : asJsonMap(imageInfo.first);
    final metadata = asJsonMap(info['extmetadata']);
    String metaValue(String key) => cleanHtml(asJsonMap(metadata[key])['value']?.toString() ?? '');
    return PhotoItem(
      id: (json['pageid'] ?? json['title'] ?? '').toString(),
      title: (json['title'] ?? 'Untitled image').toString().replaceFirst('File:', ''),
      imageUrl: (info['thumburl'] ?? info['url'] ?? '').toString(),
      pageUrl: (info['descriptionurl'] ?? '').toString(),
      artist: metaValue('Artist').isEmpty ? 'Creator not listed' : metaValue('Artist'),
      license: metaValue('LicenseShortName').isEmpty ? 'See file page for licence' : metaValue('LicenseShortName'),
      licenseUrl: metaValue('LicenseUrl'),
    );
  }

  factory PhotoItem.fromSavedJson(Map<String, dynamic> json) => PhotoItem(
        id: (json['id'] ?? '').toString(),
        title: (json['title'] ?? 'Untitled image').toString(),
        imageUrl: (json['imageUrl'] ?? '').toString(),
        pageUrl: (json['pageUrl'] ?? '').toString(),
        artist: (json['artist'] ?? 'Creator not listed').toString(),
        license: (json['license'] ?? 'See file page for licence').toString(),
        licenseUrl: (json['licenseUrl'] ?? '').toString(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'imageUrl': imageUrl,
        'pageUrl': pageUrl,
        'artist': artist,
        'license': license,
        'licenseUrl': licenseUrl,
      };
}

class TravelDestination {
  const TravelDestination({
    required this.id,
    required this.title,
    required this.summary,
    required this.imageUrl,
    required this.pageUrl,
  });

  final String id;
  final String title;
  final String summary;
  final String imageUrl;
  final String pageUrl;

  factory TravelDestination.fromWikipedia(Map<String, dynamic> json) {
    final thumbnail = asJsonMap(json['thumbnail']);
    final rawSummary = cleanHtml((json['extract'] ?? '').toString());
    return TravelDestination(id: (json['pageid'] ?? json['title'] ?? '').toString(), title: (json['title'] ?? 'Untitled place').toString(), summary: rawSummary.isEmpty ? 'Open the source article for more information.' : rawSummary, imageUrl: (thumbnail['source'] ?? '').toString(), pageUrl: (json['fullurl'] ?? '').toString());
  }

  factory TravelDestination.fromWikivoyage(Map<String, dynamic> json) {
    final thumbnail = asJsonMap(json['thumbnail']);
    final rawSummary = cleanHtml((json['extract'] ?? '').toString());
    return TravelDestination(
      id: (json['pageid'] ?? json['title'] ?? '').toString(),
      title: (json['title'] ?? 'Untitled destination').toString(),
      summary: rawSummary.isEmpty ? 'Open the source article for destination information and travel tips.' : rawSummary,
      imageUrl: (thumbnail['source'] ?? '').toString(),
      pageUrl: (json['fullurl'] ?? '').toString(),
    );
  }
}

class ForecastDay {
  const ForecastDay({
    required this.date,
    required this.weatherCode,
    required this.minTemp,
    required this.maxTemp,
    required this.sunrise,
    required this.sunset,
  });

  final String date;
  final int weatherCode;
  final double minTemp;
  final double maxTemp;
  final String sunrise;
  final String sunset;
}

class WeatherSnapshot {
  const WeatherSnapshot({
    required this.latitude,
    required this.longitude,
    required this.timezone,
    required this.updatedAt,
    required this.temperature,
    required this.apparentTemperature,
    required this.humidity,
    required this.windSpeed,
    required this.weatherCode,
    required this.isDay,
    required this.hourlyTimes,
    required this.hourlyTemps,
    required this.hourlyRain,
    required this.days,
    this.usAqi,
    this.pm25,
  });

  final double latitude;
  final double longitude;
  final String timezone;
  final String updatedAt;
  final double temperature;
  final double apparentTemperature;
  final int humidity;
  final double windSpeed;
  final int weatherCode;
  final bool isDay;
  final List<String> hourlyTimes;
  final List<double> hourlyTemps;
  final List<int> hourlyRain;
  final List<ForecastDay> days;
  final double? usAqi;
  final double? pm25;
}

class PublicEntity {
  const PublicEntity({required this.id, required this.label, required this.description, required this.url});
  final String id, label, description, url;
  factory PublicEntity.fromJson(Map<String, dynamic> json) => PublicEntity(
    id: (json['id'] ?? '').toString(),
    label: (json['label'] ?? json['id'] ?? '').toString(),
    description: (json['description'] ?? '').toString(),
    url: (json['concepturi'] ?? 'https://www.wikidata.org/wiki/${json['id'] ?? ''}').toString(),
  );
}

class WorldBankIndicator {
  const WorldBankIndicator({required this.code, required this.value, required this.year});
  final String code;
  final double value;
  final String year;
}
