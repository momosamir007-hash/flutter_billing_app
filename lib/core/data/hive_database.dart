import 'package:hive_flutter/hive_flutter.dart';

import '../../features/product/data/models/product_model.dart';
import '../../features/shop/data/models/shop_model.dart';
import '../../features/billing/data/models/sale_model.dart';

class HiveDatabase {
  static const String productBoxName = 'products';
  static const String shopBoxName = 'shop';
  static const String settingsBoxName = 'settings';
  static const String saleBoxName = 'sales';

  static Future<void> init() async {
    await Hive.initFlutter();

    // Register Hive adapters only once.
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ProductModelAdapter());
    }

    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(ShopModelAdapter());
    }

    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(SaleModelAdapter());
    }

    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(SaleItemModelAdapter());
    }

    // Open boxes.
    await Hive.openBox<ProductModel>(productBoxName);
    await Hive.openBox<ShopModel>(shopBoxName);
    await Hive.openBox(settingsBoxName);
    await Hive.openBox<SaleModel>(saleBoxName);
  }

  static Box<ProductModel> get productBox {
    return Hive.box<ProductModel>(productBoxName);
  }

  static Box<ShopModel> get shopBox {
    return Hive.box<ShopModel>(shopBoxName);
  }

  static Box get settingsBox {
    return Hive.box(settingsBoxName);
  }

  static Box<SaleModel> get saleBox {
    return Hive.box<SaleModel>(saleBoxName);
  }
}
