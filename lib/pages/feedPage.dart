import 'package:flutter/material.dart';
import 'package:flutter_instagram_clon/models/postmodel.dart';
import 'package:flutter_instagram_clon/servises/data_servise.dart';
import 'package:flutter_instagram_clon/views/appBar_widget.dart';
import 'package:flutter_instagram_clon/views/feef%20widget.dart';

class FeedPage extends StatefulWidget {
  final Post post;
  Function likePost;
  Function unLikePost;

  PageController? pageController;

  FeedPage({Key? key, this.pageController,required this.likePost,required this.unLikePost,required this.post
  }) : super(key: key);

  static const String id = "/ feedPage";

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  bool isLoading = true;
  List<Post> items = [];

  @override
  void initState() {
    super.initState();
    _apiLoadFeeds();
  }

  void _apiLoadFeeds() async {
    setState(() {
      isLoading = true;
    });

    DataService.loadFeeds().then((posts) => {
      _resLoadFeeds(posts)
    });
  }

  void _resLoadFeeds(List<Post> posts) {
    setState(() {
      isLoading = false;
      items = posts;
    });
  }
void apiPostLike(Post post )async{
    setState(() {
      isLoading = false ;
      items = post as List<Post>;
    });
}
  void apiPostUnLike(Post post )async{
    setState(() {
      isLoading = false;
      items = post as List<Post>;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(
          title: "Instagram",
          icon: const Icon(Icons.camera_alt, color: Colors.black,),
          onPressed: () {
            widget.pageController!.jumpToPage(2);
          }),
      body: Stack(
        children: [
          ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) => FeedWidget(post: items[index]),
          ),

          if(isLoading) const Center(
            child: CircularProgressIndicator(),
          )
        ],
      ),
    );
  }
}