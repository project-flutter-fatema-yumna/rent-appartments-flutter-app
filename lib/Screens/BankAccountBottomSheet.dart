import 'package:flutter/material.dart';

import '../Services/reserveApartment.dart';
import 'finally.dart';

class BankAccountBottomSheet extends StatefulWidget {
  final String token;
  final int apartmentId;
  final DateTimeRange range;
  BankAccountBottomSheet({
    required this.token,
    required this.apartmentId,
    required this.range,
  });

  @override
  State<BankAccountBottomSheet> createState() => _BankAccountBottomSheetState();
}

class _BankAccountBottomSheetState extends State<BankAccountBottomSheet> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController _bankController = TextEditingController();
  bool _loading = false;
  String? _serverError;


  //statusCode
  int? extractStatusCode(Object e) {
    final text = e.toString();
    final match = RegExp(r'Error\s+(\d{3})').firstMatch(text);
    if (match == null) return null;
    return int.tryParse(match.group(1)!);
  }

  bool get _isValidBank {
    final text = _bankController.text.trim();
    return RegExp(r'^\d{4}-\d{4}-\d{4}$').hasMatch(text);
  }

  String formatDate(DateTime d) {
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '${d.year}-$m-$day';
  }

  @override
  void dispose() {
    _bankController.dispose();
    super.dispose();
  }

  /*Future<void> _submit() async {
    if (!formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      final data = {
        "apartment_id": widget.apartmentId,
        "start_date": formatDate(widget.range.start),
        "end_date": formatDate(widget.range.end),
        "account_number": _bankController.text.trim(),
      };

      final Reserve = await reserveService().reserveApatment(
        token: widget.token,
        data: data,
      );
      print("RESERVE RESPONSE: $Reserve");
      if (!mounted) return;
      Navigator.pop(context);

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (_) => const FinallyPage(),
      );
    } catch (e) {
      if (!mounted) return;

      final code = extractStatusCode(e);

      String message;
      if (code == 422) {
        message = 'رقم الحساب غير صحيح، تأكدي من الرقم';
      } else if (code == 401) {
        message = 'انتهت صلاحية الجلسة، سجّلي دخول من جديد';
      } else {
        message = 'حدث خطأ غير متوقع، حاولي مرة ثانية';
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }*/
  Future<void> _submit() async {
    if (!formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _serverError = null;
    });

    try {
      final data = {
        "apartment_id": widget.apartmentId,
        "start_date": formatDate(widget.range.start),
        "end_date": formatDate(widget.range.end),
        "account_number": _bankController.text.trim(),
      };

      final reserve = await reserveService().reserveApatment(
        token: widget.token,
        data: data,
      );

      print("RESERVE RESPONSE: $reserve");

      if (!mounted) return;
      Navigator.pop(context,true);

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (_) => const FinallyPage(),
      );
    } catch (e) {
      if (!mounted) return;

      final code = extractStatusCode(e);

      setState(() {
        _loading = false;
        if (code == 422) {
          _serverError = 'رقم الحساب غير صحيح، تأكدي من الرقم';
        } else if (code == 401) {
          _serverError = 'انتهت صلاحية الجلسة، سجّلي دخول من جديد';
        } else {
          _serverError = 'حدث خطأ غير متوقع، حاولي مرة ثانية';
        }
      });

      return;
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Center(
                child: const Text(
                  '   Please ensure you have sufficient\nfunds in your account before booking.',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 25),

              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: const Text('Bank Account'),
              ),
              const SizedBox(height: 6),

              Form(
                key: formKey,
                child: TextFormField(
                  controller: _bankController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: '1111-2222-3333',
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: const Icon(Icons.credit_card),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Bank account is required';
                    }
                    final formOfNumber = RegExp(r'^\d{4}-\d{4}-\d{4}$');
                    if (!formOfNumber.hasMatch(value.trim())) {
                      return 'Format must be 1111-2222-3333';
                    }
                    return null;
                  },
                  onChanged: (_) => setState(() {}),
                  onFieldSubmitted: (_) => _submit(),
                ),
              ),
              if (_serverError != null) ...[
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(
                    _serverError!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],


              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: (_loading || !_isValidBank) ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: (_loading || !_isValidBank)
                        ? Colors.grey
                        : Colors.blue,
                    disabledBackgroundColor: Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: _loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Invest Property',
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: -40,
          left: 0,
          right: 0,
          child: Center(
            child: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
                ),
                child: const Icon(Icons.close),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
