
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_instagram_clon/models/postmodel.dart';
import 'package:flutter_instagram_clon/models/user.model.dart';
import 'package:flutter_instagram_clon/servises/pref_servise.dart';
import 'package:flutter_instagram_clon/utils/utilServise.dart';

class DataService {
  static final _fireStore = FirebaseFirestore.instance;

  static String folder_user = "users";
  static String folder_posts = "posts";
  static String folder_feeds = "feeds";
  static String folder_followers = "followers";
  static String folder_followings = "followings";

  // User Related

  static Future storeUser(UserModel user) async {
    user.uid = HiveDB.loadUid();
    Map<String, String> params = await Utils.deviceParams();

    user.device_id = params['device_id']!;
    user.device_type = params['device_type']!;
    user.device_token = params['device_token']!;

    return _fireStore.collection(folder_user).doc(user.uid).set(user.toJson());
  }

  static Future<UserModel> loadUser(String? userUid) async {
    userUid ??= HiveDB.loadUid();
    var value = await _fireStore.collection("users").doc(userUid).get();
    UserModel user = UserModel.fromJson(value.data()!);

    var querySnapshot1 = await _fireStore
        .collection(folder_user)
        .doc(userUid)
        .collection(folder_followers)
        .get();
    user.followers = querySnapshot1.docs.length;

    var querySnapshot2 = await _fireStore
        .collection(folder_user)
        .doc(userUid)
        .collection(folder_followings)
        .get();
    user.followings = querySnapshot2.docs.length;

    return user;
  }

  static Future updateUser(UserModel user) async {
    String uid = HiveDB.loadUid();
    var querySnapshot = await _fireStore
        .collection(folder_user)
        .doc(user.uid)
        .collection(folder_posts)
        .get();
    for (var result in querySnapshot.docs) {
      Post post = Post.fromJson(result.data());
      post.uid = user.uid;
      post.fullName = user.fullName;
      post.img_user = user.img_url;
      await _fireStore
          .collection(folder_user)
          .doc(user.uid)
          .collection(folder_posts)
          .doc(post.id)
          .update(post.toJson());
      await _fireStore
          .collection(folder_user)
          .doc(user.uid)
          .collection(folder_feeds)
          .doc(post.id)
          .update(post.toJson());
    }
    return _fireStore.collection(folder_user).doc(uid).update(user.toJson());
  }

  static Future<List<UserModel>> searchUsers(String keyword) async {
    List<UserModel> users = [];
    String uid = HiveDB.loadUid();

    var querySnapshot = await _fireStore
        .collection(folder_user)
        .orderBy("fullName")
        .startAt([keyword]).endAt([keyword + '\uf8ff']).get();

    for (var result in querySnapshot.docs) {
      UserModel newUser = UserModel.fromJson(result.data());
      if (newUser.uid != uid) {
        users.add(newUser);
      }
    }

    List<UserModel> following = [];

    var querySnapshot2 = await _fireStore
        .collection(folder_user)
        .doc(uid)
        .collection(folder_followings)
        .get();
    for (var result in querySnapshot2.docs) {
      following.add(UserModel.fromJson(result.data()));
    }

    for (UserModel user in users) {
      if (following.contains(user)) {
        user.followed = true;
      } else {
        user.followed = false;
      }
    }
    return users;
  }

  // Post Related

  static Future<Post> storePost(Post post) async {
    UserModel me = await loadUser(null);
    post.uid = me.uid;
    post.fullName = me.fullName;
    post.img_user = me.img_url;
    post.date = DateTime.now().toString().substring(0, 16);

    String postId = _fireStore
        .collection(folder_user)
        .doc(me.uid)
        .collection(folder_posts)
        .doc()
        .id;
    post.id = postId;

    await _fireStore
        .collection(folder_user)
        .doc(me.uid)
        .collection(folder_posts)
        .doc(postId)
        .set(post.toJson());
    return post;
  }

  static Future<Post> storeFeed(Post post) async {
    String uid = HiveDB.loadUid();
    await _fireStore
        .collection(folder_user)
        .doc(uid)
        .collection(folder_feeds)
        .doc(post.id)
        .set(post.toJson());
    return post;
  }

  static Future<List<Post>> loadFeeds() async {
    List<Post> posts = [];
    String uid = HiveDB.loadUid();
    var querySnapshot = await _fireStore
        .collection(folder_user)
        .doc(uid)
        .collection(folder_feeds)
        .orderBy("date", descending: true)
        .get();
    for (var element in querySnapshot.docs) {
      Post post = Post.fromJson(element.data());
      if (post.uid == uid) post.mine = true;
      posts.add(post);
    }
    return posts;
  }

  static Future<List<Post>> loadPosts(String? userUid) async {
    List<Post> posts = [];
    userUid ??= HiveDB.loadUid();
    var querySnapshot = await _fireStore
        .collection(folder_user)
        .doc(userUid)
        .collection(folder_posts)
        .get();
    for (var element in querySnapshot.docs) {
      Post post = Post.fromJson(element.data());
      posts.add(post);
    }
    return posts;
  }

