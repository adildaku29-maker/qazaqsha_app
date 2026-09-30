import json, os
from datetime import datetime, timedelta, timezone
from pathlib import Path
import jwt
from fastapi import Depends, FastAPI, HTTPException
from fastapi.responses import HTMLResponse
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from pwdlib import PasswordHash
from pydantic import BaseModel, Field
from sqlalchemy import Boolean, Column, DateTime, ForeignKey, Integer, String, Text, UniqueConstraint, create_engine
from sqlalchemy.orm import Session, declarative_base, sessionmaker

BASE_DIR=Path(__file__).resolve().parent
DATABASE_URL=os.getenv("DATABASE_URL","sqlite:///./qazaqsha_content.db")
engine=create_engine(DATABASE_URL,connect_args={"check_same_thread":False} if DATABASE_URL.startswith("sqlite") else {})
SessionLocal=sessionmaker(bind=engine,autocommit=False,autoflush=False)
Base=declarative_base()

class AdminUser(Base):
    __tablename__="admin_users"
    id=Column(Integer,primary_key=True)
    username=Column(String(80),unique=True,index=True,nullable=False)
    password_hash=Column(String(255),nullable=False)
    is_active=Column(Boolean,default=True,nullable=False)

class User(Base):
    __tablename__="users"
    id=Column(Integer,primary_key=True)
    device_id=Column(String(120),unique=True,index=True,nullable=False)
    nickname=Column(String(80),default="")
    age=Column(Integer,default=0)
    language=Column(String(8),default="ru")
    goal=Column(String(120),default="")
    created_at=Column(DateTime,default=datetime.utcnow,nullable=False)
    last_seen_at=Column(DateTime,default=datetime.utcnow,nullable=False)

class Topic(Base):
    __tablename__="topics"
    id=Column(Integer,primary_key=True)
    slug=Column(String(80),unique=True,index=True,nullable=False)
    title=Column(String(120),nullable=False)
    subtitle=Column(String(255),default="")
    emoji=Column(String(16),default="📚")
    level=Column(String(20),default="A1")
    xp=Column(Integer,default=100)
    sort_order=Column(Integer,default=0)
    required_after=Column(String(80),nullable=True)

class Lesson(Base):
    __tablename__="lessons"
    id=Column(Integer,primary_key=True)
    topic_id=Column(Integer,ForeignKey("topics.id"),nullable=False,index=True)
    number=Column(Integer,nullable=False)
    title=Column(String(160),nullable=False)
    kind=Column(String(20),default="lesson")
    __table_args__=(UniqueConstraint("topic_id","number",name="uq_topic_lesson"),)

class Question(Base):
    __tablename__="questions"
    id=Column(Integer,primary_key=True)
    lesson_id=Column(Integer,ForeignKey("lessons.id"),nullable=False,index=True)
    type=Column(String(30),nullable=False)
    prompt_kk=Column(Text,default="")
    prompt_ru=Column(Text,default="")
    prompt_en=Column(Text,default="")
    options_json=Column(Text,default="[]")
    correct_index=Column(Integer,nullable=True)
    answer_kk=Column(Text,default="")
    audio_key=Column(String(160),default="")
    sort_order=Column(Integer,default=0)
    active=Column(Boolean,default=True,nullable=False)

class Progress(Base):
    __tablename__="progress"
    id=Column(Integer,primary_key=True)
    user_id=Column(Integer,ForeignKey("users.id"),nullable=False,index=True)
    topic_id=Column(Integer,ForeignKey("topics.id"),nullable=False)
    lesson_number=Column(Integer,nullable=False)
    best_score=Column(Integer,default=0)
    grade=Column(Integer,default=0)
    updated_at=Column(DateTime,default=datetime.utcnow,nullable=False)
    __table_args__=(UniqueConstraint("user_id","topic_id","lesson_number",name="uq_user_progress"),)

Base.metadata.create_all(engine)
password_hash=PasswordHash.recommended()
bearer=HTTPBearer(auto_error=False)
JWT_SECRET=os.getenv("JWT_SECRET","CHANGE_ME_BEFORE_DEPLOYMENT")
JWT_MINUTES=int(os.getenv("JWT_MINUTES","720"))

class LoginIn(BaseModel):
    username:str
    password:str
class UserIn(BaseModel):
    device_id:str
    nickname:str=""
    age:int=0
    language:str="ru"
    goal:str=""
class ProgressIn(BaseModel):
    device_id:str
    topic_slug:str
    lesson_number:int
    score:int
    grade:int
