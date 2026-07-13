import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:noriskclient/config/Colors.dart';
import 'package:noriskclient/utils/NoRiskApi.dart';
import 'package:noriskclient/widgets/NewsPost.dart';
import 'package:noriskclient/widgets/NoRiskText.dart';
import 'package:shared_preferences/shared_preferences.dart';

class News extends StatefulWidget {
  const News({super.key});

  @override
  State<News> createState() => _NewsState();
}

class _NewsState extends State<News> {
  List<Widget> news = [];
  bool isShowingCachedData = false;

  @override
  void initState() {
    loadNews();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: NoRiskClientColors.background,
      body: Padding(
        padding: const EdgeInsets.only(
          top: 15,
          left: 15,
          right: 15,
          bottom: 55,
        ),
        child: RefreshIndicator(
          onRefresh: loadNews,
          child: ListView(
            children: [
              // Offline caching: if the last live fetch failed, we still show
              // whatever was cached from the previous successful load instead
              // of an empty screen, with a small hint that it may be stale.
              if (isShowingCachedData)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: NoRiskText(
                    'Showing saved posts - no connection'.toLowerCase(),
                    spaceTop: false,
                    spaceBottom: false,
                    style: TextStyle(
                      color: NoRiskClientColors.textLight,
                      fontSize: 18,
                    ),
                  ),
                ),
              ...news,
            ],
          ),
        ),
      ),
    );
  }

  Future<void> loadNews() async {
    List<dynamic>? posts;
    bool usedCache = false;

    try {
      posts = await NoRiskApi().getBlogPostsAndChangeLogs();
      await _cachePosts(posts);
    } catch (_) {
      posts = await _loadCachedPosts();
      usedCache = posts != null;
    }

    if (posts == null) {
      setState(() {
        isShowingCachedData = false;
      });
      return;
    }

    List<Widget> newsPosts = [];
    for (int i = 0; i < posts.length; i++) {
      final post = posts[i];
      bool isNewest = i == 0;
      if (isNewest) {
        newsPosts.add(
          NoRiskText(
            'Newest'.toLowerCase(),
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: NoRiskClientColors.text,
            ),
          ),
        );
      }
      newsPosts.add(
        NewsPost(
          title: post['title']['rendered'],
          imageUrl: post['yoast_head_json']?['og_image']?[0]?['url'] ?? '',
          link: post['link'],
          postedAt: post['date'].split('T')[0].split('-').reversed.join('.'),
          isNewest: isNewest,
        ),
      );
      newsPosts.add(const SizedBox(height: 10));
      if (isNewest) {
        newsPosts.add(
          NoRiskText(
            'Older Posts'.toLowerCase(),
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: NoRiskClientColors.text,
            ),
          ),
        );
      }
    }

    setState(() {
      news = newsPosts;
      isShowingCachedData = usedCache;
    });
  }

  Future<void> _cachePosts(List<dynamic> posts) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('newsCache', jsonEncode(posts));
  }

  Future<List<dynamic>?> _loadCachedPosts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('newsCache');
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as List<dynamic>;
    } catch (_) {
      return null;
    }
  }
}
