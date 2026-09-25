import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class QazaqshaDatabase {
  QazaqshaDatabase._();
  static final instance = QazaqshaDatabase._();
  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await openDatabase(
      p.join(await getDatabasesPath(), 'qazaqsha_progress.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('CREATE TABLE lesson_results (topic TEXT NOT NULL, lesson INTEGER NOT NULL, best_score INTEGER NOT NULL DEFAULT 0, grade INTEGER NOT NULL DEFAULT 0, updated_at TEXT NOT NULL, PRIMARY KEY(topic, lesson))');
        await db.execute('CREATE TABLE user_stats (id INTEGER PRIMARY KEY CHECK(id = 1), xp INTEGER NOT NULL DEFAULT 0, completed_lessons INTEGER NOT NULL DEFAULT 0, learned_words INTEGER NOT NULL DEFAULT 0, streak INTEGER NOT NULL DEFAULT 0, last_activity_date TEXT)');
        await db.insert('user_stats', {'id':1,'xp':0,'completed_lessons':0,'learned_words':0,'streak':0,'last_activity_date':null});
      },
    );
    return _db!;
  }

  Future<Map<String,int>> grades() async {
    final db=await database;
    final rows=await db.query('lesson_results');
    return {for(final r in rows) '${r['topic']}_u${r['lesson']}':(r['grade'] as int?)??0};
  }

  Future<bool> saveResult({required String topic,required int lesson,required int score,required int grade}) async {
    final db=await database;
    final old=await db.query('lesson_results',where:'topic=? AND lesson=?',whereArgs:[topic,lesson],limit:1);
    final oldGrade=old.isEmpty?0:(old.first['grade'] as int? ?? 0);
    final oldScore=old.isEmpty?0:(old.first['best_score'] as int? ?? 0);
    final bestGrade=grade>oldGrade?grade:oldGrade;
    final bestScore=score>oldScore?score:oldScore;
    await db.insert('lesson_results',{
      'topic':topic,'lesson':lesson,'best_score':bestScore,'grade':bestGrade,
      'updated_at':DateTime.now().toIso8601String(),
    },conflictAlgorithm:ConflictAlgorithm.replace);
    return oldGrade<3 && bestGrade>=3;
  }

  Future<void> recordCompletion({required int xp,required int words}) async {
    final db=await database;
    final rows=await db.query('user_stats',where:'id=1',limit:1);
    final r=rows.first;
    final today=_dateKey(DateTime.now());
    final last=r['last_activity_date'] as String?;
    var streak=r['streak'] as int? ?? 0;
    if(last==null) {
      streak=1;
    } else if(last!=today) {
      final lastDate=DateTime.tryParse(last);
      final todayDate=DateTime.parse(today);
      streak=lastDate!=null && todayDate.difference(lastDate).inDays==1 ? streak+1 : 1;
    }
    await db.update('user_stats',{
      'xp':(r['xp'] as int? ?? 0)+xp,
      'completed_lessons':(r['completed_lessons'] as int? ?? 0)+1,
      'learned_words':(r['learned_words'] as int? ?? 0)+words,
      'streak':streak,'last_activity_date':today,
    },where:'id=1');
  }

  Future<Map<String,int>> stats() async {
    final db=await database;
    final rows=await db.query('user_stats',where:'id=1',limit:1);
    if(rows.isEmpty)return {'xp':0,'lessons':0,'words':0,'streak':0};
    final r=rows.first;
    return {'xp':r['xp'] as int? ?? 0,'lessons':r['completed_lessons'] as int? ?? 0,'words':r['learned_words'] as int? ?? 0,'streak':r['streak'] as int? ?? 0};
  }

  String _dateKey(DateTime d)=>'${d.year.toString().padLeft(4,'0')}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}';
}
