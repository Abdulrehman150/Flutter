import 'package:cloud_firestore/cloud_firestore.dart';

class Contact {
  final String id;
  final String email;
  final String image;
  final Timestamp lastseen;
  final String name;
  final double latitude;
  final double longitude;

  Contact(
      {this.id,
      this.email,
      this.name,
      this.image,
      this.lastseen,
      this.latitude,
      this.longitude});

  factory Contact.fromFirestore(DocumentSnapshot _snapshot) {
    var _data = _snapshot.data();
    return Contact(
        id: _snapshot.id,
        lastseen: _data["lastSeen"],
        email: _data["email"],
        name: _data["name"],
        image: _data["image"],
        latitude: _data["latitude"],
        longitude: _data["longitude"]);
  }
}
