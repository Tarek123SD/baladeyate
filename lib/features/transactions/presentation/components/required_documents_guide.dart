import 'package:baladeyate/features/transactions/models/transaction_document_catalog.dart';
import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

/// Shows the exact documents a citizen should upload for a transaction type.
class RequiredDocumentsGuide extends StatelessWidget {
  const RequiredDocumentsGuide({
    super.key,
    required this.type,
    this.compact = false,
  });

  final String? type;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final guide = TransactionDocumentCatalog.forType(type);
    if (guide == null) {
      return const SizedBox.shrink();
    }

    final primaryColor = Theme.of(context).colorScheme.primary;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? 12.s(context) : 14.s(context)),
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12.r(context)),
        border: Border.all(color: primaryColor.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.checklist_rtl_rounded,
                color: primaryColor,
                size: 20.ic(context),
              ),
              SizedBox(width: 8.w(context)),
              Expanded(
                child: Text(
                  'الوثائق المطلوبة — ${guide.typeLabel}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13.f(context),
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h(context)),
          Text(
            TransactionDocumentCatalog.formatNote,
            style: TextStyle(
              fontSize: 11.f(context),
              color: Colors.grey.shade700,
              height: 1.35,
            ),
          ),
          if (guide.notes != null) ...[
            SizedBox(height: 4.h(context)),
            Text(
              guide.notes!,
              style: TextStyle(
                fontSize: 11.f(context),
                color: Colors.grey.shade700,
                height: 1.35,
              ),
            ),
          ],
          SizedBox(height: 10.h(context)),
          ...guide.documents.map((document) {
            return Padding(
              padding: EdgeInsets.only(bottom: 8.h(context)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    document.isRequired
                        ? Icons.check_circle_outline
                        : Icons.add_circle_outline,
                    size: 18.ic(context),
                    color: document.isRequired
                        ? primaryColor
                        : Colors.grey.shade600,
                  ),
                  SizedBox(width: 8.w(context)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: document.title,
                                style: TextStyle(
                                  fontSize: 12.5.f(context),
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              TextSpan(
                                text: document.isRequired
                                    ? '  (إلزامي)'
                                    : '  (اختياري)',
                                style: TextStyle(
                                  fontSize: 11.f(context),
                                  color: document.isRequired
                                      ? primaryColor
                                      : Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (document.hint != null) ...[
                          SizedBox(height: 2.h(context)),
                          Text(
                            document.hint!,
                            style: TextStyle(
                              fontSize: 11.f(context),
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
          Text(
            'الحد الأدنى للمرفقات الإلزامية: ${guide.requiredCount}',
            style: TextStyle(
              fontSize: 11.5.f(context),
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
