import 'package:flutter/material.dart';

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
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      cursorColor: Colors.blue,
      textInputAction: textInputAction,
      keyboardType: keyboardType,
      obscureText: obscureText,
      readOnly: readOnly,
      onTap: onTap,
      decoration: InputDecoration(
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.blue),
        ),
        fillColor: Colors.white,
        filled: true,
        hintText: hint,
        icon: Icon(icon, color: Colors.grey),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: onToggleVisibility,
              )
            : suffixIcon,
        suffixIconColor: Colors.grey,
        hintStyle: TextStyle(color: Colors.grey)
      ),
    );
  }
}
