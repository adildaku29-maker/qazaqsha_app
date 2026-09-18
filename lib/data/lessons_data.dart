import '../models/app_models.dart';

const allLessons = <Lesson>[
  Lesson(id: 1, title: 'Алғашқы сөздер', category: 'Базовые фразы', icon: '👋', vocabulary: [
    MapEntry('Сәлем', 'Привет'), MapEntry('Рақмет', 'Спасибо'), MapEntry('Өтінемін', 'Пожалуйста'), MapEntry('Иә', 'Да'), MapEntry('Жоқ', 'Нет'), MapEntry('Жақсы', 'Хорошо'), MapEntry('Кешіріңіз', 'Извините'), MapEntry('Сау болыңыз', 'До свидания')], questions: [
    Question(id:'1a', type:QuestionType.choice, questionText:'«Рақмет» деген не?', translation:'Что означает «Рақмет»?', correctAnswer:'Спасибо', options:['Спасибо','Пожалуйста','Извините','До свидания']),
    Question(id:'1b', type:QuestionType.choice, questionText:'«Иә» аудармасы қандай?', translation:'Перевод слова «Иә»', correctAnswer:'Да', options:['Нет','Да','Хорошо','Привет']),
    Question(id:'1c', type:QuestionType.assemble, questionText:'«Привет» сөзін құрастырыңыз', translation:'Соберите слово «Привет»', correctAnswer:'Сәлем', options:['Сәлем','Рақмет','Жақсы','Жоқ']),
    Question(id:'1d', type:QuestionType.typing, questionText:'«До свидания» — қазақша қалай?', translation:'Введите перевод', correctAnswer:'Сау болыңыз', hint:'Екі сөз: «Сау» + «болыңыз».')]),
  Lesson(id: 2, title: 'Танысу', category: 'Знакомство', icon: '🤝', vocabulary: [
    MapEntry('Менің атым...', 'Меня зовут...'), MapEntry('Сіздің атыңыз кім?', 'Как вас зовут?'), MapEntry('Танысқаныма қуаныштымын', 'Приятно познакомиться'), MapEntry('Қайдансыз?', 'Откуда вы?'), MapEntry('Мен Қазақстаннанмын', 'Я из Казахстана'), MapEntry('Қалайсыз?', 'Как вы?'), MapEntry('Жақсымын', 'Я в порядке')], questions: [
    Question(id:'2a', type:QuestionType.choice, questionText:'«Менің атым Айдос» деген не?', translation:'Выберите перевод', correctAnswer:'Меня зовут Айдос', options:['Меня зовут Айдос','Я из Айдоса','Где Айдос?','Это Айдос']),
    Question(id:'2b', type:QuestionType.choice, questionText:'«Қайдансыз?»', translation:'Что спрашивают?', correctAnswer:'Откуда вы?', options:['Куда вы?','Откуда вы?','Как вас зовут?','Как вы?']),
    Question(id:'2c', type:QuestionType.assemble, questionText:'«Приятно познакомиться»', translation:'Соберите фразу', correctAnswer:'Танысқаныма қуаныштымын', options:['Танысқаныма','қуаныштымын','Жақсымын','атым']),
    Question(id:'2d', type:QuestionType.typing, questionText:'Как сказать «Как вы?»', translation:'Введите на казахском', correctAnswer:'Қалайсыз?')]),
  Lesson(id: 3, title: 'Отбасы', category: 'Семья', icon: '👨‍👩‍👧', vocabulary: [
    MapEntry('Отбасы', 'Семья'), MapEntry('Әке', 'Отец'), MapEntry('Ана', 'Мать'), MapEntry('Аға', 'Старший брат'), MapEntry('Іні', 'Младший брат'), MapEntry('Әпке', 'Старшая сестра'), MapEntry('Қарындас', 'Младшая сестра'), MapEntry('Бала', 'Ребёнок')], questions: [
    Question(id:'3a', type:QuestionType.choice, questionText:'«Әке» деген не?', translation:'Выберите перевод', correctAnswer:'Отец', options:['Отец','Мать','Брат','Ребёнок']),
    Question(id:'3b', type:QuestionType.choice, questionText:'«Ана» аудармасы', translation:'Перевод', correctAnswer:'Мать', options:['Сестра','Мать','Отец','Семья']),
    Question(id:'3c', type:QuestionType.assemble, questionText:'«Моя семья»', translation:'Соберите фразу', correctAnswer:'Менің отбасым', options:['Менің','отбасым','анам','әкем']),
    Question(id:'3d', type:QuestionType.typing, questionText:'Как сказать «семья»?', translation:'Введите слово', correctAnswer:'Отбасы')]),
  Lesson(id: 4, title: 'Дүкен', category: 'Магазин и покупки', icon: '🛍️', vocabulary: [
    MapEntry('Дүкен', 'Магазин'), MapEntry('Баға', 'Цена'), MapEntry('Қанша тұрады?', 'Сколько стоит?'), MapEntry('Арзан', 'Дешёвый'), MapEntry('Қымбат', 'Дорогой'), MapEntry('Ақша', 'Деньги'), MapEntry('Аламын', 'Возьму / куплю'), MapEntry('Карта', 'Карта')], questions: [
    Question(id:'4a', type:QuestionType.choice, questionText:'«Қанша тұрады?»', translation:'Выберите перевод', correctAnswer:'Сколько стоит?', options:['Сколько стоит?','Где магазин?','Мне нравится','Дайте воду']),
    Question(id:'4b', type:QuestionType.choice, questionText:'«Қымбат» деген не?', translation:'Перевод', correctAnswer:'Дорогой', options:['Дешёвый','Дорогой','Большой','Новый']),
    Question(id:'4c', type:QuestionType.assemble, questionText:'«Я возьму это»', translation:'Соберите фразу', correctAnswer:'Мынаны аламын', options:['Мынаны','аламын','арзан','ақша']),
    Question(id:'4d', type:QuestionType.typing, questionText:'Как сказать «магазин»?', translation:'Введите слово', correctAnswer:'Дүкен')]),
  Lesson(id: 5, title: 'Қала', category: 'Город и направления', icon: '🏙️', vocabulary: [
    MapEntry('Қала', 'Город'), MapEntry('Көше', 'Улица'), MapEntry('Оңға', 'Направо'), MapEntry('Солға', 'Налево'), MapEntry('Тура', 'Прямо'), MapEntry('Қайда?', 'Где?'), MapEntry('Жақын', 'Близко'), MapEntry('Алыс', 'Далеко')], questions: [
    Question(id:'5a', type:QuestionType.choice, questionText:'«Оңға»', translation:'Куда повернуть?', correctAnswer:'Направо', options:['Налево','Направо','Прямо','Назад']),
    Question(id:'5b', type:QuestionType.choice, questionText:'«Тура» аудармасы', translation:'Выберите перевод', correctAnswer:'Прямо', options:['Прямо','Далеко','Близко','Где?']),
    Question(id:'5c', type:QuestionType.assemble, questionText:'«Идите прямо»', translation:'Соберите фразу', correctAnswer:'Тура жүріңіз', options:['Тура','жүріңіз','оңға','қала']),
    Question(id:'5d', type:QuestionType.typing, questionText:'Как сказать «где?»', translation:'Введите слово', correctAnswer:'Қайда?')]),
  Lesson(id: 6, title: 'Уақыт', category: 'Время и дни', icon: '⏰', vocabulary: [
    MapEntry('Бүгін', 'Сегодня'), MapEntry('Ертең', 'Завтра'), MapEntry('Кеше', 'Вчера'), MapEntry('Қазір', 'Сейчас'), MapEntry('Сағат', 'Час'), MapEntry('Таңертең', 'Утром'), MapEntry('Кешке', 'Вечером'), MapEntry('Апта', 'Неделя')], questions: [
    Question(id:'6a', type:QuestionType.choice, questionText:'«Бүгін»', translation:'Перевод', correctAnswer:'Сегодня', options:['Сегодня','Завтра','Вчера','Сейчас']),
    Question(id:'6b', type:QuestionType.choice, questionText:'«Ертең»', translation:'Перевод', correctAnswer:'Завтра', options:['Вчера','Завтра','Утром','Вечером']),
    Question(id:'6c', type:QuestionType.assemble, questionText:'«Сейчас»', translation:'Соберите одно слово', correctAnswer:'Қазір', options:['Қазір','Бүгін','Ертең','Кеше']),
    Question(id:'6d', type:QuestionType.typing, questionText:'Как сказать «неделя»?', translation:'Введите слово', correctAnswer:'Апта')]),
  Lesson(id: 7, title: 'Ауа райы', category: 'Погода', icon: '🌤️', vocabulary: [
    MapEntry('Ауа райы', 'Погода'), MapEntry('Күн', 'Солнце / день'), MapEntry('Жаңбыр', 'Дождь'), MapEntry('Қар', 'Снег'), MapEntry('Суық', 'Холодно'), MapEntry('Ыстық', 'Жарко'), MapEntry('Жел', 'Ветер'), MapEntry('Бұлт', 'Облако')], questions: [
    Question(id:'7a', type:QuestionType.choice, questionText:'«Жаңбыр» деген не?', translation:'Перевод', correctAnswer:'Дождь', options:['Дождь','Снег','Ветер','Облако']),
    Question(id:'7b', type:QuestionType.choice, questionText:'«Суық»', translation:'Какой смысл?', correctAnswer:'Холодно', options:['Жарко','Холодно','Солнечно','Ветрено']),
    Question(id:'7c', type:QuestionType.assemble, questionText:'«Погода хорошая»', translation:'Соберите фразу', correctAnswer:'Ауа райы жақсы', options:['Ауа','райы','жақсы','суық']),
    Question(id:'7d', type:QuestionType.typing, questionText:'Как сказать «снег»?', translation:'Введите слово', correctAnswer:'Қар')]),
  Lesson(id: 8, title: 'Жұмыс', category: 'Работа и профессии', icon: '💼', vocabulary: [
    MapEntry('Жұмыс', 'Работа'), MapEntry('Мамандық', 'Профессия'), MapEntry('Дәрігер', 'Врач'), MapEntry('Мұғалім', 'Учитель'), MapEntry('Инженер', 'Инженер'), MapEntry('Кеңсе', 'Офис'), MapEntry('Бастық', 'Начальник'), MapEntry('Әріптес', 'Коллега')], questions: [
    Question(id:'8a', type:QuestionType.choice, questionText:'«Мұғалім» деген кім?', translation:'Выберите профессию', correctAnswer:'Учитель', options:['Врач','Учитель','Инженер','Начальник']),
    Question(id:'8b', type:QuestionType.choice, questionText:'«Жұмыс»', translation:'Перевод', correctAnswer:'Работа', options:['Офис','Работа','Профессия','Коллега']),
    Question(id:'8c', type:QuestionType.assemble, questionText:'«Я работаю в офисе»', translation:'Соберите предложение', correctAnswer:'Мен кеңседе жұмыс істеймін', options:['Мен','кеңседе','жұмыс','істеймін','үйде']),
    Question(id:'8d', type:QuestionType.typing, questionText:'Как сказать «профессия»?', translation:'Введите слово', correctAnswer:'Мамандық')]),
  Lesson(id: 9, title: 'Саяхат', category: 'Путешествия', icon: '✈️', vocabulary: [
    MapEntry('Саяхат', 'Путешествие'), MapEntry('Әуежай', 'Аэропорт'), MapEntry('Билет', 'Билет'), MapEntry('Ұшақ', 'Самолёт'), MapEntry('Қонақүй', 'Отель'), MapEntry('Жүк', 'Багаж'), MapEntry('Қайда барасыз?', 'Куда вы едете?'), MapEntry('Көмектесіңізші', 'Помогите, пожалуйста')], questions: [
    Question(id:'9a', type:QuestionType.choice, questionText:'«Әуежай»', translation:'Перевод', correctAnswer:'Аэропорт', options:['Аэропорт','Вокзал','Отель','Билет']),
    Question(id:'9b', type:QuestionType.choice, questionText:'«Көмектесіңізші»', translation:'Что значит?', correctAnswer:'Помогите, пожалуйста', options:['Подождите','Помогите, пожалуйста','До свидания','Где билет?']),
    Question(id:'9c', type:QuestionType.assemble, questionText:'«Где отель?»', translation:'Соберите вопрос', correctAnswer:'Қонақүй қайда?', options:['Қонақүй','қайда?','билет','ұшақ']),
    Question(id:'9d', type:QuestionType.typing, questionText:'Как сказать «билет»?', translation:'Введите слово', correctAnswer:'Билет')]),
  Lesson(id: 10, title: 'Қазақ дәстүрлері', category: 'Традиции и культура', icon: '🇰🇿', vocabulary: [
    MapEntry('Қонақ', 'Гость'), MapEntry('Дастарқан', 'Накрытый стол'), MapEntry('Бата', 'Благословение'), MapEntry('Наурыз', 'Наурыз'), MapEntry('Домбыра', 'Домбра'), MapEntry('Шашу', 'Обряд осыпания сладостями'), MapEntry('Тұсаукесер', 'Обряд первых шагов'), MapEntry('Ұлттық', 'Национальный')], questions: [
    Question(id:'10a', type:QuestionType.choice, questionText:'«Қонақ» деген не?', translation:'Перевод', correctAnswer:'Гость', options:['Гость','Хозяин','Праздник','Подарок']),
    Question(id:'10b', type:QuestionType.choice, questionText:'«Дастарқан»', translation:'Что это?', correctAnswer:'Накрытый стол', options:['Домбра','Накрытый стол','Подарок','Благословение']),
    Question(id:'10c', type:QuestionType.assemble, questionText:'«Добро пожаловать!»', translation:'Соберите знакомую фразу', correctAnswer:'Төрлетіңіз', options:['Төрлетіңіз','Рақмет','Сау болыңыз','Қош келдіңіз']),
    Question(id:'10d', type:QuestionType.typing, questionText:'Как называется казахский национальный инструмент?', translation:'Введите слово', correctAnswer:'Домбыра')]),
];
