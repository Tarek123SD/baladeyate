import 'package:baladeyate/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

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

        /// ================= APP BAR =================
        appBar: CustomAppBar(),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16.s(context)),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: 700.w(context),
                      ),
                      child: _buildFormCard(context),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ================= FORM CARD =================
  Widget _buildFormCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.s(context)),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20.r(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SizedBox(height: 10.s(context)),

          /// TITLE
          Center(
            child: Text(
              'تقديم شكوى رسمية',
              style: TextStyle(
                fontSize: 22.f(context),
                fontWeight: FontWeight.bold,
                color: AppConstants.primaryForest,
              ),
            ),
          ),

          SizedBox(height: 20.s(context)),

          /// PRIORITY
          Text(
            'درجة الأولوية',
            style: TextStyle(
              fontSize: 15.f(context),
            ),
          ),

          SizedBox(height: 10.s(context)),

          Row(
            children: [
              Expanded(
                child: _buildButton(
                  context,
                  text: 'طارئ / مستعجل',
                  isActive: false,
                ),
              ),
              SizedBox(width: 10.s(context)),
              Expanded(
                child: _buildButton(
                  context,
                  text: 'اعتيادي',
                  isActive: true,
                ),
              ),
            ],
          ),

          SizedBox(height: 20.s(context)),

          /// SUBJECT
          Text(
            'موضوع الشكوى',
            style: TextStyle(
              fontSize: 15.f(context),
            ),
          ),

          SizedBox(height: 8.s(context)),

          _buildInputField(
            context,
            hint: 'مثال: صيانة الطرق...',
          ),

          SizedBox(height: 20.s(context)),

          /// DETAILS
          Text(
            'تفاصيل الشكوى',
            style: TextStyle(
              fontSize: 15.f(context),
            ),
          ),

          SizedBox(height: 8.s(context)),

          _buildInputField(
            context,
            hint: 'يرجى كتابة وصف دقيق...',
            maxLines: 5,
          ),

          SizedBox(height: 20.s(context)),

          /// UPLOAD
          Text(
            'المرفقات و الصور',
            style: TextStyle(
              fontSize: 15.f(context),
            ),
          ),

          SizedBox(height: 10.s(context)),

          _buildUploadBox(context),

          SizedBox(height: 20.s(context)),

          /// MAP
          Text(
            'الموقع الجغرافي',
            style: TextStyle(
              fontSize: 15.f(context),
            ),
          ),

          SizedBox(height: 10.s(context)),

          _buildMap(context),

          SizedBox(height: 20.s(context)),
        ],
      ),
    );
  }

  /// ================= BUTTON =================
  Widget _buildButton(
    BuildContext context, {
    required String text,
    required bool isActive,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 14.s(context),
      ),
      decoration: BoxDecoration(
        color: isActive ? AppConstants.green : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12.r(context)),
        border: Border.all(
          color: Colors.grey.shade400,
        ),
      ),
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14.f(context),
            color: isActive ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  /// ================= INPUT =================
  Widget _buildInputField(
    BuildContext context, {
    required String hint,
    int maxLines = 1,
  }) {
    return TextField(
      maxLines: maxLines,
      textAlign: TextAlign.right,
      style: TextStyle(
        fontSize: 14.f(context),
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          fontSize: 13.f(context),
        ),
        filled: true,
        fillColor: Colors.grey.shade200,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 14.s(context),
          vertical: 14.s(context),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r(context)),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  /// ================= UPLOAD BOX =================
  Widget _buildUploadBox(BuildContext context) {
    return Container(
      height: 150.h(context),
      decoration: BoxDecoration(
        border: Border.all(
          color: AppConstants.primaryForest,
        ),
        borderRadius: BorderRadius.circular(12.r(context)),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.upload_file,
              size: 30.ic(context),
              color: AppConstants.primaryForest,
            ),
            SizedBox(height: 10.s(context)),
            Text(
              'رفع صور أو مستندات',
              style: TextStyle(
                fontSize: 14.f(context),
                color: AppConstants.primaryForest,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ================= MAP =================
  Widget _buildMap(BuildContext context) {
    return Container(
      height: 120.h(context),
      decoration: BoxDecoration(
        color: AppConstants.secondaryGoldenWheat,
        borderRadius: BorderRadius.circular(12.r(context)),
      ),
      child: Center(
        child: Icon(
          Icons.location_pin,
          size: 30.ic(context),
          color: AppConstants.primaryForest,
        ),
      ),
    );
  }
}
