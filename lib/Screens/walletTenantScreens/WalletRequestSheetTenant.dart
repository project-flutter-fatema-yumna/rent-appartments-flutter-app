import 'dart:convert';
import 'package:flats_app/global_data.dart';
import 'package:flats_app/widgets/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Services/take_monyServices.dart';
import '../../authentication_screens/login_screen.dart';
import 'package:easy_localization/easy_localization.dart';

enum WalletRequestType { add, withdraw }

class TenantWalletRequestSheet extends StatefulWidget {
  final WalletRequestType type;
  final double availableAmount;
  final String? message;

  const TenantWalletRequestSheet({
    super.key,
    required this.type,
    required this.availableAmount,
    this.message,
  });

  @override
  State<TenantWalletRequestSheet> createState() =>
      _TenantWalletRequestSheetState();
}

class _TenantWalletRequestSheetState extends State<TenantWalletRequestSheet> {
  final _formKey = GlobalKey<FormState>();
  final amountCtrl = TextEditingController();
  bool _loading = false;

  bool get isWithdraw => widget.type == WalletRequestType.withdraw;

  @override
  void dispose() {
    amountCtrl.dispose();
    super.dispose();
  }

  Future<void> send() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(amountCtrl.text.trim()) ?? 0;

    setState(() => _loading = true);
    try {
      //final prefs = await SharedPreferences.getInstance();
      // final token = prefs.getString('token');
      final String token = userToken;

      if (token == null || token.isEmpty) {
        if (!mounted) return;
        Navigator.pop(context);
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil(LoginScreen.id, (_) => false);
        return;
      }

      await WalletRequestService().sendRequest(
        token: token,
        amount: amount,
        type: isWithdraw ? 'withdraw' : 'add',
      );

      if (!mounted) return;

      Navigator.pop(context);

      mySnackBar(
        context,
        isWithdraw
            ? 'withdraw_request_sent'.tr()
            : 'add_request_sent'.tr(),
        color: Theme.of(context).primaryColor,
      );

    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);

      final raw = e.toString().replaceFirst('Exception: ', '');
      final parts = raw.split('|');
      final code = int.tryParse(parts.first);
      final bodyText = parts.length > 1 ? parts.sublist(1).join('|') : raw;

      String msg = bodyText;
      try {
        final body = jsonDecode(bodyText);
        if (body is Map && body['message'] != null) {
          msg = body['message'].toString();
        }
      } catch (_) {}

      /* if (code == 401) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('token');
        if (!mounted) return;
        Navigator.pop(context);
        Navigator.of(context).pushNamedAndRemoveUntil(LoginScreen.id, (_) => false);
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));*/
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = isWithdraw
        ? 'withdraw_request'.tr()
        : 'add_money_request'.tr();

    final subtitle = widget.message ??
        (isWithdraw
            ? 'withdraw_subtitle'.tr()
            : 'add_subtitle'.tr());


    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 55,
                    color: isWithdraw ? Colors.blueGrey : Theme.of(context).primaryColor,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(subtitle, textAlign: TextAlign.center),
                  const SizedBox(height: 14),
                  
                  // Wallet info box
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Theme.of(context).primaryColor),
                    ),
                    child: Text(
                      '${'available_balance'.tr()} ${widget.availableAmount}',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: amountCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'amount'.tr(),
                      hintText: isWithdraw
                          ? '${'max_hint'.tr()} ${widget.availableAmount}'
                          : 'enter_amount'.tr(),
            
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (v) {
                      final text = (v ?? '').trim();
                      final value = double.tryParse(text);
                      if (value == null || value <= 0) {
                        return 'enter_valid_amount'.tr();
                      }
            
                      if (isWithdraw && value > widget.availableAmount) {
                        return '${'cant_withdraw_more_than'.tr()} ${widget.availableAmount}';
                      }
            
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _loading ? null : send,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        _loading ? 'sending'.tr() : 'send_request_to_admin'.tr(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
