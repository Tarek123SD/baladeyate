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
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: files.length,
      itemBuilder: (context, index) {
        final file = files[index];
        final isPdf = file.extension?.toLowerCase() == 'pdf';

        return Card(
          margin: EdgeInsets.only(bottom: 8.h(context)),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r(context)),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 12.w(context),
              vertical: 8.h(context),
            ),
            child: Row(
              textDirection: TextDirection.rtl,
              children: [
                Container(
                  padding: EdgeInsets.all(8.r(context)),
                  decoration: BoxDecoration(
                    color: isPdf
                        ? Colors.red.withValues(alpha: 0.1)
                        : Colors.blue.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isPdf ? Icons.picture_as_pdf : Icons.image,
                    color: isPdf ? Colors.red : Colors.blue,
                    size: 20.s(context),
                  ),
                ),
                SizedBox(width: 12.w(context)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        file.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          fontSize: 13.s(context),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 2.h(context)),
                      Text(
                        _formatFileSize(file.size),
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          fontSize: 11.s(context),
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => onRemove(index),
                ),
              ],
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
