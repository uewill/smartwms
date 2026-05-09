class User {
  final String id;
  final int tenantId;
  final String phone;
  final String nickname;
  final String? avatar;
  final String? wechatOpenId;
  final int status;
  final DateTime? lastLoginAt;
  final DateTime createdAt;

  User({
    required this.id,
    required this.tenantId,
    required this.phone,
    required this.nickname,
    this.avatar,
    this.wechatOpenId,
    this.status = 1,
    this.lastLoginAt,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      tenantId: json['tenantId'] ?? 0,
      phone: json['phone'] ?? '',
      nickname: json['nickname'] ?? '',
      avatar: json['avatar'],
      wechatOpenId: json['wechatOpenId'],
      status: json['status'] ?? 1,
      lastLoginAt: json['lastLoginAt'] != null ? DateTime.parse(json['lastLoginAt']) : null,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'tenantId': tenantId,
    'phone': phone,
    'nickname': nickname,
    'avatar': avatar,
    'wechatOpenId': wechatOpenId,
    'status': status,
  };
}

class Tenant {
  final int id;
  final String name;
  final String phone;
  final String? logo;
  final String? address;
  final int status;

  Tenant({
    required this.id,
    required this.name,
    required this.phone,
    this.logo,
    this.address,
    this.status = 1,
  });

  factory Tenant.fromJson(Map<String, dynamic> json) {
    return Tenant(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      logo: json['logo'],
      address: json['address'],
      status: json['status'] ?? 1,
    );
  }
}

class Staff {
  final String id;
  final int tenantId;
  final String? userId;
  final String name;
  final String phone;
  final String? email;
  final int level;
  final List<String>? permissions;
  final String status;
  final String? nickname;
  final String? remark;
  final String? wechatOpenId;
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  Staff({
    required this.id,
    required this.tenantId,
    this.userId,
    required this.name,
    required this.phone,
    this.email,
    this.level = 3,
    this.permissions,
    this.status = 'active',
    this.nickname,
    this.remark,
    this.wechatOpenId,
    required this.createdAt,
    this.lastLoginAt,
  });

  factory Staff.fromJson(Map<String, dynamic> json) {
    List<String>? perms;
    if (json['permissions'] != null) {
      if (json['permissions'] is String) {
        perms = (json['permissions'] as String).split(',');
      } else if (json['permissions'] is List) {
        perms = List<String>.from(json['permissions']);
      }
    }
    return Staff(
      id: json['id']?.toString() ?? '',
      tenantId: json['tenantId'] ?? 0,
      userId: json['userId']?.toString(),
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'],
      level: json['level'] ?? 3,
      permissions: perms,
      status: json['status'] ?? 'active',
      nickname: json['nickname'],
      remark: json['remark'],
      wechatOpenId: json['wechatOpenId'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      lastLoginAt: json['lastLoginAt'] != null ? DateTime.parse(json['lastLoginAt']) : null,
    );
  }

  String get levelName {
    switch (level) {
      case 1: return '超级管理员';
      case 2: return '管理员';
      case 3: return '操作员';
      case 4: return '查看者';
      default: return '未知';
    }
  }

  bool hasPermission(String permission) {
    if (permissions == null) return false;
    if (permissions!.contains('*')) return true;
    return permissions!.contains(permission);
  }

  bool get isSuperAdmin => level == 1;
  bool get isAdmin => level == 2 || level == 1;

  bool get canManageProduct => level <= 2;
  bool get canManageWarehouse => level <= 2;
  bool get canInbound => level <= 3;
  bool get canOutbound => level <= 3;
  bool get canViewReport => true;
  bool get canManageStaff => level == 1;
}

class AuthResult {
  final String token;
  final User user;
  final Staff? staff;
  final Tenant? tenant;

  AuthResult({
    required this.token,
    required this.user,
    this.staff,
    this.tenant,
  });

  factory AuthResult.fromJson(Map<String, dynamic> json) {
    return AuthResult(
      token: json['token'] ?? '',
      user: User.fromJson(json['user'] ?? {}),
      staff: json['staff'] != null ? Staff.fromJson(json['staff']) : null,
      tenant: json['tenant'] != null ? Tenant.fromJson(json['tenant']) : null,
    );
  }
}

class OperationLog {
  final String id;
  final int tenantId;
  final String? staffId;
  final String? staffName;
  final String type;
  final String action;
  final String detail;
  final String? ip;
  final DateTime createdAt;

  OperationLog({
    required this.id,
    required this.tenantId,
    this.staffId,
    this.staffName,
    required this.type,
    required this.action,
    required this.detail,
    this.ip,
    required this.createdAt,
  });

  factory OperationLog.fromJson(Map<String, dynamic> json) {
    return OperationLog(
      id: json['id']?.toString() ?? '',
      tenantId: json['tenantId'] ?? 0,
      staffId: json['staffId']?.toString(),
      staffName: json['staffName'],
      type: json['type'] ?? '',
      action: json['action'] ?? '',
      detail: json['detail'] ?? '',
      ip: json['ip'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
  }
}
