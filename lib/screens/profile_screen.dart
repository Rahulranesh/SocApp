import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram/resources/authmethods.dart';
import 'package:instagram/resources/firestore_methods.dart';
import 'package:instagram/screens/login_screen.dart';
import 'package:instagram/utils/colors.dart';
import 'package:instagram/utils/utils.dart';
import 'package:instagram/widgets/follow_button.dart';

class Profilescreen extends StatefulWidget {
  final String uid;
  const Profilescreen({super.key, required this.uid});

  @override
  State<Profilescreen> createState() => _ProfilescreenState();
}

class _ProfilescreenState extends State<Profilescreen> {
  var userData = {};
  int postlen = 0;
  int followers = 0;
  int following = 0;
  bool isfollowing = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    setState(() {
      isLoading = true;
    });
    try {
      // Fetch user data
      var userSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .get();

      // Fetch posts of the user whose profile is being viewed
      var postSnap = await FirebaseFirestore.instance
          .collection('posts')
          .where('uid', isEqualTo: widget.uid) // Corrected to use widget.uid
          .get();

      setState(() {
        postlen = postSnap.docs.length;
        userData = userSnap.data() ?? {};
        followers = userData['followers']?.length ?? 0;
        following = userData['following']?.length ?? 0;
        isfollowing = userData['followers']
                ?.contains(FirebaseAuth.instance.currentUser!.uid) ??
            false;
        isLoading = false;
      });
    } catch (e) {
      showSnackBar(e.toString(), context);
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : Scaffold(
            appBar: AppBar(
              backgroundColor: mobileBackgroundColor,
              title: Text(userData['username'] ?? 'User'),
              centerTitle: false,
            ),
            body: ListView(
              children: [
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.grey,
                            backgroundImage: userData['photoUrl'] != null
                                ? NetworkImage(userData['photoUrl'])
                                : null,
                            radius: 40,
                          ),
                          Expanded(
                            flex: 1,
                            child: Column(children: [
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  buildStatColumn(postlen, "posts"),
                                  buildStatColumn(followers, "followers"),
                                  buildStatColumn(following, "following")
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  FirebaseAuth.instance.currentUser!.uid ==
                                          widget.uid
                                      ? FollowButton(
                                          backgroundColor:
                                              mobileBackgroundColor,
                                          borderColor: Colors.grey,
                                          text: 'Sign out',
                                          textColor: primaryColor,
                                          function: () async {
                                            await AuthMethods().signOut();
                                            Navigator.of(context)
                                                .pushReplacement(
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    LoginScreen(),
                                              ),
                                            );
                                          },
                                        )
                                      : isfollowing
                                          ? FollowButton(
                                              backgroundColor: Colors.white,
                                              borderColor: Colors.black,
                                              text: 'Unfollow',
                                              textColor: Colors.grey,
                                              function: () async {
                                                await FireStoreMethods()
                                                    .followUser(
                                                        FirebaseAuth.instance
                                                            .currentUser!.uid,
                                                        userData['uid']);
                                                setState(() {
                                                  isfollowing = false;
                                                  followers--;
                                                });
                                              },
                                            )
                                          : FollowButton(
                                              backgroundColor: Colors.blue,
                                              borderColor: Colors.white,
                                              text: 'Follow',
                                              textColor: Colors.blue,
                                              function: () async {
                                                await FireStoreMethods()
                                                    .followUser(
                                                        FirebaseAuth.instance
                                                            .currentUser!.uid,
                                                        userData['uid']);

                                                setState(() {
                                                  isfollowing = true;
                                                  followers++;
                                                });
                                              },
                                            ),
                                ],
                              )
                            ]),
                          ),
                        ],
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.only(top: 15),
                        child: Text(
                          userData['username'] ?? '',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.only(top: 1),
                        child: Text(
                          userData['bio'] ?? '',
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(),
                FutureBuilder(
                  future: FirebaseFirestore.instance
                      .collection('posts')
                      .where('uid', isEqualTo: widget.uid)
                      .get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    if (!snapshot.hasData || snapshot.data == null) {
                      return Center(
                        child: Text('No posts yet'),
                      );
                    }
                    return GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 5,
                          mainAxisSpacing: 1.5,
                          childAspectRatio: 1),
                      itemBuilder: (context, index) {
                        DocumentSnapshot snap =
                            (snapshot.data! as QuerySnapshot).docs[index];
                        return Container(
                          child: Image(
                            image: NetworkImage(
                              snap['postUrl'],
                            ),
                            fit: BoxFit.cover,
                          ),
                        );
                      },
                      shrinkWrap: true,
                      itemCount: (snapshot.data! as QuerySnapshot).docs.length,
                    );
                  },
                )
              ],
            ),
          );
  }

  Column buildStatColumn(int num, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          num.toString(),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 4),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }
}
