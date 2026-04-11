import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user.dart';
import '../utils/toast.dart';

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
      backgroundColor: Colors.white, // 改为纯白背景，更简约
      appBar: AppBar(
        title: const Text("个人中心"),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          children: [
            const SizedBox(height: 40),
            // --- 上部分：个人信息展示 ---
            Center(
              child: Column(
                children: [
                  // 头像
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.blue.withValues(alpha: 0.1),
                        width: 5,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.blue[50],
                      backgroundImage:
                          (user?.avatar != null && user!.avatar.isNotEmpty)
                          ? NetworkImage(user.avatar)
                          : null,
                      child: (user?.avatar == null || user!.avatar.isEmpty)
                          ? Icon(
                              Icons.person,
                              size: 50,
                              color: Colors.blue[200],
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // 名称
                  Text(
                    user?.name ?? '未设置昵称',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // 手机号
                  Text(
                    user?.phone ?? '---',
                    style: TextStyle(color: Colors.grey[500], fontSize: 15),
                  ),
                  const SizedBox(height: 25),
                  // 修改资料按钮
                  SizedBox(
                    width: 120,
                    child: OutlinedButton(
                      onPressed: () {
                        Tip.show("功能开发中");
                      },
                      style: OutlinedButton.styleFrom(
                        shape: StadiumBorder(), // 圆角矩形
                        side: BorderSide(
                          color: Colors.blue.withValues(alpha: 0.5),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      child: const Text("修改资料", style: TextStyle(fontSize: 14)),
                    ),
                  ),
                ],
              ),
            ),

            // --- 中间：填充空白 ---
            const Spacer(),

            // --- 下部分：退出登录 ---
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: TextButton.icon(
                    onPressed: () => _confirmLogout(context, userStore),
                    icon: const Icon(Icons.logout_rounded, color: Colors.red),
                    label: const Text(
                      "退出登录",
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.red.withValues(alpha: 0.05),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
