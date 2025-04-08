import 'package:imdb_scraper/imdb_scraper.dart';

void main() async {
  final imdb = Imdb();
  final movieData = await imdb.fetchIMDbMovieData();
  print('Fetched ${movieData.length} movies:');
  int count = 1;
  print(movieData);
  movieData.forEach((ids, datas) {
    print(
        '$ids: ${datas['title']} (${datas['year']}) - Rating: ${datas['rating']}');
    print('Poster: ${datas['posterUrl']}');
    print('${count++}\n');
  });
}
