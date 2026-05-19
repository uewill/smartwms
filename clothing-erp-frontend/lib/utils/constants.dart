enum PaymentMethod {
  cash('cash', '现金'),
  wechat('wechat', '微信'),
  alipay('alipay', '支付宝'),
  credit('credit', '赊账');

  final String value;
  final String label;
  const PaymentMethod(this.value, this.label);

  static PaymentMethod fromValue(String value) {
    return PaymentMethod.values.firstWhere(
      (e) => e.value == value,
      orElse: () => PaymentMethod.cash,
    );
  }
}

enum Season {
  spring('spring', '春'),
  summer('summer', '夏'),
  autumn('autumn', '秋'),
  winter('winter', '冬'),
  allSeason('all', '四季');

  final String value;
  final String label;
  const Season(this.value, this.label);

  static Season fromValue(String value) {
    return Season.values.firstWhere(
      (e) => e.value == value,
      orElse: () => Season.allSeason,
    );
  }
}

class SizePresets {
  static const List<String> sM = ['S', 'M', 'L', 'XL', 'XXL'];
  static const List<String> numeric2638 = [
    '26', '27', '28', '29', '30', '31', '32', '33', '34', '35', '36', '37', '38'
  ];
  static const List<String> numeric3846 = [
    '38', '39', '40', '41', '42', '43', '44', '45', '46'
  ];
  static const List<String> kidsHeight = [
    '100', '110', '120', '130', '140', '150', '160'
  ];
  static const List<String> pantsSize = [
    '26', '27', '28', '29', '30', '31', '32', '33', '34'
  ];

  static const Map<String, List<String>> allPresets = {
    'S-XXL': sM,
    '26-38': numeric2638,
    '38-46': numeric3846,
    '童装尺码': kidsHeight,
    '裤装尺码': pantsSize,
  };
}

class ColorPresets {
  static const List<String> commonColors = [
    '黑色', '白色', '红色', '蓝色', '灰色', '绿色',
    '黄色', '粉色', '紫色', '橙色', '棕色', '卡其色',
    '藏青', '米白', '酒红', '墨绿',
  ];
}

class PlanType {
  static const String free = 'free';
  static const String basic = 'basic';
  static const String pro = 'pro';

  static const Map<String, String> labels = {
    free: '免费版',
    basic: '基础版',
    pro: '专业版',
  };

  static String getLabel(String type) {
    return labels[type] ?? '未知';
  }
}

class FeatureKeys {
  static const String hotRanking = 'hot_ranking';
  static const String overstockWarning = 'overstock_warning';
  static const String customerDebt = 'customer_debt';
  static const String profitAnalysis = 'profit_analysis';
  static const String multiShop = 'multi_shop';
  static const String staffManagement = 'staff_management';
}
