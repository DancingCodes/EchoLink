import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  // 弹窗确认退出
  void _confirmLogout(BuildContext context, UserProvider userStore) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("确认退出"),
        content: const Text("您确定要退出登录吗？"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("取消"),
          ),
          TextButton(
            onPressed: () async {
              // 1. 执行 Provider 的退出逻辑
              await userStore.logout();
              // 2. 关闭弹窗
              if (context.mounted) Navigator.pop(ctx);
              // 3. 跳转到登录页并清空路由栈（防止返回）
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              }
            },
            child: const Text("退出", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 建议 listen 设为 true，这样用户信息变化时 UI 会刷新
    final userStore = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("个人中心")), // 加上 AppBar 更好看
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 头像回显逻辑
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blue.shade100,
              backgroundImage:
                  (userStore.user?.avatar != null &&
                      userStore.user!.avatar.isNotEmpty)
                  ? NetworkImage(userStore.user!.avatar) // 如果后端返回了 URL
                  : null,
              child:
                  (userStore.user?.avatar == null ||
                      userStore.user!.avatar.isEmpty)
                  ? const Icon(Icons.person, size: 50, color: Colors.blue)
                  : null,
            ),
            const SizedBox(height: 20),
            Text(
              "当前用户: ${userStore.user?.name ?? '未登录'}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              "手机号: ${userStore.user?.phone ?? '---'}",
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 50),
            SizedBox(
              width: 200,
              height: 45,
              child: ElevatedButton.icon(
                onPressed: () => _confirmLogout(context, userStore),
                icon: const Icon(Icons.exit_to_app),
                label: const Text("退出登录"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade50,
                  foregroundColor: Colors.red,
                  side: BorderSide(color: Colors.red.shade200),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