  static Future<Post> likePost(Post post, bool liked) async {
    String uid = HiveDB.loadUid();
    post.liked = liked;
    await _fireStore
        .collection(folder_user)
        .doc(uid)
        .collection(folder_feeds)
        .doc(post.id)
        .set(post.toJson());
    if (uid == post.uid) {
      await _fireStore
          .collection(folder_user)
          .doc(uid)
          .collection(folder_posts)
          .doc(post.id)
          .set(post.toJson());
    }
    return post;
  }

  static Future<List<Post>> loadLikes() async {
    String uid = HiveDB.loadUid();
    List<Post> posts = [];
    var querySnapshot = await _fireStore
        .collection(folder_user)
        .doc(uid)
        .collection(folder_feeds)
        .where("liked", isEqualTo: true)
        .get();
    for (var element in querySnapshot.docs) {
      Post post = Post.fromJson(element.data());
      if (uid == post.uid) post.mine = true;
      posts.add(post);
    }
    return posts;
  }

  // Follower and Following Related

  static Future<UserModel> followUser(UserModel someone) async {
    UserModel me = await loadUser(null);

    // I followed to someone
    await _fireStore
        .collection(folder_user)
        .doc(me.uid)
        .collection(folder_followings)
        .doc(someone.uid)
        .set(someone.toJson());

    // I am followed from someone
    await _fireStore
        .collection(folder_user)
        .doc(someone.uid)
        .collection(folder_followers)
        .doc(me.uid)
        .set(me.toJson());

    return someone;
  }

  static Future<UserModel> unfollowUser(UserModel someone) async {
    UserModel me = await loadUser(null);

    // I don't followed to someone
    await _fireStore
        .collection(folder_user)
        .doc(me.uid)
        .collection(folder_followings)
        .doc(someone.uid)
        .delete();

    // I am not followed from someone
    await _fireStore
        .collection(folder_user)
        .doc(someone.uid)
        .collection(folder_followers)
        .doc(me.uid)
        .delete();

    return someone;
  }

  static Future updatePostsToFollowersFeed(UserModel me) async {
    // Store someone's posts to my feed
    List<String> userUids = [];
    var querySnapshot = await _fireStore
        .collection(folder_user)
        .doc(me.uid)
        .collection(folder_followers)
        .get();

    for (var element in querySnapshot.docs) {
      UserModel follower = UserModel.fromJson(element.data());
      userUids.add(follower.uid);
    }
    for (String follower in userUids) {
      var querySnapshot = await _fireStore
          .collection(folder_user)
          .doc(follower)
          .collection(folder_feeds)
          .where("uid", isEqualTo: me.uid)
          .get();
      for (var element in querySnapshot.docs) {
        Post post = Post.fromJson(element.data());
        post.img_user = me.img_url;
        post.fullName = me.fullName;
        await _fireStore
            .collection(folder_user)
            .doc(follower)
            .collection(folder_feeds)
            .doc(post.id)
            .update(post.toJson());
      }
    }
  }

  static Future storePostsToMyFeed(UserModel someone) async {
    // Store someone's posts to my feed
    List<Post> posts = [];
    var querySnapshot = await _fireStore
        .collection(folder_user)
        .doc(someone.uid)
        .collection(folder_posts)
        .get();
    for (var element in querySnapshot.docs) {
      Post post = Post.fromJson(element.data());
      post.liked = false;
      posts.add(post);
    }
    for (Post post in posts) {
      storeFeed(post);
    }
  }

  static Future removePostsFromMyFeed(UserModel someone) async {
    // Remove someone's posts from my feed
    List<Post> posts = [];
    var querySnapshot = await _fireStore
        .collection(folder_user)
        .doc(someone.uid)
        .collection(folder_posts)
        .get();
    for (var element in querySnapshot.docs) {
      Post post = Post.fromJson(element.data());
      posts.add(post);
    }
    for (Post post in posts) {
      removeFeed(post);
    }
  }

  static Future removeFeed(Post post) async {
    String uid = HiveDB.loadUid();
    return await _fireStore
        .collection(folder_user)
        .doc(uid)
        .collection(folder_feeds)
        .doc(post.id)
        .delete();
  }

  static Future removePost(Post post) async {
    String uid = HiveDB.loadUid();
    await removeFeed(post);
    await _fireStore
        .collection(folder_user)
        .doc(uid)
        .collection(folder_posts)
        .doc(post.id)
        .delete();
    List<String> userUids = [];
    var querySnapshot = await _fireStore
        .collection(folder_user)
        .doc(uid)
        .collection(folder_followers)
        .get();
    for (var element in querySnapshot.docs) {
      UserModel follower = UserModel.fromJson(element.data());
      userUids.add(follower.uid);
    }
    for (String follower in userUids) {
      await _fireStore
          .collection(folder_user)
          .doc(follower)
          .collection(folder_feeds)
          .doc(post.id)
          .delete();
    }
  }
}

