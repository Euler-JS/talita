import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://localhost:3000/api';
  
  static Future<List<dynamic>> getEvents() async {
    final response = await http.get(
      Uri.parse('$baseUrl/events'),
      headers: {'Content-Type': 'application/json'},
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['events'] ?? [];
    }
    throw Exception('Failed to load events');
  }
}