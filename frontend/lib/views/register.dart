import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../utils/http.dart';
import 'package:dio/dio.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // 1. 定义 Controller
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController(); // 新增昵称

  File? _avatarFile; // 用于在 UI 展示本地选中的图片
  String? _uploadedAvatarUrl; // 用于存储后端返回的 URL
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  // 2. 选图方法
  Future<void> _pickAvatar() async {
    try {
      // 调用相册 (Source 可以改为摄像头 ImageSource.camera)
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 500, // 限制图片大小，节省带宽
        imageQuality: 80, // 压缩质量
      );

      if (image != null) {
        setState(() {
          _avatarFile = File(image.path); // 更新 UI
        });
      }
    } catch (e) {
      debugPrint("选图失败: $e");
      _showLocalMsg("选图失败，请检查相册权限");
    }
  }

  // 3. 核心：分步上传逻辑
  Future<String?> _uploadAvatarStream() async {
    if (_avatarFile == null) {
      debugPrint("DEBUG: [Upload] 没选图片，跳过");
      return null;
    }

    try {
      debugPrint("DEBUG: [Upload] 开始读取文件: ${_avatarFile!.path}");

      // 检查文件是否存在
      if (!await _avatarFile!.exists()) {
        debugPrint("DEBUG: [Upload] 错误：文件不存在！");
        return null;
      }

      final fileData = await MultipartFile.fromFile(
        _avatarFile!.path,
        filename: 'avatar.jpg',
      );
      debugPrint("DEBUG: [Upload] MultipartFile 读取成功");

      final formData = FormData.fromMap({'file': fileData});

      debugPrint("DEBUG: [Upload] 准备发起 POST /upload 请求...");

      // 注意：这里如果没打印，说明 HttpClient.instance 初始化崩了
      final res = await HttpClient.instance.post('/upload', data: formData);

      debugPrint("DEBUG: [Upload] 后端返回原始数据: ${res.data}");

      if (res.data['code'] == 200) {
        return res.data['data']['url'];
      }
    } catch (e) {
      debugPrint("DEBUG: [Upload] 抛出异常: $e");
    }
    return null;
  }

  void _doRegister() async {
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    final name = _nameController.text.trim();

    // 1. 本地校验 (增加 Name 和头像的判断)
    if (name.isEmpty || phone.isEmpty || password.isEmpty) {
      _showLocalMsg("请填写完整昵称、手机号和密码");
      return;
    }

    // 强制要求上传头像 (根据你后端设计，也可以设为可选)
    if (_avatarFile == null) {
      _showLocalMsg("请上传头像");
      return;
    }

    if (!RegExp(r'^1[3-9]\d{9}$').hasMatch(phone)) {
      _showLocalMsg("手机号格式不正确");
      return;
    }

    if (password != confirmPassword) {
      _showLocalMsg("两次输入的密码不一致");
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 2. Step A: 先传图片，拿 URL
      // 拦截器已经帮你弹了红色提示框，这里处理业务
      _uploadedAvatarUrl = await _uploadAvatarStream();

      // 如果强制上传图片，这里可以加判断
      // if (_uploadedAvatarUrl == null) { throw Exception("头像上传失败"); }

      // 3. Step B: 对接 Go 后端 Register, 包含 Name 和 Avatar URL
      await HttpClient.instance.post(
        '/user/register',
        data: {
          'name': name, // 匹配 Go 的 json:"name"
          'phone': phone,
          'password': password,
          'avatar': _uploadedAvatarUrl ?? '', // 匹配 Go 的 json:"avatar"
        },
      );

      // 4. 注册成功
      if (mounted) {
        _showLocalMsg("注册成功，请登录", isError: false);
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) Navigator.pop(context);
        });
      }
    } catch (e) {
      debugPrint("注册异常: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showLocalMsg(String msg, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.orange : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("账号注册")),
      // 使用 SingleChildScrollView 防止键盘遮挡，同时让内容居中
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // --- 头像上传组件 ---
              GestureDetector(
                onTap: _pickAvatar,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.blue[100]!, width: 2),
                    image: _avatarFile != null
                        ? DecorationImage(
                            image: FileImage(_avatarFile!), // 显示本地文件
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _avatarFile == null
                      ? Icon(
                          Icons.add_a_photo,
                          size: 40,
                          color: Colors.blue[300],
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 10),
              const Text("点击上传头像", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 30),

              // --- 昵称输入框 ---
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "个性昵称",
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
                maxLength: 20,
              ),
              const SizedBox(height: 20),

              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: "手机号",
                  prefixIcon: Icon(Icons.phone_iphone),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                maxLength: 11,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "设置密码(至少6位)",
                  prefixIcon: Icon(Icons.lock_outline),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "确认密码",
                  prefixIcon: Icon(Icons.lock_reset),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _doRegister,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text("立即注册"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
