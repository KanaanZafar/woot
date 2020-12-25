import 'package:flutter/material.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:wootter_x/state/searchState.dart';
import 'helper/routes.dart';
import 'helper/theme.dart';
import 'state/appState.dart';
import 'package:provider/provider.dart';
import 'state/authState.dart';
import 'state/chats/chatState.dart';
import 'state/feedState.dart';
import 'package:google_fonts/google_fonts.dart';
import 'state/notificationState.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';

import 'state/suggestionState.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
  //   systemNavigationBarColor: Colors.blue, // navigation bar color
  //   statusBarColor: Colors.white, // status bar color
  // ));

  await Parse().initialize(
      'KLOUDBOY123',
      'http://173.249.19.78:1337/parse',
      masterKey: 'KLOUDBOY456', // Required for Back4App and others
      debug: true, // When enabled, prints logs to console
      // liveQueryUrl: keyLiveQueryUrl, // Required if using LiveQuery
      autoSendSessionId: true, // Required for authentication and ACL
      // securityContext: securityContext, // Again, required for some setups
      coreStore: CoreStoreMemoryImp(),
  );

  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    // FlutterStatusbarcolor.setStatusBarColor(Colors.white);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AppState>(create: (_) => AppState()),
        ChangeNotifierProvider<AuthState>(create: (_) => AuthState()),
        ChangeNotifierProvider<FeedState>(create: (_) => FeedState()),
        ChangeNotifierProvider<ChatState>(create: (_) => ChatState()),
        ChangeNotifierProvider<SearchState>(create: (_) => SearchState()),
        ChangeNotifierProvider<SuggestionState>(
            create: (_) => SuggestionState()),
        ChangeNotifierProvider<NotificationState>(
            create: (_) => NotificationState()),
      ],
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.grey,
        ),
        child: MaterialApp(
          title: 'Wootter',
          theme: AppTheme.apptheme.copyWith(
            textTheme: GoogleFonts.muliTextTheme(
              Theme.of(context).textTheme,
            ),
          ),

          debugShowCheckedModeBanner: false,
          routes: Routes.route(),
          onGenerateRoute: (settings) => Routes.onGenerateRoute(settings),
          onUnknownRoute: (settings) => Routes.onUnknownRoute(settings),
          initialRoute: "SplashPage",
        ),
      ),
    );
  }
}
