class Booking {
  final String id;
  final String bookingNumber;
  final String userId;
  final String eventId;
  final int quantity;
  final double totalAmount;
  final String currency;
  final List<String> seatNumbers;
  final String? customerNotes;
  final String status;
  final String paymentStatus;
  final String? paymentMethod;
  final String? paymentReference;
  final DateTime bookedAt;
  final DateTime? confirmedAt;
  final DateTime? cancelledAt;
  final String? adminNotes;
  final Event? event;

  Booking({
    required this.id,
    required this.bookingNumber,
    required this.userId,
    required this.eventId,
    required this.quantity,
    required this.totalAmount,
    required this.currency,
    required this.seatNumbers,
    this.customerNotes,
    required this.status,
    required this.paymentStatus,
    this.paymentMethod,
    this.paymentReference,
    required this.bookedAt,
    this.confirmedAt,
    this.cancelledAt,
    this.adminNotes,
    this.event,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'],
      bookingNumber: json['booking_number'],
      userId: json['user_id'],
      eventId: json['event_id'],
      quantity: json['quantity'],
      totalAmount: double.parse(json['total_amount'].toString()),
      currency: json['currency'],
      seatNumbers: List<String>.from(json['seat_numbers'] ?? []),
      customerNotes: json['customer_notes'],
      status: json['status'],
      paymentStatus: json['payment_status'],
      paymentMethod: json['payment_method'],
      paymentReference: json['payment_reference'],
      bookedAt: DateTime.parse(json['booked_at']),
      confirmedAt: json['confirmed_at'] != null ? DateTime.parse(json['confirmed_at']) : null,
      cancelledAt: json['cancelled_at'] != null ? DateTime.parse(json['cancelled_at']) : null,
      adminNotes: json['admin_notes'],
      event: json['events'] != null ? Event.fromJson(json['events']) : null,
    );
  }
}

class Event {
  final String id;
  final String title;
  final String type;
  final DateTime startDateTime;
  final DateTime? endDateTime;
  final double price;
  final String currency;
  final Venue? venue;

  Event({
    required this.id,
    required this.title,
    required this.type,
    required this.startDateTime,
    this.endDateTime,
    required this.price,
    required this.currency,
    this.venue,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      title: json['title'],
      type: json['type'],
      startDateTime: DateTime.parse(json['start_date_time']),
      endDateTime: json['end_date_time'] != null ? DateTime.parse(json['end_date_time']) : null,
      price: double.parse(json['price'].toString()),
      currency: json['currency'],
      venue: json['venues'] != null ? Venue.fromJson(json['venues']) : null,
    );
  }
}

class Venue {
  final String id;
  final String name;
  final String? address;
  final String city;
  final String? state;
  final String? country;

  Venue({
    required this.id,
    required this.name,
    this.address,
    required this.city,
    this.state,
    this.country,
  });

  factory Venue.fromJson(Map<String, dynamic> json) {
    return Venue(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      city: json['city'],
      state: json['state'],
      country: json['country'],
    );
  }
}
  
