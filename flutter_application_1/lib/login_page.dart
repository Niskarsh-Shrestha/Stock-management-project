import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'manager_home_page.dart';
import 'employee_home_page.dart';
import 'admin_home_page.dart';
import 'data_analyst_home_page.dart';
import 'env.dart';
import 'http_client.dart';
import 'session.dart';

final OutlineInputBorder roundedBorder = OutlineInputBorder(
  borderRadius: BorderRadius.circular(12),
  borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 1.5),
);

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController loginIdController = TextEditingController(); // for email or username
  final TextEditingController passwordController = TextEditingController();
  bool _obscurePassword = true;

  List<String> roles = [];
  String? selectedRole;

  final TextEditingController forgotEmailController = TextEditingController();
  final TextEditingController codeController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  late final http.Client _client;

  @override
  void initState() {
    super.initState();
    _client = createHttpClient();
    fetchRoles().then((roleList) {
      setState(() {
        roles = roleList;
        selectedRole = null; // No default role selected
      });
    });
  }

  Future<void> loginUser() async {
    if (loginIdController.text.isEmpty || passwordController.text.isEmpty || selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields and select a role')),
      );
      return;
    }

    final user = loginIdController.text.trim();
    final pass = passwordController.text;

    final res = await http.post(
      Uri.parse('${Env.baseUrl}/login.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': user,
        'password': pass,
        'role': selectedRole, // <-- add this line
      }),
    );
    final data = jsonDecode(res.body);

    if (data['success'] == true && data['require_2fa'] == true) {
      show2FADialog(data['email']);
    } else if (data['success'] == true) {
      // Proceed to home page
      final String username = data['username'];
      final String email = data['email'];
      final String role = data['role'];

      Session.sid = data['sid'] as String?;

      if (role == 'manager') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ManagerHomePage(
              username: username,
              email: email,
              role: role,
            ),
          ),
        );
      } else if (role == 'employee') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => EmployeeHomePage(
              username: username,
              email: email,
              role: role,
            ),
          ),
        );
      } else if (role == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => AdminHomePage(
              username: username,
              email: email,
              role: role,
            ),
          ),
        );
      } else if (role == 'data analyst') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => DataAnalystHomePage(
              username: username,
              email: email,
              role: role,
            ),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data['message'] ?? 'Login failed')),
      );
    }
  }

  void show2FADialog(String email) {
    final codeController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Verification Code'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: codeController,
              decoration: const InputDecoration(labelText: '4-digit code'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () async {
                await resendLoginCode(email);
              },
              child: const Text('Resend Code'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await verifyLoginCode(email, codeController.text.trim());
            },
            child: const Text('Verify'),
          ),
        ],
      ),
    );
  }

  Future<void> resendLoginCode(String emailOrUsername) async {
    final response = await http.post(
      Uri.parse('${Env.baseUrl}/resend_login_code.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': emailOrUsername}), // or {'username': emailOrUsername}
    );
    final data = jsonDecode(response.body);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(data['message'] ?? 'Could not resend code')),
    );
  }

  Future<void> verifyLoginCode(String email, String code) async {
    final response = await http.post(
      Uri.parse('${Env.baseUrl}/verify_login_code.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'code': code}),
    );
    final data = jsonDecode(response.body);
    if (data['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login successful!')),
      );
      // Use backend response for navigation
      final String username = data['username'];
      final String email = data['email'];
      final String role = data['role'];

      Session.sid = data['sid'] as String?;

      if (role == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => AdminHomePage(
              username: username,
              email: email,
              role: role,
            ),
          ),
        );
      } else if (role == 'data_analyst') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => DataAnalystHomePage(
              username: username,
              email: email,
              role: role,
            ),
          ),
        );
      } else if (role == 'manager') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ManagerHomePage(
              username: username,
              email: email,
              role: role,
            ),
          ),
        );
      } else if (role == 'employee') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => EmployeeHomePage(
              username: username,
              email: email,
              role: role,
            ),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data['message'] ?? 'Verification failed')),
      );
    }
  }

  // Show forgot password dialog
  void showForgotPasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Forgot Password'),
        content: TextField(
          controller: forgotEmailController,
          decoration: const InputDecoration(labelText: 'Enter your email'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await sendCodeToEmail();
            },
            child: const Text('Send Code'),
          ),
        ],
      ),
    );
  }

  Future<void> sendCodeToEmail() async {
    final email = forgotEmailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email')),
      );
      return;
    }
    final url = Uri.parse('${Env.baseUrl}/forgot_password.php');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );
    final data = jsonDecode(response.body);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(data['message'] ?? 'Check your email for the code')),
    );
    if (data['success'] == true) {
      showCodeDialog(email);
    }
  }

  void showCodeDialog(String email) {
    final codeController = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Verify Code'),
        content: TextField(
          controller: codeController,
          decoration: const InputDecoration(labelText: 'Enter verification code'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await verifyCode(email, codeController.text.trim());
            },
            child: const Text('Verify'),
          ),
        ],
      ),
    );
  }

  Future<void> resendForgotCode(String emailOrUsername) async {
    final response = await http.post(
      Uri.parse('${Env.baseUrl}/resend_forgot_code.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': emailOrUsername}), // or {'username': emailOrUsername}
    );
    final data = jsonDecode(response.body);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(data['message'] ?? 'Could not resend forgot code')),
    );
  }

  Future<void> verifyCode(String email, String code) async {
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the code')),
      );
      return;
    }
    final url = Uri.parse('${Env.baseUrl}/verify_code.php');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'code': code}),
    );
    final data = jsonDecode(response.body);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(data['message'] ?? 'Verification failed')),
    );
    if (data['success'] == true) {
      showResetPasswordDialog(email);
    }
  }

  void showResetPasswordDialog(String email) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: newPasswordController,
              decoration: const InputDecoration(labelText: 'New Password'),
              obscureText: true,
            ),
            TextField(
              controller: confirmPasswordController,
              decoration: const InputDecoration(labelText: 'Confirm Password'),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await resetPassword(email);
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  Future<void> resetPassword(String email) async {
    final newPassword = newPasswordController.text;
    final confirmPassword = confirmPasswordController.text;
    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill both password fields')),
      );
      return;
    }
    if (newPassword != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }
    final url = Uri.parse('${Env.baseUrl}/reset_password.php');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'new_password': newPassword}),
    );
    final data = jsonDecode(response.body);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(data['message'] ?? 'Password reset failed')),
    );
  }

  Future<List<String>> fetchRoles() async {
    final response = await http.get(
      Uri.parse('${Env.baseUrl}/get_roles.php'),
    );
    final data = jsonDecode(response.body);
    final List<String> fetchedRoles = List<String>.from(data['roles'].map((role) => role['role_name'].toString()));
    print(fetchedRoles); // <-- Add this line here
    return fetchedRoles;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Page', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF4F46E5),
        iconTheme: const IconThemeData(color: Color(0xFFFFFFFF)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextFormField(
              controller: loginIdController,
              decoration: InputDecoration(
                labelText: 'Email Address or Username',
                border: roundedBorder,
                enabledBorder: roundedBorder,
                focusedBorder: roundedBorder,
              ),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: selectedRole,
              hint: const Text('Select Role'),
              items: roles.map((role) {
                return DropdownMenuItem<String>(
                  value: role,
                  child: Text(role),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedRole = value;
                });
              },
              decoration: InputDecoration(
                labelText: 'Role',
                border: roundedBorder,
                enabledBorder: roundedBorder,
                focusedBorder: roundedBorder,
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Password',
                border: roundedBorder,
                enabledBorder: roundedBorder,
                focusedBorder: roundedBorder,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: const Color(0xFF9E9E9E),
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: loginUser,
              child: const Text('LOG IN', style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: showForgotPasswordDialog,
                child: const Text('Forgot Password?'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
