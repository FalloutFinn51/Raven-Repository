import 'package:flutter_raven/models/auth_provider.dart';
import 'package:flutter_raven/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_raven/pages/login_page.dart';

class RootPage extends StatelessWidget {
  const RootPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var auth = AuthProvider.of(context)!.auth;
    return StreamBuilder<String>(
      stream: auth!.onAuthStateChanged,
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final bool isLoggedIn = snapshot.hasData;
          return isLoggedIn ? const HomePage() : const LoginPage();
        } else {
          return _waitingScreen();
        }
      },
    );
  }

  Widget _waitingScreen() {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: const CircularProgressIndicator(),
      ),
    );
  }
}
