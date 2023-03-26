import 'package:Talkaboat/services/downloading/file-downloader.service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'dart:async';

class DownloadButton extends StatefulWidget {
  const DownloadButton({Key? key, required this.url, required this.clickAction, required this.finishAction}) : super(key: key);
  final String url;
  final clickAction;
  final finishAction;

  @override
  State<DownloadButton> createState() => _DownloadButtonState();
}

class _DownloadButtonState extends State<DownloadButton> {
  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  bool _isDownloaded = false;

  @override
  void initState() {
    super.initState();
    _checkIfDownloaded();
  }

  Future<void> _checkIfDownloaded() async {
    FileInfo? fileInfo = await DefaultCacheManager().getFileFromCache(widget.url);
    setState(() {
      _isDownloaded = fileInfo != null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _onIconPressed(),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (_isDownloading)
            CircularProgressIndicator(
              value: _downloadProgress,
              backgroundColor: Colors.grey[200],
              strokeWidth: 4.0,
            ),
          Icon(
            Icons.cloud_download,
            size: 32.0,
            color: _isDownloaded ? Colors.green : null,
          ),
        ],
      ),
    );
  }


  void _onIconPressed() {
    if (_isDownloaded) {
      _removeFile(widget.url);
    } else {
      _downloadFile(widget.url);
    }
    if(widget.clickAction != null) {
      widget.clickAction();
    }
  }

  Future<void> _removeFile(String url) async {
    await FileDownloadService.removeFile(url);

    setState(() {
      _isDownloaded = false;
    });
  }

  Future<void> _downloadFile(String url) async {
    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
    });

    final fileStream = FileDownloadService.cacheFile(url);

    fileStream.listen(
          (fileResponse) {
        if (fileResponse is DownloadProgress) {
          setState(() {
            _downloadProgress = fileResponse.progress!;
          });
        } else if (fileResponse is FileInfo) {
          setState(() {
            _isDownloading = false;
            _isDownloaded = true;
          });
          if(widget.finishAction != null) {
            widget.finishAction(_isDownloaded);
          }

          // Use the downloaded file (e.g., play the MP3)
        }
      },
      onError: (error) {
        // Handle download error
      },
    );
  }
}
