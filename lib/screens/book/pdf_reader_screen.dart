import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:async';
import '../../providers/theme_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../models/book_model.dart';
import '../../widgets/glass_widgets.dart';

class PDFReaderScreen extends StatefulWidget {
  final BookModel book;

  const PDFReaderScreen({super.key, required this.book});

  @override
  State<PDFReaderScreen> createState() => _PDFReaderScreenState();
}

class _PDFReaderScreenState extends State<PDFReaderScreen> {
  late PDFViewController _pdfViewController;
  String? _localPath;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  int _currentPage = 0;
  int _totalPages = 0;
  double _downloadProgress = 0.0;
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    _loadPDF();
  }

  Future<void> _loadPDF() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _isDownloading = true;
    });

    try {
      final file = await _downloadFile(widget.book.fileUrl, widget.book.title);
      if (mounted) {
        setState(() {
          _localPath = file.path;
          _isLoading = false;
          _isDownloading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Failed to load PDF: $e';
          _isLoading = false;
          _isDownloading = false;
        });
      }
    }
  }

  Future<File> _downloadFile(String url, String filename) async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final file = File('${appDocDir.path}/$filename.pdf');

    if (await file.exists()) {
      return file;
    }

    final request = http.Request('GET', Uri.parse(url));
    final response = await request.send();

    if (response.statusCode == 200) {
      final contentLength = response.contentLength ?? 0;
      var downloadedBytes = 0;

      final sink = file.openWrite();
      await for (final chunk in response.stream) {
        sink.add(chunk);
        downloadedBytes += chunk.length;

        if (contentLength > 0 && mounted) {
          setState(() {
            _downloadProgress = downloadedBytes / contentLength;
          });
        }
      }
      await sink.close();

      return file;
    } else {
      throw Exception('Failed to download file: ${response.statusCode}');
    }
  }

  void _onPDFViewCreated(PDFViewController controller) {
    _pdfViewController = controller;
  }

  void _onPageChanged(int? page, int? total) {
    if (mounted && page != null && total != null) {
      setState(() {
        _currentPage = page;
        _totalPages = total;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          child: GlassContainer(
            blurSigma: 10,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [
                          AppColors.primaryBlack.withOpacity(0.8),
                          AppColors.primaryBlack.withOpacity(0.6),
                        ]
                      : [
                          AppColors.accentWhite.withOpacity(0.8),
                          AppColors.accentWhite.withOpacity(0.6),
                        ],
                ),
              ),
            ),
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: isDark ? AppColors.accentWhite : AppColors.primaryBlack,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.book.title,
          style: TextStyle(
            color: isDark ? AppColors.accentWhite : AppColors.primaryBlack,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          if (!_isLoading && !_hasError)
            IconButton(
              icon: Icon(
                Icons.bookmark_border,
                color: isDark ? AppColors.accentWhite : AppColors.primaryBlack,
              ),
              onPressed: () {
                // TODO: Implement bookmark functionality
              },
            ),
          IconButton(
            icon: Icon(
              Icons.more_vert,
              color: isDark ? AppColors.accentWhite : AppColors.primaryBlack,
            ),
            onPressed: () {
              _showOptionsMenu(context, isDark);
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: const [0.0, 0.5, 1.0],
            colors: isDark
                ? [
                    const Color(0xFF0A0A0A), // Deep black
                    const Color(0xFF1E1E2E), // Dark navy
                    const Color(0xFF2A2A3A), // Medium dark
                  ]
                : [
                    const Color(0xFFFFFFFF), // Pure white
                    const Color(0xFFF8F8FA), // Very light gray
                    const Color(0xFFF0F0F2), // Light gray
                  ],
          ),
        ),
        child: SafeArea(child: _buildBody(isDark)),
      ),
      bottomNavigationBar: !_isLoading && !_hasError && _totalPages > 0
          ? _buildNavigationBar(isDark)
          : null,
    );
  }

  Widget _buildBody(bool isDark) {
    if (_isLoading || _isDownloading) {
      return _buildLoadingView(isDark);
    }

    if (_hasError) {
      return _buildErrorView(isDark);
    }

    if (_localPath == null) {
      return _buildErrorView(isDark);
    }

    return Container(
      margin: const EdgeInsets.all(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: GlassContainer(
          blurSigma: 10,
          child: PDFView(
            filePath: _localPath!,
            enableSwipe: true,
            swipeHorizontal: false,
            autoSpacing: false,
            pageSnap: true,
            defaultPage: _currentPage,
            fitPolicy: FitPolicy.BOTH,
            preventLinkNavigation: false,
            onViewCreated: _onPDFViewCreated,
            onPageChanged: _onPageChanged,
            onError: (error) {
              setState(() {
                _hasError = true;
                _errorMessage = error.toString();
              });
            },
            onPageError: (page, error) {
              print('Error on page $page: $error');
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingView(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GlassContainer(
            blurSigma: 20,
            borderRadius: 20,
            child: Container(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.accentGold,
                    ),
                    value: _isDownloading ? _downloadProgress : null,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _isDownloading ? 'Downloading PDF...' : 'Loading PDF...',
                    style: TextStyle(
                      color: isDark
                          ? AppColors.accentWhite
                          : AppColors.primaryBlack,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (_isDownloading && _downloadProgress > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(
                        '${(_downloadProgress * 100).toInt()}%',
                        style: TextStyle(
                          color: AppColors.accentGold,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GlassContainer(
            blurSigma: 20,
            borderRadius: 20,
            child: Container(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 24),
                  Text(
                    'Error Loading PDF',
                    style: TextStyle(
                      color: isDark
                          ? AppColors.accentWhite
                          : AppColors.primaryBlack,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage,
                    style: TextStyle(
                      color: isDark
                          ? AppColors.accentWhite.withOpacity(0.7)
                          : AppColors.primaryBlack.withOpacity(0.7),
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _loadPDF,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentGold,
                      foregroundColor: AppColors.primaryBlack,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Retry',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationBar(bool isDark) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: GlassContainer(
        blurSigma: 20,
        borderRadius: 20,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: _currentPage > 0 ? _previousPage : null,
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: _currentPage > 0
                      ? (isDark
                            ? AppColors.accentWhite
                            : AppColors.primaryBlack)
                      : (isDark
                            ? AppColors.accentWhite.withOpacity(0.3)
                            : AppColors.primaryBlack.withOpacity(0.3)),
                ),
              ),
              Text(
                'Page ${_currentPage + 1} of $_totalPages',
                style: TextStyle(
                  color: isDark
                      ? AppColors.accentWhite
                      : AppColors.primaryBlack,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              IconButton(
                onPressed: _currentPage < _totalPages - 1 ? _nextPage : null,
                icon: Icon(
                  Icons.arrow_forward_ios,
                  color: _currentPage < _totalPages - 1
                      ? (isDark
                            ? AppColors.accentWhite
                            : AppColors.primaryBlack)
                      : (isDark
                            ? AppColors.accentWhite.withOpacity(0.3)
                            : AppColors.primaryBlack.withOpacity(0.3)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pdfViewController.setPage(_currentPage - 1);
    }
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pdfViewController.setPage(_currentPage + 1);
    }
  }

  void _showOptionsMenu(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        child: GlassContainer(
          blurSigma: 20,
          borderRadius: 20,
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.accentWhite.withOpacity(0.3)
                        : AppColors.primaryBlack.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                _buildOptionItem(
                  icon: Icons.bookmark_add_outlined,
                  title: 'Add Bookmark',
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Implement bookmark functionality
                  },
                  isDark: isDark,
                ),
                _buildOptionItem(
                  icon: Icons.content_copy,
                  title: 'Copy Page',
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Implement copy functionality
                  },
                  isDark: isDark,
                ),
                _buildOptionItem(
                  icon: Icons.search,
                  title: 'Search in Book',
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Implement search functionality
                  },
                  isDark: isDark,
                ),
                _buildOptionItem(
                  icon: Icons.brightness_6,
                  title: 'Reading Mode',
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Implement reading mode toggle
                  },
                  isDark: isDark,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDark ? AppColors.accentWhite : AppColors.primaryBlack,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDark ? AppColors.accentWhite : AppColors.primaryBlack,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