class TopicIn(BaseModel):
    slug:str
    title:str
    subtitle:str=""
    emoji:str="📚"
    level:str="A1"
    xp:int=100
    sort_order:int=0
    required_after:str|None=None
class LessonIn(BaseModel):
    topic_id:int
    number:int
    title:str
    kind:str="lesson"
class QuestionIn(BaseModel):
    lesson_id:int
    type:str
    prompt_kk:str=""
    prompt_ru:str=""
    prompt_en:str=""
    options:list[str]=Field(default_factory=list)
    correct_index:int|None=None
    answer_kk:str=""
    audio_key:str=""
    sort_order:int=0
    active:bool=True

app=FastAPI(title="Qazaqsha Content Server",version="1.0.0")

def db():
    s=SessionLocal()
    try: yield s
    finally: s.close()

def token_for(username):
    exp=datetime.now(timezone.utc)+timedelta(minutes=JWT_MINUTES)
    return jwt.encode({"sub":username,"exp":exp},JWT_SECRET,algorithm="HS256")

def admin_required(credentials:HTTPAuthorizationCredentials=Depends(bearer),session:Session=Depends(db)):
    if not credentials: raise HTTPException(401,"Admin authentication required")
    try:
        payload=jwt.decode(credentials.credentials,JWT_SECRET,algorithms=["HS256"])
        username=payload["sub"]
    except Exception:
        raise HTTPException(401,"Invalid or expired token")
    admin=session.query(AdminUser).filter_by(username=username,is_active=True).first()
    if not admin: raise HTTPException(403,"Admin account is inactive")
    return admin

@app.on_event("startup")
def startup():
    username=os.getenv("ADMIN_USERNAME","admin")
    password=os.getenv("ADMIN_PASSWORD","change-me-now")
    with SessionLocal() as s:
        if not s.query(AdminUser).filter_by(username=username).first():
            s.add(AdminUser(username=username,password_hash=password_hash.hash(password)))
            s.commit()

@app.get("/health")
def health(): return {"status":"ok","service":"qazaqsha-content"}

@app.post("/api/auth/login")
def login(data:LoginIn,session:Session=Depends(db)):
    admin=session.query(AdminUser).filter_by(username=data.username,is_active=True).first()
    if not admin or not password_hash.verify(data.password,admin.password_hash):
        raise HTTPException(401,"Неверный логин или пароль")
    return {"access_token":token_for(admin.username),"token_type":"bearer"}

@app.get("/api/topics")
def public_topics(session:Session=Depends(db)):
    rows=session.query(Topic).order_by(Topic.sort_order).all()
    return [{"id":t.id,"slug":t.slug,"title":t.title,"subtitle":t.subtitle,"emoji":t.emoji,"level":t.level,"xp":t.xp,"required_after":t.required_after} for t in rows]

@app.get("/api/topics/{slug}/lessons/{number}")
def public_lesson(slug:str,number:int,session:Session=Depends(db)):
    t=session.query(Topic).filter_by(slug=slug).first()
    if not t: raise HTTPException(404,"Topic not found")
    l=session.query(Lesson).filter_by(topic_id=t.id,number=number).first()
    if not l: raise HTTPException(404,"Lesson not found")
    qs=session.query(Question).filter_by(lesson_id=l.id,active=True).order_by(Question.sort_order,Question.id).all()
    return {"topic":{"slug":t.slug,"title":t.title,"level":t.level},"lesson":{"number":l.number,"title":l.title,"kind":l.kind},"questions":[{"id":q.id,"type":q.type,"prompt_kk":q.prompt_kk,"prompt_ru":q.prompt_ru,"prompt_en":q.prompt_en,"options":json.loads(q.options_json or "[]"),"correct_index":q.correct_index,"answer_kk":q.answer_kk,"audio_key":q.audio_key,"sort_order":q.sort_order} for q in qs]}

@app.post("/api/users/sync")
def sync_user(data:UserIn,session:Session=Depends(db)):
    u=session.query(User).filter_by(device_id=data.device_id).first()
    if not u:
        u=User(device_id=data.device_id)
        session.add(u)
    u.nickname=data.nickname;u.age=data.age;u.language=data.language;u.goal=data.goal;u.last_seen_at=datetime.utcnow()
    session.commit();session.refresh(u)
    return {"id":u.id,"device_id":u.device_id}

