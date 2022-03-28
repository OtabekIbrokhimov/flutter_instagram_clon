import 'package:flutter/material.dart';
import 'package:flutter_instagram_clon/models/postmodel.dart';
import 'package:flutter_instagram_clon/views/appBar_widget.dart';
import 'package:flutter_instagram_clon/views/feef%20widget.dart';

class Likes extends StatefulWidget {
  const Likes({Key? key}) : super(key: key);
static const String id = "/LikesPage";
  @override
  State<Likes> createState() => _LikesState();
}

class _LikesState extends State<Likes> {
  List<Post> items = [];

  @override
  void initState() {
    super.initState();
    items.addAll([
      Post(postImage: "https://firebasestorage.googleapis.com/v0/b/koreanguideway.appspot.com/o/develop%2Fpost.png?alt=media&token=f0b1ba56-4bf4-4df2-9f43-6b8665cdc964", caption: "Discover more great images on our sponsor's site",),
      Post(postImage: "https://firebasestorage.googleapis.com/v0/b/koreanguideway.appspot.com/o/develop%2Fpost2.png?alt=media&token=ac0c131a-4e9e-40c0-a75a-88e586b28b72", caption: "Discover more great images on our sponsor's site",)
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(title: "Likes",),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) => FeedWidget(post: items[index]),
      ),
    );
  }
}