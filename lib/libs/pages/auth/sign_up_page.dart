import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../samples/home_page.dart';
import 'login_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  String _error = '';
  bool _showPassword = false;
  final _supabase = Supabase.instance.client;

  Future<void> _handleSignUp() async {
    setState(() => _error = '');

    if (!_formKey.currentState!.validate()) return;

    try {
      final AuthResponse response = await _supabase.auth.signUp(
        email: _email,
        password: _password,
      );

      if (response.user != null) {
        if (mounted) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage()));
        }
      }
    } on AuthException catch (e) {
      setState(() => _error = 'Ro‘yxatdan o‘tishda xatolik: ${e.message}');
    } catch (e) {
      setState(() => _error = 'Kutilmagan xatolik: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE3F2FD), Color(0xFFC7D2FE)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: EdgeInsets.all(32.r),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.person_add, color: Colors.indigo, size: 48),
                    SizedBox(height: 16.h),
                    const Text('Create Account', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8.h),
                    Text('Sign up to continue', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                    SizedBox(height: 24.h),
                    if (_error.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          border: Border(left: BorderSide(color: Colors.red[400]!, width: 4)),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(_error, style: TextStyle(color: Colors.red[700], fontSize: 14)),
                      ),
                    if (_error.isNotEmpty) SizedBox(height: 16.h),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            decoration: InputDecoration(
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.r)),
                              labelText: 'Email address',
                              prefixIcon: const Icon(Icons.mail_outline),
                              hintText: 'you@example.com',
                              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey[300]!)),
                              focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.indigo)),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Emailni kiriting';
                              if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) return 'Yaroqli email kiriting';
                              return null;
                            },
                            onChanged: (value) => _email = value,
                          ),
                          SizedBox(height: 16.h),
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(_showPassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                                onPressed: () => setState(() => _showPassword = !_showPassword),
                              ),
                              hintText: '••••••••',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.r)),
                            ),
                            obscureText: !_showPassword,
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Parolni kiriting';
                              if (value.length < 8) return 'Parol kamida 8 ta belgidan iborat bo‘lishi kerak';
                              return null;
                            },
                            onChanged: (value) => _password = value,
                          ),
                          SizedBox(height: 16.h),
                          ElevatedButton(
                            onPressed: _handleSignUp,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigo,
                              foregroundColor: Colors.white,
                              minimumSize: Size(double.infinity, 48.h),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                            ),
                            child: const Text('Sign up'),
                          ),
                          SizedBox(height: 16.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Already have an account? ", style: TextStyle(color: Colors.grey[600])),
                              TextButton(
                                onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage())),
                                child: const Text('Sign in', style: TextStyle(color: Colors.indigo)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
