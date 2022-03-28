import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_instagram_clon/pages/feedPage.dart';
import 'package:flutter_instagram_clon/pages/likesPage.dart';
import 'package:flutter_instagram_clon/pages/profilePage.dart';
import 'package:flutter_instagram_clon/pages/searchPage.dart';
import 'package:flutter_instagram_clon/pages/uploadPage.dart';
import 'package:flutter_instagram_clon/utils/theme.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
static const String id = "/HomePage";
  @override
  State<HomePage> createState() => _HomePageState();

}

class _HomePageState extends State<HomePage> {
  PageController pageController = PageController();
  int currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: pageController,
        children: [
          FeedPage(pageController: pageController,),
          SearchPage(),
          UploadPage(),
          Likes(),
          ProfilePage(),
        ],
        onPageChanged: (index) {
          setState(() {
            currentPage = index;
          });
        },
      ),
      bottomNavigationBar: CupertinoTabBar(
        currentIndex: currentPage,
        backgroundColor: Colors.white54,
        activeColor: Colors.purple,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home)),
          BottomNavigationBarItem(icon: Icon(Icons.search)),
          BottomNavigationBarItem(icon: Icon(Icons.add_box)),
          BottomNavigationBarItem(icon: Icon(Icons.favorite)),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle)),
        ],
        onTap: (index) {
          pageController.jumpToPage(index);
        },
      ),
    );
  }
}