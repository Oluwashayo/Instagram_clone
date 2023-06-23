// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String email;
  final String uid;
  final String bio;
  final String username;
  final String photoUrl;
  final List followers;
  final List following;

  const User({
    required this.email,
    required this.uid,
    required this.bio,
    required this.username,
    required this.photoUrl,
    required this.followers,
    required this.following,
  });

  Map<String, dynamic> toJson() => {
        "username": username,
        "uid": uid,
        "email": email,
        "bio": bio,
        "followers": followers,
        "following": following,
        "photoUrl": photoUrl,
      };

  static User fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return User(
      username: snapshot['username'],
      bio: snapshot['bio'],
      followers: snapshot['followers'],
      following: snapshot['following'],
      uid: snapshot['uid'],
      photoUrl: snapshot['photoUrl'],
      email: snapshot['email'],
    );
  }
}
