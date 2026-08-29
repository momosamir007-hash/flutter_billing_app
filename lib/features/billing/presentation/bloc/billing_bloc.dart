import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/cart_item.dart';
import 'package:billing_app/features/product/domain/entities/product.dart';
import 'package:billing_app/features/product/domain/usecases/product_usecases.dart';
import '../../../../core/data/hive_database.dart';
import '../../data/models/sale_model.dart';

part 'billing_event.dart';
part 'billing_state.dart';

class BillingBloc extends Bloc<BillingEvent, BillingState> {
  final GetProductByBarcodeUseCase getProductByBarcodeUseCase;

  BillingBloc({
    required this.getProductByBarcodeUseCase,
  }) : super(const BillingState()) {
    on<ScanBarcodeEvent>(_onScanBarcode);
    on<AddProductToCartEvent>(_onAddProductToCart);
    on<RemoveProductFromCartEvent>(_onRemoveProductFromCart);
    on<UpdateQuantityEvent>(_onUpdateQuantity);
    on<ClearCartEvent>(_onClearCart);
    on<CompleteSaleEvent>(_onCompleteSale);
  }

  Future<void> _onScanBarcode(
    ScanBarcodeEvent event,
    Emitter<BillingState> emit,
  ) async {
    final barcode = event.barcode.trim();

    if (barcode.isEmpty) {
      return;
    }

    try {
      final result = await getProductByBarcodeUseCase(barcode);

      result.fold(
        (failure) {
          emit(
            state.copyWith(
              error: 'المنتج غير موجود: $barcode',
              clearSaleSuccess: true,
            ),
          );
        },
        (product) {
          add(
            AddProductToCartEvent(product),
          );
        },
      );
    } catch (e) {
      emit(
        state.copyWith(
          error: 'حدث خطأ أثناء البحث عن المنتج: $e',
          clearSaleSuccess: true,
        ),
      );
    }
  }

  void _onAddProductToCart(
    AddProductToCartEvent event,
    Emitter<BillingState> emit,
  ) {
    final product = event.product;

    final cleanState = state.copyWith(
      clearError: true,
      clearSaleSuccess: true,
    );

    final existingIndex = cleanState.cartItems.indexWhere(
      (item) => item.product.id == product.id,
    );

    if (existingIndex >= 0) {
      final existingItem = cleanState.cartItems[existingIndex];

      final updatedItems = List<CartItem>.from(
        cleanState.cartItems,
      );

      updatedItems[existingIndex] = existingItem.copyWith(
        quantity: existingItem.quantity + 1,
      );

      emit(
        cleanState.copyWith(
          cartItems: updatedItems,
        ),
      );

      return;
    }

    emit(
      cleanState.copyWith(
        cartItems: [
          ...cleanState.cartItems,
          CartItem(
            product: product,
          ),
        ],
      ),
    );
  }

  void _onRemoveProductFromCart(
    RemoveProductFromCartEvent event,
    Emitter<BillingState> emit,
  ) {
    final updatedList = state.cartItems
        .where(
          (item) => item.product.id != event.productId,
        )
        .toList();

    emit(
      state.copyWith(
        cartItems: updatedList,
        clearError: true,
        clearSaleSuccess: true,
      ),
    );
  }

  void _onUpdateQuantity(
    UpdateQuantityEvent event,
    Emitter<BillingState> emit,
  ) {
    if (event.quantity <= 0) {
      add(
        RemoveProductFromCartEvent(
          event.productId,
        ),
      );

      return;
    }

    final index = state.cartItems.indexWhere(
      (item) => item.product.id == event.productId,
    );

    if (index < 0) {
      return;
    }

    final items = List<CartItem>.from(
      state.cartItems,
    );

    items[index] = items[index].copyWith(
      quantity: event.quantity,
    );

    emit(
      state.copyWith(
        cartItems: items,
        clearError: true,
        clearSaleSuccess: true,
      ),
    );
  }

  void _onClearCart(
    ClearCartEvent event,
    Emitter<BillingState> emit,
  ) {
    emit(
      const BillingState(),
    );
  }

  Future<void> _onCompleteSale(
    CompleteSaleEvent event,
    Emitter<BillingState> emit,
  ) async {
    if (state.cartItems.isEmpty) {
      emit(
        state.copyWith(
          error: 'لا توجد منتجات في السلة لحفظ الفاتورة.',
          clearSaleSuccess: true,
        ),
      );

      return;
    }

    try {
      final shopBox = HiveDatabase.shopBox;

      final shopName = shopBox.isNotEmpty
          ? shopBox.values.first.name
          : 'متجري';

      final saleItems = state.cartItems.map(
        (cartItem) {
          return SaleItemModel(
            productId: cartItem.product.id,
            productName: cartItem.product.name,
            quantity: cartItem.quantity,
            price: cartItem.product.price,
            total: cartItem.product.price * cartItem.quantity,
          );
        },
      ).toList();

      final now = DateTime.now();

      final newSale = SaleModel(
        id: now.millisecondsSinceEpoch.toString(),
        date: now,
        items: saleItems,
        totalAmount: state.totalAmount,
        shopName: shopName,
        address: '',
        phone: '',
      );

      // حفظ الفاتورة فعليًا
      final key = await HiveDatabase.saleBox.add(
        newSale,
      );

      // التأكد من نجاح عملية الحفظ
      final savedSale = HiveDatabase.saleBox.get(key);

      if (savedSale == null) {
        emit(
          state.copyWith(
            error: 'حدث خطأ: لم يتم العثور على الفاتورة بعد حفظها.',
            clearSaleSuccess: true,
          ),
        );

        return;
      }

      emit(
        state.copyWith(
          saleSuccess: true,
          clearError: true,
          cartItems: const [],
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          error: 'تعذر حفظ الفاتورة: $e',
          clearSaleSuccess: true,
        ),
      );
    }
  }
}
