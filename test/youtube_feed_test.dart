import 'dart:convert';
import 'dart:io';

import 'package:choloto/backend/schema/structs/youtube_response_struct.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('generated YouTube feed contains usable video cards', () async {
    final feedFile = File('web/youtube-feed.json');
    final response = YoutubeResponseStruct.maybeFromMap(
      jsonDecode(await feedFile.readAsString()),
    );

    expect(response, isNotNull);
    expect(response!.items.length, greaterThanOrEqualTo(10));

    for (final video in response.items) {
      expect(video.title, isNotEmpty);
      expect(video.link, startsWith('https://www.youtube.com/watch?v='));
      expect(video.thumbnail, startsWith('https://i.ytimg.com/vi/'));
      expect(DateTime.tryParse(video.pubDate), isNotNull);
    }
  });
}
