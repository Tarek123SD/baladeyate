import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:baladeyate/config/theme/app_colors.dart';

class TrackComplaintsScreen extends StatefulWidget {
  const TrackComplaintsScreen({super.key});

  @override
  State<TrackComplaintsScreen> createState() => _TrackComplaintsScreenState();
}

class _TrackComplaintsScreenState extends State<TrackComplaintsScreen> {
  int selectedFilter = 0;

  final List<Map<String, dynamic>> _complaints = [
    {
      'statusLabel': 'قيد المراجعة',
      'statusColor': const Color(0xFFFFB980),
      'icon': Icons.remove_red_eye,
      'title': 'انقطاع المياه في حي القصاع',
      'date': 'تم تقديمها في 14 أكتوبر 2023',
      'request': '#9821',
      'description':
          'نعاني من انقطاع متكرر للمياه الصالحة للشرب منذ ثلاثة أيام دون سابق إنذار أو توضيح من مؤسسة المياه.',
      'tags': ['دمشق', 'مياه'],
    },
    {
      'statusLabel': 'تم الحل بنجاح',
      'statusColor': const Color(0xFFE2F5E8),
      'icon': Icons.flash_on,
      'title': 'عطل في محول الكهرباء الرئيسي',
      'date': 'تم تقديمها في 10 أكتوبر 2023',
      'request': '#9755',
      'description':
          'وضع متكرر في أعمدة الإنارة يُبقي انقطاعاً كلياً في الحي السكني الثالث.',
      'tags': ['ريف دمشق', 'كهرباء'],
    },
    {
      'statusLabel': 'قيد المراجعة',
      'statusColor': const Color(0xFFFFB980),
      'icon': Icons.delete_outline,
      'title': 'تراكم النفايات في الساحة العامة',
      'date': 'تم تقديمها في 08 أكتوبر 2023',
      'request': '#9601',
      'description':
          'لم يتم إفراغ حاويات القمامة منذ أكثر من أسبوع مما أدى لتراكمها بشكل غير صحي.',
      'tags': ['حلب', 'نفايات'],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/background_white.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 4,
          automaticallyImplyLeading: false,
          title: Row(
            textDirection: TextDirection.rtl,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 250,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    'assets/images/Syrian_horizontal_dark_green.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  context.go('/notifications');
                },
                icon: const Icon(
                  Icons.notifications_none,
                  color: Colors.black87,
                  size: 24,
                ),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          shape: const CircleBorder(),
          onPressed: () {
            context.go('/complains');
          },
          backgroundColor: AppColors.green,
          child: const Icon(
            Icons.add,
            color: AppColors.thirdGoldenWheat,
          ),
        ),
        body: SafeArea(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const SizedBox(height: 14),
                    Text(
                      'مركز تتبع الشكاوى والمقترحات',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: AppColors.primaryForest,
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'نلتزم بالشفافية و السرعة في معالجة طلباتكم لضمان جودة الخدمات العامة في كافة المحافظات.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF3A4B3F),
                            height: 1.7,
                          ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        _buildStatisticCard(
                          title: 'إجمالي الشكاوى',
                          value: '12 طلب',
                          backgroundColor: Colors.white,
                          textColor: const Color(0xFF1F3A2E),
                        ),
                        const SizedBox(width: 12),
                        _buildStatisticCard(
                          title: 'قيد المعالجة',
                          value: '03 طلب',
                          backgroundColor: Colors.white,
                          textColor: const Color(0xFF1F3A2E),
                        ),
                        const SizedBox(width: 12),
                        _buildStatisticCard(
                          title: 'تم الحل',
                          value: '09 طلب',
                          backgroundColor: AppColors.primaryForest,
                          textColor: Colors.white,
                          icon: Icons.task_alt,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        _buildFilterButton('الكل', 0),
                        const SizedBox(width: 8),
                        _buildFilterButton('قيد الانتظار', 1),
                        const SizedBox(width: 8),
                        _buildFilterButton('مكتملة', 2),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Column(
                      children: _complaints.map((complaint) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _buildComplaintCard(context, complaint),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatisticCard({
    required String title,
    required String value,
    required Color backgroundColor,
    required Color textColor,
    IconData? icon,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.05),
              blurRadius: 14,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              title,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            if (icon != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    icon,
                    color: textColor,
                    size: 24,
                  ),
                ],
              )
            else
              Text(
                value,
                style: TextStyle(
                  color: textColor,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterButton(String label, int index) {
    final bool isSelected = selectedFilter == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedFilter = index;
          });
        },
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryForest : Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isSelected
                  ? AppColors.primaryForest
                  : const Color(0xFFE0E0E0),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.primaryForest,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildComplaintCard(
      BuildContext context, Map<String, dynamic> complaint) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.06),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: complaint['statusColor'],
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  complaint['statusLabel'],
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Row(
                children: [
                  Icon(complaint['icon'],
                      color: AppColors.primaryForest, size: 22),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 170,
                    child: Text(
                      complaint['title'],
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                complaint['date'],
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF777777),
                    ),
              ),
              Text(
                complaint['request'],
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF777777),
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            complaint['description'],
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.6,
                  color: const Color(0xFF4D4D4D),
                ),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: complaint['tags'].map<Widget>((tag) {
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE7F4EC),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      tag,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF235235),
                      ),
                    ),
                  );
                }).toList(),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.thirdGoldenWheat,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Text(
                  'تحديث الحالة',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
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
