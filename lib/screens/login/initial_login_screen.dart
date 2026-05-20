import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../config/app_settings.dart';
import '../../config/constants.dart';
import '../senior/senior_main.dart';
import 'counselor_login_screen.dart';

class InitialLoginScreen extends StatefulWidget {
  const InitialLoginScreen({super.key});

  @override
  State<InitialLoginScreen> createState() => _InitialLoginScreenState();
}

class _InitialLoginScreenState extends State<InitialLoginScreen> {
  final TextEditingController _pinController = TextEditingController();
  bool _isLoading = false;
  bool _isObscure = true;

  Future<void> _verifyPin(AppSettings settings) async {
    final String inputPin = _pinController.text;
    if (inputPin.length < 4) return;

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 500));

    if (inputPin == MockData.seniorPin) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SeniorMain()),
      );
    } else {
      _pinController.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppTexts.wrongPassword)),
        );
      }
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final settings = SettingsProvider.of(context);
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Header ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    
                    Image.asset(
                      'asset/logomem.png',
                      height: 100,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
              ),
              const Divider(
                height: 1,
                thickness: 2,
                color: AppColors.primary,
              ),

              // --- Content ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 50),
                    Text(
                      AppTexts.passwordInput,
                      style: GoogleFonts.notoSans(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppTexts.enterPassword,
                      style: GoogleFonts.notoSans(
                        fontSize: 20,
                        color: theme.colorScheme.onSurface.withOpacity(0.8),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 60),
                    Text(
                      AppTexts.passwordLabel,
                      style: GoogleFonts.notoSans(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _pinController,
                      obscureText: _isObscure,
                      keyboardType: TextInputType.number,
                      maxLength: 8,
                      style: TextStyle(
                        fontSize: 24,
                        letterSpacing: 4,
                        color: theme.colorScheme.onSurface,
                      ),
                      decoration: InputDecoration(
                        counterText: "",
                        hintText: "••••",
                        hintStyle: const TextStyle(color: Colors.grey),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isObscure
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: Colors.grey,
                            size: 28,
                          ),
                          onPressed: () {
                            setState(() => _isObscure = !_isObscure);
                          },
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: theme.colorScheme.onSurface,
                            width: 2.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: primaryColor,
                            width: 2.5,
                          ),
                        ),
                      ),
                      onChanged: (val) {
                        if (val.length >= 4 && val == MockData.seniorPin) {
                          _verifyPin(settings);
                        }
                      },
                    ),
                    const SizedBox(height: 60),
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            onPressed: () => _verifyPin(settings),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.login,
                                      color: AppColors.primary,
                                      size: 24,
                                    ),
                                  ),
                                ),
                                Text(
                                  AppTexts.loginButton,
                                  style: GoogleFonts.notoSans(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22,
                                  ),
                                ),
                              ],
                            ),
                          ),
                    const SizedBox(height: 24),
                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CounselorLoginScreen(),
                            ),
                          );
                        },
                        child: Text(
                          AppTexts.counselorLoginButton,
                          style: GoogleFonts.notoSans(
                            color: Colors.grey[700],
                            fontSize: 18,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 80),

                    // --- Help Box ---
                    Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SvgPicture.asset(
                            'asset/Border.svg',
                            width: double.infinity,
                            fit: BoxFit.contain,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 30),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.help_outline,
                                  size: 40,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  "로그인이 어려우신가요?",
                                  style: GoogleFonts.notoSans(
                                    fontSize: 16,
                                    color: Colors.grey[800],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  AppTexts.helpCenter,
                                  style: GoogleFonts.notoSans(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[800],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
