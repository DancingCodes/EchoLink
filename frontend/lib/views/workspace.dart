import 'package:flutter/material.dart';

class WorkspacePage extends StatelessWidget {
  const WorkspacePage({super.key});

  // 模拟一些初始展示数据
  final List<Map<String, String>> mockData = const [
    {"title": "买咖啡", "subtitle": "账单 | ￥30.00", "icon": "money"},
    {"title": "整理项目文档", "subtitle": "待办 | 14:00 截止", "icon": "todo"},
    {"title": "灵感：做一个AI记事本", "subtitle": "随笔", "icon": "memo"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('工作区'), centerTitle: true),
      body: ListView.builder(
        itemCount: mockData.length,
        padding: const EdgeInsets.all(12),
        itemBuilder: (context, index) {
          final item = mockData[index];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue.shade50,
                child: Icon(_getIcon(item['icon']!), color: Colors.blue),
              ),
              title: Text(
                item['title']!,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(item['subtitle']!),
            ),
          );
        },
      ),
      // 右下角“说”按钮
      floatingActionButton: GestureDetector(
        onLongPressStart: (_) => _showRecordingDialog(context),
        onLongPressEnd: (_) => Navigator.pop(context),
        child: FloatingActionButton.extended(
          onPressed: () {}, // 仅点击不触发，主要靠长按
          label: const Text('说'),
          icon: const Icon(Icons.mic),
        ),
      ),
    );
  }

  // 根据分类显示图标
  IconData _getIcon(String type) {
    if (type == 'money') return Icons.attach_money;
    if (type == 'todo') return Icons.checklist;
    return Icons.edit_note;
  }

  // 模拟长按时的录音提示框
  void _showRecordingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.mic, size: 50, color: Colors.red),
                SizedBox(height: 10),
                Text("正在倾听...", style: TextStyle(fontSize: 18)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
