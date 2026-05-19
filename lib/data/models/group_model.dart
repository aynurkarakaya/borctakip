import 'package:cloud_firestore/cloud_firestore.dart';

class GroupModel {
  final String id;
  final String name;
  final String createdBy;
  final String createdByName;
  final List<String> memberIds;
  final Map<String, dynamic> memberNames;
  final DateTime createdAt;

  const GroupModel({
    required this.id,
    required this.name,
    required this.createdBy,
    required this.createdByName,
    required this.memberIds,
    required this.memberNames,
    required this.createdAt,
  });

  factory GroupModel.fromMap(Map<String, dynamic> map, String docId) {
    return GroupModel(
      id: docId,
      name: map['name'] as String? ?? '',
      createdBy: map['createdBy'] as String? ?? '',
      createdByName: map['createdByName'] as String? ?? '',
      memberIds: List<String>.from(map['memberIds'] as List? ?? const []),
      memberNames: Map<String, dynamic>.from(map['memberNames'] as Map? ?? const {}),
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'createdBy': createdBy,
      'createdByName': createdByName,
      'memberIds': memberIds,
      'memberNames': memberNames,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
