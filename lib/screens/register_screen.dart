import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pos_nlh/localizations/app_localizations.dart';
import 'package:pos_nlh/utils/responsive.dart';
import 'package:pos_nlh/widgets/app_gap.dart';
import 'package:pos_nlh/widgets/auth_widgets.dart';

class RegisterScreen extends StatefulWidget {
  final VoidCallback? onSignIn;

  const RegisterScreen({super.key, this.onSignIn});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _shopNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final ValueNotifier<bool> _obscurePassword = ValueNotifier<bool>(true);
  final ValueNotifier<bool> _obscureConfirmPassword = ValueNotifier<bool>(true);
  final ValueNotifier<bool> _termsAccepted = ValueNotifier<bool>(false);

  bool _isLoading = false;

  @override
  void dispose() {
    _shopNameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _obscurePassword.dispose();
    _obscureConfirmPassword.dispose();
    _termsAccepted.dispose();
    super.dispose();
  }

  // Firebase Auth + Firestore Register Logic
  Future<void> _handleSignUp() async {
    FocusScope.of(context).unfocus();

    final shopName = _shopNameController.text.trim();
    final phone = _phoneController.text.trim();
    final location = _locationController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    // 1. Validation စစ်ဆေးခြင်း
    if (shopName.isEmpty ||
        phone.isEmpty ||
        location.isEmpty ||
        email.isEmpty ||
        password.isEmpty) {
      _showSnackBar('အချက်အလက်များကို အပြည့်အစုံ ဖြည့်စွက်ပါ');
      return;
    }

    if (password.length < 8) {
      _showSnackBar('Password သည် အနည်းဆုံး ၈ လုံး ရှိရပါမည်');
      return;
    }

    if (password != confirmPassword) {
      _showSnackBar('Password နှင့် Confirm Password တူညီမှု မရှိပါ');
      return;
    }

    if (!_termsAccepted.value) {
      _showSnackBar('စည်းကမ်းချက်များကို လက်ခံပေးရန် လိုအပ်ပါသည်');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 2. Firebase Auth ဖြင့် User အကောင့်သစ် တည်ဆောက်ခြင်း
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      final String uid = userCredential.user!.uid;

      // 3. Firestore ၏ "Shops" collection ထဲတွင် Shop Data သွားရောက်သိမ်းဆည်းခြင်း
      await FirebaseFirestore.instance.collection('Shops').doc(uid).set({
        'uid': uid,
        'shopName': shopName,
        'phoneNo': phone,
        'location': location,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      _showSnackBar('Register အောင်မြင်စွာ ပြုလုပ်ပြီးပါပြီ');

      // Login Screen သို့မဟုတ် Home Screen သို့ လမ်းကြောင်းပြောင်းရန်
      if (widget.onSignIn != null) {
        widget.onSignIn!();
      } else {
        Navigator.of(context).pop();
      }
    } on FirebaseAuthException catch (e) {
      _showSnackBar(_getAuthErrorMessage(e.code));
    } catch (e) {
      _showSnackBar('အမှားတစ်ခု ဖြစ်ပွားခဲ့ပါသည်: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'ဒီ Email က အသုံးပြုပြီးသား ဖြစ်နေပါသည်။';
      case 'invalid-email':
        return 'Email ပုံစံ မမှန်ကန်ပါ။';
      case 'weak-password':
        return 'Password သည် အနည်းဆုံး ၈ လုံး ရှိရပါမည်။';
      default:
        return 'Register ပြုလုပ်၍ မရပါ၊ ပြန်လည် ကြိုးစားကြည့်ပါ။';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final verticalPadding = 24.h;
              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: 18.w,
                  vertical: verticalPadding,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - verticalPadding * 2,
                  ),
                  child: ResponsiveCenter(
                    maxWidth: ResponsiveContext.maxListWidth,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const _SignUpTitle(),
                        AppGap.height(20.h),
                        _buildForm(context),
                        AppGap.height(16.h),
                        _TermsRow(accepted: _termsAccepted),
                        AppGap.height(16.h),
                        _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : PrimaryAuthButton(
                                label: AppLocalizations.of(context).signUp,
                                border: Border.all(
                                  color: const Color(0xFFF5F1E9),
                                  width: 1,
                                ),
                                onTap: _handleSignUp,
                              ),
                        AppGap.height(20.h),
                        AuthSwitchRow(
                          question: AppLocalizations.of(
                            context,
                          ).alreadyHaveAccount,
                          action: AppLocalizations.of(context).signIn,
                          onTap: widget.onSignIn,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Shop Name
        const AuthFieldLabel(label: 'Shop Name'),
        AppGap.height(6.h),
        AuthTextField(
          key: const Key('shop_name_field'),
          controller: _shopNameController,
          iconAsset: 'assets/icons/login/account_icon.svg',
          hint: 'Enter your shop name',
        ),
        AppGap.height(12.h),

        // 2. Phone Number
        const AuthFieldLabel(label: 'Phone Number'),
        AppGap.height(6.h),
        AuthTextField(
          key: const Key('phone_field'),
          controller: _phoneController,
          iconAsset: 'assets/icons/login/phone.svg',
          hint: 'Enter phone number',
        ),
        AppGap.height(12.h),

        // 3. Location
        const AuthFieldLabel(label: 'Location'),
        AppGap.height(6.h),
        AuthTextField(
          key: const Key('location_field'),
          controller: _locationController,
          iconAsset: 'assets/icons/login/location.svg',
          hint: 'Enter shop location / address',
        ),
        AppGap.height(12.h),

        // 4. Email
        const AuthFieldLabel(label: 'Email Address'),
        AppGap.height(6.h),
        AuthTextField(
          key: const Key('email_field'),
          controller: _emailController,
          iconAsset: 'assets/icons/login/email_icon.svg',
          hint: 'Enter email address',
        ),
        AppGap.height(12.h),

        // 5. Password
        const AuthFieldLabel(label: 'Password'),
        AppGap.height(6.h),
        AuthTextField(
          key: const Key('password_field'),
          controller: _passwordController,
          iconAsset: 'assets/icons/login/password.svg',
          hint: 'Enter password (min 8 chars)',
          obscurePassword: _obscurePassword,
        ),
        AppGap.height(12.h),

        // 6. Confirm Password
        const AuthFieldLabel(label: 'Confirm Password'),
        AppGap.height(6.h),
        AuthTextField(
          key: const Key('confirm_password_field'),
          controller: _confirmPasswordController,
          iconAsset: 'assets/icons/login/lock.svg',
          hint: 'Re-enter password',
          obscurePassword: _obscureConfirmPassword,
          toggleVisibilityKey: const Key('toggle_confirm_visibility'),
        ),
      ],
    );
  }
}

class _SignUpTitle extends StatelessWidget {
  const _SignUpTitle();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = AuthColors.of(context);
    final textTheme = Theme.of(context).textTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 10.h),
          child: Text(
            l10n.signUpTitle,
            textAlign: TextAlign.center,
            style: textTheme.headlineSmall?.copyWith(height: 1),
          ),
        ),
        AppGap.height(4.h),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 258.w),
          child: Text(
            l10n.signUpSubtitle,
            textAlign: TextAlign.center,
            style: textTheme.bodySmall?.copyWith(color: colors.secondary),
          ),
        ),
      ],
    );
  }
}

class _TermsRow extends StatelessWidget {
  const _TermsRow({required this.accepted});

  final ValueNotifier<bool> accepted;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = AuthColors.of(context);
    final textTheme = Theme.of(context).textTheme;
    final regularStyle = textTheme.bodySmall;
    final accentStyle = regularStyle?.copyWith(
      fontWeight: FontWeight.w500,
      color: AppColors.accent,
    );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ValueListenableBuilder<bool>(
          valueListenable: accepted,
          builder: (context, value, _) {
            return Checkbox(
              key: const Key('terms_checkbox'),
              value: value,
              onChanged: (next) => accepted.value = next ?? false,
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              side: BorderSide(color: colors.secondary, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.r),
              ),
            );
          },
        ),
        AppGap.width(8.w),
        Expanded(
          child: Text.rich(
            TextSpan(
              style: regularStyle,
              children: [
                TextSpan(text: l10n.byContinuing),
                TextSpan(text: l10n.termsAndConditions, style: accentStyle),
                TextSpan(text: l10n.andWord),
                TextSpan(text: l10n.privacyPolicy, style: accentStyle),
                TextSpan(text: l10n.agreementEnd, style: accentStyle),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
