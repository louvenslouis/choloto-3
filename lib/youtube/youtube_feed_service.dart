import 'dart:convert';

import '/backend/api_requests/api_calls.dart';
import '/backend/backend.dart';
import 'package:shared_preferences/shared_preferences.dart';

const youtubeStoryWindow = Duration(hours: 24);

class YoutubeFeedLoadException implements Exception {
  const YoutubeFeedLoadException(this.message);

  final String message;

  @override
  String toString() => 'YoutubeFeedLoadException: $message';
}

typedef YoutubeVideoSource = Future<List<YoutubeItemStruct>> Function();

abstract class YoutubeStoryCacheStore {
  Future<List<YoutubeItemStruct>> read();
  Future<void> write(List<YoutubeItemStruct> videos);
}

class SharedPreferencesYoutubeStoryCache implements YoutubeStoryCacheStore {
  static const _cacheKey = 'youtube_story_feed_v1';

  @override
  Future<List<YoutubeItemStruct>> read() async {
    final preferences = await SharedPreferences.getInstance();
    final serialized = preferences.getString(_cacheKey);
    if (serialized == null || serialized.isEmpty) return const [];

    try {
      final decoded = jsonDecode(serialized);
      if (decoded is! List) return const [];
      return decoded
          .whereType<Map>()
          .map(
              (item) => YoutubeItemStruct.fromMap(item.cast<String, dynamic>()))
          .toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<void> write(List<YoutubeItemStruct> videos) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _cacheKey,
      jsonEncode(videos.map((video) => video.toMap()).toList(growable: false)),
    );
  }
}

Future<List<YoutubeItemStruct>> _loadPublicYoutubeVideos() async {
  final result = await GetLatestVideosCall.call();
  final response = YoutubeResponseStruct.maybeFromMap(result.jsonBody);

  if (!result.succeeded || response == null || response.items.isEmpty) {
    throw const YoutubeFeedLoadException(
      'The public YouTube feed did not contain any videos.',
    );
  }

  return response.items.toList(growable: false);
}

Future<List<YoutubeItemStruct>> _loadFirestoreYoutubeVideos(
  String fallbackTitle,
) async {
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
}

Future<List<YoutubeItemStruct>> loadYoutubeVideos({
  required String fallbackTitle,
}) async {
  Object? publicFeedError;
  try {
    return await _loadPublicYoutubeVideos();
  } catch (error) {
    publicFeedError = error;
  }

  try {
    return await _loadFirestoreYoutubeVideos(fallbackTitle);
  } catch (firestoreError) {
    throw YoutubeFeedLoadException(
      'Public feed failed ($publicFeedError); Firestore fallback failed '
      '($firestoreError).',
    );
  }
}

Future<List<YoutubeItemStruct>> loadYoutubeStoryVideos({
  required String fallbackTitle,
  required DateTime now,
  Duration window = youtubeStoryWindow,
  YoutubeVideoSource? publicSource,
  YoutubeVideoSource? firestoreSource,
  YoutubeStoryCacheStore? cache,
}) async {
  final storyCache = cache ?? SharedPreferencesYoutubeStoryCache();
  final sourceErrors = <Object>[];
  final sources = <YoutubeVideoSource>[
    publicSource ?? _loadPublicYoutubeVideos,
    firestoreSource ?? () => _loadFirestoreYoutubeVideos(fallbackTitle),
  ];

  for (final source in sources) {
    try {
      final recentVideos = youtubeVideosPublishedWithin(
        await source(),
        now: now,
        window: window,
      );
      if (recentVideos.isEmpty) {
        throw const YoutubeFeedLoadException(
          'The source did not contain a currently active story.',
        );
      }
      try {
        await storyCache.write(recentVideos);
      } catch (_) {
        // A cache write failure must never hide fresh stories.
      }
      return recentVideos;
    } catch (error) {
      sourceErrors.add(error);
    }
  }

  try {
    final cachedVideos = youtubeVideosPublishedWithin(
      await storyCache.read(),
      now: now,
      window: window,
    );
    if (cachedVideos.isNotEmpty) return cachedVideos;
  } catch (error) {
    sourceErrors.add(error);
  }

  throw YoutubeFeedLoadException(
    'No active YouTube story could be loaded: ${sourceErrors.join('; ')}',
  );
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
