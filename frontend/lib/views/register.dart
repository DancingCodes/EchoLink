import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../utils/http.dart';
import '../utils/toast.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  File? _avatarFile;
  String? _uploadedAvatarUrl;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  Future<void> _pickAvatar() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _avatarFile = File(image.path);
        });
      }
    } catch (e) {
      Tip.show("选图失败");
    }
  }

  Future<String?> _uploadAvatarStream() async {
    if (_avatarFile == null) {
      Tip.show("没有选择头像");
      return null;
    }

    try {
      if (!await _avatarFile!.exists()) {
        Tip.show("头像文件不存在");
        return null;
      }
      final filePath = _avatarFile!.path;
      final fileName = p.basename(filePath);
      final fileData = await MultipartFile.fromFile(
        _avatarFile!.path,
        filename: fileName,
      );
      final formData = FormData.fromMap({'file': fileData});
      final res = await HttpClient.instance.post('/upload', data: formData);
      return res.data['data']['url'];
    } catch (e) {
      Tip.show("上传头像失败");
    }
    return null;
  }

  void _doRegister() async {
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;
    final name = _nameController.text.trim();

    if (_avatarFile == null) {
      Tip.show("请上传头像");
      return;
    }

    if (name.isEmpty || phone.isEmpty || password.isEmpty) {
      Tip.show("请填写完整昵称、手机号和密码");
      return;
    }

    if (!RegExp(r'^1[3-9]\d{9}$').hasMatch(phone)) {
      Tip.show("手机号格式不正确");
      return;
    }

    setState(() => _isLoading = true);

    try {
      _uploadedAvatarUrl = await _uploadAvatarStream();

      await HttpClient.instance.post(
        '/user/register',
        data: {
          'name': name,
          'phone': phone,
          'password': password,
          'avatar': _uploadedAvatarUrl,
        },
      );

      if (mounted) {
        Tip.show("注册成功，请登录");
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) Navigator.pop(context);
        });
      }
    } catch (e) {
      Tip.show("注册失败");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("账号注册"), centerTitle: true),
      resizeToAvoidBottomInset: false,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
                            image: FileImage(_avatarFile!),
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
                  labelText: "设置密码",
                  prefixIcon: Icon(Icons.lock_outline),
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
