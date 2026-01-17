import 'package:easy_localization/easy_localization.dart';
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

  late TextEditingController startDateController;
  late TextEditingController endDateController;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    originalStartDate = widget.oldStartDate.toIso8601String().split('T').first;
    originalEndDate = widget.oldEndDate.toIso8601String().split('T').first;

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
      mySnackBar(context, 'choose_start_first'.tr(), color: Colors.amber);
      return;
    }
    final start = DateTime.parse(startDateController.text);

    final picked = await showDatePicker(
      context: context,
      firstDate: start.add(const Duration(days: 1)),
      lastDate: DateTime(2100),
      initialDate: start.add(const Duration(days: 1)),
    );

    if (picked != null) {
      endDateController.text = picked.toIso8601String().split('T').first;
    }
  }

  Future<void> submitEdit() async {
    final isStartSame = startDateController.text == originalStartDate;
    final isEndSame = endDateController.text == originalEndDate;

    if (isStartSame && isEndSame) {
      Navigator.pop(context);
      return;
    }
    if (startDateController.text.isEmpty ||
        endDateController.text.isEmpty) {
      mySnackBar(context, 'enter_dates'.tr(), color: Colors.amber);
      return;
    }

    setState(() => isLoading = true);

    final errorMessage = await editReservation(
      reservationId: widget.reservationId,
      startDate: startDateController.text,
      endDate: endDateController.text,
    );

    if (errorMessage != null) {
      mySnackBar(context, errorMessage, color: Colors.red);
    } else {
      mySnackBar(
        context,
        'request_sent_success'.tr(),
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
        title: Text('edit_reservation'.tr()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            buildBlueTextField(
              context: context,
              controller: startDateController,
              label: 'start_date'.tr(),
              readOnly: true,
              onTap: pickStartDate,
            ),
            const SizedBox(height: 10),
            buildBlueTextField(
              context: context,
              controller: endDateController,
              label: 'end_date'.tr(),
              readOnly: true,
              onTap: pickEndDate,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: isLoading ? null : () => Navigator.pop(context),
            child: Text(
              'back'.tr(),
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
                color: Theme.of(context).cardColor,
              ),
            )
                : Text(
              'apply_edits'.tr(),
              style: const TextStyle(color: Colors.white),
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
    decoration: InputDecoration(
      suffixIcon: readOnly
          ? Icon(Icons.calendar_month,
          color: Theme.of(context).textTheme.bodyLarge!.color!)
          : null,
      labelText: label,
      floatingLabelStyle: TextStyle(color: Theme.of(context).primaryColor),
      labelStyle:
      TextStyle(color: Theme.of(context).textTheme.bodyLarge!.color!),
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
