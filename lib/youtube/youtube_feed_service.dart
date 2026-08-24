import '/backend/api_requests/api_calls.dart';
import '/backend/backend.dart';

const youtubeStoryWindow = Duration(hours: 24);

class YoutubeFeedLoadException implements Exception {
  const YoutubeFeedLoadException(this.message);

  final String message;

  @override
  String toString() => 'YoutubeFeedLoadException: $message';
}

Future<List<YoutubeItemStruct>> loadYoutubeVideos({
  required String fallbackTitle,
}) async {
  Object? apiError;

  try {
    final result = await GetLatestVideosCall.call();
    final response = YoutubeResponseStruct.maybeFromMap(result.jsonBody);

    if (!result.succeeded || response == null || response.items.isEmpty) {
      throw const YoutubeFeedLoadException(
        'The public YouTube feed did not contain any videos.',
      );
    }

    return response.items.toList(growable: false);
  } catch (error) {
    apiError = error;
  }

  try {
    final fallbackRecords = await queryYoutubeLinksRecordOnce(
      queryBuilder: (records) => records.orderBy('date', descending: true),
      limit: 24,
    );
    final fallbackVideos = fallbackRecords
        .where((record) => record.id.isNotEmpty)
        .map(
          (record) => YoutubeItemStruct(
            title: record.caption.isEmpty ? fallbackTitle : record.caption,
            link: record.link.isNotEmpty
                ? record.link
                : 'https://www.youtube.com/watch?v=${record.id}',
            thumbnail: 'https://i.ytimg.com/vi/${record.id}/hqdefault.jpg',
            pubDate: record.date?.toIso8601String(),
          ),
        )
        .toList(growable: false);

    if (fallbackVideos.isEmpty) {
      throw const YoutubeFeedLoadException(
        'The Firestore YouTube fallback did not contain any videos.',
      );
    }

    return fallbackVideos;
  } catch (fallbackError) {
    throw YoutubeFeedLoadException(
      'Public feed failed ($apiError); Firestore fallback failed '
      '($fallbackError).',
    );
  }
}

List<YoutubeItemStruct> youtubeVideosPublishedWithin(
  Iterable<YoutubeItemStruct> videos, {
  required DateTime now,
  Duration window = youtubeStoryWindow,
}) {
  final oldestAllowed = now.subtract(window);
  final recentVideos = videos.where((video) {
    final publishedAt = DateTime.tryParse(video.pubDate);
    if (publishedAt == null) {
      return false;
    }

    return !publishedAt.isBefore(oldestAllowed) && !publishedAt.isAfter(now);
  }).toList(growable: false);

  recentVideos.sort((first, second) {
    final firstDate = DateTime.parse(first.pubDate);
    final secondDate = DateTime.parse(second.pubDate);
    return secondDate.compareTo(firstDate);
  });

  return recentVideos;
}
