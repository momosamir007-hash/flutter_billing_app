import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // لتنسيق التاريخ والوقت
import '../../../../core/theme/app_theme.dart';
import '../../../../core/data/hive_database.dart';
import '../../data/models/sale_model.dart';

class SalesHistoryPage extends StatelessWidget {
  const SalesHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final saleBox = HiveDatabase.saleBox;

    return Scaffold(
      appBar: AppBar(
        title: const Text('سجل المبيعات والفواتير'),
        centerTitle: true,
      ),
      body: ValueListenableBuilder(
        valueListenable: saleBox.listenable(),
        builder: (context, box, _) {
          final sales = box.values.toList().reversed.toList(); // أحدث المبيعات أولاً

          if (sales.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.receipt_long_outlined, size: 70, color: Colors.grey.shade300),
                  const SizedBox(height: 12),
                  const Text('لا توجد مبيعات مسجلة حتى الآن', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text('ستظهر هنا كافة الفواتير التي تقوم بإنتهائها.', style: TextStyle(color: Colors.grey.shade600)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sales.length,
            itemBuilder: (context, index) {
              final sale = sales[index] as SaleModel;
              final formattedDate = DateFormat('yyyy/MM/dd - hh:mm a').format(sale.date);

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: ExpansionTile(
                  title: Text(
                    'فاتورة رقم: ${sale.id.substring(sale.id.length - 6)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(formattedDate, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                  ),
                  trailing: Text(
                    '${sale.totalAmount.toStringAsFixed(0)} DZD',
                    style: TextStyle(fontWeight: FontWeight.w900, color: AppTheme.primaryColor, fontSize: 15),
                  ),
                  children: [
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('تفاصيل المتجر: ${sale.shopName}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          if (sale.address.isNotEmpty) Text('العنوان: ${sale.address}', style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
                          const SizedBox(height: 8),
                          const Text('المنتجات المباعة:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.blueGrey)),
                          const SizedBox(height: 4),
                          ...sale.items.map((item) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 3),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text('${item.productName} (x${item.quantity})', style: const TextStyle(fontSize: 13)),
                                    ),
                                    Text('${item.total.toStringAsFixed(0)} DZD', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
