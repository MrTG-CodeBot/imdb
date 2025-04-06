<<<<<<< HEAD
import 'package:imdb_scraper/imdb_scraper.dart';
=======
import 'package:imdb/imdb_scraper.dart';
>>>>>>> 2b0399e07563160184a6a19265b46a99e0ca0b69

void main() async {
  final imdb = Imdb();
  
  final movieName = "weathering with you"; 
  final imdbId = await imdb.getImdbId(movieName);
  
  if (imdbId == null) {
    print('Failed to find IMDb ID for "$movieName"');
    return;
  }
  
  final details = await imdb.getDetails(imdbId);
  
  if (details != null) {
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
