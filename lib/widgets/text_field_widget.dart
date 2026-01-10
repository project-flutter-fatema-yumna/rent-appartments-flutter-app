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
    return TextField(
      controller: controller,
      cursorColor: Theme.of(context).primaryColor,
      textInputAction: textInputAction,
      keyboardType: keyboardType,
      obscureText: obscureText,
      readOnly: readOnly,
      onTap: onTap,
      decoration: InputDecoration(
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
        fillColor: Theme.of(context).cardColor,
        filled: true,
        hintText: hint,
        icon: Icon(icon, color: Theme.of(context).textTheme.bodyLarge!.color),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: onToggleVisibility,
              )
            : suffixIcon,
        suffixIconColor: Theme.of(context).textTheme.bodyLarge!.color,
        hintStyle: TextStyle(
          color: Theme.of(context).textTheme.bodyLarge!.color,
        ),
      ),
      inputFormatters: inputFormatters,
    );
  }
}
