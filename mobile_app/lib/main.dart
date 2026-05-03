import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  String msg = "";

  final BASE_URL = "http://10.0.2.2:8080"; 
  // emulator use করলে localhost এর বদলে এটা লাগবে

  Future<void> login() async {
    final res = await http.post(
      Uri.parse("$BASE_URL/auth/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": usernameController.text,
        "password": passwordController.text,
      }),
    );

    if (res.statusCode == 200) {
      setState(() {
        msg = "✅ Login successful";
      });
    } else {
      setState(() {
        msg = "❌ Invalid login";
      });
    }
  }

  Future<void> register() async {
    final res = await http.post(
      Uri.parse("$BASE_URL/auth/register"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": usernameController.text,
        "password": passwordController.text,
      }),
    );

    setState(() {
      msg = "✅ Registered!";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo, Colors.purple],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Container(
            padding: EdgeInsets.all(20),
            width: 300,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("🎓 Student System",
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),

                SizedBox(height: 20),

                TextField(
                  controller: usernameController,
                  decoration: InputDecoration(labelText: "Username"),
                ),

                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(labelText: "Password"),
                ),

                SizedBox(height: 20),

                ElevatedButton(
                  onPressed: login,
                  child: Text("Login"),
                ),

                ElevatedButton(
                  onPressed: register,
                  child: Text("Register"),
                ),

                SizedBox(height: 10),

                Text(msg, style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}