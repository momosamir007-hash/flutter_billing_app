import 'package:hive/hive.dart';

part 'sale_model.g.dart';

@HiveType(typeId: 3)
class SaleModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime date;

  @HiveField(2)
  final List<SaleItemModel> items;

  @HiveField(3)
  final double totalAmount;

  // تفاصيل المتجر المرتبطة بالفاتورة
  @HiveField(4)
  final String shopName;

  @HiveField(5)
  final String address;

  @HiveField(6)
  final String phone;

  SaleModel({
    required this.id,
    required this.date,
    required this.items,
    required this.totalAmount,
    required this.shopName,
    required this.address,
    required this.phone,
  });
}

@HiveType(typeId: 4)
class SaleItemModel extends HiveObject {
  @HiveField(0)
  final String productId;

  @HiveField(1)
  final String productName;

  @HiveField(2)
  final int quantity;

  @HiveField(3)
  final double price;

  @HiveField(4)
  final double total;

  SaleItemModel({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
    required this.total,
  });
}
