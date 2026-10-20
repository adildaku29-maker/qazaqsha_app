import 'dart:convert';

import 'package:http/http.dart' as http;

import '../data/lesson_content.dart';

class ContentTopic {
  final int id;
  final String slug;
  final String title;
  final String subtitle;
  final String emoji;
  final String level;
  final int xp;
  final String? requiredAfter;

  const ContentTopic({
    required this.id,
    required this.slug,
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.level,
    required this.xp,
    this.requiredAfter,
  });

  factory ContentTopic.fromJson(Map<String, dynamic> json) => ContentTopic(
        id: (json['id'] as num?)?.toInt() ?? 0,
        slug: json['slug']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        subtitle: json['subtitle']?.toString() ?? '',
        emoji: json['emoji']?.toString() ?? '📚',
        level: json['level']?.toString() ?? 'A1',
        xp: (json['xp'] as num?)?.toInt() ?? 100,
        requiredAfter: json['required_after']?.toString(),
      );

  ContentTopic withRequiredAfterTitle(String? title) => ContentTopic(
        id: id,
        slug: slug,
        title: this.title,
        subtitle: subtitle,
        emoji: emoji,
        level: level,
        xp: xp,
        requiredAfter: title,
      );
}

class RemoteLessonContent {
  final LessonPack pack;
  final ExamPack? exam;

  const RemoteLessonContent({required this.pack, this.exam});
}

class ContentService {
  ContentService._();
  static final instance = ContentService._();

  static const String baseUrl = String.fromEnvironment(
    'CONTENT_API_URL',
    defaultValue: 'http://127.0.0.1:8001',
  );

  Uri _uri(String path) => Uri.parse('${baseUrl.replaceFirst(RegExp(r'/+$'), '')}$path');

  Future<List<ContentTopic>> fetchTopics({bool forceRefresh = false}) async {
    final response = await http
        .get(_uri('/api/topics'))
        .timeout(const Duration(seconds: 8));
    if (response.statusCode != 200) {
      throw Exception('Content API topics: HTTP ${response.statusCode}');
    }

    final raw = jsonDecode(response.body) as List<dynamic>;
    final parsed = raw
        .whereType<Map<String, dynamic>>()
        .map(ContentTopic.fromJson)
        .toList();
    final titleBySlug = {for (final topic in parsed) topic.slug: topic.title};
    return parsed
        .map((topic) => topic.withRequiredAfterTitle(
              topic.requiredAfter == null
                  ? null
                  : titleBySlug[topic.requiredAfter],
            ))
        .toList();
  }

  Future<RemoteLessonContent?> fetchLesson(
    String topicTitle,
    int lessonNumber,
  ) async {
    final topics = await fetchTopics();
    ContentTopic? topic;
    for (final item in topics) {
      if (item.title == topicTitle) {
        topic = item;
        break;
      }
    }
    if (topic == null) return null;

    final current = await _getLessonJson(topic.slug, lessonNumber);
    if (current == null) return null;

    if (lessonNumber == 5) {
      final first = await _getLessonJson(topic.slug, 1);
      final packSource = first ?? current;
      return RemoteLessonContent(
        pack: _toLessonPack(topic.title, packSource),
        exam: _toExamPack(current),
      );
    }

    return RemoteLessonContent(pack: _toLessonPack(topic.title, current));
  }

  Future<Map<String, dynamic>?> _getLessonJson(String slug, int number) async {
    final response = await http
        .get(_uri('/api/topics/${Uri.encodeComponent(slug)}/lessons/$number'))
        .timeout(const Duration(seconds: 8));
    if (response.statusCode == 404) return null;
    if (response.statusCode != 200) {
      throw Exception('Content API lesson: HTTP ${response.statusCode}');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  LessonPack _toLessonPack(String topic, Map<String, dynamic> json) {
    final words = ((json['vocabulary'] as List<dynamic>?) ?? const [])
        .whereType<Map<String, dynamic>>()
        .map((word) => LessonWord(
              word['kk']?.toString() ?? '',
              word['ru']?.toString() ?? '',
              word['en']?.toString() ?? '',
              word['audio_key']?.toString() ?? '',
            ))
        .toList();

    final translations = <TranslationQuestion>[];
    final pairs = <MatchPair>[];
    final fills = <FillQuestion>[];
    final speaking = <SpeakingPrompt>[];

    for (final raw in ((json['questions'] as List<dynamic>?) ?? const [])) {
      if (raw is! Map<String, dynamic>) continue;
      final type = raw['type']?.toString() ?? '';
      final kk = raw['prompt_kk']?.toString() ?? '';
      final ru = raw['prompt_ru']?.toString() ?? '';
      final enValue = raw['prompt_en']?.toString() ?? '';
      final en = enValue.isEmpty ? ru : enValue;
      final audio = raw['audio_key']?.toString() ?? '';
      final options = ((raw['options'] as List<dynamic>?) ?? const [])
          .map((value) => value.toString())
          .toList();
      final correct = (raw['correct_index'] as num?)?.toInt() ?? 0;

      switch (type) {
        case 'translation':
          translations.add(TranslationQuestion(
            kk, ru, en, options, options, correct, audio,
          ));
          break;
        case 'matching':
          pairs.add(MatchPair(kk, ru, audio));
          break;
        case 'fill':
          fills.add(FillQuestion(kk, ru, en, options, correct, audio));
          break;
        case 'speaking':
          speaking.add(SpeakingPrompt(kk, ru, audio));
          break;
      }
    }

    return LessonPack(topic, words, translations, pairs, fills, speaking);
  }

  ExamPack _toExamPack(Map<String, dynamic> json) {
    final pack = _toLessonPack('', json);
    return ExamPack(
      pack.translations,
      pack.pairs,
      pack.fills,
      pack.speaking,
    );
  }
}
