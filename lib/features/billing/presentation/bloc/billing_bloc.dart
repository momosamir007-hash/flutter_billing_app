import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/cart_item.dart';
import 'package:billing_app/features/product/domain/entities/product.dart';
import 'package:billing_app/features/product/domain/usecases/product_usecases.dart';
import '../../../../core/data/hive_database.dart';
import '../models/sale_model.dart';

part 'billing_event.dart';
part 'billing_state.dart';

class BillingBloc extends Bloc<BillingEvent, BillingState> {
  final GetProductByBarcodeUseCase getProductByBarcodeUseCase;

  BillingBloc({
    required this.getProductByBarcodeUseCase,
  }) : super(const BillingState()) {
    // مسح الباركود
    on<ScanBarcodeEvent>(_onScanBarcode);

    // إضافة منتج إلى السلة
    on<AddProductToCartEvent>(_onAddProductToCart);

    // حذف منتج من السلة
    on<RemoveProductFromCartEvent>(_onRemoveProductFromCart);

    // تعديل كمية المنتج
    on<UpdateQuantityEvent>(_onUpdateQuantity);

    // تفريغ السلة
    on<ClearCartEvent>(_onClearCart);

    // إنهاء وحفظ الفاتورة
    on<CompleteSaleEvent>(_onCompleteSale);
  }

  // ============================================================
  // SCAN BARCODE
  // ============================================================

  Future<void> _onScanBarcode(
    ScanBarcodeEvent event,
    Emitter<BillingState> emit,
  ) async {
    final barcode = event.barcode.trim();

    if (barcode.isEmpty) {
      emit(
        state.copyWith(
          error: 'الباركود فارغ',
          clearSaleSuccess: true,
        ),
      );
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
          // عند العثور على المنتج يتم إضافته مباشرة إلى السلة.
          add(
            AddProductToCartEvent(product),
          );
        },
      );
    } catch (e) {
      emit(
        state.copyWith(
          error: 'حدث خطأ أثناء البحث عن المنتج',
          clearSaleSuccess: true,
        ),
      );
    }
  }

  // ============================================================
  // ADD PRODUCT TO CART
  // ============================================================

  void _onAddProductToCart(
    AddProductToCartEvent event,
    Emitter<BillingState> emit,
  ) {
    final product = event.product;

    // تنظيف رسالة الخطأ القديمة
    final cleanState = state.copyWith(
      clearError: true,
      clearSaleSuccess: true,
    );

    final existingIndex = cleanState.cartItems.indexWhere(
      (item) => item.product.id == product.id,
    );

    // المنتج موجود مسبقاً في السلة
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
          clearError: true,
          clearSaleSuccess: true,
        ),
      );

      return;
    }

    // المنتج غير موجود في السلة
    final newItem = CartItem(
      product: product,
    );

    emit(
      cleanState.copyWith(
        cartItems: [
          ...cleanState.cartItems,
          newItem,
        ],
        clearError: true,
        clearSaleSuccess: true,
      ),
    );
  }

  // ============================================================
  // REMOVE PRODUCT FROM CART
  // ============================================================

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

  // ============================================================
  // UPDATE QUANTITY
  // ============================================================

  void _onUpdateQuantity(
    UpdateQuantityEvent event,
    Emitter<BillingState> emit,
  ) {
    // إذا أصبحت الكمية صفر أو أقل، نحذف المنتج من السلة.
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

  // ============================================================
  // CLEAR CART
  // ============================================================

  void _onClearCart(
    ClearCartEvent event,
    Emitter<BillingState> emit,
  ) {
    emit(
      const BillingState(),
    );
  }

  // ============================================================
  // COMPLETE SALE
  // ============================================================

  Future<void> _onCompleteSale(
    CompleteSaleEvent event,
    Emitter<BillingState> emit,
  ) async {
    if (state.cartItems.isEmpty) {
      emit(
        state.copyWith(
          error: 'السلة فارغة، أضف منتجاً أولاً',
          clearSaleSuccess: true,
        ),
      );
      return;
    }

    try {
      // 1. جلب تفاصيل المتجر من قاعدة البيانات Hive لتضمينها في الفاتورة
      final shopBox = HiveDatabase.shopBox;
      String shopName = 'متجري';
      String address = '';
      String phone = '';

      if (shopBox.isNotEmpty) {
        final shop = shopBox.values.first;
        shopName = shop.name;
        address = shop.address;
        phone = shop.phone;
      }

      // 2. تجهيز عناصر الفاتورة من السلة الحالية
      final saleItems = state.cartItems.map((cartItem) {
        return SaleItemModel(
          productId: cartItem.product.id,
          productName: cartItem.product.name,
          quantity: cartItem.quantity,
          price: cartItem.product.price,
          total: cartItem.product.price * cartItem.quantity,
        );
      }).toList();

      // 3. إنشاء نموذج الفاتورة الكامل
      final newSale = SaleModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        date: DateTime.now(),
        items: saleItems,
        totalAmount: state.totalAmount,
        shopName: shopName,
        address: address,
        phone: phone,
      );

      // 4. حفظ الفاتورة في صندوق المبيعات (Hive Box)
      final saleBox = HiveDatabase.saleBox;
      await saleBox.add(newSale);

      // 5. نجاح العملية وتفريغ السلة
      emit(
        state.copyWith(
          saleSuccess: true,
          clearError: true,
          cartItems: [],
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
