import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'config/routes/app_routes.dart';
import 'core/data/hive_database.dart';
import 'core/service_locator.dart' as di;
import 'core/theme/app_theme.dart';
import 'features/billing/presentation/bloc/billing_bloc.dart';
import 'features/product/presentation/bloc/product_bloc.dart';
import 'features/shop/presentation/bloc/shop_bloc.dart';
import 'features/settings/presentation/bloc/printer_bloc.dart';
import 'features/settings/presentation/bloc/printer_event.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await HiveDatabase.init();
    await di.init();

    runApp(const MyApp());
  } catch (error, stackTrace) {
    runApp(
      StartupErrorApp(
        error: error,
        stackTrace: stackTrace,
      ),
    );
  }
}

class StartupErrorApp extends StatelessWidget {
  final Object error;
  final StackTrace stackTrace;

  const StartupErrorApp({
    super.key,
    required this.error,
    required this.stackTrace,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('خطأ في تشغيل التطبيق'),
        ),
        body: Directionality(
          textDirection: TextDirection.rtl,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'حدث خطأ أثناء تشغيل التطبيق:',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                SelectableText(
                  error.toString(),
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'تفاصيل الخطأ:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                SelectableText(
                  stackTrace.toString(),
                  style: const TextStyle(
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ProductBloc>(
          create: (context) =>
              di.sl<ProductBloc>()..add(LoadProducts()),
        ),
        BlocProvider<ShopBloc>(
          create: (context) =>
              di.sl<ShopBloc>()..add(LoadShopEvent()),
        ),
        BlocProvider<BillingBloc>(
          create: (context) => BillingBloc(
            getProductByBarcodeUseCase: di.sl(),
          ),
        ),
        BlocProvider<PrinterBloc>(
          create: (context) =>
              di.sl<PrinterBloc>()..add(InitPrinterEvent()),
        ),
      ],
      child: MaterialApp.router(
        title: 'متجري',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: router,
        builder: (context, child) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: child ?? const SizedBox.shrink(),
          );
        },
      ),
    );
  }
}
