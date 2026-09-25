class LessonWord{final String kk,ru,en,audio;const LessonWord(this.kk,this.ru,this.en,this.audio);}
class TranslationQuestion{final String kk,ruPrompt,enPrompt,audio;final List<String> ru,en;final int correct;const TranslationQuestion(this.kk,this.ruPrompt,this.enPrompt,this.ru,this.en,this.correct,this.audio);}
class MatchPair{final String kk,ru,en,audio;const MatchPair(this.kk,this.ru,this.en,this.audio);}
class FillQuestion{final String sentence,ru,en,audio;final List<String> options;final int correct;const FillQuestion(this.sentence,this.ru,this.en,this.options,this.correct,this.audio);}
class SpeakingPrompt{final String kk,ru,en,audio;const SpeakingPrompt(this.kk,this.ru,this.en,this.audio);}
class LessonPack{final String topic;final List<LessonWord> words;final List<TranslationQuestion> translations;final List<MatchPair> pairs;final List<FillQuestion> fills;final List<SpeakingPrompt> speaking;const LessonPack(this.topic,this.words,this.translations,this.pairs,this.fills,this.speaking);}
class ExamPack{final List<TranslationQuestion> translations;final List<MatchPair> pairs;final List<FillQuestion> fills;final List<SpeakingPrompt> speaking;const ExamPack(this.translations,this.pairs,this.fills,this.speaking);}
class Topic{final String title,subtitle,emoji,level;final int xp;final List<String> words;const Topic(this.title,this.subtitle,this.emoji,this.level,this.xp,this.words);}
const topics=<Topic>[
Topic('Танысу','Өзіңді таныстыру','👋','A1',80,['сәлем','аты','жас','қала','танысу']),Topic('Отбасы','Жақындарың туралы','👨‍👩‍👧','A1',90,['отбасы','ана','әке','аға','әпке']),Topic('Үй','Үйің және бөлмелер','🏠','A1',90,['үй','бөлме','асүй','есік','терезе']),Topic('Тамақ','Тағам және сусындар','🍲','A1',100,['тамақ','су','ет','нан','шай']),Topic('Күнделікті өмір','Күн тәртібі','☀️','A1',100,['таңертең','жұмыс','күн','кеш','ұйқы']),Topic('Дүкен','Сатып алу','🛍️','A2',120,['баға','ақша','сатып алу','арзан','қымбат']),Topic('Мейрамхана','Мейрамханада сөйлесу','🍽️','A2',120,['мәзір','тапсырыс','есеп','дәмді','даяшы']),Topic('Достар','Достық туралы','🤝','A2',120,['дос','кездесу','әңгіме','көңіл','бірге']),Topic('Жұмыс','Жұмыс және мамандық','💼','A2',140,['жұмыс','әріптес','кеңсе','жоба','басшы']),Topic('Саяхат','Саяхат және жол','✈️','B1',160,['саяхат','әуежай','қонақүй','билет','бағыт']),Topic('Қазақстан','Ел туралы сөйлесу','🇰🇿','B1',180,['Қазақстан','Астана','дәстүр','мәдениет','тарих'])];
LessonWord w(String kk,String ru,String en,String a)=>LessonWord(kk,ru,en,a);
TranslationQuestion tq(String kk,String ru,List<String> o,int c,String a)=>TranslationQuestion(kk,ru,ru,o,o,c,a);
FillQuestion fq(String s,String ru,List<String> o,int c,String a)=>FillQuestion(s,ru,ru,o,c,a);
SpeakingPrompt sp(String kk,String ru,String a)=>SpeakingPrompt(kk,ru,ru,a);
MatchPair mp(String kk,String ru,String a)=>MatchPair(kk,ru,ru,a);

final _t1=LessonPack('Танысу',[
w('Сәлем!','Привет!','Hello!','salem'),w('Сәлеметсіз бе?','Здравствуйте!','Hello!','salemetsiz_be'),w('Қайырлы таң!','Доброе утро!','Good morning!','qaiyrly_tan'),w('Қайырлы күн!','Добрый день!','Good afternoon!','qaiyrly_kun'),w('Қайырлы кеш!','Добрый вечер!','Good evening!','qaiyrly_kesh'),w('Мұғалім','Учитель','Teacher','mugalim'),w('Достар','Друзья','Friends','dostar'),w('Алма','Яблоко','Apple','alma'),w('Қалай','Как','How','qalai')],
[tq('Сәлем!','Как переводится слово «Сәлем!»?',['Здравствуйте!','Привет!','Добрый вечер!','Пока!'],1,'salem'),tq('Қайырлы таң!','Как переводится фраза «Қайырлы таң!»?',['Добрый день!','Добрый вечер!','Доброе утро!','До свидания!'],2,'qaiyrly_tan'),tq('Мұғалім','Как переводится слово «Мұғалім»?',['Друг','Учитель','Ученик','Яблоко'],1,'mugalim')],
[mp('Сәлеметсіз бе?','Здравствуйте!','salemetsiz_be'),mp('Қайырлы кеш!','Добрый вечер!','qaiyrly_kesh'),mp('Достар','Друзья','dostar')],
[fq('Сәлеметсіз бе, _____!','Здравствуйте, учитель!',['алма','мұғалім','қалай','таң'],1,'salemetsiz_be'),fq('Қайырлы _____, достар!','Доброе утро, друзья!',['кеш','күн','таң','сәлем'],2,'qaiyrly_tan'),fq('Қайырлы _____, досым!','Добрый день, мой друг!',['күн','таң','кеш','алма'],0,'qaiyrly_kun')],
[sp('Сәлеметсіз бе?','Здравствуйте!','salemetsiz_be'),sp('Қайырлы таң!','Доброе утро!','qaiyrly_tan'),sp('Қайырлы кеш, достар!','Добрый вечер, друзья!','qaiyrly_kesh_dostar')]);

