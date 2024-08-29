import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sipinter_admin/dashboard.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscureTextNewPassword = true;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final String? userId = prefs.getString('userId');

    if (userId != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyDashboard()),
      );
    }
  }

  Future<void> _login() async {
    final String username = _usernameController.text;
    final String password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      _showErrorDialog('Masukkan Username dan Password Terlebih Dahulu!');
      return;
    }

    final client = http.Client();

    try {
      final response = await client.post(
        Uri.parse('192.168.1.9/pesantrenadmin/api/login'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'username': username,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        if (responseData['status'] == 'success') {
          await _saveSessionData(responseData['user']);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MyDashboard()),
          );
        } else {
          _showErrorDialog(responseData['message']);
        }
      } else {
        _showErrorDialog('Failed to connect to the server');
      }
    } catch (e) {
      _showErrorDialog('An error occurred: $e');
    } finally {
      client.close();
    }
  }

  Future<void> _saveSessionData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userData['id']);
    await prefs.setString('username', userData['username']);
    await prefs.setString('nama', userData['nama']);
    await prefs.setString('avatar', userData['avatar']);
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFE0E7FF),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'ADMIN PANEL | SI-PINTER',
                style: TextStyle(
                  color: Colors.orange,
                  fontSize: screenWidth < 600 ? 20 : 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Stack(
                alignment: Alignment.topCenter,
                children: <Widget>[
                  FractionallySizedBox(
                    widthFactor: screenWidth < 600 ? 0.9 : 0.5,
                    child: Container(
                      margin: const EdgeInsets.only(top: 60.0),
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.0),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6.0,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: <Widget>[
                          const SizedBox(height: 50),
                          TextField(
                            controller: _usernameController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              filled: true,
                              hintStyle: const TextStyle(color: Colors.black),
                              prefixIcon: const Icon(Icons.person),
                              hintText: "Username",
                              fillColor: Colors.grey[100],
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _passwordController,
                            obscureText: _obscureTextNewPassword,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureTextNewPassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureTextNewPassword =
                                        !_obscureTextNewPassword;
                                  });
                                },
                              ),
                              filled: true,
                              hintStyle: const TextStyle(color: Colors.black),
                              prefixIcon: const Icon(Icons.lock),
                              fillColor: Colors.grey[100],
                              hintText: "Password",
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextButton(
                            onPressed: _login,
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 50, vertical: 10),
                            ),
                            child: const Text(
                              'Masuk',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    child: Container(
                      height: screenWidth < 600 ? 100.0 : 120.0,
                      width: screenWidth < 600 ? 100.0 : 120.0,
                      child: Image.asset("assets/image/logo.png"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
