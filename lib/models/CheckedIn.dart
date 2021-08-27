import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:notes_app/models/user_model.dart';

class CheckedIn {
  final String id, uid, name, image, role;
  final Address? address;
  final bool regulatory;
  final Timestamp timestamp;

  CheckedIn({
    required this.id,
    required this.uid,
    required this.name,
    required this.image,
    required this.address,
    required this.regulatory,
    required this.timestamp,
    required this.role,
  });

  factory CheckedIn.fromJson(Map<String, dynamic> json) {
    return CheckedIn(
      id: json['id'],
      uid: json['uid'],
      name: json['name'],
      image: json['image'],
      role: json["role"] == null ? null : json["role"],
      address: json["address"] == null ? null : Address.fromJson(json["address"]),
      regulatory: json['regulatory'],
      timestamp: json['timestamp'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "uid": uid,
      "name": name,
      "image": image,
      "role": role,
      "address": address?.toJson(),
      "regulatory": regulatory,
      "timestamp": timestamp,
    };
  }
}
