class LessonWord{
  final String kk,ru,en;
  const LessonWord(this.kk,this.ru,this.en);
  String tr(String lang)=>lang=='en'?en:lang=='kk'?kk:ru;
}
class LessonSentence{
  final String kk,ru,en;
  const LessonSentence(this.kk,this.ru,this.en);
  String tr(String lang)=>lang=='en'?en:lang=='kk'?kk:ru;
}
class DialogueTurn{
  final String question,answer,ruQuestion,ruAnswer,enQuestion,enAnswer;
  const DialogueTurn(this.question,this.answer,this.ruQuestion,this.ruAnswer,this.enQuestion,this.enAnswer);
  String q(String lang)=>lang=='en'?enQuestion:lang=='kk'?question:ruQuestion;
  String a(String lang)=>lang=='en'?enAnswer:lang=='kk'?answer:ruAnswer;
}
class LessonPack{
  final String topic;
  final List<LessonWord> words;
  final List<LessonSentence> sentences;
  final List<DialogueTurn> dialogue;
  final LessonWord? reviewWord;
  const LessonPack(this.topic,this.words,this.sentences,this.dialogue,{this.reviewWord});
}

class Topic{
  final String title,subtitle,emoji,level;final int xp;final List<String> words;
  const Topic(this.title,this.subtitle,this.emoji,this.level,this.xp,this.words);
}

const topics=<Topic>[
  Topic('Танысу','Өзіңді таныстыру','👋','A1',80,['сәлем','аты','жас','қала','танысу']),
  Topic('Отбасы','Жақындарың туралы','👨‍👩‍👧','A1',90,['отбасы','ана','әке','аға','әпке']),
  Topic('Үй','Үйің және бөлмелер','🏠','A1',90,['үй','бөлме','асүй','есік','терезе']),
  Topic('Тамақ','Тағам және сусындар','🍲','A1',100,['тамақ','су','ет','нан','шай']),
  Topic('Күнделікті өмір','Күн тәртібі','☀️','A1',100,['таңертең','жұмыс','күн','кеш','ұйқы']),
  Topic('Дүкен','Сатып алу','🛍️','A2',120,['баға','ақша','сатып алу','арзан','қымбат']),
  Topic('Мейрамхана','Мейрамханада сөйлесу','🍽️','A2',120,['мәзір','тапсырыс','есеп','дәмді','даяшы']),
  Topic('Достар','Достық туралы','🤝','A2',120,['дос','кездесу','әңгіме','көңіл','бірге']),
  Topic('Жұмыс','Жұмыс және мамандық','💼','A2',140,['жұмыс','әріптес','кеңсе','жоба','басшы']),
  Topic('Саяхат','Саяхат және жол','✈️','B1',160,['саяхат','әуежай','қонақүй','билет','бағыт']),
  Topic('Қазақстан','Ел туралы сөйлесу','🇰🇿','B1',180,['Қазақстан','Астана','дәстүр','мәдениет','тарих']),
];

