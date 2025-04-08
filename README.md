<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/tools/pub/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/to/develop-packages).
-->

# imdb_scraper

A Dart package for scraping movie and series information from IMDb, including titles, ratings, cast details, and more.

## Features

-  Fetch IMDb IDs by movie/series name
-  Get detailed information including:
  - Title, original title, and content rating
  - Release date and runtime
  - Ratings and vote counts
  - Cast and crew information
  - Plot summaries
  - Box office statistics
  - Similar titles recommendations
-  Retrieve poster images
-  Access trailer URLs
-  Lightweight and easy to use
- Fetch current trending movies from IMDb's Moviemeter chart
- Fetch popular TV series from IMDb's TV Meter chart
- Get detailed information including:
  - Titles and release years
  - Ratings and vote counts
  - Poster images
  - For TV series: start/end years and episode counts

## Getting started

### Prerequisites
- Dart SDK (>=3.0.0)


### Installation
Add this to your `pubspec.yaml`:

```yaml
dependencies:
  imdb_scraper: 1.0.4
```

## Usage

### Basic example for search a movie or series
```dart
 // Example demonstrating comprehensive usage of the IMDb scraper package.
 // Shows how to:
 // 1. Search for a title to get its IMDb ID
 // 2. Fetch detailed information using the ID
 // 3. Access and display various data points


import 'package:imdb_scraper/imdb_scraper.dart';

void main() async {
  // Initialize the IMDb scraper
  final imdb = Imdb();
  
  // Search for a movie by title
  final movieName = "weathering with you"; 
  final imdbId = await imdb.getImdbId(movieName);
  
  if (imdbId == null) {
    print('Failed to find IMDb ID for "$movieName"');
    return;
  }
  
  // Get detailed information
  final details = await imdb.getDetails(imdbId);
  
  if (details != null) {
    // Display all available information
    print('\n=== Basic Information ===');
    print('Title: ${details['title']}');
    print('Original Title: ${details['originalTitle']}');
        print('IMDb ID: ${details['id']}');
    print('Rating: ${details['rating']}');
    print('Release Date: ${details['releaseDate']['year']}-${details['releaseDate']['month']}-${details['releaseDate']['day']}');
    print('Runtime: ${details['runtime']}');
    
    print('\n=== Series/Episode Info ===');
    print('Is Series: ${details['isSeries']}');
    print('Can Have Episodes: ${details['canHaveEpisodes']}');
    print('Is Episode: ${details['isEpisode']}');
    
    print('\n=== Ratings ===');
    print('IMDb Rating: ${details['ratings']['average']} (${details['ratings']['count']} votes)');
    
    print('\n=== Media ===');
    print('Poster Image URL: ${details['image']}');
    print('Trailers Available: ${details['trailers'].length}');
    if (details['trailers'].isNotEmpty) {
      print('First trailer URL: ${details['trailers'][0]['url']}');
    }
    
    print('\n=== Genres & Keywords ===');
    print('Genres: ${details['genres'].join(', ')}');
    print('Keywords: ${details['keywords'].join(', ')}');
    
    print('\n=== Credits ===');
    print('Director: ${details['director']}');
    print('Writer: ${details['writer']}');
    print('Cast:');
    for (final actor in details['cast']) {
      print('  ${actor['name']} as ${actor['character']} ${actor['voice'] ? '(voice)' : ''}');
    }
    
    print('\n=== Statistics ===');
    print('Watchlist: ${details['watchlistStats']}');
    print('Total Reviews: ${details['reviewsCount']}');
    print('Country of Origin: ${details['countryOfOrigin']}');
    
    print('\n=== Plot ===');
    print(details['plot']);
    
    print('\n=== Box Office ===');
    print('Production Budget: ${details['boxOffice']['productionBudget']['amount']} ${details['boxOffice']['productionBudget']['currency']}');
    print('Lifetime Gross: ${details['boxOffice']['lifetimeGross']['amount']} ${details['boxOffice']['lifetimeGross']['currency']}');
    print('Opening Weekend Gross: ${details['boxOffice']['openingWeekendGross']['amount']} ${details['boxOffice']['openingWeekendGross']['currency']}');
    
    print('\n=== Similar Titles ===');
    for (final similar in details['similarTitles']) {
      print('  ${similar['title']} (${similar['year']})');
    }

  } else {
    print('Failed to get details for IMDb ID: $imdbId');
  }
}
```
[Search movie or series](https://github.com/MrTG-CodeBot/imdb_scraper/blob/main/example/example.dart)

### Basic example for get the trending movies
```dart
/// Example demonstrating how to fetch and display trending movies from IMDb.
///
/// Shows:
/// - How to get the current Moviemeter chart
/// - Basic movie information structure
/// - Simple display formatting
///
/// Usage:

import 'package:imdb_scraper/imdb_scraper.dart';

void main() async {
  final imdb = Imdb();
  final movieData = await imdb.fetchIMDbMovieData();
  
  print('Fetched ${movieData.length} movies:');
  int count = 1;
  
  movieData.forEach((ids, datas) {
    print('$ids: ${datas['title']} (${datas['year']}) - Rating: ${datas['rating']}');
    print('Poster: ${datas['posterUrl']}');
    print('${count++}\n');
  });
}
```
[Get the trending movies](https://github.com/MrTG-CodeBot/imdb_scraper/blob/main/example/gettrendingmovies.dart)


### Basic example for get the trending series
```dart
/// Example demonstrating how to fetch and display trending TV series from IMDb.
///
/// Shows:
/// - How to get the current TV Meter chart
/// - Series-specific information structure
/// - Handling of ongoing vs completed series
///
/// Usage:
import 'package:imdb_scraper/imdb_scraper.dart';

void main() async {
  final imdb = Imdb();
  final result = await imdb.fetchIMDbSeriesData();
  
  print('Status: ${result['status']}');
  if (result['status'] == 'success') {
    print('Series Data:');
    for (var series in result['data']) {
      print('Title: ${series['title']}');
      print('Type: ${series['type']}');
      print('Poster URL: ${series['posterUrl']}');
      print('Start Year: ${series['startYear']}');
      print('End Year: ${series['endYear']}');
      print('Rating: ${series['rating']}');
      print('Vote Count: ${series['voteCount']}');
      print('Episodes: ${series['episodes']}');
      print('---');
    }
  }
}

```
[Get the trending series](https://github.com/MrTG-CodeBot/imdb_scraper/blob/main/example/gettrendingseries.dart)
## Additional information

### Contributing
We welcome contributions! 

### Issues
Found a bug? Please file an issue on our GitHub [repository](https://github.com/MrTG-CodeBot/imdb_scraper/issues)

### Disclaimer
This package is not affiliated with IMDb. Use responsibly and respect IMDb's terms of service.

### License
MIT - See [LICENSE](https://github.com/MrTG-CodeBot/imdb_scraper/blob/main/LICENSE) for more information.
