import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pos_nlh/localizations/app_localizations.dart';
import 'package:pos_nlh/screens/home_screen.dart';
import 'package:pos_nlh/screens/register_screen.dart';
import 'package:pos_nlh/utils/responsive.dart';
import 'package:pos_nlh/widgets/app_gap.dart';
import 'package:pos_nlh/widgets/auth_widgets.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback? onSignUpTap;

  const LoginScreen({super.key, this.onSignUpTap});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ValueNotifier<bool> _obscurePassword = ValueNotifier<bool>(true);

  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _obscurePassword.dispose();
    super.dispose();
  }

  // Firebase Auth Login Logic
  Future<void> _handleSignIn() async {
    FocusScope.of(context).unfocus();

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    // 1. Input Validation စစ်ဆေးခြင်း
    if (email.isEmpty || password.isEmpty) {
      _showSnackBar('Email နှင့် Password ကို ဖြည့်သွင်းပေးပါ');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 2. Firebase Auth ဖြင့် Sign In လုပ်ခြင်း
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      final String uid = userCredential.user!.uid;

      // 3. Firestore ရှိ 'shopName' collection မှ အချက်အလက်များ ဖတ်ယူစစ်ဆေးခြင်း
      DocumentSnapshot shopDoc = await FirebaseFirestore.instance
          .collection('Shops')
          .doc(uid)
          .get();

      if (!mounted) return;

      if (shopDoc.exists) {
        final shopData = shopDoc.data() as Map<String, dynamic>?;
        final shopName = shopData?['shopName'] ?? 'Shop';
        _showSnackBar('$shopName မှ ကြိုဆိုပါသည်');
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => HomeScreen()));
      } else {
        _showSnackBar('Login အောင်မြင်ပါသည်');
      }

      // TODO: Login အောင်မြင်ပါက Home Screen သို့ လမ်းကြောင်းပြောင်းရန် (ဥပမာ- Navigator.pushReplacement)
    } on FirebaseAuthException catch (e) {
      _showSnackBar(_getAuthErrorMessage(e.code));
    } catch (e) {
      _showSnackBar('အမှားတစ်ခု ဖြစ်ပွားခဲ့ပါသည်: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'ဒီ Email ဖြင့် အကောင့်ဖွင့်ထားခြင်း မရှိပါ။';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email သို့မဟုတ် Password မှားယွင်းနေပါသည်။';
      case 'invalid-email':
        return 'Email ပုံစံ မမှန်ကန်ပါ။';
      case 'user-disabled':
        return 'ဒီ အကောင့်ကို ခေတ္တ ပိတ်ထားပါသည်။';
      default:
        return 'Login ဝင်ရောက်၍ မရပါ၊ ပြန်လည် ကြိုးစားကြည့်ပါ။';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

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
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const _LoginTitle(),
                        AppGap.height(32.h),
                        _buildForm(context),
                        AppGap.height(12.h),

                        // Forgot Password
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              // TODO: Forgot Password Screen သို့ သွားရန်
                            },
                            child: const Text('Forgot Password?'),
                          ),
                        ),

                        AppGap.height(16.h),

                        // Login Button
                        _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : PrimaryAuthButton(
                                label: l10n.signIn,
                                onTap: _handleSignIn,
                              ),

                        AppGap.height(24.h),

                        // Register သို့ သွားရန် Button / Link
                        AuthSwitchRow(
                          question: "Don't have an account?",
                          action: l10n.signUp,
                          onTap:
                              widget.onSignUpTap ??
                              () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => RegisterScreen(
                                      onSignIn: () =>
                                          Navigator.of(context).pop(),
                                    ),
                                  ),
                                );
                              },
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
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Email Field
        AuthFieldLabel(label: l10n.emailOrPhoneNumber),
        AppGap.height(6.h),
        AuthTextField(
          key: const Key('login_email_field'),
          controller: _emailController,
          iconAsset: 'assets/icons/login/email_icon.svg',
          hint: l10n.emailOrPhoneNumberHint,
        ),
        AppGap.height(16.h),

        // Password Field
        AuthFieldLabel(label: l10n.passwordLabel),
        AppGap.height(6.h),
        AuthTextField(
          key: const Key('login_password_field'),
          controller: _passwordController,
          iconAsset: 'assets/icons/login/lock.svg',
          hint: l10n.passwordLabel,
          obscurePassword: _obscurePassword,
        ),
      ],
    );
  }
}

class _LoginTitle extends StatelessWidget {
  const _LoginTitle();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Welcome Back!',
          textAlign: TextAlign.center,
          style: textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        AppGap.height(6.h),
        Text(
          'Please sign in to continue to your POS store',
          textAlign: TextAlign.center,
          style: textTheme.bodyMedium?.copyWith(color: Colors.grey),
        ),
      ],
    );
  }
}
