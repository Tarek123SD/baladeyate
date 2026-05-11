import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../utils/constants.dart';

class ComplaintScreen extends StatelessWidget {
  const ComplaintScreen({super.key});

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
              Row(
                children: [
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
            ],
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: _buildFormCard(),
                ),
              ),
              _buildBottomNav(),
            ],
          ),
        ),
      ),
    );
  }

  /// ================= FORM CARD =================
  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const SizedBox(height: 10),

          /// 🔹 Title
          const Center(
            child: Text(
              'تقديم شكوى رسمية',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppConstants.primaryForest,
              ),
            ),
          ),

          const SizedBox(height: 20),

          /// 🔹 Priority Buttons
          const Text('درجة الأولوية'),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildButton(
                  text: 'طارئ / مستعجل',
                  isActive: false,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildButton(
                  text: 'اعتيادي',
                  isActive: true,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          /// 🔹 Subject
          const Text('موضوع الشكوى'),
          const SizedBox(height: 8),
          _buildInputField(hint: 'مثال: صيانة الطرق...'),

          const SizedBox(height: 20),

          /// 🔹 Details
          const Text('تفاصيل الشكوى'),
          const SizedBox(height: 8),
          _buildInputField(
            hint: 'يرجى كتابة وصف دقيق...',
            maxLines: 5,
          ),

          const SizedBox(height: 20),

          /// 🔹 Upload Box
          const Text('المرفقات و الصور'),
          const SizedBox(height: 10),
          _buildUploadBox(),

          const SizedBox(height: 20),

          /// 🔹 Map Section
          const Text('الموقع الجغرافي'),
          const SizedBox(height: 10),
          _buildMap(),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  /// ================= BUTTON =================
  Widget _buildButton({required String text, required bool isActive}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: isActive ? AppConstants.green : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  /// ================= INPUT =================
  Widget _buildInputField({required String hint, int maxLines = 1}) {
    return TextField(
      maxLines: maxLines,
      textAlign: TextAlign.right,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.grey.shade200,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  /// ================= UPLOAD BOX =================
  Widget _buildUploadBox() {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        border: Border.all(
          color: AppConstants.primaryForest,
          style: BorderStyle.solid,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.upload_file,
                size: 30, color: AppConstants.primaryForest),
            SizedBox(height: 10),
            Text(
              'رفع صور أو مستندات',
              style: TextStyle(color: AppConstants.primaryForest),
            ),
          ],
        ),
      ),
    );
  }

  /// ================= MAP =================
  Widget _buildMap() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: AppConstants.secondaryGoldenWheat,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Icon(Icons.location_pin, color: AppConstants.primaryForest),
      ),
    );
  }

  /// ================= BOTTOM NAV =================
  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        color: Color(0xff0f3d2e),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Icon(Icons.settings, color: Colors.white),
          Icon(Icons.fingerprint, color: Colors.white),
          Icon(Icons.description, color: Colors.white),
          Icon(Icons.home, color: Colors.white),
        ],
      ),
    );
  }
}
