import 'package:feed_app/presentation/pages/detail/details_page.dart';
import 'package:flutter/material.dart';

import '../../presentation/pages/feed/feed_page.dart';
import '../../presentation/pages/login/login_page.dart';

class AppRoutes {
  static const login = '/login';
  static const feed = '/feed';
  static const details = '/details';
  static const favorites = '/favorites';

  static Map<String, WidgetBuilder> routes = {
    login: (_) => const LoginPage(),
    feed: (_) => const FeedPage(),
    details: (context) {
      final postId = ModalRoute.of(context)!.settings.arguments as int;
      return DetailsPage(postId: postId);
    },
  };
}
