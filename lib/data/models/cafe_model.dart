import 'package:cloud_firestore/cloud_firestore.dart';

class CafeModel {
  final String uid;
  final String name;
  final String username;
  final String email;
  final String phone;
  final String accountType;
  final DateTime createdAt;

  const CafeModel({
    required this.uid,
    required this.name,
    required this.username,
    required this.email,
    required this.phone,
    required this.accountType,
    required this.createdAt,
  });

  factory CafeModel.fromMap(Map<String, dynamic> map) {
    return CafeModel(
      uid: map['uid'] as String,
      name: map['name'] as String,
      username: map['username'] as String,
      email: map['email'] as String,
      phone: map['phone'] as String? ?? '',
      accountType: map['accountType'] as String,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'username': username,
      'email': email,
      'phone': phone,
      'accountType': accountType,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  CafeModel copyWith({
    String? uid,
    String? name,
    String? username,
    String? email,
    String? phone,
    String? accountType,
    DateTime? createdAt,
  }) {
    return CafeModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      username: username ?? this.username,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      accountType: accountType ?? this.accountType,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
