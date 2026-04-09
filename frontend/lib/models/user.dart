class UserModel {
  final int id;
  final String phone;
  final String name;
  final String sex;
  final String avatar;

  UserModel({
    required this.id,
    required this.phone,
    this.name = '',
    this.sex = '',
    this.avatar = '',
  });

  // 从 JSON 转换
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['ID'] ?? 0,
      phone: json['phone'] ?? '',
      name: json['name'] ?? '',
      sex: json['sex'] ?? '',
      avatar: json['avatar'] ?? '',
    );
  }
}
