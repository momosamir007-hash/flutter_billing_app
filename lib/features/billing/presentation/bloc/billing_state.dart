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

  double get totalAmount => cartItems.fold(
        0.0,
        (sum, item) => sum + (item.product.price * item.quantity),
      );

  int get totalQuantity => cartItems.fold(
        0,
        (sum, item) => sum + item.quantity,
      );

  BillingState copyWith({
    List<CartItem>? cartItems,
    String? error,
    bool? saleSuccess,
    bool clearError = false,
    bool clearSaleSuccess = false,
  }) {
    return BillingState(
      cartItems: cartItems ?? this.cartItems,
      error: clearError ? null : (error ?? this.error),
      saleSuccess: clearSaleSuccess ? false : (saleSuccess ?? this.saleSuccess),
    );
  }

  @override
  List<Object?> get props => [cartItems, error, saleSuccess];
}
