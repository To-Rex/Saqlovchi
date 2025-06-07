import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import '../../../controllers/get_controller.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final GetController controller = Get.put(GetController());
    final formKey = GlobalKey<FormState>();
    final emailFocusNode = FocusNode();
    final passwordFocusNode = FocusNode();

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
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                padding: EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.indigo[100], shape: BoxShape.circle),
                      child: const Icon(Icons.lock, color: Colors.indigo, size: 24),
                    ),
                    SizedBox(height: 16),
                    const Text('Welcome back', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text(
                      'Sign in to your account',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    SizedBox(height: 24),
                    Obx(
                          () => controller.error.value.isNotEmpty
                          ? Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          border: Border(
                            left: BorderSide(color: Colors.red[400]!, width: 4),
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          controller.error.value,
                          style: TextStyle(color: Colors.red[700], fontSize: 14),
                        ),
                      )
                          : const SizedBox.shrink(),
                    ),
                    SizedBox(height: 16),
                    Form(
                      key: formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            focusNode: emailFocusNode,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
                              labelText: 'Email address',
                              prefixIcon: const Icon(Icons.mail_outline),
                              hintText: 'you@example.com',
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: const BorderSide(color: Colors.indigo),
                              ),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            onChanged: (value) {
                              if (value.contains('@gmail.com')) {
                                controller.email.value = value;
                              } else {
                                controller.email.value = '$value@gmail.com';
                              }
                            },
                            onFieldSubmitted: (value) {
                              FocusScope.of(context).requestFocus(passwordFocusNode);
                            },
                          ),
                          SizedBox(height: 16),
                          Obx(() => TextFormField(
                            focusNode: passwordFocusNode,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  controller.showPassword.value ? Icons.visibility_off : Icons.visibility,
                                  color: Colors.grey,
                                ),
                                onPressed: controller.toggleShowPassword,
                              ),
                              hintText: 'password',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: const BorderSide(color: Colors.indigo),
                              ),
                            ),
                            obscureText: !controller.showPassword.value,
                            onChanged: (value) => controller.password.value = value,
                            onFieldSubmitted: (value) {
                              if (value.length >= 6 && formKey.currentState!.validate()) {
                                controller.handleSubmit(context);
                              }
                            },
                          )),
                          SizedBox(height: 36),
                          ElevatedButton(
                            onPressed: () {
                              if (formKey.currentState!.validate()) {
                                controller.handleSubmit(context);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigo,
                              foregroundColor: Colors.white,
                              minimumSize: Size(double.infinity, 48),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('Sign in'),
                          ),
                          SizedBox(height: 16),
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