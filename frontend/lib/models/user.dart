class UserModel {
  final int id;
  final String phone;
  final String name;
  final String sex;
  final String avatar;

  UserModel({
    this.id = 0,
    this.phone = '',
    this.name = '',
    this.sex = '',
    this.avatar = '',
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['ID'] ?? 0,
      phone: json['phone'] ?? '',
      name: json['name'] ?? '',
      sex: json['sex'] ?? '',
      avatar: json['avatar'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'phone': phone,
      'name': name,
      'sex': sex,
      'avatar': avatar,
    };
  }
}
