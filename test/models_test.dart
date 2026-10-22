import 'package:atlasflow/models.dart';
import 'package:atlasflow/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Country model', () {
    test('parses country fields and creates a flag emoji', () {
      final country = Country.fromJson({
        'name': {'common': 'Testland', 'official': 'Republic of Testland'},
        'cca2': 'TL',
        'region': 'Test Region',
        'subregion': 'Test Subregion',
        'population': 123456,
        'area': 456.7,
        'capital': ['Sample City'],
        'flags': {'png': 'https://example.org/flag.png'},
        'languages': {'eng': 'English'},
        'currencies': {'TST': {'name': 'Test dollar'}},
        'timezones': ['UTC+00:00'],
        'borders': ['XX'],
      });

      expect(country.name, 'Testland');
      expect(country.officialName, 'Republic of Testland');
      expect(country.capital, 'Sample City');
      expect(country.currencyLabel, 'Test dollar');
      expect(country.languages, contains('English'));
      expect(country.flagEmoji, '🇹🇱');
      expect(Country.fromSavedJson(country.toJson()).name, 'Testland');
    });
  });

  group('Book model', () {
    test('parses public catalogue results', () {
      final book = Book.fromJson({
        'key': '/works/OL1W',
        'title': 'A Real Book',
        'author_name': ['A. Writer'],
        'first_publish_year': 2001,
        'cover_i': 12345,
        'edition_count': 4,
        'subject': ['World', 'Travel'],
      });
      expect(book.title, 'A Real Book');
      expect(book.authorLabel, 'A. Writer');
      expect(book.coverUrl, contains('12345-M.jpg'));
      expect(Book.fromSavedJson(book.toJson()).key, '/works/OL1W');
    });
  });

  group('TravelDestination model', () {
    test('parses public Wikivoyage article summaries', () {
      final destination = TravelDestination.fromWikivoyage({
        'pageid': 123,
        'title': 'Example City',
        'extract': 'A destination with history and food.',
        'thumbnail': {'source': 'https://example.org/place.jpg'},
        'fullurl': 'https://en.wikivoyage.org/wiki/Example_City',
      });
      expect(destination.title, 'Example City');
      expect(destination.summary, contains('history and food'));
      expect(destination.imageUrl, contains('place.jpg'));
      expect(destination.pageUrl, contains('wikivoyage.org'));
    });
  });

  test('weather copy is human-readable', () {
    expect(weatherDescription(0), 'Clear sky');
    expect(weatherDescription(61), 'Rain');
    expect(weatherDescription(95), 'Thunderstorm');
    expect(formatCompactNumber(1200000), '1.2M');
  });
}