@app.post("/api/progress")
def save_progress(data:ProgressIn,session:Session=Depends(db)):
    u=session.query(User).filter_by(device_id=data.device_id).first()
    t=session.query(Topic).filter_by(slug=data.topic_slug).first()
    if not u or not t: raise HTTPException(404,"User or topic not found")
    p=session.query(Progress).filter_by(user_id=u.id,topic_id=t.id,lesson_number=data.lesson_number).first()
    if not p:
        p=Progress(user_id=u.id,topic_id=t.id,lesson_number=data.lesson_number)
        session.add(p)
    p.best_score=max(p.best_score or 0,data.score);p.grade=max(p.grade or 0,data.grade);p.updated_at=datetime.utcnow()
    session.commit()
    return {"ok":True,"grade":p.grade,"score":p.best_score}

@app.get("/api/admin/stats")
def admin_stats(_:AdminUser=Depends(admin_required),session:Session=Depends(db)):
    return {"users":session.query(User).count(),"topics":session.query(Topic).count(),"questions":session.query(Question).count()}

@app.get("/api/admin/topics")
def admin_topics(_:AdminUser=Depends(admin_required),session:Session=Depends(db)):
    return public_topics(session)

@app.post("/api/admin/topics")
def create_topic(data:TopicIn,_:AdminUser=Depends(admin_required),session:Session=Depends(db)):
    if session.query(Topic).filter_by(slug=data.slug).first(): raise HTTPException(409,"Slug already exists")
    t=Topic(**data.model_dump());session.add(t);session.flush()
    for n in range(1,6):
        session.add(Lesson(topic_id=t.id,number=n,title="Экзамен" if n==5 else f"Урок {n}",kind="exam" if n==5 else "lesson"))
    session.commit();session.refresh(t);return {"id":t.id}

@app.get("/api/admin/lessons")
def admin_lessons(topic_id:int,_:AdminUser=Depends(admin_required),session:Session=Depends(db)):
    return [{"id":l.id,"topic_id":l.topic_id,"number":l.number,"title":l.title,"kind":l.kind} for l in session.query(Lesson).filter_by(topic_id=topic_id).order_by(Lesson.number)]

@app.post("/api/admin/lessons")
def create_lesson(data:LessonIn,_:AdminUser=Depends(admin_required),session:Session=Depends(db)):
    l=Lesson(**data.model_dump());session.add(l);session.commit();session.refresh(l);return {"id":l.id}

@app.get("/api/admin/questions")
def admin_questions(lesson_id:int,_:AdminUser=Depends(admin_required),session:Session=Depends(db)):
    return [{"id":q.id,"lesson_id":q.lesson_id,"type":q.type,"prompt_kk":q.prompt_kk,"prompt_ru":q.prompt_ru,"prompt_en":q.prompt_en,"options":json.loads(q.options_json or "[]"),"correct_index":q.correct_index,"answer_kk":q.answer_kk,"audio_key":q.audio_key,"sort_order":q.sort_order,"active":q.active} for q in session.query(Question).filter_by(lesson_id=lesson_id).order_by(Question.sort_order,Question.id)]

@app.post("/api/admin/questions")
def create_question(data:QuestionIn,_:AdminUser=Depends(admin_required),session:Session=Depends(db)):
    payload=data.model_dump();payload["options_json"]=json.dumps(payload.pop("options"),ensure_ascii=False)
    q=Question(**payload);session.add(q);session.commit();session.refresh(q);return {"id":q.id}

@app.put("/api/admin/questions/{qid}")
def update_question(qid:int,data:QuestionIn,_:AdminUser=Depends(admin_required),session:Session=Depends(db)):
    q=session.get(Question,qid)
    if not q: raise HTTPException(404,"Question not found")
    payload=data.model_dump();payload["options_json"]=json.dumps(payload.pop("options"),ensure_ascii=False)
    for k,v in payload.items(): setattr(q,k,v)
    session.commit();return {"ok":True}

@app.delete("/api/admin/questions/{qid}")
def delete_question(qid:int,_:AdminUser=Depends(admin_required),session:Session=Depends(db)):
    q=session.get(Question,qid)
    if not q: raise HTTPException(404,"Question not found")
    session.delete(q);session.commit();return {"ok":True}

@app.get("/api/admin/users")
def admin_users(_:AdminUser=Depends(admin_required),session:Session=Depends(db)):
    users=session.query(User).order_by(User.last_seen_at.desc()).all()
    return [{"id":u.id,"nickname":u.nickname,"age":u.age,"language":u.language,"goal":u.goal,"last_seen_at":u.last_seen_at.isoformat(),"passed_stages":sum(1 for p in session.query(Progress).filter_by(user_id=u.id).all() if p.grade>=3)} for u in users]

@app.get("/admin",response_class=HTMLResponse)
def admin_page():
    p=BASE_DIR/"admin.html"
    return p.read_text(encoding="utf-8") if p.exists() else "<h1>Qazaqsha Admin</h1>"
