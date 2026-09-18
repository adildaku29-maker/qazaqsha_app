class AppText {
  static String get(String key,String lang) {
    const ru=<String,String>{
      'home':'Главная','lessons':'Уроки','achievements':'Достижения','profile':'Профиль',
      'welcome':'Добро пожаловать','learn':'Начнём учить казахский?','mission':'МИССИЯ НА СЕГОДНЯ',
      'ai':'AI-учитель','path':'Твой путь','lessons_sub':'Уроки по уровням A1 → A2 → B1',
      'choose_language':'На каком языке тебе удобнее получать подсказки?',
      'nickname':'Как тебя называть?','character':'Выбери своего персонажа','continue':'Продолжить',
      'tutorial':'Как работает Qazaqsha','tutorial1':'Сначала слушай и смотри перевод.',
      'tutorial2':'Потом отвечай сам — текстом или голосом.',
      'tutorial3':'AI объяснит ошибку и даст перевод на понятном тебе языке.',
      'start':'Начать обучение','streak':'дней подряд','words':'слов','lesson':'уроков',
    };
    const en=<String,String>{
      'home':'Home','lessons':'Lessons','achievements':'Achievements','profile':'Profile',
      'welcome':'Welcome','learn':'Ready to learn Kazakh?','mission':'TODAY’S MISSION',
      'ai':'AI tutor','path':'Your path','lessons_sub':'Lessons from A1 → A2 → B1',
      'choose_language':'Which language is most comfortable for your hints?',
      'nickname':'What should we call you?','character':'Choose your character','continue':'Continue',
      'tutorial':'How Qazaqsha works','tutorial1':'First listen and look at the translation.',
      'tutorial2':'Then answer yourself — by text or voice.',
      'tutorial3':'AI explains mistakes and translates into the language you understand.',
      'start':'Start learning','streak':'day streak','words':'words','lesson':'lessons',
    };
    const kk=<String,String>{
      'home':'Басты бет','lessons':'Сабақтар','achievements':'Жетістіктер','profile':'Профиль',
      'welcome':'Қош келдің','learn':'Қазақ тілін үйренуге дайынсың ба?','mission':'БҮГІНГІ МИССИЯ',
      'ai':'AI ұстаз','path':'Оқу жолы','lessons_sub':'A1 → A2 → B1 деңгейлері',
      'choose_language':'Қай тілде түсіндірме алған ыңғайлы?',
      'nickname':'Сені қалай атаймыз?','character':'Кейіпкеріңді таңда','continue':'Жалғастыру',
      'tutorial':'Qazaqsha қалай жұмыс істейді','tutorial1':'Алдымен тыңда және аудармасына қара.',
      'tutorial2':'Сосын мәтінмен немесе дауыспен өзің жауап бер.',
      'tutorial3':'AI қателерді түсіндіріп, саған түсінікті тілге аударады.',
      'start':'Оқуды бастау','streak':'күн қатарынан','words':'сөз','lesson':'сабақ',
    };
    return (lang=='en'?en:lang=='kk'?kk:ru)[key]??key;
  }
}
