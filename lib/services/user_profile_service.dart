import 'package:shared_preferences/shared_preferences.dart';

class UserProfile {
  final String nickname;
  final String language;
  final String character;
  final int age;
  const UserProfile({required this.nickname,required this.language,required this.character,this.age=0});
}

class UserProfileService {
  Future<SharedPreferences> get _prefs=>SharedPreferences.getInstance();
  Future<bool> get isRegistered async=>(await _prefs).getBool('registered')??false;
  Future<UserProfile> get profile async {
    final p=await _prefs;
    return UserProfile(
      nickname:p.getString('nickname')??'',
      language:p.getString('ui_language')??'ru',
      character:p.getString('character')??'🦅',
      age:p.getInt('age')??0,
    );
  }
  Future<void> save({required String nickname,required String language,required String character,String? goal,int age=0})async{
    final p=await _prefs;
    await p.setBool('registered',true);
    await p.setString('nickname',nickname.trim());
    await p.setString('ui_language',language);
    await p.setString('character',character);
    if(goal!=null)await p.setString('learning_goal',goal);
    if(age>0)await p.setInt('age',age);
  }
}