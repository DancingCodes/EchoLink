import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/http.dart';
import '../models/user_provider.dart';
import '../models/user.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});
  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  void _doLogin() async {
    try {
      final res = await HttpClient.instance.post(
        '/login',
        data: {
          'username': _usernameController.text,
          'password': _passwordController.text,
        },
      );

      if (res.data['code'] == 200) {
        final String token = res.data['data']['token'];
        // 将数据保存到全局 Store
        if (mounted) {
          Provider.of<UserProvider>(context, listen: false).login(
            token,
            UserModel(username: _usernameController.text), // 假设你有对应的 Model
          );
          Navigator.pushReplacementNamed(context, '/home');
        }
      }
    } catch (e) {
      // 这里的错误会被 HttpClient 的拦截器或这里的 catch 捕获
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("登录 EchoLink")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: "用户名"),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "密码"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _doLogin, child: const Text("登录")),
          ],
        ),
      ),
    );
  }
}
