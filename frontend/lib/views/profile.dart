import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user.dart';
import '../utils/toast.dart'; // 别忘了用你刚写的 Tip 工具

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  void _confirmLogout(BuildContext context, UserProvider userStore) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("确认退出"),
        content: const Text("您确定要退出登录吗？"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("取消", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              await userStore.logout();
              if (context.mounted) {
                Tip.show("已成功退出");
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              }
            },
            child: const Text(
              "退出",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;
    final userStore = context.read<UserProvider>();

    return Scaffold(
      backgroundColor: Colors.grey[100], // 1. 页面底色设为浅灰
      appBar: AppBar(
        title: const Text("个人中心"),
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 2. 顶部头部卡片
          Container(
            color: Colors.white,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 30),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.blue[50],
                    backgroundImage:
                        (user?.avatar != null && user!.avatar.isNotEmpty)
                        ? NetworkImage(user.avatar)
                        : null,
                    child: (user?.avatar == null || user!.avatar.isEmpty)
                        ? Icon(Icons.person, size: 45, color: Colors.blue[200])
                        : null,
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  user?.name ?? '未设置昵称',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  user?.phone ?? '---',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),

          // 3. 菜单列表部分
          Expanded(
            child: ListView(
              children: [
                _buildMenuTile(Icons.security, "账号安全", () {}),
                _buildMenuTile(Icons.notifications_none, "消息通知", () {}),
                _buildMenuTile(Icons.help_outline, "帮助与反馈", () {}),
                const SizedBox(height: 30),
                // 退出登录按钮
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ElevatedButton(
                    onPressed: () => _confirmLogout(context, userStore),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.red,
                      elevation: 0,
                      side: BorderSide(
                        color: Colors.red.withValues(alpha: 0.3),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text("退出当前账号", style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 抽离的列表项组件，方便复用
  Widget _buildMenuTile(IconData icon, String title, VoidCallback onTap) {
    return Container(
      color: Colors.white,
      child: ListTile(
        leading: Icon(icon, color: Colors.blue[400], size: 22),
        title: Text(title, style: const TextStyle(fontSize: 15)),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
        onTap: onTap,
      ),
    );
  }
}
