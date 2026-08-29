part of 'billing_bloc.dart';

/// الحدث الأساسي الخاص بـ BillingBloc
abstract class BillingEvent extends Equatable {
  const BillingEvent();

  @override
  List<Object?> get props => [];
}

/// مسح باركود المنتج
class ScanBarcodeEvent extends BillingEvent {
  final String barcode;

  const ScanBarcodeEvent(this.barcode);

  @override
  List<Object?> get props => [barcode];
}

/// إضافة منتج إلى السلة
class AddProductToCartEvent extends BillingEvent {
  final Product product;

  const AddProductToCartEvent(this.product);

  @override
  List<Object?> get props => [product];
}

/// حذف منتج من السلة
class RemoveProductFromCartEvent extends BillingEvent {
  final dynamic productId;

  const RemoveProductFromCartEvent(this.productId);

  @override
  List<Object?> get props => [productId];
}

/// تغيير كمية منتج داخل السلة
class UpdateQuantityEvent extends BillingEvent {
  final dynamic productId;
  final int quantity;

  const UpdateQuantityEvent(
    this.productId,
    this.quantity,
  );

  @override
  List<Object?> get props => [
        productId,
        quantity,
      ];
}

/// تفريغ السلة بالكامل
class ClearCartEvent extends BillingEvent {
  const ClearCartEvent();
}

/// إنهاء وحفظ الفاتورة الرقمية
///
/// هذا الحدث يستبدل PrintReceiptEvent.
/// لا توجد أي عملية طباعة أو اتصال بطابعة.
class CompleteSaleEvent extends BillingEvent {
  const CompleteSaleEvent();
}
