import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:stashed/common/widgets/disk_picker.dart';

class FilePicker extends StatelessWidget {
  final String? initialValue;
  final String label;
  final void Function(String? value) onPicked;
  final FormFieldValidator<String>? validator;
  final bool enabled;
  final String? errorText;

  const FilePicker({
    this.initialValue,
    required this.label,
    required this.onPicked,
    this.validator,
    this.enabled = true,
    this.errorText,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return DiskPicker(
      initialValue: initialValue,
      label: label,
      icon: Icons.file_open_outlined,
      onPicked: onPicked,
      validator: validator,
      enabled: enabled,
      onPressed: (textController) async {
        final file = await openFile(initialDirectory: p.dirname(textController.text));
        return file?.path;
      },
      errorText: errorText,
    );
  }
}
