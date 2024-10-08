import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:instagram/utils/colors.dart';
import 'package:instagram/utils/global_variables.dart';
import 'package:instagram/widgets/post_card.dart';

class FeedScreenLayout extends StatelessWidget {
  const FeedScreenLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: width > webScreenSize
            ? null
            : AppBar(
                backgroundColor: width > webScreenSize
                    ? webBackgroundColor
                    : mobileBackgroundColor,
                title: Text(
                  "GRAMHUB",
                  style: TextStyle(
                      fontSize: 20,
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.bold),
                ),
                actions: [
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.messenger_outline),
                  ),
                ],
              ),
        body: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('posts').snapshots(),
          builder: (context,
              AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Text('No posts available'),
              );
            }

            return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) => Container(
                      margin: EdgeInsets.symmetric(
                          horizontal: width > webScreenSize ? width * 0.3 : 0,
                          vertical: width > webScreenSize ? 15 : 0),
                      child: PostCard(
                        snap: snapshot.data!.docs[index].data(),
                      ),
                    ));
          },
        ));
  }
}
