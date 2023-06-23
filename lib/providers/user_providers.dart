import 'package:flutter/material.dart';
import 'package:instagram_clone/models/user_model.dart';
import 'package:instagram_clone/resources/auth_methods.dart';

class UserProvider with ChangeNotifier {
  final AuthMethods _authMethods = AuthMethods();
  User? _user;
  final String email = "";
  final String uid = "";
  final String bio = " ";
  final String username = "";
  final String photoUrl = "";
  final List followers = [];
  final List following = [];

  User get getUser {
    return _user ??
        User(
          email: email,
          uid: uid,
          bio: bio,
          username: username,
          photoUrl: photoUrl,
          followers: followers,
          following: following,
        );
  }

  Future<void> refreshUser() async {
    User user = await _authMethods.getUserDetails();
    _user = user;
    notifyListeners();
  }
}
