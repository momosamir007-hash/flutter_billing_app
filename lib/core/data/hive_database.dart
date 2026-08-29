import 'package:hive_flutter/hive_flutter.dart';
import '../../features/product/data/models/product_model.dart';
import '../../features/shop/data/models/shop_model.dart';
// السطر الجديد لاستدعاء نموذج الفاتورة (الذي سننشئه في الخطوة القادمة)
import '../../features/billing/data/models/sale_model.dart';

class HiveDatabase {
  static const String productBoxName = 'products';
  static const String shopBoxName = 'shop';
  static const String settingsBoxName = 'settings';
  // اسم الصندوق الجديد الخاص بالمبيعات
  static const String saleBoxName = 'sales';

  static Future<void> init() async {
    await Hive.initFlutter();

    // Register Adapters
    Hive.registerAdapter(ProductModelAdapter());
    Hive.registerAdapter(ShopModelAdapter());
    
    // تسجيل محولات الفواتير ومحتوياتها
    Hive.registerAdapter(SaleModelAdapter());
    Hive.registerAdapter(SaleItemModelAdapter());

    // Open Boxes
    await Hive.openBox<ProductModel>(productBoxName);
    await Hive.openBox<ShopModel>(shopBoxName);
    await Hive.openBox(settingsBoxName); 
    
    // فتح صندوق المبيعات
    await Hive.openBox<SaleModel>(saleBoxName);
  }

  static Box<ProductModel> get productBox =>
      Hive.box<ProductModel>(productBoxName);
  static Box<ShopModel> get shopBox => Hive.box<ShopModel>(shopBoxName);
  static Box get settingsBox => Hive.box(settingsBoxName);
  
  // جلب صندوق المبيعات للتعامل معه في التطبيق
  static Box<SaleModel> get saleBox => Hive.box<SaleModel>(saleBoxName);
}
