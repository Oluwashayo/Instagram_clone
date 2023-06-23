import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:instagram_clone/screens/profile_screen.dart';
import '../utils/colors.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  @override
  void dispose() {
    super.dispose();
    _searchController.dispose();
  }

  void NavigateToProfile() {}

  bool _showUser = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: TextFormField(
          controller: _searchController,
          onFieldSubmitted: (String _) {
            setState(() {
              _showUser = true;
            });
          },
          decoration: const InputDecoration(
            labelText: "Search for user",
          ),
        ),
      ),
      body: _showUser
          ? FutureBuilder(
              future: FirebaseFirestore.instance
                  .collection("Users")
                  .where("username",
                      isGreaterThanOrEqualTo: _searchController.text)
                  .get(),
              builder: (context,
                  AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                      snapshots) {
                if (!snapshots.hasData) {
                  return const CircularProgressIndicator();
                }
                return ListView.builder(
                  itemCount: snapshots.data!.docs.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ProfileScream(
                            uid: snapshots.data!.docs[index]["uid"],
                          ),
                        ),
                      ),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundImage: AssetImage("assets/Meta3.jpeg"),
                        ),
                        title: Text(snapshots.data!.docs[index]["username"]),
                      ),
                    );
                  },
                );
              },
            )
          : FutureBuilder(
              future: FirebaseFirestore.instance.collection("posts").get(),
              builder: ((context,
                  AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                return MasonryGridView.count(
                  crossAxisCount: 3,
                  crossAxisSpacing: 5,
                  mainAxisSpacing: 5,
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) =>
                      Image.network(snapshot.data!.docs[index]["postUrl"]),
                );
              }),
            ),
    );
  }
}
