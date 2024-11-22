import 'package:flutter/material.dart';

class DiskPicker extends StatefulWidget {
  final String? initialValue;
  final String label;
  final IconData icon;
  final Future<String?> Function(TextEditingController textEditingController) onPressed;
  final void Function(String? value) onPicked;
  final FormFieldValidator<String>? validator;
  final bool enabled;
  final String? errorText;

  const DiskPicker({
    this.initialValue,
    required this.label,
    required this.icon,
    required this.onPressed,
    required this.onPicked,
    this.validator,
    this.enabled = true,
    this.errorText,
    super.key,
  });

  @override
  State<DiskPicker> createState() => _DiskPickerState();
}

class _DiskPickerState extends State<DiskPicker> {
  late TextEditingController textController;

  @override
  void initState() {
    super.initState();

    if (widget.initialValue == null) {
      textController = TextEditingController();
    } else {
      textController = TextEditingController(text: widget.initialValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
          child: TextFormField(
            decoration: InputDecoration(
              labelText: widget.label,
              errorText: widget.errorText,
            ),
            enabled: widget.enabled,
            controller: textController,
            onChanged: (value) {
              textController.text = value;
              widget.onPicked(value);
            },
            validator: widget.validator,
          ),
        ),
        IconButton(
          icon: Icon(widget.icon),
          onPressed: widget.enabled
              ? () async {
                  final path = await widget.onPressed(textController);
                  textController.text = path ?? textController.text;
                  widget.onPicked(textController.text);
                }
              : null,
        )
      ],
    );
  }
}
