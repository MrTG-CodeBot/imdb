library imdb;

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;

class Imdb {
  final _header = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/134.0.0.0 Safari/537.36",
    "Accept": "*/*",
    "Accept-Language": "en-US,en;q=0.9",
    "Accept-Encoding": "gzip, deflate, br, zstd",
    "Content-Type": "text/plain;charset=UTF-8",
    "x-amzn-requestid": "b09bdf82-60c1-41d4-a361-fba7b0a4f35f",
    "Origin": "https://www.imdb.com",
    "Connection": "keep-alive",
    "Referer": "https://www.imdb.com/",
  };

  String? __addNameFormat(String? url) {
    if (url == null) return "";
    String newUrl = url.replaceAll(' ', '%20');
    return newUrl;
  }

  Future<String?> __getScrapeId(String? url) async {
    try {
      var newUrl = __addNameFormat(url);
      var response =
          Uri.parse("https://www.imdb.com/find/?q=$newUrl&ref_=nv_sr_sm");
      var result = await http.get(response, headers: _header);
      if (result.statusCode == 200) {
        final htmlString = result.body;
        final document = parse(htmlString);
        final linkElement =
            document.querySelector('.ipc-metadata-list-summary-item__t');
        if (linkElement != null) {
          final href = linkElement.attributes['href'];
          return href;
        } else {
          print("No link found with the specified class.");
          return null;
        }
      } else {
        print('Request failed with status: ${result.statusCode}');
        return null;
      }
    } catch (e) {
      print('An error occurred: $e');
      return null;
    }
  }

  Future<String?> getImdbId(String? moviename) async {
    if (moviename == null) {
      return null;
    }
    final href = await __getScrapeId(moviename);
    if (href != null) {
      final parts = href.split('/');
      for (var i = 0; i < parts.length; i++) {
        if (parts[i] == 'title' && i + 1 < parts.length) {
          final idWithRef = parts[i + 1];
          final idParts = idWithRef.split('?');
          return idParts.first;
        }
      }
    }
    return null;
  }

  Future<Map<String, dynamic>?> getDetails(String? imdbId) async {
    if (imdbId == null) {
      return null;
    }
    final url = Uri.parse('https://www.imdb.com/title/$imdbId/');
    try {
      final response = await http.get(url, headers: _header);
      if (response.statusCode == 200) {
        final document = parse(response.body);
        final scriptElement =
            document.querySelector('script#__NEXT_DATA__[type="application/json"]');
        if (scriptElement != null) {
          final jsonString = scriptElement.innerHtml;
          final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;

          final props = jsonData['props']?['pageProps']?['aboveTheFoldData'] ?? {};
          final mainColumnData =
              jsonData['props']?['pageProps']?['mainColumnData'] ?? {};
          final titleType = props['titleType'] ?? {};

          final id = props['id'] ?? imdbId;
          final originalTitle = props['originalTitleText']?['text'] ?? '';
          final title = props['titleText']?['text'] ?? '';
          final rating = props['certificate']?['rating'] ?? '';
          final releaseDate = props['releaseDate'] ?? {};
          final runtime = props['runtime']?['displayableProperty']?['value']
                  ?['plainText'] ??
              '';
          final plot = props['plot']?['plotText']?['plainText'] ?? '';

          final isSeries = titleType['isSeries'] ?? false;
          final canHaveEpisodes = titleType['canHaveEpisodes'] ?? false;
          final isEpisode = titleType['isEpisode'] ?? false;

          final ratingsSummary = props['ratingsSummary'] ?? {};
          final aggregateRating =
              ratingsSummary['aggregateRating']?.toDouble() ?? 0.0;
          final voteCount = ratingsSummary['voteCount'] ?? 0;

          final primaryImage = props['primaryImage'] ?? {};
          final imageUrl = primaryImage['url'] ?? '';

          List<dynamic> trailers = [];
          final primaryVideos = props['primaryVideos']?['edges'] ?? [];
          if (primaryVideos.isNotEmpty) {
            trailers = primaryVideos[0]['node']?['playbackURLs'] ?? [];
          }
          final trailerUrls = trailers
              .map((trailer) => {
                    'videoMimeType': trailer['videoMimeType'] ?? '',
                    'videoDefinition': trailer['videoDefinition'] ?? '',
                    'url': trailer['url'] ?? ''
                  })
              .toList();

          final keywords = (props['keywords']?['edges'] ?? [])
              .take(5)
              .map((kw) => kw['node']?['text'] ?? '')
              .toList();

          final genres = (props['genres']?['genres'] ?? [])
              .map((g) => g['text'] ?? '')
              .toList();

          final principalCredits = props['principalCredits'] ?? [];
          String director = '';
          String writer = '';
          final cast = <Map<String, dynamic>>[];

          for (final credit in principalCredits) {
            final category = credit['category']?['text'] ?? '';
            if (category == 'Director') {
              director = credit['credits']?[0]?['name']?['nameText']?['text'] ??
                  '';
            } else if (category == 'Writer') {
              writer = credit['credits']?[0]?['name']?['nameText']?['text'] ?? '';
            } else if (category == 'Stars') {
              final credits = credit['credits'] ?? [];
              for (final person in credits.take(3)) {
                cast.add({
                  'name': person['name']?['nameText']?['text'] ?? '',
                  'character': person['characters']?[0]?['name'] ?? '',
                  'voice': (person['attributes'] ?? [])
                      .any((attr) => attr['text'] == 'voice')
                });
              }
            }
          }

          final watchlistStats = props['engagementStatistics']
                  ?['watchlistStatistics']?['displayableCount']?['text'] ??
              '';

          final reviewsCount = mainColumnData['reviews']?['total'] ?? 0;

          final countries = props['countriesOfOrigin']?['countries'] ?? [];
          final countryOfOrigin = countries.isNotEmpty ? countries[0]['id'] : '';

          final boxOffice = {
            'productionBudget': mainColumnData['productionBudget']?['budget'] ?? {},
            'lifetimeGross': mainColumnData['lifetimeGross']?['total'] ?? {},
            'openingWeekendGross': mainColumnData['openingWeekendGross']?['gross']
                    ?['total'] ??
                {}
          };

          final similarTitles = (mainColumnData['moreLikeThisTitles']?['edges'] ?? [])
              .take(5)
              .map((title) => {
                    'title': title['node']?['titleText']?['text'] ?? '',
                    'year': title['node']?['releaseYear']?['year'] ?? 0
                  })
              .toList();

          return {
            'id': id,
            'title': title,
            'originalTitle': originalTitle,
            'rating': rating,
            'releaseDate': {
              'day': releaseDate['day'],
              'month': releaseDate['month'],
              'year': releaseDate['year']
            },
            'runtime': runtime,
            'isSeries': isSeries,
            'canHaveEpisodes': canHaveEpisodes,
            'isEpisode': isEpisode,
            'ratings': {'average': aggregateRating, 'count': voteCount},
            'image': imageUrl,
            'trailers': trailerUrls,
            'keywords': keywords,
            'genres': genres,
            'director': director,
            'writer': writer,
            'cast': cast,
            'watchlistStats': watchlistStats,
            'reviewsCount': reviewsCount,
            'countryOfOrigin': countryOfOrigin,
            'plot': plot,
            'boxOffice': boxOffice,
            'similarTitles': similarTitles
          };
        } else {
          print('Failed to get the details');
          return null;
        }
      } else {
        print('Failed to load IMDb page. Status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching IMDb details: $e');
      return null;
    }
  }
}