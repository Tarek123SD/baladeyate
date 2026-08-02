import 'package:baladeyate/features/transactions/models/transaction_model.dart';
import 'package:baladeyate/features/transactions/presentation/transaction_display.dart';
import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

Future<void> showTransactionDetailsSheet(
  BuildContext context,
  TransactionModel transaction,
) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => TransactionDetailsSheet(transaction: transaction),
  );
}

class TransactionDetailsSheet extends StatelessWidget {
  const TransactionDetailsSheet({
    super.key,
    required this.transaction,
  });

  final TransactionModel transaction;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final statusProps = getTransactionStatusProps(transaction.status);
    final typeLabel = getTransactionTypeLabel(transaction.type);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(24.r(context)),
          ),
        ),
        padding: EdgeInsets.all(20.s(context)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.w(context),
                height: 4.h(context),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2.r(context)),
                ),
              ),
            ),
            SizedBox(height: 16.h(context)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  typeLabel,
                  style: TextStyle(
                    fontSize: 17.f(context),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w(context),
                    vertical: 4.h(context),
                  ),
                  decoration: BoxDecoration(
                    color: statusProps.bgColor,
                    borderRadius: BorderRadius.circular(16.r(context)),
                  ),
                  child: Text(
                    statusProps.label,
                    style: TextStyle(
                      color: statusProps.color,
                      fontWeight: FontWeight.bold,
                      fontSize: 12.f(context),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h(context)),
            Text(
              'رقم المعاملة: ${transaction.transactionNumber}',
              style: TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 14.f(context),
              ),
            ),
            SizedBox(height: 4.h(context)),
            Text(
              'تاريخ التقديم: ${formatTransactionDate(transaction.createdAt)}',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12.f(context),
              ),
            ),
            SizedBox(height: 16.h(context)),
            if (transaction.formData != null &&
                transaction.formData!.isNotEmpty) ...[
              const Divider(),
              SizedBox(height: 8.h(context)),
              Text(
                'البيانات المرفقة بالطلب:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14.f(context),
                ),
              ),
              SizedBox(height: 8.h(context)),
              ...transaction.formData!.entries.map((entry) {
                final label =
                    transactionFormDataLabels[entry.key] ?? entry.key;
                final formattedVal =
                    formatTransactionFormDataValue(entry.key, entry.value);
                return Padding(
                  padding: EdgeInsets.only(bottom: 6.h(context)),
                  child: Row(
                    children: [
                      Text(
                        '• $label: ',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13.f(context),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          formattedVal,
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 13.f(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              SizedBox(height: 16.h(context)),
            ],
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: EdgeInsets.symmetric(vertical: 12.h(context)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r(context)),
                  ),
                ),
                child: Text(
                  'إغلاق',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.f(context),
                  ),
                ),
              ),
            ),
            SizedBox(height: 12.h(context)),
          ],
        ),
      ),
    );
  }
}