final _t2=LessonPack('Танысу',[
w('Қалай?','Как?','How?','qalai'),w('Жақсы','Хорошо','Good','zhaqsy'),w('Керемет','Прекрасно / Отлично','Great / Excellent','keremet'),w('Рақмет','Спасибо','Thank you','raqmet'),w('Қал қалай?','Как дела?','How are you?','qal_qalai'),w('Өзің ше?','А ты? / А вы?','And you?','ozin_she'),w('Жаман','Плохо','Bad','zhaman'),w('Қала','Город','City','qala'),w('Сен','Ты','You','sen')],
[tq('Рақмет','Что означает слово «Рақмет»?',['Пожалуйста','Спасибо','Хорошо','Как дела?'],1,'raqmet'),tq('Өзің ше?','Как переводится фраза «Өзің ше?»?',['А ты? / А вы?','Как дела?','Все отлично','До свидания'],0,'ozin_she'),tq('Керемет','Как переводится слово «Керемет»?',['Плохо','Прекрасно / Отлично','Город','Спасибо'],1,'keremet')],
[mp('Қалай?','Как?','qalai'),mp('Жақсы','Хорошо','zhaqsy'),mp('Жаман','Плохо','zhaman')],
[fq('Жалпы, бәрі _____.','В целом, всё хорошо.',['қала','жақсы','рақмет','сен'],1,'zhaqsy'),fq('Қал _____, досым?','Как дела, друг?',['жақсы','қалай','керемет','жаман'],1,'qal_qalai'),fq('Жақсы, _____. Өзің ше?','Хорошо, спасибо. А ты?',['рақмет','қала','керемет','сәлем'],0,'raqmet')],
[sp('Қал қалай?','Как дела?','qal_qalai'),sp('Жақсы, рақмет!','Хорошо, спасибо!','zhaqsy_raqmet'),sp('Керемет, өзің ше?','Отлично, а ты?','keremet_ozin_she')]);

final _t3=LessonPack('Танысу',[
w('Ат / Есім','Имя','Name','at_esim'),w('Менің атым...','Меня зовут...','My name is...','menin_atym'),w('Көріскенше!','До встречи!','See you!','koriskenshe'),w('Сау болыңыз!','До свидания!','Goodbye!','sau_bolynyz'),w('Танысқаныма қуаныштымын','Рад(а) знакомству!','Nice to meet you!','tanysqanyma_quanyshtymyn'),w('Қаласың','Остаёшься / останешься','Stay / remain','qalasyn'),w('Дос','Друг','Friend','dos'),w('Кеш','Вечер / поздно','Evening / late','kesh')],
[tq('Сау болыңыз!','Как переводится фраза «Сау болыңыз!»?',['До свидания!','Привет!','Как дела?','Рад знакомству!'],0,'sau_bolynyz'),tq('Менің атым...','Что означает «Менің атым...»?',['Меня зовут...','До встречи!','Спасибо большое','Мой друг'],0,'menin_atym'),tq('Көріскенше!','Как переводится «Көріскенше!»?',['До свидания!','До встречи!','Умница','Хорошо'],1,'koriskenshe')],
[mp('Есім','Имя','esim'),mp('Дос','Друг','dos'),mp('Кеш','Вечер','kesh')],
[fq('Менің _____ Айнұр.','Меня зовут Айнур.',['атым','дос','кеш','қала'],0,'menin_atym'),fq('Танысқаныма _____.','Рад знакомству.',['сау','қуаныштымын','жақсы','қалай'],1,'tanysqanyma_quanyshtymyn'),fq('Сау болыңыз, _____!','До свидания, до встречи!',['көріскенше','рақмет','мұғалім','алма'],0,'koriskenshe')],
[sp('Менің атым Айнұр','Меня зовут Айнур.','menin_atym_ainur'),sp('Танысқаныма қуаныштымын','Рад(а) знакомству!','tanysqanyma_quanyshtymyn'),sp('Сау болыңыз!','До свидания!','sau_bolynyz')]);

