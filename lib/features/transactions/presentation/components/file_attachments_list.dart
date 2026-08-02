import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class FileAttachmentsList extends StatelessWidget {
  final List<PlatformFile> files;
  final Function(int) onRemove;

  const FileAttachmentsList({
    super.key,
    required this.files,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    if (files.isEmpty) return const SizedBox.shrink();

    final primaryColor = Theme.of(context).colorScheme.primary;

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: files.length,
      itemBuilder: (context, index) {
        final file = files[index];
        final isPdf = file.extension?.toLowerCase() == 'pdf';

        return Card(
          elevation: 0,
          color: Colors.grey.shade100,
          margin: EdgeInsets.only(bottom: 8.h(context)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r(context)),
          ),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(
              horizontal: 12.w(context),
              vertical: 4.h(context),
            ),
            leading: Container(
              padding: EdgeInsets.all(8.r(context)),
              decoration: BoxDecoration(
                color: isPdf
                    ? Colors.red.withValues(alpha: 0.1)
                    : primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isPdf ? Icons.picture_as_pdf : Icons.image,
                color: isPdf ? Colors.red : primaryColor,
                size: 22.s(context),
              ),
            ),
            title: Text(
              file.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                fontSize: 13.s(context),
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            subtitle: Text(
              _formatFileSize(file.size),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                fontSize: 11.s(context),
                color: Colors.grey.shade800,
              ),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => onRemove(index),
              tooltip: 'حذف الملف',
            ),
          ),
        );
      },
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    double size = bytes.toDouble();
    int suffixIndex = 0;
    while (size >= 1024 && suffixIndex < suffixes.length - 1) {
      size /= 1024;
      suffixIndex++;
    }
    return "${size.toStringAsFixed(1)} ${suffixes[suffixIndex]}";
  }
}
