import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('我的'), centerTitle: true),
      body: Column(
        children: [
          const SizedBox(height: 40),
          const Center(
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey,
              child: Icon(Icons.person, size: 60, color: Colors.white),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "开发者用户",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 40),
          const ListTile(
            leading: Icon(Icons.storage),
            title: Text("数据统计"),
            trailing: Text("152 条记录"),
          ),
          const ListTile(leading: Icon(Icons.settings), title: Text("系统设置")),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text("关于 AI 记事本"),
          ),
        ],
      ),
    );
  }
}
