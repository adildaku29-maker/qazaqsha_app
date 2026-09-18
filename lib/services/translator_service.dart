class TranslationResult {
  final String text;
  const TranslationResult(this.text);
}

abstract class AiTranslatorService {
  Future<TranslationResult> translate({
    required String kazakhText,
    required String targetLanguage,
  });
}

/// Интерфейс уже готов для подключения реальной AI-модели.
/// Сейчас офлайн-режим не требует API-ключа и дает понятные подсказки.
class DemoAiTranslatorService implements AiTranslatorService {
  static const ru=<String,String>{
    'Сәлем! 👋 Мен сенің AI ұстазыңмын.':'Привет! 👋 Я твой AI-учитель.',
    'Өзіңді қазақша таныстыршы.':'Представься по-казахски.',
    'Керемет!':'Отлично!',
    'Жақсы бастама.':'Хорошее начало.',
    'Толық сөйлеммен жауап беріп көрші.':'Попробуй ответить полным предложением.',
    'Жақсы жауап! 👏':'Хороший ответ! 👏',
  };
  static const en=<String,String>{
    'Сәлем! 👋 Мен сенің AI ұстазыңмын.':'Hello! 👋 I am your AI tutor.',
    'Өзіңді қазақша таныстыршы.':'Introduce yourself in Kazakh.',
    'Керемет!':'Great!',
    'Жақсы бастама.':'Good start.',
    'Толық сөйлеммен жауап беріп көрші.':'Try answering with a full sentence.',
    'Жақсы жауап! 👏':'Good answer! 👏',
  };

  @override
  Future<TranslationResult> translate({required String kazakhText,required String targetLanguage}) async {
    await Future<void>.delayed(const Duration(milliseconds:180));
    if(targetLanguage=='kk') return TranslationResult(kazakhText);
    final map=targetLanguage=='en'?en:ru;
    var result=map[kazakhText];
    if(result!=null) return TranslationResult(result);
    for(final e in map.entries) {
      if(kazakhText.startsWith(e.key)) {
        return TranslationResult(kazakhText.replaceFirst(e.key,e.value));
      }
    }
    return TranslationResult(targetLanguage=='en'?'Translation hint: $kazakhText':'Перевод-подсказка: $kazakhText');
  }
}
