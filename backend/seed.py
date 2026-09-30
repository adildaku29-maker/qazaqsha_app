from app.main import SessionLocal, Topic, Lesson, Question
import json

TOPICS=[
("tanysu","Танысу","Өзіңді таныстыру","👋","A1",80,0,None),
("ui","Үй","Үйің және бөлмелер","🏠","A1",90,1,"tanysu"),
("mektep","Мектеп","Мектептегі сөздер","🏫","A1",90,2,"ui"),
("tamaq","Тамақ","Мейрамхана және тағам","🍲","A1",100,3,"ui"),
("densaulyq","Денсаулық","Дәрігер және денсаулық","🏥","A1",100,4,"ui"),
("otbasy","Отбасы","Жақындарың туралы","👨‍👩‍👧","A1",90,5,"mektep"),
("kundelikti-omir","Күнделікті өмір","Күн тәртібі","☀️","A1",100,6,"tamaq"),
("duken","Дүкен","Сатып алу","🛍️","A2",120,7,"tamaq"),
("meiramkhana","Мейрамхана","Мейрамханада сөйлесу","🍽️","A2",120,8,"duken"),
("dostar","Достар","Достық туралы","🤝","A2",120,9,"otbasy"),
("zhumys","Жұмыс","Жұмыс және мамандық","💼","A2",140,10,"kundelikti-omir"),
("sayakhat","Саяхат","Саяхат және жол","✈️","B1",160,11,"meiramkhana"),
("qazaqstan","Қазақстан","Ел туралы сөйлесу","🇰🇿","B1",180,12,"sayakhat"),
]

def add_question(s,lesson,kind,kk,ru="",en="",options=None,correct=None,answer="",audio="",order=0):
    if s.query(Question).filter_by(lesson_id=lesson.id,sort_order=order).first(): return
    s.add(Question(lesson_id=lesson.id,type=kind,prompt_kk=kk,prompt_ru=ru,prompt_en=en,options_json=json.dumps(options or [],ensure_ascii=False),correct_index=correct,answer_kk=answer,audio_key=audio,sort_order=order,active=True))

