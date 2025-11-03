import 'service.dart';
import 'user.dart';

class Booking {
  final String id;
  final Service service;
  final User user;
  final DateTime dateTime;
  final String status; // pending, confirmed, completed, cancelled
  final String? notes;

  Booking({
    required this.id,
    required this.service,
    required this.user,
    required this.dateTime,
    required this.status,
    this.notes,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] as String,
      service: Service.fromJson(json['service'] as Map<String, dynamic>),
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      dateTime: DateTime.parse(json['date_time'] as String),
      status: json['status'] as String,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'service': service.toJson(),
      'user': user.toJson(),
      'date_time': dateTime.toIso8601String(),
      'status': status,
      'notes': notes,
    };
  }

  Booking copyWith({
    String? id,
    Service? service,
    User? user,
    DateTime? dateTime,
    String? status,
    String? notes,
  }) {
    return Booking(
      id: id ?? this.id,
      service: service ?? this.service,
      user: user ?? this.user,
      dateTime: dateTime ?? this.dateTime,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }
}

