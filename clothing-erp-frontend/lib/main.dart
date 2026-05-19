import 'package:flutter/material.dart';
import 'package:clothing_erp/app.dart';
import 'package:clothing_erp/utils/storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageUtil.init();
  runApp(const ClothingErpApp());
}
