import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'authentication_screens/onboarding_screens.dart';


class SelectLanguageScreen extends StatelessWidget {
  static String id = 'SelectLanguageScreen';

  const SelectLanguageScreen({super.key});

  Future<void> _selectLanguage(
      BuildContext context, String code, Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lang_code', code);
    await context.setLocale(locale);

    Navigator.pushReplacementNamed(context, OnboardingScreen.id);
  }

  @override
  Widget build(BuildContext context) {
    final Color primary = Colors.blue.shade700;
    final Color softBlue = Colors.blue.shade50;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              softBlue,
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  Image.asset(
                    'assets/logo.png',
                    width: 120,
                  ),

                  Text(
                    'Flats App',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: primary,
                      letterSpacing: 0.5,
                    ),
                  ),

                  const Spacer(),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 30),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.96),
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 28,
                          spreadRadius: 0,
                          offset: const Offset(0, 18),
                          color: Colors.black.withOpacity(0.10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'language'.tr(),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Choose the language you prefer for the app.'
                              .tr(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 30),

                        _LanguageOption(
                          title: 'arabic'.tr(),
                          code: 'AR',
                          alignment: Alignment.centerRight,
                          flagText: 'ع',
                          isRtlPreview: true,
                          onTap: () => _selectLanguage(
                            context,
                            'ar',
                            const Locale('ar'),
                          ),
                          primary: primary,
                        ),
                        const SizedBox(height: 16),

                        _LanguageOption(
                          title: 'english'.tr(),
                          code: 'EN',
                          alignment: Alignment.centerRight,
                          flagText: 'EN',
                          isRtlPreview: false,
                          onTap: () => _selectLanguage(
                            context,
                            'en',
                            const Locale('en'),
                          ),
                          primary: primary,
                        ),

                        const SizedBox(height: 12),
                      ],
                    ),
                  ),

                  const Spacer(),

                  Text(
                    'You can change the language later from Settings.'
                        .tr(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String title;
  final String code;
  final String flagText;
  final bool isRtlPreview;
  final Alignment alignment;
  final VoidCallback onTap;
  final Color primary;

  const _LanguageOption({
    required this.title,
    required this.code,
    required this.flagText,
    required this.isRtlPreview,
    required this.alignment,
    required this.onTap,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(40),
      onTap: onTap,
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              primary.withOpacity(0.09),
              Colors.white,
            ],
          ),
          border: Border.all(color: primary.withOpacity(0.2), width: 1),
          boxShadow: [
            BoxShadow(
              blurRadius: 16,
              offset: const Offset(0, 10),
              color: Colors.black.withOpacity(0.06),
            ),
          ],
        ),
        child: Container(
          padding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  flagText,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: primary,
                  ),
                ),
              ),
              const SizedBox(width: 14),

              Expanded(
                child: Align(
                  alignment: alignment,
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: primary.withOpacity(0.7),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
