import 'package:flats_app/Services/edit_reservation_service.dart';
import 'package:flats_app/models/snack_bar.dart';
import 'package:flutter/material.dart';

class EditReservationDialog extends StatefulWidget {
  final int reservationId;
  final DateTime oldStartDate;
  final DateTime oldEndDate;

  const EditReservationDialog({
    super.key,
    required this.reservationId,
    required this.oldStartDate,
    required this.oldEndDate,
  });

  @override
  State<EditReservationDialog> createState() => _EditReservationDialogState();
}

class _EditReservationDialogState extends State<EditReservationDialog> {
  late final String originalStartDate;
  late final String originalEndDate;
  late final String originalBankAccount;

  late TextEditingController startDateController;
  late TextEditingController endDateController;
  final TextEditingController bankController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    originalStartDate = widget.oldStartDate.toIso8601String().split('T').first;

    originalEndDate = widget.oldEndDate.toIso8601String().split('T').first;

    originalBankAccount = '';

    startDateController = TextEditingController(text: originalStartDate);

    endDateController = TextEditingController(text: originalEndDate);
  }

  Future<void> pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      initialDate: widget.oldStartDate.isAfter(DateTime.now())
          ? widget.oldStartDate
          : DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Colors.blue),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        startDateController.text = picked.toIso8601String().split('T').first;
        if (endDateController.text.isNotEmpty) {
          final end = DateTime.parse(endDateController.text);
          if (end.isBefore(picked)) {
            endDateController.clear();
          }
        }
      });
    }
  }

  Future<void> pickEndDate() async {
    if (startDateController.text.isEmpty) {
      mySnackBar(context, 'Choose start date first', color: Colors.amber);
      return;
    }
    final start = DateTime.parse(startDateController.text);
    final picked = await showDatePicker(
      context: context,
      firstDate: start.add(const Duration(days: 1)),
      lastDate: DateTime(2100),
      initialDate: start.add(const Duration(days: 1)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Colors.blue),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      endDateController.text = picked.toIso8601String().split('T').first;
    }
  }

  Future<void> submitEdit() async {
    final isStartSame = startDateController.text == originalStartDate;

    final isEndSame = endDateController.text == originalEndDate;

    final isBankSame = bankController.text.trim() == originalBankAccount;

    if (isStartSame && isEndSame && isBankSame) {
      Navigator.pop(context);
      return;
    }
    if (startDateController.text.isEmpty || endDateController.text.isEmpty) {
      mySnackBar(context, 'Enter start and end dates', color: Colors.amber);
      return;
    }
    setState(() => isLoading = true);

    final errorMessage = await editReservation(
      reservationId: widget.reservationId,
      startDate: startDateController.text,
      endDate: endDateController.text,
      bankAccount: bankController.text,
    );
    if (errorMessage != null) {
      mySnackBar(context, errorMessage, color: Colors.red);
    } else {
      mySnackBar(
        context,
        'Request has been sent successfully',
        color: Colors.green,
      );
      Navigator.pop(context);
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: AlertDialog(
        title: const Text('Edit reservation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            buildBlueTextField(
              controller: startDateController,
              label: 'Start date',
              readOnly: true,
              onTap: pickStartDate,
            ),

            const SizedBox(height: 10),

            buildBlueTextField(
              controller: endDateController,
              label: 'End date',
              readOnly: true,
              onTap: pickEndDate,
            ),

            const SizedBox(height: 10),

            buildBlueTextField(
              controller: bankController,
              label: 'Bank account number (optional)',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: isLoading ? null : () => Navigator.pop(context),
            child: const Text('Back', style: TextStyle(color: Colors.blue)),
          ),
          ElevatedButton(
            onPressed: isLoading ? null : submitEdit,
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(color: Colors.blue),
                  )
                : const Text(
                    'Apply edits',
                    style: TextStyle(color: Colors.blue),
                  ),
          ),
        ],
      ),
    );
  }
}

Widget buildBlueTextField({
  required TextEditingController controller,
  required String label,
  bool readOnly = false,
  VoidCallback? onTap,
}) {
  return TextField(
    controller: controller,
    readOnly: readOnly,
    onTap: onTap,
    cursorColor: Colors.blue,
    decoration: InputDecoration(
      suffixIcon: readOnly
          ? const Icon(Icons.calendar_month, color: Colors.grey)
          : null,
      labelText: label,
      floatingLabelStyle: const TextStyle(color: Colors.blue),
      labelStyle: const TextStyle(color: Colors.grey, fontSize: 15),
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.grey),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.blue, width: 2),
      ),
    ),
  );
}
