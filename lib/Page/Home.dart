import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Provider/index.dart';

import '../widget/navbar.dart';
import '../widget/localisation.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    Future<bool> findMe() async {
      return true;
    }

    return Scaffold(
      appBar: authProvider.isAuthenticated
          ? AppBar(
              title: Text('Home'),
            )
          : null,
      bottomNavigationBar:
          authProvider.isAuthenticated ? MyBottomNavigationBar() : null,
      body: Center(
        child: authProvider.isAuthenticated
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Consumer<UserProvider>(
                    builder: (context, user, _) => Text(
                      'Welcome ${user.firstName} ${user.lastName}!',
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                  SizedBox(height: 20),
                  LocationWidget(),
                  ElevatedButton(
                    child: Text('Logout'),
                    onPressed: () {
                      Provider.of<AuthProvider>(context, listen: false)
                          .logout();
                    },
                  ),
                ],
              )
            : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                ElevatedButton(
                  child: Text('Login'),
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                ),
                ElevatedButton(
                  child: Text('Register'),
                  onPressed: () {
                    Navigator.pushNamed(context, '/register');
                  },
                )
              ]),
      ),
    );
  }
}
