import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../Provider/index.dart';

class LoginPage extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    Future<bool> login(String email, String password) async {
      final url = Uri.parse('http://193.168.146.22:8080/api/v1/user/login');
      final body =
          json.encode({'user_email': email, 'user_password': password});
      final headers = {'Content-Type': 'application/json'};
      final response = await http.post(url, body: body, headers: headers);
      final jsonResponse = json.decode(response.body);
      if (!jsonResponse['success']) {
        return false;
      }
      final token = jsonResponse['data'][0]['user_token'] as String;
      final email_response = jsonResponse['data'][0]['user_email'] as String;
      final firstname_response =
          jsonResponse['data'][0]['user_first_name'] as String;
      final lastname_response =
          jsonResponse['data'][0]['user_last_name'] as String;
      final pseudo_response = jsonResponse['data'][0]['user_pseudo'] != null
          ? jsonResponse['data'][0]['user_pseudo'] as String
          : '';
      Provider.of<UserProvider>(context, listen: false).setUser(
          firstname_response,
          lastname_response,
          email_response,
          token,
          pseudo_response);
      Provider.of<AuthProvider>(context, listen: false).login();
      return true;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                ),
                validator: (value) {
                  if (value != null && value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                ),
                validator: (value) {
                  if (value != null && value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                child: Text('Login'),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final success = await login(
                      _emailController.text.trim(),
                      _passwordController.text.trim(),
                    );
                    if (success) {
                      authProvider.login();
                      Navigator.pushReplacementNamed(context, '/');
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Invalid email or password'),
                        ),
                      );
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
