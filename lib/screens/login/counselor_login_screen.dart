import 'package:flutter/material.dart';
import '../../config/app_settings.dart';
import '../../config/constants.dart';
import '../counselor/counselor_main.dart';

class CounselorLoginScreen extends StatefulWidget {
  const CounselorLoginScreen({super.key});

  @override
  State<CounselorLoginScreen> createState() => _CounselorLoginScreenState();
}

class _CounselorLoginScreenState extends State<CounselorLoginScreen> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();
  bool _isLoading = false;

  Future<void> _verifyCounselorAuth(AppSettings settings) async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));

    if (_idController.text == MockData.counselorId &&
        _pwController.text == MockData.counselorPassword) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CounselorMain()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppTexts.wrongIdPassword)),
      );
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final settings = SettingsProvider.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppTexts.counselorLogin),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            size: 30,
            color: AppColors.primary,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          children: [
            const Icon(
              Icons.admin_panel_settings,
              size: 80,
              color: AppColors.primary,
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _idController,
              decoration: const InputDecoration(
                labelText: AppTexts.counselorId,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _pwController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: AppTexts.passwordLabel,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 30),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () => _verifyCounselorAuth(settings),
                    child: const Text(AppTexts.counselorLoginButton),
                  ),
          ],
        ),
      ),
    );
  }
}
