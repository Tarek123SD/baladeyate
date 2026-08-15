import 'package:baladeyate/features/transactions/models/transaction_model.dart';
import 'package:baladeyate/features/transactions/presentation/transaction_display.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class TransactionCard extends StatelessWidget {
  const TransactionCard({
    super.key,
    required this.transaction,
  });

  final TransactionModel transaction;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final statusProps = getTransactionStatusProps(transaction.status);
    final typeLabel = getTransactionTypeLabel(transaction.type);

    return Container(
      margin: EdgeInsets.only(bottom: 16.h(context)),
      padding: EdgeInsets.all(16.s(context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r(context)),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  typeLabel,
                  style: TextStyle(
                    fontSize: 15.f(context),
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              SizedBox(width: 8.w(context)),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 10.w(context),
                  vertical: 4.h(context),
                ),
                decoration: BoxDecoration(
                  color: statusProps.bgColor,
                  borderRadius: BorderRadius.circular(20.r(context)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      statusProps.icon,
                      size: 13.ic(context),
                      color: statusProps.color,
                    ),
                    SizedBox(width: 4.w(context)),
                    Text(
                      statusProps.label,
                      style: TextStyle(
                        fontSize: 11.f(context),
                        fontWeight: FontWeight.bold,
                        color: statusProps.color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h(context)),
          Row(
            children: [
              Text(
                transaction.transactionNumber,
                style: TextStyle(
                  fontSize: 13.f(context),
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 6.w(context)),
                child: Text(
                  '•',
                  style: TextStyle(
                    fontSize: 12.f(context),
                    color: Colors.grey.shade400,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Icon(
                Icons.calendar_today_outlined,
                size: 12.ic(context),
                color: Colors.grey.shade600,
              ),
              SizedBox(width: 4.w(context)),
              Text(
                formatTransactionDate(transaction.createdAt),
                style: TextStyle(
                  fontSize: 12.f(context),
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h(context)),
            child: Divider(
              color: Colors.grey.shade200,
              height: 1,
              thickness: 1,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TransactionCardFooterFormData(rawFormData: transaction.formData),
              SizedBox(width: 8.w(context)),
              InkWell(
                onTap: () => context.push('/transactions/${transaction.id}'),
                borderRadius: BorderRadius.circular(8.r(context)),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 6.w(context),
                    vertical: 4.h(context),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        transaction.needsDocuments ? 'استكمال' : 'التفاصيل',
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 13.f(context),
                        ),
                      ),
                      SizedBox(width: 4.w(context)),
                      Icon(
                        Icons.chevron_left_rounded,
                        color: primaryColor,
                        size: 18.ic(context),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class TransactionCardFooterFormData extends StatelessWidget {
  const TransactionCardFooterFormData({
    super.key,
    required this.rawFormData,
  });

  final Map<String, dynamic>? rawFormData;

  @override
  Widget build(BuildContext context) {
    if (rawFormData == null || rawFormData!.isEmpty) {
      return const Spacer();
    }

    final entries = rawFormData!.entries
        .where((e) => e.value != null && e.value.toString().trim().isNotEmpty)
        .take(2)
        .toList();

    if (entries.isEmpty) {
      return const Spacer();
    }

    return Expanded(
      child: Text.rich(
        TextSpan(
          children: entries.asMap().entries.map((indexed) {
            final isLast = indexed.key == entries.length - 1;
            final entry = indexed.value;
            final formattedPair =
                formatTransactionFormDataPair(entry.key, entry.value);

            return TextSpan(
              children: [
                TextSpan(text: formattedPair),
                if (!isLast)
                  TextSpan(
                    text: '  •  ',
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            );
          }).toList(),
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 12.f(context),
          color: Colors.grey.shade600,
        ),
      ),
    );
  }
}
