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
  const LessonPack(this.topic,this.words,this.sentences,this.dialogue);
}

final Map<String,LessonPack> lessonPacks={
  'Танысу':LessonPack('Танысу',[
    LessonWord('сәлем','привет','hello'),
    LessonWord('аты','имя','name'),
    LessonWord('жас','возраст','age'),
  ],[
    LessonSentence('Менің атым Адиль.','Меня зовут Адиль.','My name is Adil.'),
    LessonSentence('Мен Астанада тұрамын.','Я живу в Астане.','I live in Astana.'),
    LessonSentence('Танысқаныма қуаныштымын.','Рад познакомиться.','Nice to meet you.'),
  ],[
    DialogueTurn('Сәлем! Қалың қалай?','Жақсы, рақмет!','Привет! Как дела?','Хорошо, спасибо!','Hi! How are you?','Good, thank you!'),
    DialogueTurn('Атың кім?','Менің атым {name}.','Как тебя зовут?','Меня зовут {name}.','What is your name?','My name is {name}.'),
    DialogueTurn('Қай қалада тұрасың?','Мен Астанада тұрамын.','В каком городе ты живёшь?','Я живу в Астане.','Which city do you live in?','I live in Astana.'),
  ]),
  'Отбасы':LessonPack('Отбасы',[
    LessonWord('отбасы','семья','family'),LessonWord('ана','мама','mother'),LessonWord('әке','папа','father'),
  ],[
    LessonSentence('Бұл менің отбасым.','Это моя семья.','This is my family.'),
    LessonSentence('Бұл менің анам.','Это моя мама.','This is my mother.'),
    LessonSentence('Менің әкем бар.','У меня есть папа.','I have a father.'),
  ],[
    DialogueTurn('Отбасың үлкен бе?','Иә, отбасым үлкен.','У тебя большая семья?','Да, у меня большая семья.','Is your family big?','Yes, my family is big.'),
    DialogueTurn('Анаң бар ма?','Иә, анам бар.','У тебя есть мама?','Да, у меня есть мама.','Do you have a mother?','Yes, I do.'),
    DialogueTurn('Әкең бар ма?','Иә, әкем бар.','У тебя есть папа?','Да, у меня есть папа.','Do you have a father?','Yes, I do.'),
  ]),
  'Үй':LessonPack('Үй',[
    LessonWord('үй','дом','house'),LessonWord('бөлме','комната','room'),LessonWord('есік','дверь','door'),
  ],[
    LessonSentence('Бұл менің үйім.','Это мой дом.','This is my house.'),
    LessonSentence('Менің бөлмем үлкен.','Моя комната большая.','My room is big.'),
    LessonSentence('Есік ашық.','Дверь открыта.','The door is open.'),
  ],[
    DialogueTurn('Үйің қандай?','Менің үйім үлкен.','Какой у тебя дом?','Мой дом большой.','What is your house like?','My house is big.'),
    DialogueTurn('Бөлмең бар ма?','Иә, бөлмем бар.','У тебя есть комната?','Да, у меня есть комната.','Do you have a room?','Yes, I do.'),
    DialogueTurn('Есік ашық па?','Иә, есік ашық.','Дверь открыта?','Да, дверь открыта.','Is the door open?','Yes, the door is open.'),
  ]),
};
LessonPack lessonFor(String topic){
  final p=lessonPacks[topic];
  if(p!=null)return p;
  return LessonPack(topic,[
    LessonWord(topic,topic,topic),LessonWord('сөз','слово','word'),LessonWord('жақсы','хорошо','good'),
  ],[
    LessonSentence('Мен қазақша үйреніп жатырмын.','Я учу казахский.','I am learning Kazakh.'),
    LessonSentence('Бұл қызықты тақырып.','Это интересная тема.','This is an interesting topic.'),
    LessonSentence('Мен тағы қайталаймын.','Я повторю ещё раз.','I will repeat it again.'),
  ],[
    DialogueTurn('Бұл тақырып ұнай ма?','Иә, маған ұнайды.','Тебе нравится эта тема?','Да, мне нравится.','Do you like this topic?','Yes, I like it.'),
    DialogueTurn('Қазақша сөйлей аласың ба?','Аздап сөйлей аламын.','Ты умеешь говорить по-казахски?','Я немного говорю.','Can you speak Kazakh?','I can speak a little.'),
    DialogueTurn('Қайта айтайық па?','Иә, қайта айтайық.','Повторим?','Да, давай повторим.','Shall we repeat?','Yes, let’s repeat.'),
  ]);
}