final _t4=LessonPack('Танысу',[
w('Қалаймын','Хочу','I want','qalaimyn'),w('Алма','Яблоко','Apple','alma'),w('Көргім келеді','Хочу увидеть','I want to see','korgim_keledi'),w('Барлық','Все','All','barlyq'),w('Бүгін','Сегодня','Today','bugin'),w('Ертең','Завтра','Tomorrow','erten')],
[tq('Бүгін','Как переводится слово «Бүгін»?',['Завтра','Сегодня','Вчера','Всегда'],1,'bugin'),tq('Ертең','Что означает «Ертең»?',['Утро','Вечер','Завтра','Скоро'],2,'erten'),tq('Қалаймын','Как переводится слово «Қалаймын»?',['Хочу','Знаю','Иду','Говорю'],0,'qalaimyn')],
[mp('Бүгін','Сегодня','bugin'),mp('Ертең','Завтра','erten'),mp('Алма','Яблоко','alma')],
[fq('Мен _____ жегім келеді.','Я хочу съесть яблоко.',['алма','кеш','дос','мұғалім'],0,'alma'),fq('Бәрі _____, рақмет!','Всё хорошо, спасибо!',['жақсы','ертең','бүгін','қалай'],0,'zhaqsy'),fq('Көріскенше _____!','До встречи завтра!',['ертең','бүгін','алма','атым'],0,'erten')],
[sp('Сәлеметсіз бе! Сәлеметсіз бе! Қал қалай?','Здравствуйте! Здравствуйте! Как дела?','dialogue_greeting'),sp('Рақмет, бәрі жақсы. Менің атым Данияр.','Спасибо, всё хорошо. Меня зовут Данияр.','dialogue_daniyar'),sp('Танысқаныма қуаныштымын, сау болыңыз!','Рад знакомству, до свидания!','dialogue_goodbye')]);

final _exam=ExamPack([
tq('Қайырлы таң!','Какое приветствие используется при встрече утром?',['Қайырлы кеш!','Қайырлы таң!','Сау болыңыз!','Көріскенше!'],1,'qaiyrly_tan'),tq('Танысқаныма қуаныштымын','Как переводится фраза «Танысқаныма қуаныштымын»?',['Как дела?','Рад знакомству!','До свидания!','Меня зовут...'],1,'tanysqanyma_quanyshtymyn'),tq('Алма','Выберите правильный перевод слова «Алма».',['Учитель','Друг','Яблоко','Вечер'],2,'alma'),tq('Қалаймын','Что означает слово «Қалаймын»?',['Хочу','Знаю','Иду','Вижу'],0,'qalaimyn'),tq('Сәлеметсіз бе?','Как вежливо сказать «Здравствуйте!» взрослому человеку?',['Сәлем!','Сәлеметсіз бе?','Қайырлы күн!','Сау бол!'],1,'salemetsiz_be')],
[mp('Бүгін','Сегодня','bugin'),mp('Ертең','Завтра','erten'),mp('Мұғалім','Учитель','mugalim'),mp('Дос','Друг','dos'),mp('Рақмет','Спасибо','raqmet')],
[fq('— Сәлеметсіз бе, мұғалім! — Сәлеметсіз бе! Қал _____?','Как дела?',['қалай','атым','алма','кеш'],0,'qalai'),fq('Менің _____ Айнұр.','Меня зовут Айнур.',['атым','қалай','бүгін','ертең'],0,'menin_atym'),fq('Мен алма жегім _____.','Я хочу съесть яблоко.',['келеді','жақсы','сау','дос'],0,'keledi')],
[sp('Сәлеметсіз бе! Менің атым [Ваше имя]. Танысқаныма қуаныштымын!','Здравствуйте! Меня зовут [Ваше имя]. Рад(а) знакомству!','exam_intro'),sp('Сау болыңыз, көріскенше!','До свидания, до встречи!','exam_goodbye')]);

LessonPack lessonFor(String topic,{int lesson=1}){
 if(topic=='Танысу')return [_t1,_t2,_t3,_t4][lesson-1];
 final ws=[w('сөз','слово','word','default'),w('жақсы','хорошо','good','default'),w('тақырып','тема','topic','default')];
 return LessonPack(topic,ws,[tq('сөз','Как переводится слово «сөз»?',['слово','Друг','Город','Спасибо'],0,'default'),tq('жақсы','Как переводится слово «жақсы»?',['хорошо','Друг','Город','Спасибо'],0,'default'),tq('тақырып','Как переводится слово «тақырып»?',['тема','Друг','Город','Спасибо'],0,'default')],ws.map((x)=>mp(x.kk,x.ru,x.audio)).toList(),[fq('Бұл _____.','Слово',['сөз','жақсы','тақырып'],0,'default'),fq('Бұл _____.','Хорошо',['сөз','жақсы','тақырып'],1,'default'),fq('Бұл _____.','Тема',['сөз','жақсы','тақырып'],2,'default')],ws.map((x)=>sp(x.kk,x.ru,x.audio)).toList());
}
ExamPack? examFor(String topic)=>topic=='Танысу'?_exam:null;
int lessonCountFor(String topic)=>examFor(topic)!=null?5:4;
const achievements=<Map<String,String>>[{'🔥':'7 күн қатарынан'},{'⚡':'1000 XP жина'},{'📚':'100 сөз үйрен'},{'🎙️':'Алғашқы дауыс жаттығуы'},{'💬':'Алғашқы диалог'},{'🇰🇿':'A1 деңгейін аяқ'}];