const topicWords=<String,List<LessonWord>>{
  'Танысу':[LessonWord('сәлем','привет','hello'),LessonWord('аты','имя','name'),LessonWord('жас','возраст','age'),LessonWord('қала','город','city'),LessonWord('танысу','знакомство','introduction')],
  'Отбасы':[LessonWord('отбасы','семья','family'),LessonWord('ана','мама','mother'),LessonWord('әке','папа','father'),LessonWord('аға','старший брат','older brother'),LessonWord('әпке','старшая сестра','older sister')],
  'Үй':[LessonWord('үй','дом','house'),LessonWord('бөлме','комната','room'),LessonWord('асүй','кухня','kitchen'),LessonWord('есік','дверь','door'),LessonWord('терезе','окно','window')],
  'Тамақ':[LessonWord('тамақ','еда','food'),LessonWord('су','вода','water'),LessonWord('ет','мясо','meat'),LessonWord('нан','хлеб','bread'),LessonWord('шай','чай','tea')],
  'Күнделікті өмір':[LessonWord('таңертең','утром','morning'),LessonWord('жұмыс','работа','work'),LessonWord('күн','день','day'),LessonWord('кеш','вечер','evening'),LessonWord('ұйқы','сон','sleep')],
  'Дүкен':[LessonWord('баға','цена','price'),LessonWord('ақша','деньги','money'),LessonWord('сатып алу','покупать','buy'),LessonWord('арзан','дешёвый','cheap'),LessonWord('қымбат','дорогой','expensive')],
  'Мейрамхана':[LessonWord('мәзір','меню','menu'),LessonWord('тапсырыс','заказ','order'),LessonWord('есеп','счёт','bill'),LessonWord('дәмді','вкусный','tasty'),LessonWord('даяшы','официант','waiter')],
  'Достар':[LessonWord('дос','друг','friend'),LessonWord('кездесу','встреча','meeting'),LessonWord('әңгіме','разговор','conversation'),LessonWord('көңіл','настроение','mood'),LessonWord('бірге','вместе','together')],
  'Жұмыс':[LessonWord('жұмыс','работа','work'),LessonWord('әріптес','коллега','colleague'),LessonWord('кеңсе','офис','office'),LessonWord('жоба','проект','project'),LessonWord('басшы','руководитель','manager')],
  'Саяхат':[LessonWord('саяхат','путешествие','travel'),LessonWord('әуежай','аэропорт','airport'),LessonWord('қонақүй','отель','hotel'),LessonWord('билет','билет','ticket'),LessonWord('бағыт','направление','route')],
  'Қазақстан':[LessonWord('Қазақстан','Казахстан','Kazakhstan'),LessonWord('Астана','Астана','Astana'),LessonWord('дәстүр','традиция','tradition'),LessonWord('мәдениет','культура','culture'),LessonWord('тарих','история','history')],
};

LessonPack lessonFor(String topic,{int lesson=1}){
  final words=topicWords[topic] ?? const <LessonWord>[LessonWord('сөз','слово','word'),LessonWord('жақсы','хорошо','good'),LessonWord('тақырып','тема','topic')];
  const patterns=[[0,1,2],[2,3,4],[0,3,4],[1,2,4]];
  final chosen=patterns[(lesson-1)%4].map((i)=>words[i]).toList();
  LessonWord? review;
  final topicIndex=topics.indexWhere((t)=>t.title==topic);
  if(topicIndex>0){
    final previous=topicWords[topics[topicIndex-1].title]!;
    review=previous[(lesson-1)%previous.length];
  }
  final a=chosen[0],b=chosen[1],c=chosen[2];
  final s1=LessonSentence('Мен '+a.kk+' туралы үйреніп жатырмын.','Я изучаю тему «'+a.ru+'».','I am learning about '+a.en+'.');
  final s2=LessonSentence('Маған '+b.kk+' ұнайды.','Мне нравится '+b.ru+'.','I like '+b.en+'.');
  final s3=LessonSentence('Мен '+c.kk+' білемін.','Я знаю слово «'+c.ru+'».','I know '+c.en+'.');
  return LessonPack(topic,chosen,[s1,s2,s3],[
    DialogueTurn('Сен '+a.kk+' білесің бе?','Иә, мен '+a.kk+' білемін.','Ты знаешь '+a.ru+'?','Да, я знаю '+a.ru+'.','Do you know '+a.en+'?','Yes, I know '+a.en+'.'),
    DialogueTurn('Саған '+b.kk+' ұнай ма?','Иә, маған '+b.kk+' ұнайды.','Тебе нравится '+b.ru+'?','Да, мне нравится '+b.ru+'.','Do you like '+b.en+'?','Yes, I like '+b.en+'.'),
    DialogueTurn('Сен '+c.kk+' туралы білесің бе?','Иә, мен '+c.kk+' туралы білемін.','Ты знаешь о '+c.ru+'?','Да, я знаю о '+c.ru+'.','Do you know about '+c.en+'?','Yes, I know about '+c.en+'.'),
  ],reviewWord:review);
}

const achievements=<Map<String,String>>[
  {'🔥':'7 күн қатарынан'},{'⚡':'1000 XP жина'},{'📚':'100 сөз үйрен'},
  {'🎙️':'Алғашқы дауыс жаттығуы'},{'💬':'Алғашқы диалог'},{'🇰🇿':'A1 деңгейін аяқ'}
];
