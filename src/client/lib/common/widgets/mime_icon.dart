import 'package:flutter/material.dart';
import 'package:mime/mime.dart';

class MimeIcon extends StatelessWidget {
  final String? _type;
  final String? _subtype;

  MimeIcon({required String filename, super.key})
      : _type = lookupMimeType(filename)?.split('/')[0],
        _subtype = lookupMimeType(filename)?.split('/')[1];

  @override
  Widget build(BuildContext context) {
    return Badge(
      label: Text(_subtype ?? "???"),
      alignment: Alignment.topRight,
      offset: const Offset(-10, 0),
      backgroundColor: switch (_type) {
        "image" => Colors.redAccent,
        "video" => Colors.blueAccent,
        "audio" => Colors.greenAccent,
        _ => Colors.grey,
      },
      child: Icon(
        size: 48,
        switch (_type) {
          "image" => Icons.image_outlined,
          "video" => Icons.video_file_outlined,
          "audio" => Icons.audio_file_outlined,
          _ => Icons.description_outlined,
        },
      ),
    );
  }
}
