// lib/views/auth.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/http.dart';
import '../utils/toast.dart';
import '../providers/user.dart';
import '../models/user.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  void _doLogin() async {
    if (_phoneController.text.isEmpty || _passwordController.text.isEmpty) {
      Tip.show("手机号和密码不能为空");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final res = await HttpClient.instance.post(
        '/user/login',
        data: {
          'phone': _phoneController.text,
          'password': _passwordController.text,
        },
      );

      if (!mounted) return;
      final data = res.data['data'];
      final userProvider = context.read<UserProvider>();

      await userProvider.setToken(data['token']);
      await userProvider.setUser(UserModel.fromJson(data['user']));

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      Tip.show("登录失败");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("登录 EchoLink"), centerTitle: true),
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.rocket_launch, size: 80, color: Colors.blue),
            const SizedBox(height: 40),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: "手机号",
                prefixIcon: Icon(Icons.phone_iphone),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "密码",
                prefixIcon: Icon(Icons.lock_outline),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _doLogin,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text("立即登录", style: TextStyle(fontSize: 16)),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/register');
              },
              child: const Text("还没有账号？立即注册"),
            ),
          ],
        ),
      ),
    );
  }
}
