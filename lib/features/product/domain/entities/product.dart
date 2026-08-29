import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final String id; 
  final String name;
  final String barcode;
  final double price;
  final int stock; 
  final String? imagePath; // مسار الصورة الجديد

  const Product({
    required this.id,
    required this.name,
    required this.barcode,
    required this.price,
    this.stock = 0,
    this.imagePath,
  });

  @override
  List<Object?> get props => [id, name, barcode, price, stock, imagePath];
}
