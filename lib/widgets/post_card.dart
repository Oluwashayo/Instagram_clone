import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/providers/user_providers.dart';
import 'package:instagram_clone/resources/firestore_methods.dart';
import 'package:instagram_clone/screens/comments_screen.dart';
import 'package:instagram_clone/utils/show_snackbar.dart';
import 'package:instagram_clone/widgets/like_animation.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/user_model.dart';
import '../utils/colors.dart';

class PostCard extends StatefulWidget {
  final snap;
  const PostCard({super.key, required this.snap});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool isLikeAnimating = false;
  int commentLength = 0;

  //get comments length
  void getComments() async {
    try {
      QuerySnapshot snap = await FirebaseFirestore.instance
          .collection("posts")
          .doc(widget.snap["postId"])
          .collection("comments")
          .get();
      setState(() {
        commentLength = snap.docs.length;
      });
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    getComments();
  }

  // End the like animation
  void endLikeAnimation() {
    setState(() {
      isLikeAnimating = false;
    });
  }

  // Start the like animation
  void startLikeAnimation() {
    setState(() {
      isLikeAnimating = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final User user = Provider.of<UserProvider>(context).getUser;
    return Container(
      color: mobileBackgroundColor,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          // Header section
          Row(
            children: [
              const SizedBox(width: 10),
              CircleAvatar(
                backgroundImage: NetworkImage(widget.snap["profileImage"]),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.snap['username'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    "lagos, Nigeria",
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
              const Spacer(),
              IconButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => Dialog(
                      child: ListView(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shrinkWrap: true,
                        children: [
                          "Delete",
                        ]
                            .map(
                              (e) => InkWell(
                                onTap: () async {
                                  FirestoreMethods()
                                      .deletePost(widget.snap["postId"]);
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 7,
                                    horizontal: 16,
                                  ),
                                  child: Text(e,
                                      style: const TextStyle(fontSize: 16)),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.more_vert),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Image Section
          GestureDetector(
            onDoubleTap: () async {
              await FirestoreMethods().likePost(
                widget.snap["postId"],
                user.uid,
                widget.snap["likes"],
              );
              startLikeAnimation();
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.35,
                  child: Image.network(
                    widget.snap["postUrl"],
                    fit: BoxFit.cover,
                  ),
                ),
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: isLikeAnimating ? 1 : 0,
                  child: LikeAnimation(
                    isAnimating: isLikeAnimating,
                    duration: const Duration(
                      milliseconds: 400,
                    ),
                    onEnd: endLikeAnimation,
                    child: const Icon(
                      Icons.favorite,
                      color: Colors.white,
                      size: 120,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Like comment section
          const SizedBox(height: 5),
          Row(
            children: [
              LikeAnimation(
                isAnimating: widget.snap['likes'].contains(user.uid),
                smallLikes: true,
                child: IconButton(
                  onPressed: () async {
                    await FirestoreMethods().likePost(
                      widget.snap["postId"],
                      user.uid,
                      widget.snap["likes"],
                    );
                  },
                  icon: widget.snap['likes'].contains(user.uid)
                      ? const Icon(
                          Icons.favorite,
                          color: Colors.red,
                          size: 30,
                        )
                      : const Icon(Icons.favorite_border),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => CommentScreen(
                      snap: widget.snap,
                    ),
                  ),
                ),
                icon: const Icon(
                  Icons.comment_outlined,
                  size: 25,
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.send_outlined,
                  size: 25,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.bookmark_border,
                  size: 30,
                ),
              ),
            ],
          ),
          // Description and number of comments
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DefaultTextStyle(
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall!
                      .copyWith(fontWeight: FontWeight.w800),
                  child: Text(
                    "${widget.snap["likes"].length} likes",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 8),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "${widget.snap["username"]}  ",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: widget.snap['description'],
                        ),
                      ],
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Text(
                      "View all $commentLength comments",
                      style:
                          const TextStyle(fontSize: 16, color: secondaryColor),
                    ),
                  ),
                ),
                Text(
                  DateFormat.yMMMd()
                      .format(widget.snap["datePublished"].toDate()),
                  style: const TextStyle(fontSize: 14, color: secondaryColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
