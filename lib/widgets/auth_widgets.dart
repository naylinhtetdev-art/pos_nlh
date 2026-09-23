// --- Custom Auth Widgets များ ---

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PrimaryAuthButton extends StatelessWidget {
  final String label;
  final BoxBorder? border;
  final VoidCallback? onTap;

  const PrimaryAuthButton({
    super.key,
    required this.label,
    this.border,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        minimumSize: Size(double.infinity, 50.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class AuthSwitchRow extends StatelessWidget {
  final String question;
  final String action;
  final VoidCallback? onTap;

  const AuthSwitchRow({
    super.key,
    required this.question,
    required this.action,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(question),
        TextButton(
          onPressed: onTap,
          child: Text(
            action,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

class AuthFieldLabel extends StatelessWidget {
  final String label;

  const AuthFieldLabel({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
    );
  }
}

class AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String iconAsset;
  final String hint;
  final ValueNotifier<bool>? obscurePassword;
  final Key? toggleVisibilityKey;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.iconAsset,
    required this.hint,
    this.obscurePassword,
    this.toggleVisibilityKey,
  });

  @override
  Widget build(BuildContext context) {
    if (obscurePassword != null) {
      return ValueListenableBuilder<bool>(
        valueListenable: obscurePassword!,
        builder: (context, isObscured, _) {
          return TextField(
            controller: controller,
            obscureText: isObscured,
            decoration: InputDecoration(
              hintText: hint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
              suffixIcon: IconButton(
                key: toggleVisibilityKey,
                icon: Icon(
                  isObscured ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  obscurePassword!.value = !obscurePassword!.value;
                },
              ),
            ),
          );
        },
      );
    }

    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
      ),
    );
  }
}

// Color Utility class နမူနာ (မရှိသေးပါက သုံးနိုင်ရန်)
class AuthColors {
  static AuthColors of(BuildContext context) => AuthColors();
  Color get secondary => Colors.grey;
}

class AppColors {
  static const Color accent = Colors.blue;
}
