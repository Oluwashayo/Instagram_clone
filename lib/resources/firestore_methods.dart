import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram_clone/models/post_model.dart';
import 'package:instagram_clone/resources/storage_methods.dart';
import 'package:uuid/uuid.dart';

class FirestoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

// Upload loads
  Future<String> uploadPost(
    Uint8List file,
    String description,
    String username,
    String profileImage,
    String uid,
  ) async {
    String res = "Something went wrong";
    try {
      String photoUrl =
          await StorageMethod().uploadImageToStorage("posts", file, true);
      String postId = const Uuid().v1();
      Post post = Post(
        description: description,
        uid: uid,
        postId: postId,
        username: username,
        datePublished: DateTime.now(),
        postUrl: photoUrl,
        profileImage: profileImage,
        likes: [],
      );

      _firestore.collection("posts").doc(postId).set(post.toJson());
      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

// Number of likes
  Future<void> likePost(String postId, String uid, List likes) async {
    try {
      if (likes.contains(uid)) {
        await _firestore.collection("posts").doc(postId).update({
          "likes": FieldValue.arrayRemove([uid]),
        });
      } else {
        await _firestore.collection("posts").doc(postId).update({
          "likes": FieldValue.arrayUnion([uid]),
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

// Post comment function
  Future<void> postComment(String postId, String text, String uid, String name,
      String profileImage) async {
    try {
      if (text.isNotEmpty) {
        String commentId = const Uuid().v1();
        await _firestore
            .collection("posts")
            .doc(postId)
            .collection("comments")
            .doc(commentId)
            .set({
          "profileImage": profileImage,
          "text": text,
          "uid": uid,
          "name": name,
          "commentId": commentId,
          "datePublished": DateTime.now(),
        });
      } else {
        print("text is empty");
      }
    } catch (e) {
      print(e.toString());
    }
  }

  //Delete post
  Future<void> deletePost(String postId) async {
    try {
      _firestore.collection("posts").doc(postId).delete();
    } catch (e) {
      print(e.toString());
    }
  }

  // Follow
  Future<void> followUser(String uid, String followId) async {
    try {
      DocumentSnapshot snap =
          await _firestore.collection("Users").doc(uid).get();
      List following = (snap.data()! as dynamic)["following"];
      if (following.contains(followId)) {
        await _firestore.collection("Users").doc(followId).update({
          "followers": FieldValue.arrayRemove([uid])
        });
        await _firestore.collection("Users").doc(uid).update({
          "following": FieldValue.arrayRemove([followId])
        });
      } else {
        await _firestore.collection("Users").doc(followId).update({
          "followers": FieldValue.arrayUnion([uid])
        });
        await _firestore.collection("Users").doc(uid).update({
          "following": FieldValue.arrayUnion([followId])
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }
}
