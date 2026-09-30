from app.main import SessionLocal, Topic, Lesson

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

def run():
    with SessionLocal() as s:
        for slug,title,subtitle,emoji,level,xp,sort_order,required_after in TOPICS:
            t=s.query(Topic).filter_by(slug=slug).first()
            if not t:
                t=Topic(slug=slug,title=title,subtitle=subtitle,emoji=emoji,level=level,xp=xp,sort_order=sort_order,required_after=required_after)
                s.add(t);s.flush()
            for n in range(1,6):
                if not s.query(Lesson).filter_by(topic_id=t.id,number=n).first():
                    s.add(Lesson(topic_id=t.id,number=n,title="Экзамен" if n==5 else f"Урок {n}",kind="exam" if n==5 else "lesson"))
        s.commit()
        print("Seed complete")

if __name__=="__main__":
    run()
