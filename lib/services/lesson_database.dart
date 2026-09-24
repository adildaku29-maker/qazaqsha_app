import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class LessonResult {
  final String topic;
  final int lesson;
  final int score;
  final int grade;
  final DateTime updatedAt;
  const LessonResult({required this.topic,required this.lesson,required this.score,required this.grade,required this.updatedAt});
}

class LessonDatabase {
  LessonDatabase._();
  static final LessonDatabase instance=LessonDatabase._();
  Database? _db;

  Future<Database> get database async {
    if(_db!=null)return _db!;
    final path=p.join(await getDatabasesPath(),'qazaqsha.db');
    _db=await openDatabase(path,version:1,onCreate:(db,version)async{
      await db.execute('''
        CREATE TABLE lesson_results(
          topic TEXT NOT NULL,
          lesson INTEGER NOT NULL,
          best_score INTEGER NOT NULL DEFAULT 0,
          grade INTEGER NOT NULL DEFAULT 0,
          updated_at INTEGER NOT NULL,
          PRIMARY KEY(topic,lesson)
        )
      ''');
      await db.execute('CREATE INDEX idx_lesson_results_topic ON lesson_results(topic)');
    });
    return _db!;
  }

  Future<Map<String,int>> grades() async {
    final rows=await (await database).query('lesson_results',columns:['topic','lesson','grade']);
    return {
      for(final r in rows)
        '${r['topic']}_u${r['lesson']}':(r['grade'] as int?)??0
    };
  }

  Future<LessonResult?> getResult(String topic,int lesson) async {
    final rows=await (await database).query('lesson_results',where:'topic=? AND lesson=?',whereArgs:[topic,lesson],limit:1);
    if(rows.isEmpty)return null;
    final r=rows.first;
    return LessonResult(topic:topic,lesson:lesson,score:r['best_score'] as int,grade:r['grade'] as int,updatedAt:DateTime.fromMillisecondsSinceEpoch(r['updated_at'] as int));
  }

  Future<void> saveResult({required String topic,required int lesson,required int score,required int grade}) async {
    final db=await database;
    final old=await getResult(topic,lesson);
    final bestScore=old==null?score:(score>old.score?score:old.score);
    final bestGrade=old==null?grade:(grade>old.grade?grade:old.grade);
    if(bestGrade==0 && old!=null && score<60)return;
    await db.insert('lesson_results',{
      'topic':topic,'lesson':lesson,'best_score':bestScore,'grade':bestGrade,
      'updated_at':DateTime.now().millisecondsSinceEpoch,
    },conflictAlgorithm:ConflictAlgorithm.replace);
  }

  Future<bool> isPassed(String topic,int lesson) async {
    final r=await getResult(topic,lesson);
    return (r?.grade??0)>=3;
  }
}