part of 'billing_bloc.dart';

class BillingState extends Equatable {
  final List<CartItem> cartItems;
  final String? error;
  final bool saleSuccess;

  const BillingState({
    this.cartItems = const [],
    this.error,
    this.saleSuccess = false,
  });

  /// إجمالي قيمة السلة
  double get totalAmount {
    return cartItems.fold(
      0.0,
      (sum, item) => sum + item.total,
    );
  }

  /// إجمالي عدد القطع في السلة
  ///
  /// مثال:
  /// منتج A = 2 قطع
  /// منتج B = 3 قطع
  /// النتيجة = 5 قطع
  int get totalQuantity {
    return cartItems.fold(
      0,
      (sum, item) => sum + item.quantity,
    );
  }

  BillingState copyWith({
    List<CartItem>? cartItems,
    String? error,
    bool clearError = false,
    bool? saleSuccess,
    bool clearSaleSuccess = false,
  }) {
    return BillingState(
      cartItems: cartItems ?? this.cartItems,
      error: clearError ? null : (error ?? this.error),
      saleSuccess:
          clearSaleSuccess ? false : (saleSuccess ?? this.saleSuccess),
    );
  }

  @override
  List<Object?> get props => [
        cartItems,
        error,
        saleSuccess,
      ];
}
