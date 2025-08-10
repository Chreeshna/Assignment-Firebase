import 'package:app/home_page.dart';
import 'package:app/signup_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class Login extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    var _mediaQuery = MediaQuery.of(context);

    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: _mediaQuery.size.height * 0.09),
                  Text(
                    'App',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 76, 152, 175),
                    ),
                  ),
                  SizedBox(height: _mediaQuery.size.height * 0.02),
                  const Text('Welcome!',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20)),
                  SizedBox(height: _mediaQuery.size.height * 0.02),
                  const Text('Login',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16)),
                  SizedBox(height: _mediaQuery.size.height * 0.04),

                  // Google Sign-In
                  OutlinedButton.icon(
                    icon: Icon(Icons.g_mobiledata),
                    label: Text('Login with Google'),
                    onPressed: () async {
                      await _signInWithGoogle(context);
                    },
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                    ),
                  ),

                  SizedBox(height: _mediaQuery.size.height * 0.03),

                  _outlinedInputField(
                    controller: _emailController,
                    label: 'Email',
                    icon: Icons.email,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                          .hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: _mediaQuery.size.height * 0.02),
                  _outlinedInputField(
                    controller: _passwordController,
                    label: 'Password',
                    icon: Icons.lock,
                    obscure: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/forgot-password');
                      },
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ),
                  SizedBox(height: _mediaQuery.size.height * 0.01),
                  ElevatedButton.icon(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        await _signInWithEmailAndPassword(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      minimumSize: const Size.fromHeight(50),
                    ),
                    icon: Icon(Icons.person, color: Colors.white),
                    label: const Text("Login",
                        style: TextStyle(color: Colors.white)),
                  ),
                  SizedBox(height: _mediaQuery.size.height * 0.02),
                  TextButton(
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (_) => SignUpPage()));
                    },
                    child: const Text("Don't have an account? Sign Up"),
                  ),
                  SizedBox(height: _mediaQuery.size.height * 0.07),
                  const Text(
                    "By signing in, you agree to our Terms of Service and Privacy Policy.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _outlinedInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32)),
      ),
    );
  }

  Future<void> _signInWithEmailAndPassword(BuildContext context) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomePage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: ${e.toString()}')),
      );
    }
  }

  Future<void> _signInWithGoogle(BuildContext context) async {
    try {
      if (kIsWeb) {
        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.setCustomParameters({
          'login_hint': 'user@example.com', // optional hint
        });

        await FirebaseAuth.instance.signInWithPopup(googleProvider);
      } else {
        // Mobile sign-in using GoogleSignIn
        final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
        if (googleUser == null) return; // User canceled

        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        await _auth.signInWithCredential(credential);
      }

      // Navigate to your original HomePage after login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomePage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google Sign-In failed: ${e.toString()}')),
      );
    }
  }
}
