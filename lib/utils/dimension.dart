import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/screens/feed_screen.dart';

import '../screens/add_post_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/search_screnn.dart';

const webScreenSize = 600;

List<Widget> homeScreenItems = [
  const FeedScreen(),
  const SearchScreen(),
  const AddPost(),
  const Center(child: Text("favorite")),
  ProfileScream(
    uid: FirebaseAuth.instance.currentUser!.uid,
  ),
];
