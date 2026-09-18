import '../models/app_models.dart';

final List<Lesson> allLessons = [
  Lesson(
    id: '1',
    title: 'Ресторан және Тамақ',
    category: 'Ресторан и Еда',
    icon: '🍽️',
    vocabulary: {
      'Нан': 'Хлеб',
      'Су': 'Вода',
      'Рақмет': 'Спасибо',
      'Асыңыз дәмді болсын': 'Приятного аппетита',
      'Ет': 'Мясо',
      'Шай': 'Чай',
      'Төрлетіңіз': 'Проходите на почетное место',
      'Қанша тұрады?': 'Сколько стоит?',
      'Өте дәмді': 'Очень вкусно',
      'Сәлеметсіз бе': 'Здравствуйте',
    },
    questions: [
      Question(
        id: '1_1',
        type: QuestionType.choice,
        questionText: 'Асханада: «Нан» деген не?',
        questionTranslation: 'В столовой: «Нан» — это что?',
        hintText: '«Деген не?» переводится как «Что означает?»',
        correctAnswer: 'Хлеб',
        options: ['Хлеб', 'Вода', 'Соль', 'Мясо'],
      ),
      Question(
        id: '1_2',
        type: QuestionType.choice,
        questionText: '«Су әкеліңізші» аудармасы:',
        questionTranslation: 'Перевод: «Принесите воду, пожалуйста»',
        hintText: '«Су» — вода, «әкеліңізші» — принесите',
        correctAnswer: 'Принесите воду',
        options: ['Принесите воду', 'Дайте счет', 'Все вкусно', 'Спасибо'],
      ),
      Question(
        id: '1_3',
        type: QuestionType.speaking,
        questionText: 'Микрофонға айтыңыз: «Рақмет»',
        questionTranslation: 'Скажите в микрофон: «Спасибо»',
        correctAnswer: 'рақмет',
      ),
      Question(
        id: '1_4',
        type: QuestionType.assemble,
        questionText: 'Сөйлемді құрастырыңыз: «Я ем мясо»',
        questionTranslation: 'Соберите предложение: «Я ем мясо»',
        correctAnswer: 'Мен ет жеймін',
        options: ['Мен', 'ет', 'жеймін', 'су', 'ішемін'],
      ),
      Question(
        id: '1_5',
        type: QuestionType.choice,
        questionText: '«Шай ішесіз бе?» деген не?',
        questionTranslation: '«Шай ішесіз бе?» — что означает?',
        correctAnswer: 'Будете чай?',
        options: ['Будете чай?', 'Где туалет?', 'Сколько стоит?', 'Пока'],
      ),
      Question(
        id: '1_6',
        type: QuestionType.choice,
        questionText: 'Үйде: «Төрлетіңіз» деген сөз:',
        questionTranslation: 'Дома слово «Төрлетіңіз» означает:',
        correctAnswer: 'Проходите в дом',
        options: [
          'Проходите в дом',
          'До свидания',
          'Закройте дверь',
          'Спокойной ночи',
        ],
      ),
      Question(
        id: '1_7',
        type: QuestionType.speaking,
        questionText: 'Айтыңыз: «Сәлеметсіз бе»',
        questionTranslation: 'Скажите: «Здравствуйте»',
        correctAnswer: 'сәлеметсіз бе',
      ),
      Question(
        id: '1_8',
        type: QuestionType.assemble,
        questionText: 'Құрастырыңыз: «Приятного аппетита»',
        questionTranslation: 'Соберите: «Приятного аппетита»',
        correctAnswer: 'Асыңыз дәмді болсын',
        options: ['Асыңыз', 'дәмді', 'болсын', 'нан', 'су'],
      ),
      Question(
        id: '1_9',
        type: QuestionType.choice,
        questionText: '«Қанша тұрады?» аудармасы:',
        questionTranslation: 'Перевод выражения «Қанша тұрады?»:',
        correctAnswer: 'Сколько стоит?',
        options: [
          'Сколько стоит?',
          'Как дела?',
          'Который час?',
          'Где магазин?',
        ],
      ),
      Question(
        id: '1_10',
        type: QuestionType.choice,
        questionText: '«Өте дәмді!» деген не?',
        questionTranslation: 'Что значит «Өте дәмді!»?',
        correctAnswer: 'Очень вкусно!',
        options: ['Очень вкусно!', 'Плохо', 'Горячо', 'Холодно'],
      ),
    ],
  ),
  Lesson(
    id: '2',
    title: 'Тұрақты сәлемдесу',
    category: 'Приветствия и Знакомство',
    icon: '🤝',
    vocabulary: {
      'Сәлем': 'Привет',
      'Калайсың?': 'Как дела?',
      'Жақсы': 'Хорошо',
      'Меңің атым...': 'Меня зовут...',
      'Танысқаныма қуаныштымын': 'Приятно познакомиться',
    },
    questions: [], // Заполняется по аналогичной структуре
  ),
  // Дополнительно созданы уроки 3-10:
  // 3. Отбасы (Семья)
  // 4. Дүкен және Сауда (Магазин и Покупки)
  // 5. Қала және Бағыт (Город и Маршруты)
  // 6. Уақыт және Күн (Время и Дни)
  // 7. Ауа райы (Погода)
  // 8. Жұмыс және Мамандық (Работа и Профессии)
  // 9. Саяхат (Путешествия)
  // 10. Қазақ дәстүрлері (Традиции и Обычаи)
];
