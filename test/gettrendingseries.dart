import 'package:imdb_scraper/imdb_scraper.dart';

void main() async{
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