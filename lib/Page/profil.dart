import 'dart:developer';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:tekflutter/Provider/index.dart';

class User {
  String email;
  String lastname;
  String firstname;
  String pseudo;
  String? user_pic;

  User(
      {required this.email,
      required this.lastname,
      required this.firstname,
      required this.pseudo,
      this.user_pic});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
        email: json['data'][0]['user_email'],
        lastname: json['data'][0]['user_last_name'],
        firstname: json['data'][0]['user_first_name'],
        pseudo: json['data'][0]['user_pseudo'] != null
            ? json['data'][0]['user_pseudo']
            : '',
        user_pic: json['data'][0]['user_pic'] != null
            ? json['data'][0]['user_pic']
            : '');
  }
}

class ProfilePage extends StatefulWidget {
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  var _firstNameController = TextEditingController();
  var _lastNameController = TextEditingController();
  var _pseudoController = TextEditingController();
  String? _base64Image;

  Future<User> fetchUser() async {
    final url = Uri.parse('http://193.168.146.22:8080/api/v1/user/me');
    final userProvider = Provider.of<UserProvider>(context);
    final token = userProvider.token;
    final headers = {'Content-Type': 'application/json', 'x-auth-token': token};
    final response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      final tmpUser = User.fromJson(jsonDecode(response.body));
      _firstNameController = TextEditingController.fromValue(
          TextEditingValue(text: tmpUser.firstname));
      _lastNameController = TextEditingController.fromValue(
          TextEditingValue(text: tmpUser.lastname));
      _pseudoController = TextEditingController.fromValue(
          TextEditingValue(text: tmpUser.pseudo));
      _base64Image = tmpUser.user_pic;
      return tmpUser;
    } else {
      throw Exception('Failed to load user data');
    }
  }

  Future<void> pickImage() async {
    final pickedFile =
        await ImagePicker().getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _base64Image = base64Encode(bytes);
      });
    }
  }

  Future<bool> updateUser() async {
    final url = Uri.parse('http://193.168.146.22:8080/api/v1/user/me');
    final body = json.encode({
      'user_first_name': _firstNameController.text.trim(),
      'user_last_name': _lastNameController.text.trim(),
      'user_pseudo': _pseudoController.text.trim(),
      'user_pic': _base64Image
    });
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final token = userProvider.token;
    final headers = {'Content-Type': 'application/json', 'x-auth-token': token};
    final response = await http.patch(url, body: body, headers: headers);
    final jsonResponse = json.decode(response.body);
    if (!jsonResponse['success']) {
      return false;
    }
    final email_response = jsonResponse['data'][0]['user_email'] as String;
    final firstname_response =
        jsonResponse['data'][0]['user_first_name'] as String;
    final lastname_response = jsonResponse['data'][0]['user_pseudo'] as String;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: Center(
        child: FutureBuilder<User>(
          future: fetchUser(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: pickImage,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey[300],
                          ),
                          child: _base64Image != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(60),
                                  child: Image.memory(
                                    base64Decode(_base64Image!),
                                    width: 120,
                                    height: 120,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Text(
                                  '${snapshot.data!.firstname[0]}${snapshot.data!.lastname[0]}',
                                  style: TextStyle(fontSize: 48),
                                ),
                        ),
                        Opacity(
                          opacity: 0.5,
                          child: Icon(Icons.camera_alt),
                        ),
                      ],
                    ),
                  ),
                  Text('Email: ${snapshot.data!.email}'),
                  SizedBox(height: 20),
                  TextField(
                      decoration: InputDecoration(
                        labelText: 'First name',
                      ),
                      controller: _firstNameController),
                  SizedBox(height: 20),
                  TextField(
                      decoration: InputDecoration(
                        labelText: 'Last name',
                      ),
                      controller: _lastNameController),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Pseudo',
                    ),
                    controller: _pseudoController,
                  ),
                  ElevatedButton(
                    child: Text('Modifier le profil'),
                    onPressed: () async {
                      await updateUser();
                    },
                  )
                ],
              );
            } else if (snapshot.hasError) {
              return Text('${snapshot.error}');
            }

            return CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}
