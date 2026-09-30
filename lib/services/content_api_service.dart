import 'dart:convert';
import 'package:http/http.dart' as http;

class ContentApiService {
  ContentApiService._();
  static final instance=ContentApiService._();

  static const baseUrl=String.fromEnvironment(
    'CONTENT_API_URL',
    defaultValue:'http://127.0.0.1:8001',
  );

  Future<bool> warmUp() async {
    try{
      final r=await http.get(Uri.parse('$baseUrl/health')).timeout(const Duration(seconds:3));
      final ok=r.statusCode==200;
      print('[QAZAQSHA][CONTENT] health=${r.statusCode} ok=$ok url=$baseUrl');
      return ok;
    }catch(e){
      print('[QAZAQSHA][CONTENT] unavailable: $e');
      return false;
    }
  }

  Future<List<Map<String,dynamic>>> topics() async {
    final r=await http.get(Uri.parse('$baseUrl/api/topics')).timeout(const Duration(seconds:5));
    if(r.statusCode!=200)throw Exception('Content topics HTTP ${r.statusCode}');
    return List<Map<String,dynamic>>.from(jsonDecode(r.body) as List);
  }

  Future<Map<String,dynamic>> lesson(String slug,int number) async {
    final r=await http.get(Uri.parse('$baseUrl/api/topics/$slug/lessons/$number')).timeout(const Duration(seconds:8));
    if(r.statusCode!=200)throw Exception('Content lesson HTTP ${r.statusCode}');
    return Map<String,dynamic>.from(jsonDecode(r.body) as Map);
  }
}
