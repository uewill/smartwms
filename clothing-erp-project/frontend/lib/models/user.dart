class User {
  final String? id;
  final String? phone;
  final String? nickname;
  final String? avatar;
  final String? token;

  User({
    this.id,
    this.phone,
    this.nickname,
    this.avatar,
    this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String?,
      phone: json['phone'] as String?,
      nickname: json['nickname'] as String?,
      avatar: json['avatar'] as String?,
      token: json['token'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'nickname': nickname,
      'avatar': avatar,
      'token': token,
    };
  }

  User copyWith({
    String? id,
    String? phone,
    String? nickname,
    String? avatar,
    String? token,
  }) {
    return User(
      id: id ?? this.id,
      phone: phone ?? this.phone,
      nickname: nickname ?? this.nickname,
      avatar: avatar ?? this.avatar,
      token: token ?? this.token,
    );
  }
}
