import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class ComplaintAttachmentGallery extends StatelessWidget {
  const ComplaintAttachmentGallery({
    super.key,
    required this.urls,
  });

  final List<String> urls;

  @override
  Widget build(BuildContext context) {
    if (urls.isEmpty) {
      return Text(
        'لا توجد صور مرفقة من المواطن.',
        style: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 13.f(context),
        ),
      );
    }

    return Wrap(
      spacing: 10.s(context),
      runSpacing: 10.s(context),
      children: [
        for (var index = 0; index < urls.length; index++)
          GestureDetector(
            onTap: () => _openViewer(context, index),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.r(context)),
              child: CachedNetworkImage(
                imageUrl: urls[index],
                width: 110.s(context),
                height: 110.s(context),
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  width: 110.s(context),
                  height: 110.s(context),
                  color: Colors.grey.shade200,
                  alignment: Alignment.center,
                  child: const CircularProgressIndicator(strokeWidth: 2),
                ),
                errorWidget: (context, url, error) => Container(
                  width: 110.s(context),
                  height: 110.s(context),
                  color: Colors.grey.shade200,
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.broken_image_outlined,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _openViewer(BuildContext context, int initialIndex) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => _ComplaintPhotoViewer(
          urls: urls,
          initialIndex: initialIndex,
        ),
      ),
    );
  }
}

class _ComplaintPhotoViewer extends StatefulWidget {
  const _ComplaintPhotoViewer({
    required this.urls,
    required this.initialIndex,
  });

  final List<String> urls;
  final int initialIndex;

  @override
  State<_ComplaintPhotoViewer> createState() => _ComplaintPhotoViewerState();
}

class _ComplaintPhotoViewerState extends State<_ComplaintPhotoViewer> {
  late final PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          title: Text('صور المواطن (${widget.urls.length})'),
        ),
        body: PageView.builder(
          controller: _controller,
          itemCount: widget.urls.length,
          itemBuilder: (context, index) {
            return InteractiveViewer(
              child: Center(
                child: CachedNetworkImage(
                  imageUrl: widget.urls[index],
                  fit: BoxFit.contain,
                  placeholder: (context, url) => const CircularProgressIndicator(),
                  errorWidget: (context, url, error) => const Icon(
                    Icons.broken_image_outlined,
                    color: Colors.white70,
                    size: 48,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
