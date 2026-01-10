import 'package:flats_app/Services/edit_reservation_service.dart';
import 'package:flats_app/widgets/snack_bar.dart';
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
        final theme = Theme.of(context);
        return Theme(
          data: theme.copyWith(
            useMaterial3: true,
            datePickerTheme: DatePickerThemeData(
              backgroundColor: theme.cardColor,
              surfaceTintColor: Colors.transparent,
              headerBackgroundColor: theme.primaryColor,
              headerForegroundColor: theme.cardColor,
            ),
            colorScheme: theme.colorScheme.copyWith(
              surface: theme.cardColor,
              onSurface: theme.textTheme.bodyLarge!.color!,
              primary: theme.primaryColor,
              onPrimary: theme.cardColor,
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
        final theme = Theme.of(context);
        return Theme(
          data: theme.copyWith(
            useMaterial3: true,
            datePickerTheme: DatePickerThemeData(
              backgroundColor: theme.cardColor,
              surfaceTintColor: Colors.transparent,
              headerBackgroundColor: theme.primaryColor,
              headerForegroundColor: theme.cardColor,
            ),
            colorScheme: theme.colorScheme.copyWith(
              surface: theme.cardColor,
              onSurface: theme.textTheme.bodyLarge!.color!,
              primary: theme.primaryColor,
              onPrimary: theme.cardColor,
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
        backgroundColor: Theme.of(context).cardColor,
        title: const Text('Edit reservation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            buildBlueTextField(
              context: context,
              controller: startDateController,
              label: 'Start date',
              readOnly: true,
              onTap: pickStartDate,
            ),

            const SizedBox(height: 10),

            buildBlueTextField(
              context: context,
              controller: endDateController,
              label: 'End date',
              readOnly: true,
              onTap: pickEndDate,
            ),

            const SizedBox(height: 10),

            buildBlueTextField(
              context: context,
              controller: bankController,
              label: 'Bank account number (optional)',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: isLoading ? null : () => Navigator.pop(context),
            child: Text(
              'Back',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge!.color!,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
            ),
            onPressed: isLoading ? null : submitEdit,
            child: isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Theme.of(context).primaryColor,
                    ),
                  )
                : Text(
                    'Apply edits',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge!.color!,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

Widget buildBlueTextField({
  required BuildContext context,
  required TextEditingController controller,
  required String label,
  bool readOnly = false,
  VoidCallback? onTap,
}) {
  return TextField(
    controller: controller,
    readOnly: readOnly,
    onTap: onTap,
    cursorColor: Theme.of(context).primaryColor,
    decoration: InputDecoration(
      suffixIcon: readOnly
          ? Icon(
              Icons.calendar_month,
              color: Theme.of(context).textTheme.bodyLarge!.color!,
            )
          : null,
      labelText: label,
      floatingLabelStyle: TextStyle(color: Theme.of(context).primaryColor),
      labelStyle: TextStyle(
        color: Theme.of(context).textTheme.bodyLarge!.color!,
        fontSize: 15,
      ),
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(
          color: Theme.of(context).textTheme.bodyLarge!.color!,
        ),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
      ),
    ),
  );
}
