import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthController extends GetxController {
  final supabase = Supabase.instance.client;

  final Rx<User?> user = Rx<User?>(null);
  final RxBool isInitialized = false.obs;

  @override
  void onInit() {
    super.onInit();

    // Ambil user aktif kalau sudah login
    user.value = supabase.auth.currentUser;

    // Listen auth state changes
    supabase.auth.onAuthStateChange.listen((data) {
      // data is AuthStateChange event (event, session)
      user.value = supabase.auth.currentUser;
    });

    // small delay to allow initial auth state to settle
    Future.delayed(const Duration(milliseconds: 500), () {
      isInitialized.value = true;
    });
  }

  bool get isLoggedIn => user.value != null;

  // LOGIN
  Future<void> signIn(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      throw Exception("Email & password wajib diisi.");
    }

    final res = await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (res.user == null) {
      throw Exception("Login gagal.");
    }
    user.value = res.user;
  }

  // REGISTER
  Future<void> signUp(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      throw Exception("Email & password wajib diisi.");
    }

    final res = await supabase.auth.signUp(email: email, password: password);

    if (res.user == null) {
      // Note: Supabase returns user null if email confirmation required; still set session if provided.
      if (res.session == null) {
        throw Exception("Register gagal.");
      }
    }
    user.value = supabase.auth.currentUser;
  }

  // LOGOUT
  Future<void> signOut() async {
    await supabase.auth.signOut();
    user.value = null;
  }
}
