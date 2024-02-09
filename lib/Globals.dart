import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Define the playlist
final playlist = ConcatenatingAudioSource(
  // Start loading next item just before reaching it
  useLazyPreparation: true,
  // Customise the shuffle algorithm
  shuffleOrder: DefaultShuffleOrder(),
  // Specify the playlist items
  children: [],
);

// Define the playlist
final playlistdrive = ConcatenatingAudioSource(
  // Start loading next item just before reaching it
  useLazyPreparation: true,
  // Customise the shuffle algorithm
  shuffleOrder: DefaultShuffleOrder(),
  // Specify the playlist items
  children: [],
);

List<String> myStrings = ['item1', 'item2', 'item3'];
Future<void> saveStringList(List<String> list, String key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setStringList("items", myStrings);
}

String link = "";
