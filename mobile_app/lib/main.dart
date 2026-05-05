import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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

// ================= LOGIN =================
class LoginPage extends StatelessWidget {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  final String BASE_URL = "http://localhost:8080";

  Future<void> login(BuildContext context) async {
    final res = await http.post(
      Uri.parse("$BASE_URL/auth/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": usernameController.text,
        "password": passwordController.text
      }),
    );

    if (res.statusCode == 200) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => DashboardPage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Login Failed")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [Colors.indigo, Colors.purple]),
        ),
        child: Center(
          child: Container(
            padding: EdgeInsets.all(20),
            width: 300,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("🎓 Student System",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
                  onPressed: () => login(context),
                  child: Text("Login"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => RegisterPage()),
                    );
                  },
                  child: Text("Create account"),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ================= REGISTER =================
class RegisterPage extends StatelessWidget {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  final String BASE_URL = "http://localhost:8080";

  Future<void> register(BuildContext context) async {
    final res = await http.post(
      Uri.parse("$BASE_URL/auth/register"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": usernameController.text,
        "password": passwordController.text
      }),
    );

    if (res.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✅ Registered!")),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Failed")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Register")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: usernameController, decoration: InputDecoration(labelText: "Username")),
            TextField(controller: passwordController, obscureText: true, decoration: InputDecoration(labelText: "Password")),
            SizedBox(height: 20),
            ElevatedButton(onPressed: () => register(context), child: Text("Register"))
          ],
        ),
      ),
    );
  }
}

// ================= DASHBOARD =================
class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {

  final String BASE_URL = "http://localhost:8080";

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final ageController = TextEditingController();

  final titleController = TextEditingController();
  final descController = TextEditingController();

  final studentIdController = TextEditingController();
  final courseIdController = TextEditingController();

  List students = [];
  List courses = [];

  // ================= API =================

  Future<void> addStudent() async {
    await http.post(
      Uri.parse("$BASE_URL/students"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": nameController.text,
        "email": emailController.text,
        "age": int.tryParse(ageController.text) ?? 0
      }),
    );
  }

  Future<void> addCourse() async {
    await http.post(
      Uri.parse("$BASE_URL/courses"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "title": titleController.text,
        "description": descController.text
      }),
    );
  }

  Future<void> assignCourse() async {
    await http.post(
      Uri.parse("$BASE_URL/students/${studentIdController.text}/courses/${courseIdController.text}"),
    );
  }

  Future<void> loadStudents() async {
    final res = await http.get(Uri.parse("$BASE_URL/students"));
    setState(() {
      students = jsonDecode(res.body);
    });
  }

  Future<void> loadCourses() async {
    final res = await http.get(Uri.parse("$BASE_URL/courses"));
    setState(() {
      courses = jsonDecode(res.body);
    });
  }

  // ================= HELPER =================

  String formatCourses(dynamic list) {
    if (list == null) return "No courses";

    final cleaned = (list as List)
        .where((c) =>
            c != null &&
            c['title'] != null &&
            c['title'].toString().trim().isNotEmpty)
        .map((c) => c['title'].toString().trim())
        .toSet()
        .toList();

    if (cleaned.isEmpty) return "No courses";

    return cleaned.join(", ");
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Student Course Management")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [

            // ADD STUDENT
            Card(
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  children: [
                    Text("Add Student"),
                    TextField(controller: nameController, decoration: InputDecoration(labelText: "Name")),
                    TextField(controller: emailController, decoration: InputDecoration(labelText: "Email")),
                    TextField(controller: ageController, decoration: InputDecoration(labelText: "Age")),
                    ElevatedButton(onPressed: addStudent, child: Text("Add"))
                  ],
                ),
              ),
            ),

            SizedBox(height: 10),

            // ADD COURSE
            Card(
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  children: [
                    Text("Add Course"),
                    TextField(controller: titleController, decoration: InputDecoration(labelText: "Title")),
                    TextField(controller: descController, decoration: InputDecoration(labelText: "Description")),
                    ElevatedButton(onPressed: addCourse, child: Text("Add"))
                  ],
                ),
              ),
            ),

            SizedBox(height: 10),

            // ASSIGN
            Card(
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  children: [
                    Text("Assign Course"),
                    TextField(controller: studentIdController, decoration: InputDecoration(labelText: "Student ID")),
                    TextField(controller: courseIdController, decoration: InputDecoration(labelText: "Course ID")),
                    ElevatedButton(onPressed: assignCourse, child: Text("Assign"))
                  ],
                ),
              ),
            ),

            SizedBox(height: 10),

            // STUDENTS
            Card(
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  children: [
                    Text("Students"),
                    ElevatedButton(onPressed: loadStudents, child: Text("Load Students")),
                    ...students.map((s) {
                      return ListTile(
                        title: Text(s['name'] ?? "Unknown"),
                        subtitle: Text("Courses: ${formatCourses(s['courses'])}"),
                      );
                    }).toList()
                  ],
                ),
              ),
            ),

            SizedBox(height: 10),

            // COURSES → STUDENTS (FIXED)
            Card(
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  children: [
                    Text("Courses"),
                    ElevatedButton(onPressed: loadCourses, child: Text("Load Courses")),

                    ...courses.map((c) {

                      String title = (c['title'] ?? "").toString().trim();
                      if (title.isEmpty) return SizedBox();

                      String studentsText = "No students";

                      if (c['students'] != null && c['students'].length > 0) {
                        final uniqueStudents = (c['students'] as List)
                            .where((s) =>
                                s != null &&
                                s['name'] != null &&
                                s['name'].toString().trim().isNotEmpty)
                            .map((s) => s['name'].toString().trim())
                            .toSet()
                            .toList();

                        if (uniqueStudents.isNotEmpty) {
                          studentsText = uniqueStudents.join(", ");
                        }
                      }

                      return ListTile(
                        title: Text(title),
                        subtitle: Text("Students: $studentsText"),
                      );

                    }).toList()
                  ],
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}