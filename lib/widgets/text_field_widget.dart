import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TextFieldWidget extends StatelessWidget {
  final TextEditingController controller;
  final String? hint;
  final IconData? icon;
  final TextInputAction textInputAction;
  final TextInputType keyboardType;
  final bool obscureText;
  final bool isPassword;
  final Widget? suffixIcon;
  final VoidCallback? onToggleVisibility;
  final bool readOnly;
  final VoidCallback? onTap;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;

  const TextFieldWidget({
    super.key,
    required this.controller,
    this.hint,
    this.icon,
    this.textInputAction = TextInputAction.next,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.isPassword = false,
    this.suffixIcon,
    this.onToggleVisibility,
    this.readOnly = false,
    this.onTap,
    this.maxLength,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextField(
      controller: controller,
      cursorColor: theme.primaryColor,
      textInputAction: textInputAction,
      keyboardType: keyboardType,
      obscureText: obscureText,
      readOnly: readOnly,
      onTap: onTap,
      maxLength: maxLength,
      inputFormatters: inputFormatters,
      style: TextStyle(
        color: theme.textTheme.bodyLarge!.color,
        fontSize: 16,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: theme.cardColor,

        hintText: hint,
        hintStyle: TextStyle(
          color: theme.textTheme.bodyLarge!.color!.withOpacity(0.6),
        ),

        // الأيقونة من "داخل" الـ TextField
        prefixIcon: icon == null
            ? null
            : Icon(
          icon,
          color: theme.primaryColor,
        ),

        suffixIcon: isPassword
            ? IconButton(
          icon: Icon(
            obscureText ? Icons.visibility_off : Icons.visibility,
          ),
          color: theme.textTheme.bodyLarge!.color,
          onPressed: onToggleVisibility,
        )
            : suffixIcon,

        counterText: '',

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: theme.primaryColor.withOpacity(0.15),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: theme.primaryColor.withOpacity(0.8),
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Colors.red,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Colors.red,
          ),
        ),

        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
