import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const StudentApp());
}

/// IMPORTANT:
/// Android Emulator: http://10.0.2.2:8080
/// Real Device: http://YOUR_PC_IP:8080
const String BASE_URL = "http://localhost:8080";

class StudentApp extends StatelessWidget {
  const StudentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Student System",
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.light,
        fontFamily: 'Roboto',
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Future<void> checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString("email");
    final role = prefs.getString("role");

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    if (email == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    } else {
      if (role == "ADMIN") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminDashboard()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const StudentDashboard()),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    checkLogin();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.indigo.shade800, Colors.indigo.shade400],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.school_rounded, size: 100, color: Colors.white),
              const SizedBox(height: 20),
              const Text(
                "LMS PRO",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 40),
              const CircularProgressIndicator(color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final email = TextEditingController();
  final password = TextEditingController();
  bool isLogin = true;
  bool loading = false;

  final regUsername = TextEditingController();
  final regEmail = TextEditingController();
  final regPassword = TextEditingController();

  Future<void> register() async {
    try {
      setState(() => loading = true);
      final res = await http.post(
        Uri.parse("$BASE_URL/auth/register"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": regUsername.text,
          "email": regEmail.text,
          "password": regPassword.text,
        }),
      );
      if (res.statusCode == 200) {
        showSuccess("Registered Successfully");
        setState(() => isLogin = true);
      } else {
        throw Exception(res.body);
      }
    } catch (e) {
      showError(e.toString());
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> login() async {
    try {
      setState(() => loading = true);
      final response = await http.post(
        Uri.parse("$BASE_URL/auth/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email.text.trim(),
          "password": password.text.trim(),
        }),
      );

      if (response.statusCode == 200) {
        final user = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("email", user["email"] ?? "");
        await prefs.setString("role", user["role"] ?? "USER");

        if (!mounted) return;
        if ((user["role"] ?? "").toString().toUpperCase() == "ADMIN") {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => const AdminDashboard()));
        } else {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => const StudentDashboard()));
        }
      } else {
        throw Exception("Login Failed: ${response.body}");
      }
    } catch (e) {
      showError(e.toString());
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.redAccent),
    );
  }

  void showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.green),
    );
  }

  InputDecoration inputStyle(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.indigo),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 300,
              decoration: BoxDecoration(
                color: Colors.indigo,
                borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(80)),
                gradient: LinearGradient(colors: [Colors.indigo.shade800, Colors.indigo.shade500]),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.school, size: 80, color: Colors.white),
                    const SizedBox(height: 10),
                    Text(
                      isLogin ? "Welcome Back" : "Create Account",
                      style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(25),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  if (isLogin) ...[
                    TextField(controller: email, decoration: inputStyle("Email", Icons.email)),
                    const SizedBox(height: 15),
                    TextField(controller: password, obscureText: true, decoration: inputStyle("Password", Icons.lock)),
                  ] else ...[
                    TextField(controller: regUsername, decoration: inputStyle("Username", Icons.person)),
                    const SizedBox(height: 15),
                    TextField(controller: regEmail, decoration: inputStyle("Email", Icons.email)),
                    const SizedBox(height: 15),
                    TextField(controller: regPassword, obscureText: true, decoration: inputStyle("Password", Icons.lock)),
                  ],
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: loading ? null : (isLogin ? login : register),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        elevation: 5,
                      ),
                      child: loading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(isLogin ? "LOGIN" : "REGISTER", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () => setState(() => isLogin = !isLogin),
                    child: Text(
                      isLogin ? "New here? Create Account" : "Already have an account? Login",
                      style: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  Map<String, dynamic>? student;
  bool loading = true;

  Future<void> loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString("email");
      final res = await http.get(Uri.parse("$BASE_URL/students/my?email=$email"));
      if (res.statusCode == 200) {
        setState(() => student = jsonDecode(res.body));
      } else {
        throw Exception("Student not found");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context, MaterialPageRoute(builder: (_) => const LoginPage()), (_) => false);
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    final courses = student?["courses"] ?? [];
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Student Portal", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.indigo,
        elevation: 0,
        actions: [IconButton(onPressed: logout, icon: const Icon(Icons.logout, color: Colors.white))],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Colors.indigo,
                    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(radius: 40, backgroundColor: Colors.white, child: Icon(Icons.person, size: 50, color: Colors.indigo)),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(student?["name"] ?? "User", style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                            Text(student?["email"] ?? "", style: TextStyle(color: Colors.indigo.shade100)),
                            Text(student?["department"] ?? "", style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      const Text("My Enrolled Courses", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
                      const SizedBox(height: 15),
                      if (courses.isEmpty)
                        const Center(child: Padding(padding: EdgeInsets.all(20), child: Text("No courses found")))
                      else
                        ...courses.map<Widget>((c) => Card(
                          margin: const EdgeInsets.only(bottom: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          elevation: 3,
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(15),
                            leading: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(color: Colors.indigo.shade50, borderRadius: BorderRadius.circular(10)),
                              child: const Icon(Icons.book_online, color: Colors.indigo),
                            ),
                            title: Text(c["title"], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                            subtitle: Text(c["description"] ?? "No description available"),
                          ),
                        )),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  List students = [];
  List courses = [];
  bool loading = true;

  final studentName = TextEditingController();
  final studentEmail = TextEditingController();
  final studentAge = TextEditingController();
  final studentDept = TextEditingController();
  final courseTitle = TextEditingController();
  final courseDesc = TextEditingController();
  final assignSid = TextEditingController();
  final assignCid = TextEditingController();

  Future<void> loadAll() async {
    try {
      setState(() => loading = true);
      final sRes = await http.get(Uri.parse("$BASE_URL/students"));
      final cRes = await http.get(Uri.parse("$BASE_URL/courses"));
      setState(() {
        students = jsonDecode(sRes.body);
        courses = jsonDecode(cRes.body);
      });
    } catch (e) {
      showError(e.toString());
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> addStudent() async {
    try {
      final res = await http.post(
        Uri.parse("$BASE_URL/students"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": studentName.text,
          "email": studentEmail.text,
          "age": int.tryParse(studentAge.text) ?? 0,
          "department": studentDept.text,
        }),
      );
      if (res.statusCode == 200) {
        await loadAll();
        clearStudentFields();
        showSuccess("Student Added");
      }
    } catch (e) { showError(e.toString()); }
  }

  Future<void> addCourse() async {
    try {
      final res = await http.post(
        Uri.parse("$BASE_URL/courses"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"title": courseTitle.text, "description": courseDesc.text}),
      );
      if (res.statusCode == 200) {
        await loadAll();
        courseTitle.clear();
        courseDesc.clear();
        showSuccess("Course Added");
      }
    } catch (e) { showError(e.toString()); }
  }

  Future<void> assignCourse() async {
    try {
      final res = await http.post(Uri.parse("$BASE_URL/students/${assignSid.text}/courses/${assignCid.text}"));
      if (res.statusCode == 200) {
        await loadAll();
        assignSid.clear();
        assignCid.clear();
        showSuccess("Enrollment Successful");
      } else {
        throw Exception("Invalid Student/Course ID");
      }
    } catch (e) { showError(e.toString()); }
  }

  Future<void> deleteStudent(int id) async {
    await http.delete(Uri.parse("$BASE_URL/students/$id"));
    loadAll();
  }

  Future<void> deleteCourse(int id) async {
    await http.delete(Uri.parse("$BASE_URL/courses/$id"));
    loadAll();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginPage()), (_) => false);
  }

  void clearStudentFields() {
    studentName.clear(); studentEmail.clear(); studentAge.clear(); studentDept.clear();
  }

  void showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.redAccent));
  }

  void showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.green));
  }

  @override
  void initState() {
    super.initState();
    loadAll();
  }

  Widget sectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: Colors.indigo),
          const SizedBox(width: 10),
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  InputDecoration adminInput(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Admin Panel", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.indigo,
        actions: [
          IconButton(onPressed: loadAll, icon: const Icon(Icons.refresh, color: Colors.white)),
          IconButton(onPressed: logout, icon: const Icon(Icons.logout, color: Colors.white)),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: loadAll,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // ADD STUDENT
                  sectionHeader("Add New Student", Icons.person_add),
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          TextField(controller: studentName, decoration: adminInput("Name")),
                          const SizedBox(height: 10),
                          TextField(controller: studentEmail, decoration: adminInput("Email")),
                          const SizedBox(height: 10),
                          Row(children: [
                            Expanded(child: TextField(controller: studentAge, decoration: adminInput("Age"), keyboardType: TextInputType.number)),
                            const SizedBox(width: 10),
                            Expanded(child: TextField(controller: studentDept, decoration: adminInput("Dept"))),
                          ]),
                          const SizedBox(height: 15),
                          SizedBox(width: double.infinity, child: ElevatedButton(onPressed: addStudent, style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white), child: const Text("Add Student"))),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  // ADD COURSE
                  sectionHeader("Add New Course", Icons.library_add),
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          TextField(controller: courseTitle, decoration: adminInput("Title")),
                          const SizedBox(height: 10),
                          TextField(controller: courseDesc, decoration: adminInput("Description")),
                          const SizedBox(height: 15),
                          SizedBox(width: double.infinity, child: ElevatedButton(onPressed: addCourse, style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white), child: const Text("Add Course"))),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  // ENROLLMENT
                  sectionHeader("Enroll Student", Icons.link),
                  Card(
                    elevation: 4,
                    color: Colors.indigo.shade50,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Row(children: [
                            Expanded(child: TextField(controller: assignSid, decoration: adminInput("Student ID"), keyboardType: TextInputType.number)),
                            const SizedBox(width: 10),
                            Expanded(child: TextField(controller: assignCid, decoration: adminInput("Course ID"), keyboardType: TextInputType.number)),
                          ]),
                          const SizedBox(height: 15),
                          SizedBox(width: double.infinity, child: ElevatedButton(onPressed: assignCourse, style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white), child: const Text("Enroll Student"))),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                  // STUDENT LIST
                  sectionHeader("Student Records", Icons.people),
                  ...students.map((s) => Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: CircleAvatar(backgroundColor: Colors.indigo, child: Text("${s["id"]}", style: const TextStyle(color: Colors.white))),
                      title: Text(s["name"] ?? "", style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(s["email"] ?? ""),
                      trailing: IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: () => deleteStudent(s["id"])),
                    ),
                  )),

                  const SizedBox(height: 20),
                  // COURSE LIST
                  sectionHeader("Course Records", Icons.book),
                  ...courses.map((c) => Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: CircleAvatar(backgroundColor: Colors.amber.shade700, child: Text("${c["id"]}", style: const TextStyle(color: Colors.white))),
                      title: Text(c["title"] ?? "", style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(
                        c["students"] != null && c["students"].length > 0
                        ? c["students"].map<String>((s) => s["name"].toString()).join(", ")
                        : "No Students Enrolled",
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                      ),
                      trailing: IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: () => deleteCourse(c["id"])),
                    ),
                  )),
                ],
              ),
            ),
    );
  }
}