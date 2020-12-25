import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wootter_x/helper/enum.dart';
import 'package:wootter_x/helper/theme.dart';
import 'package:wootter_x/page/Auth/welcomePage.dart';
import 'package:wootter_x/page/homePage.dart';
import 'package:wootter_x/state/authState.dart';
import 'package:wootter_x/widgets/customWidgets.dart';
import 'package:provider/provider.dart';

class SplashPage extends StatefulWidget {
  SplashPage({Key key}) : super(key: key);

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    // timer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      timer();
    });
    super.initState();
  }

  void timer() async {
    await Future.delayed(Duration(milliseconds: 3400));
    var state = Provider.of<AuthState>(context, listen: false);
    await state.getCurrentUser();
  }

  Widget _body() {
    var height = 150.0;
    return Container(
      height: fullHeight(context),
      width: fullWidth(context),
      child: Container(
        height: height,
        width: height,
        alignment: Alignment.center,
        child: Container(
          padding: EdgeInsets.all(50),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
//              Platform.isIOS
//                  ? CupertinoActivityIndicator(
//                      radius: 35,
//                    )
//                  : CircularProgressIndicator(
//                      strokeWidth: 2,
//                    ),
              Image.asset(
                'assets/images/splashGIF.gif',
//                height: 30,
//                width: 30,
                repeat: ImageRepeat.noRepeat,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TwitterColor.white,
      body: Selector<AuthState, AuthStatus>(
        builder: (context, value, child) {
          switch (value) {
            case AuthStatus.LOGGED_IN:
              return HomePage();
              break;
            case AuthStatus.NOT_LOGGED_IN:
              return WelcomePage();
              break;
            default:
              return _body();
          }
        },
        selector: (context, state) => state.authStatus,
      ),
      // body: stata.  state.authStatus == AuthStatus.NOT_DETERMINED
      //     ? _body()
      //     : state.authStatus == AuthStatus.NOT_LOGGED_IN
      //         ? WelcomePage()
      //         : HomePage(),
    );
  }
}
