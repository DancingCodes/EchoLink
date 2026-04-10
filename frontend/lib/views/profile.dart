import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_provider.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final userStore = Provider.of<UserProvider>(context);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(radius: 40, child: Icon(Icons.person, size: 40)),
            const SizedBox(height: 10),
            Text("当前用户: ${userStore.user?.name ?? '未知'}"),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade50,
              ),
              onPressed: () {
                userStore.logout();
                Navigator.pushReplacementNamed(context, '/auth');
              },
              child: const Text("退出登录", style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }
}
