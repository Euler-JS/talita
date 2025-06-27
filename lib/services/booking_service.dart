// booking_service.dart - VERSÃO ATUALIZADA
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:movie_app_ui/Model/booking.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookingService {
  static const String baseUrl = 'http://localhost:3000/api';
  
  // Método para obter dados do usuário
  Future<Map<String, dynamic>?> _getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user_data');
    if (userData != null) {
      return json.decode(userData);
    }
    return null;
  }

  // Método básico para headers HTTP
  Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
    };
  }

  // Listar bookings do usuário usando a nova rota /user/:userId
  Future<List<Booking>> getUserBookings({
    int page = 1,
    int limit = 10,
    String? status,
    String? eventId,
    String? startDate,
    String? endDate,
    String sortBy = 'booked_at',
    String sortOrder = 'desc',
  }) async {
    try {
      final userData = await _getUserData();
      if (userData == null) {
        throw Exception('Usuário não autenticado');
      }

      final userId = userData['id'];
      final headers = _getHeaders();
      
      // Construir query parameters
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
        'sort_by': sortBy,
        'sort_order': sortOrder,
      };
      
      if (status != null) queryParams['status'] = status;
      if (eventId != null) queryParams['event_id'] = eventId;
      if (startDate != null) queryParams['start_date'] = startDate;
      if (endDate != null) queryParams['end_date'] = endDate;
      
      final uri = Uri.parse('$baseUrl/bookings/user/$userId').replace(queryParameters: queryParams);
      
      final response = await http.get(uri, headers: headers);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success'] == true) {
          final List<dynamic> bookingsJson = data['bookings'];
          return bookingsJson.map((json) => Booking.fromJson(json)).toList();
        } else {
          throw Exception('Erro na resposta da API: ${data['error'] ?? 'Erro desconhecido'}');
        }
      } else {
        final error = json.decode(response.body);
        throw Exception(error['error'] ?? 'Erro ao carregar reservas: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  // Buscar booking específico usando a nova rota
  Future<Booking> getBookingById(String bookingId) async {
    try {
      final userData = await _getUserData();
      if (userData == null) {
        throw Exception('Usuário não autenticado');
      }

      final userId = userData['id'];
      final headers = _getHeaders();
      
      final response = await http.get(
        Uri.parse('$baseUrl/bookings/$bookingId/user/$userId'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return Booking.fromJson(data['booking']);
        } else {
          throw Exception('Erro na resposta da API');
        }
      } else {
        final error = json.decode(response.body);
        throw Exception(error['error'] ?? 'Reserva não encontrada');
      }
    } catch (e) {
      throw Exception('Erro ao carregar reserva: $e');
    }
  }

  // Confirmar booking usando a nova rota
  Future<Booking> confirmBooking(String bookingId, {
    String paymentMethod = 'credit_card',
    String? paymentReference,
  }) async {
    try {
      final userData = await _getUserData();
      if (userData == null) {
        throw Exception('Usuário não autenticado');
      }

      final userId = userData['id'];
      final headers = _getHeaders();
      
      final response = await http.put(
        Uri.parse('$baseUrl/bookings/$bookingId/confirm/user/$userId'),
        headers: headers,
        body: json.encode({
          'payment_method': paymentMethod,
          if (paymentReference != null) 'payment_reference': paymentReference,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return Booking.fromJson(data['booking']);
        } else {
          throw Exception(data['error'] ?? 'Erro ao confirmar reserva');
        }
      } else {
        final error = json.decode(response.body);
        throw Exception(error['error'] ?? 'Erro ao confirmar reserva');
      }
    } catch (e) {
      throw Exception('Erro ao confirmar reserva: $e');
    }
  }

  // Cancelar booking usando a nova rota
  Future<Booking> cancelBooking(String bookingId, {String? reason}) async {
    try {
      final userData = await _getUserData();
      if (userData == null) {
        throw Exception('Usuário não autenticado');
      }

      final userId = userData['id'];
      final headers = _getHeaders();
      
      final response = await http.put(
        Uri.parse('$baseUrl/bookings/$bookingId/cancel/user/$userId'),
        headers: headers,
        body: json.encode({
          if (reason != null) 'reason': reason,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return Booking.fromJson(data['booking']);
        } else {
          throw Exception(data['error'] ?? 'Erro ao cancelar reserva');
        }
      } else {
        final error = json.decode(response.body);
        throw Exception(error['error'] ?? 'Erro ao cancelar reserva');
      }
    } catch (e) {
      throw Exception('Erro ao cancelar reserva: $e');
    }
  }

  // Criar nova reserva usando a rota atualizada
  Future<Booking> createBooking({
    required String eventId,
    required int quantity,
    List<String>? seatNumbers,
    String? customerNotes,
  }) async {
    try {
      final userData = await _getUserData();
      if (userData == null) {
        throw Exception('Usuário não autenticado');
      }

      final userId = userData['id'];
      final headers = _getHeaders();
      
      final response = await http.post(
        Uri.parse('$baseUrl/bookings'),
        headers: headers,
        body: json.encode({
          'event_id': eventId,
          'quantity': quantity,
          'user_id': userId, // Enviando user_id diretamente
          if (seatNumbers != null) 'seat_numbers': seatNumbers,
          if (customerNotes != null) 'customer_notes': customerNotes,
        }),
      );
      
      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return Booking.fromJson(data['booking']);
        } else {
          throw Exception(data['error'] ?? 'Erro ao criar reserva');
        }
      } else {
        final error = json.decode(response.body);
        throw Exception(error['error'] ?? 'Erro ao criar reserva');
      }
    } catch (e) {
      throw Exception('Erro ao criar reserva: $e');
    }
  }

  // Método helper para verificar se o usuário está logado
  Future<bool> isUserLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_logged_in') ?? false;
  }

  // Método helper para obter ID do usuário
  Future<String?> getUserId() async {
    final userData = await _getUserData();
    return userData?['id'];
  }

  // Método para logout (limpar dados)
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data');
    await prefs.setBool('is_logged_in', false);
  }
}