def run():
    with SessionLocal() as s:
        for slug,title,subtitle,emoji,level,xp,sort_order,required_after in TOPICS:
            t=s.query(Topic).filter_by(slug=slug).first()
            if not t:
                t=Topic(slug=slug,title=title,subtitle=subtitle,emoji=emoji,level=level,xp=xp,sort_order=sort_order,required_after=required_after)
                s.add(t);s.flush()
            for n in range(1,6):
                l=s.query(Lesson).filter_by(topic_id=t.id,number=n).first()
                if not l:
                    l=Lesson(topic_id=t.id,number=n,title="Экзамен" if n==5 else f"Урок {n}",kind="exam" if n==5 else "lesson")
                    s.add(l);s.flush()

        tanysu=s.query(Topic).filter_by(slug="tanysu").first()
        lessons={l.number:l for l in s.query(Lesson).filter_by(topic_id=tanysu.id).all()}

        # Tanysu lesson 1
        l=lessons[1]
        data=[
          ("translation","Сәлем!","Как переводится «Сәлем!»?",["Здравствуйте!","Привет!","Добрый вечер!","Пока!"],1,"","salem"),
          ("translation","Қайырлы таң!","Как переводится «Қайырлы таң!»?",["Добрый день!","Добрый вечер!","Доброе утро!","До свидания!"],2,"","qaiyrly_tan"),
          ("translation","Мұғалім","Как переводится «Мұғалім»?",["Друг","Учитель","Ученик","Яблоко"],1,"","mugalim"),
          ("matching","Сәлеметсіз бе?","Здравствуйте!",[],None,"Здравствуйте!","salemetsiz_be"),
          ("matching","Қайырлы кеш!","Добрый вечер!",[],None,"Добрый вечер!","qaiyrly_kesh"),
          ("matching","Достар","Друзья",[],None,"Друзья","dostar"),
          ("fill","Сәлеметсіз бе, _____!","Здравствуйте, учитель!",["алма","мұғалім","қалай","таң"],1,"мұғалім","salemetsiz_be"),
          ("fill","Қайырлы _____, достар!","Доброе утро, друзья!",["кеш","күн","таң","сәлем"],2,"таң","qaiyrly_tan"),
          ("fill","Қайырлы _____, досым!","Добрый день, мой друг!",["күн","таң","кеш","алма"],0,"күн","qaiyrly_kun"),
          ("speaking","Сәлеметсіз бе?","Здравствуйте!",[],None,"","salemetsiz_be"),
          ("speaking","Қайырлы таң!","Доброе утро!",[],None,"","qaiyrly_tan"),
          ("speaking","Қайырлы кеш, достар!","Добрый вечер, друзья!",[],None,"","qaiyrly_kesh_dostar"),
        ]
        for i,x in enumerate(data): add_question(s,l,*x,order=i)

        # Tanysu lesson 2
        l=lessons[2]
        data=[
          ("translation","Рақмет","Что означает «Рақмет»?",["Пожалуйста","Спасибо","Хорошо","Как дела?"],1,"","raqmet"),
          ("translation","Өзің ше?","Как переводится «Өзің ше?»?",["А ты? / А вы?","Как дела?","Все отлично","До свидания"],0,"","ozin_she"),
          ("translation","Керемет","Как переводится «Керемет»?",["Плохо","Прекрасно / Отлично","Город","Спасибо"],1,"","keremet"),
          ("matching","Қалай?","Как?",[],None,"Как?","qalai"),
          ("matching","Жақсы","Хорошо",[],None,"Хорошо","zhaqsy"),
          ("matching","Жаман","Плохо",[],None,"Плохо","zhaman"),
          ("fill","Жалпы, бәрі _____.","В целом, всё хорошо.",["қала","жақсы","рақмет","сен"],1,"жақсы","zhaqsy"),
          ("fill","Қал _____, досым?","Как дела, друг?",["жақсы","қалай","керемет","жаман"],1,"қалай","qal_qalai"),
          ("fill","Жақсы, _____. Өзің ше?","Хорошо, спасибо. А ты?",["рақмет","қала","керемет","сәлем"],0,"рақмет","raqmet"),
          ("speaking","Қал қалай?","Как дела?",[],None,"","qal_qalai"),
          ("speaking","Жақсы, рақмет!","Хорошо, спасибо!",[],None,"","zhaqsy_raqmet"),
          ("speaking","Керемет, өзің ше?","Отлично, а ты?",[],None,"","keremet_ozin_she"),
        ]
        for i,x in enumerate(data): add_question(s,l,*x,order=i)

        # Tanysu lesson 3
        l=lessons[3]
        data=[
          ("translation","Сау болыңыз!","Как переводится «Сау болыңыз!»?",["До свидания!","Привет!","Как дела?","Рад знакомству!"],0,"","sau_bolynyz"),
          ("translation","Менің атым...","Что означает «Менің атым...»?",["Меня зовут...","До встречи!","Спасибо большое","Мой друг"],0,"","menin_atym"),
          ("translation","Көріскенше!","Как переводится «Көріскенше!»?",["До свидания!","До встречи!","Умница","Хорошо"],1,"","koriskenshe"),
          ("matching","Есім","Имя",[],None,"Имя","esim"),
          ("matching","Дос","Друг",[],None,"Друг","dos"),
          ("matching","Кеш","Вечер",[],None,"Вечер","kesh"),
          ("fill","Менің _____ Айнұр.","Меня зовут Айнур.",["атым","дос","кеш","қала"],0,"атым","menin_atym"),
          ("fill","Танысқаныма _____.","Рад знакомству.",["сау","қуаныштымын","жақсы","қалай"],1,"қуаныштымын","tanysqanyma_quanyshtymyn"),
          ("fill","Сау болыңыз, _____!","До свидания, до встречи!",["көріскенше","рақмет","мұғалім","алма"],0,"көріскенше","koriskenshe"),
          ("speaking","Менің атым Айнұр","Меня зовут Айнур.",[],None,"","menin_atym_ainur"),
          ("speaking","Танысқаныма қуаныштымын","Рад(а) знакомству!",[],None,"","tanysqanyma_quanyshtymyn"),
          ("speaking","Сау болыңыз!","До свидания!",[],None,"","sau_bolynyz"),
        ]
        for i,x in enumerate(data): add_question(s,l,*x,order=i)

        # Tanysu lesson 4
        l=lessons[4]
        data=[
          ("translation","Бүгін","Как переводится «Бүгін»?",["Завтра","Сегодня","Вчера","Всегда"],1,"","bugin"),
          ("translation","Ертең","Что означает «Ертең»?",["Утро","Вечер","Завтра","Скоро"],2,"","erten"),
          ("translation","Қалаймын","Как переводится «Қалаймын»?",["Хочу","Знаю","Иду","Говорю"],0,"","qalaimyn"),
          ("matching","Бүгін","Сегодня",[],None,"Сегодня","bugin"),
          ("matching","Ертең","Завтра",[],None,"Завтра","erten"),
          ("matching","Алма","Яблоко",[],None,"Яблоко","alma"),
          ("fill","Мен _____ жегім келеді.","Я хочу съесть яблоко.",["алма","кеш","дос","мұғалім"],0,"алма","alma"),
          ("fill","Бәрі _____, рақмет!","Всё хорошо, спасибо!",["жақсы","ертең","бүгін","қалай"],0,"жақсы","zhaqsy"),
          ("fill","Көріскенше _____!","До встречи завтра!",["ертең","бүгін","алма","атым"],0,"ертең","erten"),
          ("speaking","Сәлеметсіз бе! Сәлеметсіз бе! Қал қалай?","Здравствуйте! Здравствуйте! Как дела?",[],None,"","dialogue_greeting"),
          ("speaking","Рақмет, бәрі жақсы. Менің атым Данияр.","Спасибо, всё хорошо. Меня зовут Данияр.",[],None,"","dialogue_daniyar"),
          ("speaking","Танысқаныма қуаныштымын, сау болыңыз!","Рад знакомству, до свидания!",[],None,"","dialogue_goodbye"),
        ]
        for i,x in enumerate(data): add_question(s,l,*x,order=i)

        # Tanysu exam
        l=lessons[5]
        data=[
          ("translation","Қайырлы таң!","Какое приветствие используется утром?",["Қайырлы кеш!","Қайырлы таң!","Сау болыңыз!","Көріскенше!"],1,"","qaiyrly_tan"),
          ("translation","Танысқаныма қуаныштымын","Как переводится эта фраза?",["Как дела?","Рад знакомству!","До свидания!","Меня зовут..."],1,"","tanysqanyma_quanyshtymyn"),
          ("translation","Алма","Выберите перевод слова «Алма».",["Учитель","Друг","Яблоко","Вечер"],2,"","alma"),
          ("translation","Қалаймын","Что означает «Қалаймын»?",["Хочу","Знаю","Иду","Вижу"],0,"","qalaimyn"),
          ("translation","Сәлеметсіз бе?","Как вежливо сказать «Здравствуйте!» взрослому?",["Сәлем!","Сәлеметсіз бе?","Қайырлы күн!","Сау бол!"],1,"","salemetsiz_be"),
          ("matching","Бүгін","Сегодня",[],None,"Сегодня","bugin"),
          ("matching","Ертең","Завтра",[],None,"Завтра","erten"),
          ("matching","Мұғалім","Учитель",[],None,"Учитель","mugalim"),
          ("matching","Дос","Друг",[],None,"Друг","dos"),
          ("matching","Рақмет","Спасибо",[],None,"Спасибо","raqmet"),
          ("fill","Қал _____?","Как дела?",["қалай","атым","алма","кеш"],0,"қалай","qalai"),
          ("fill","Менің _____ Айнұр.","Меня зовут Айнур.",["атым","қалай","бүгін","ертең"],0,"атым","menin_atym"),
          ("fill","Мен алма жегім _____.","Я хочу съесть яблоко.",["келеді","жақсы","сау","дос"],0,"келеді","keledi"),
          ("speaking","Сәлеметсіз бе! Менің атым [Ваше имя]. Танысқаныма қуаныштымын!","Здравствуйте! Меня зовут [Ваше имя]. Рад(а) знакомству!",[],None,"","exam_intro"),
          ("speaking","Сау болыңыз, көріскенше!","До свидания, до встречи!",[],None,"","exam_goodbye"),
        ]
        for i,x in enumerate(data): add_question(s,l,*x,order=i)

        s.commit()
        print("Seed complete")

if __name__=="__main__":
    run()
