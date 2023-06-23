// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/resources/auth_methods.dart';
import 'package:instagram_clone/resources/firestore_methods.dart';
import 'package:instagram_clone/screens/login_screen.dart';

import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/utils/show_snackbar.dart';

import '../widgets/follow_button.dart';

class ProfileScream extends StatefulWidget {
  final String uid;
  const ProfileScream({
    Key? key,
    required this.uid,
  }) : super(key: key);

  @override
  State<ProfileScream> createState() => _ProfileScreamState();
}

class _ProfileScreamState extends State<ProfileScream> {
  var userData;
  int postLenght = 0;
  int followers = 0;
  int following = 0;
  bool isFollowing = false;
  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    try {
      var userSnap = await FirebaseFirestore.instance
          .collection("Users")
          .doc(widget.uid)
          .get();

      // get post length

      var postSnap = await FirebaseFirestore.instance
          .collection("posts")
          .where("uid", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .get();
      setState(() {
        userData = userSnap.data()!;
        postLenght = postSnap.docs.length;
        followers = userSnap.data()!['followers'].length;
        following = userSnap.data()!['following'].length;
        isFollowing = userSnap
            .data()!['followers']
            .contains(FirebaseAuth.instance.currentUser!.uid);
      });
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return userData == null
        ? const Center(child: CircularProgressIndicator())
        : Scaffold(
            appBar: AppBar(
              backgroundColor: mobileBackgroundColor,
              title: Text(userData['username']),
              centerTitle: false,
            ),
            body: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: NetworkImage(userData["photoUrl"]),
                            radius: 40,
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    buildStatColumn(postLenght, "posts"),
                                    buildStatColumn(followers, "followers"),
                                    buildStatColumn(following, "following"),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    FirebaseAuth.instance.currentUser!.uid ==
                                            widget.uid
                                        ? FollowButton(
                                            text: "Sign out",
                                            backgroundColor:
                                                mobileBackgroundColor,
                                            textColor: primaryColor,
                                            onPressed: () async {
                                              await AuthMethods().signOut();
                                              // ignore: use_build_context_synchronously
                                              Navigator.of(context)
                                                  .pushReplacement(
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      const LoginScreen(),
                                                ),
                                              );
                                            },
                                            borderColor: secondaryColor,
                                          )
                                        : isFollowing
                                            ? FollowButton(
                                                text: "Unfollow",
                                                backgroundColor: primaryColor,
                                                textColor: Colors.black,
                                                onPressed: () async {
                                                  FirestoreMethods().followUser(
                                                    FirebaseAuth.instance
                                                        .currentUser!.uid,
                                                    userData["uid"],
                                                  );
                                                  setState(() {
                                                    isFollowing = false;
                                                    followers--;
                                                  });
                                                },
                                                borderColor: secondaryColor,
                                              )
                                            : FollowButton(
                                                text: "follow",
                                                backgroundColor: blueColor,
                                                textColor: primaryColor,
                                                onPressed: () async {
                                                  FirestoreMethods().followUser(
                                                    FirebaseAuth.instance
                                                        .currentUser!.uid,
                                                    userData["uid"],
                                                  );
                                                  setState(() {
                                                    isFollowing = true;
                                                    followers++;
                                                  });
                                                },
                                                borderColor: blueColor,
                                              ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.only(top: 10, left: 10),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          userData["username"],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.only(top: 2, left: 10),
                        alignment: Alignment.centerLeft,
                        child: Text(userData["bio"]),
                      ),
                      const Divider(),
                      FutureBuilder(
                        future: FirebaseFirestore.instance
                            .collection("posts")
                            .where("uid", isEqualTo: widget.uid)
                            .get(),
                        builder: ((context,
                            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                                snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          return GridView.builder(
                              shrinkWrap: true,
                              itemCount: snapshot.data!.docs.length,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 5,
                                mainAxisSpacing: 1.5,
                                childAspectRatio: 1,
                              ),
                              itemBuilder: (context, index) {
                                DocumentSnapshot snap =
                                    snapshot.data!.docs[index];
                                return Container(
                                  child: Image(
                                    image: NetworkImage(
                                      snap["postUrl"],
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                );
                              });
                        }),
                      )
                    ],
                  ),
                )
              ],
            ),
          );
  }

  Column buildStatColumn(int num, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          num.toString(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 5),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: secondaryColor,
            ),
          ),
        ),
      ],
    );
  }
}
