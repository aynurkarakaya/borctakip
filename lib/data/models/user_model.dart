import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String username;
  final String email;
  final String phone;
  final String accountType;
  final DateTime createdAt;

  const UserModel({
    required this.uid,
    required this.name,
    required this.username,
    required this.email,
    required this.phone,
    required this.accountType,
    required this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: (map['uid'] ?? '') as String,
      name: (map['name'] ?? 'Bilinmiyen Kullanıcı') as String,
      username: (map['username'] ?? 'unknown') as String,
      email: (map['email'] ?? '') as String,
      phone: (map['phone'] ?? '') as String,
      accountType: (map['accountType'] ?? 'user') as String,
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
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

  UserModel copyWith({
    String? uid,
    String? name,
    String? username,
    String? email,
    String? phone,
    String? accountType,
    DateTime? createdAt,
  }) {
    return UserModel(
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
