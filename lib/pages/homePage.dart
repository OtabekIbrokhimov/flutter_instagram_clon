import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_instagram_clon/pages/feedPage.dart';
import 'package:flutter_instagram_clon/pages/likesPage.dart';
import 'package:flutter_instagram_clon/pages/profilePage.dart';
import 'package:flutter_instagram_clon/pages/searchPage.dart';
import 'package:flutter_instagram_clon/pages/uploadPage.dart';
import 'package:flutter_instagram_clon/utils/utilServise.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
static const String id = "/HomePage";
  @override
  State<HomePage> createState() => _HomePageState();

}

class _HomePageState extends State<HomePage> {
  final PageController _pageController = PageController();
  int _currentTap = 0;

  _initNotification() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      Utils.showLocalNotification(message, context);
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      Utils.showLocalNotification(message, context);
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initNotification();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentTap = index;
          });
        },
        children: [
          FeedPage(pageController: _pageController),
          const SearchPage(),
          UploadPage(pageController: _pageController),
          const Likes(),
          const ProfilePage()
        ],
      ),
      bottomNavigationBar: CupertinoTabBar(
        onTap: (index) {
          setState(() {
            _currentTap = index;
            _pageController.jumpToPage(index);
          });
        },
        currentIndex: _currentTap,
        activeColor: const Color.fromRGBO(193, 53, 132, 1),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home)),
          BottomNavigationBarItem(icon: Icon(Icons.search)),
          BottomNavigationBarItem(icon: Icon(Icons.add_box)),
          BottomNavigationBarItem(icon: Icon(Icons.favorite)),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle)),
        ],
      ),
    );
  }
}