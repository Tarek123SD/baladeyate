import 'package:baladeyate/core/widgets/custom_track_statistic_card.dart';
import 'package:baladeyate/features/profile/models/household.dart';
import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class ProfileStatsRow extends StatelessWidget {
  const ProfileStatsRow({
    super.key,
    required this.household,
    required this.isLoading,
  });

  final Household? household;
  final bool isLoading;

  static const _cardTextColor = Color(0xFF1F3A2E);

  String _display(String? value, {int maxLength = 12}) {
    if (value == null || value.trim().isEmpty || value == '—') return '—';
    final trimmed = value.trim();
    if (trimmed.length <= maxLength) return trimmed;
    return '${trimmed.substring(0, maxLength)}…';
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Row(
        children: List.generate(
          3,
          (index) => Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: index < 2 ? 12.w(context) : 0),
              child: Container(
                height: 90.h(context),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(20.r(context)),
                ),
              ),
            ),
          ),
        ),
      );
    }

    final memberCount = household?.members.length ?? 0;
    final familyBook = _display(household?.familyBook);
    final district = _display(household?.district);

    return LayoutBuilder(
      builder: (context, constraints) {
        final cards = [
          CustomTrackStatisticCard(
            title: 'أفراد الأسرة',
            value: '$memberCount',
            backgroundColor: Colors.white,
            textColor: _cardTextColor,
            icon: Icons.people_outline_rounded,
          ),
          CustomTrackStatisticCard(
            title: 'دفتر العائلة',
            value: familyBook,
            backgroundColor: Colors.white,
            textColor: _cardTextColor,
            icon: Icons.menu_book_outlined,
          ),
          CustomTrackStatisticCard(
            title: 'الحي',
            value: district,
            backgroundColor: Colors.white,
            textColor: _cardTextColor,
            icon: Icons.location_on_outlined,
          ),
        ];

        if (constraints.maxWidth < 340.w(context)) {
          return Column(
            children: [
              Row(children: [cards[0]]),
              SizedBox(height: 12.h(context)),
              Row(
                children: [
                  cards[1],
                  SizedBox(width: 12.w(context)),
                  cards[2],
                ],
              ),
            ],
          );
        }

        return Row(
          children: [
            cards[0],
            SizedBox(width: 12.w(context)),
            cards[1],
            SizedBox(width: 12.w(context)),
            cards[2],
          ],
        );
      },
    );
  }
}
