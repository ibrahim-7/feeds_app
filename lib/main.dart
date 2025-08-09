import 'package:feed_app/auth_gate.dart';
import 'package:feed_app/core/utils/routes.dart';
import 'package:feed_app/data/repo/auth_repo_impl.dart';
import 'package:feed_app/data/repo/post_repository_impl.dart';
import 'package:feed_app/data/sources/local_data_source.dart';
import 'package:feed_app/data/sources/remote_data_sources.dart';
import 'package:feed_app/domain/repo/auth_repository.dart';
import 'package:feed_app/presentation/blocs/auth/auth_bloc.dart';
import 'package:feed_app/presentation/blocs/auth/auth_event.dart';
import 'package:feed_app/presentation/blocs/feed/feed_block.dart';
import 'package:feed_app/presentation/pages/detail/details_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

import 'core/utils/db_helper.dart';
import 'data/repo/feed_repo_impl.dart';
import 'domain/repo/feed_repository.dart';
import 'domain/repo/post_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final db = await DBHelper.initDB();

  final remoteDataSource = RemoteDataSource(http.Client());
  final localDataSource = LocalDataSource(db);

  final postRepository = PostRepositoryImpl(
    remote: remoteDataSource,
    local: localDataSource,
  );
  final authRepository = AuthRepositoryImpl(db: db);
  final feedRepository = FeedRepositoryImpl(
    remote: remoteDataSource,
    local: localDataSource,
  );

  runApp(MyApp(
    feedRepository: feedRepository,
    postRepository: postRepository,
    authRepository: authRepository,
  ));
}

class MyApp extends StatelessWidget {
  final FeedRepository feedRepository;
  final PostRepository postRepository;
  final AuthRepository authRepository;

  const MyApp({
    super.key,
    required this.feedRepository,
    required this.postRepository,
    required this.authRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: feedRepository),
        RepositoryProvider.value(value: postRepository),
        RepositoryProvider.value(value: authRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) =>
                AuthBloc(authRepository)..add(CheckAuthStatus()),
          ),
          BlocProvider<FeedBloc>(
            create: (context) => FeedBloc(feedRepository),
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Feed App',
          home:
              const AuthGate(), // Reacts to AuthBloc states and shows correct screen
          routes: AppRoutes.routes,
          onGenerateRoute: (settings) {
            if (settings.name == '/details') {
              final postId = settings.arguments as int;
              return DetailsPage.route(postId);
            }
            return null;
          },
        ),
      ),
    );
  }
}
