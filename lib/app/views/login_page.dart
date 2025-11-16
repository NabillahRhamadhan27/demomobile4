import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailC = TextEditingController();
  final passC = TextEditingController();
  final authC = Get.find<AuthController>();
  final isLoading = false.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login / Register')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: emailC,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: passC,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),

            const SizedBox(height: 20),

            Obx(
              () => ElevatedButton(
                onPressed: isLoading.value
                    ? null
                    : () async {
                        isLoading.value = true;

                        try {
                          await authC.signIn(
                            emailC.text.trim(),
                            passC.text.trim(),
                          );
                          Get.snackbar("Sukses", "Berhasil login!");
                          // after login navigate to home
                          Get.offAllNamed('/');
                        } catch (e) {
                          Get.snackbar("Error Login", e.toString());
                        } finally {
                          isLoading.value = false;
                        }
                      },
                child: isLoading.value
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text("Login"),
              ),
            ),

            const SizedBox(height: 8),

            TextButton(
              onPressed: () async {
                try {
                  await authC.signUp(emailC.text.trim(), passC.text.trim());
                  Get.snackbar(
                    "Sukses",
                    "Registrasi berhasil. Periksa email untuk verifikasi.",
                  );
                } catch (e) {
                  Get.snackbar("Error Register", e.toString());
                }
              },
              child: const Text("Register"),
            ),
          ],
        ),
      ),
    );
  }
}
