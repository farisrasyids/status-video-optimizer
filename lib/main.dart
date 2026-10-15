import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';

void main() {
  runApp(const StatusOptimizerApp());
}

class StatusOptimizerApp extends StatelessWidget {
  const StatusOptimizerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Status Optimizer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF25D366),
          secondary: Color(0xFF10B981),
          surface: Color(0xFF1E293B),
        ),
      ),
      home: const OptimizerHomeScreen(),
    );
  }
}

class OptimizerHomeScreen extends StatefulWidget {
  const OptimizerHomeScreen({super.key});

  @override
  State<OptimizerHomeScreen> createState() => _OptimizerHomeScreenState();
}

class _OptimizerHomeScreenState extends State<OptimizerHomeScreen> {
  String? _inputPath;
  String? _outputPath;
  bool _isProcessing = false;
  String _statusText = 'Pilih video untuk mulai mengompres';
  String _selectedResolution = '720p';

  VideoPlayerController? _videoController;
  final TextEditingController _captionController = TextEditingController(); // Tugas 2: Controller caption
  RangeValues _trimRange = const RangeValues(0, 1);
  double _totalDurationInSeconds = 1;

  @override
  void dispose() {
    _videoController?.dispose();
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _pickVideo() async {
    final result = await FilePicker.pickFiles(
      type: FileType.video,
    );

    if (result != null && result.isNotEmpty && result.first.path != null) {
      final selectedPath = result.first.path!;
      
      // Bersihkan pemutar lama jika ada
      await _videoController?.dispose();
      
      // Inisialisasi video player baru
      final controller = VideoPlayerController.file(File(selectedPath));
      await controller.initialize();

      final duration = controller.value.duration.inMilliseconds / 1000.0;

      setState(() {
        _inputPath = selectedPath;
        _outputPath = null;
        _captionController.clear();
        _videoController = controller;
        _totalDurationInSeconds = duration > 0 ? duration : 1.0;
        _trimRange = RangeValues(0, _totalDurationInSeconds);
        _statusText = 'Video siap! Atur potongan durasi jika perlu.';
      });

      controller.setLooping(true);
      controller.play();
    }
  }

  String _formatTime(double seconds) {
    final int m = (seconds / 60).floor();
    final int s = (seconds % 60).floor();
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Future<void> _processVideo() async {
    if (_inputPath == null) return;

    setState(() {
      _isProcessing = true;
      _statusText = 'Sedang mengoptimalkan & menajamkan video...';
    });

    final String dir = Directory.systemTemp.path;
    final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final String outPath = '$dir/WA_Pure_$timestamp.mp4';

    final double start = _trimRange.start;
    final double duration = _trimRange.end - _trimRange.start;

    // Formula Asli Bawaan Kamu
    final String ffmpegCommand =
        '-y -ss $start -t $duration -i "$_inputPath" '
        '-vf "scale=720:1280:force_original_aspect_ratio=decrease,pad=720:1280:(ow-iw)/2:(oh-ih)/2,unsharp=5:5:0.8:5:5:0.0" '
        '-r 30 -c:v libx264 -profile:v main -level 3.1 -pix_fmt yuv420p '
        '-b:v 1400k -maxrate 1500k -bufsize 2000k '
        '-c:a aac -b:a 128k -ar 44100 '
        '-movflags +faststart "$outPath"';

    await FFmpegKit.executeAsync(ffmpegCommand, (session) async {
      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        setState(() {
          _isProcessing = false;
          _outputPath = outPath;
          _statusText = 'Selesai! Kirim ke chat WA kamu, lalu teruskan ke status.';
        });
      } else {
        setState(() {
          _isProcessing = false;
          _statusText = 'Gagal memproses video. Silakan coba lagi.';
        });
      }
    });
  }

  // Tugas 2: Mengirim video beserta caption teks
  void _shareVideo() {
    if (_outputPath != null) {
      final String caption = _captionController.text.trim();
      Share.shareXFiles(
        [XFile(_outputPath!)],
        text: caption.isNotEmpty ? caption : null,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Status Video Optimizer', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Area Pratinjau Video / Kotak Status
            Container(
              width: double.infinity,
              height: 240,
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white10),
              ),
              clipBehavior: Clip.antiAlias,
              child: _videoController != null && _videoController!.value.isInitialized
                  ? Stack(
                      alignment: Alignment.center,
                      children: [
                        AspectRatio(
                          aspectRatio: _videoController!.value.aspectRatio,
                          child: VideoPlayer(_videoController!),
                        ),
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: IconButton(
                            color: Colors.white,
                            style: IconButton.styleFrom(backgroundColor: Colors.black54),
                            icon: Icon(
                              _videoController!.value.isPlaying ? Icons.pause : Icons.play_arrow,
                            ),
                            onPressed: () {
                              setState(() {
                                _videoController!.value.isPlaying
                                    ? _videoController!.pause()
                                    : _videoController!.play();
                              });
                            },
                          ),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isProcessing ? Icons.sync : Icons.video_collection_outlined,
                          size: 48,
                          color: const Color(0xFF25D366),
                        ),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            _statusText,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 15, color: Colors.white70),
                          ),
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 16),

            if (_isProcessing) ...[
              const LinearProgressIndicator(
                color: Color(0xFF25D366),
                backgroundColor: Colors.white12,
              ),
              const SizedBox(height: 16),
            ],

            // Slider Pemotong Durasi Video
            if (_videoController != null && _videoController!.value.isInitialized) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Potong Durasi Video:', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(
                          '${_formatTime(_trimRange.start)} - ${_formatTime(_trimRange.end)}',
                          style: const TextStyle(color: Color(0xFF25D366), fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    RangeSlider(
                      values: _trimRange,
                      min: 0,
                      max: _totalDurationInSeconds,
                      activeColor: const Color(0xFF25D366),
                      inactiveColor: Colors.white24,
                      onChanged: _isProcessing
                          ? null
                          : (RangeValues values) {
                              setState(() {
                                _trimRange = values;
                              });
                            },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Pengaturan Kualitas Target
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Text('Kualitas:', style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: _selectedResolution,
                        dropdownColor: const Color(0xFF1E293B),
                        items: const [
                          DropdownMenuItem(value: '720p', child: Text('Standard HD (720p)')),
                          DropdownMenuItem(value: '1080p', child: Text('Super HD (1080p)')),
                        ],
                        onChanged: _isProcessing
                            ? null
                            : (val) {
                                if (val != null) {
                                  setState(() => _selectedResolution = val);
                                }
                              },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Tugas 2: Input Caption & Tombol Kirim ke WhatsApp
            if (_outputPath != null) ...[
              TextField(
                controller: _captionController,
                maxLines: 2,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Tulis caption video di sini (opsional)...',
                  hintStyle: const TextStyle(color: Colors.white38),
                  prefixIcon: const Icon(Icons.edit_note, color: Color(0xFF25D366)),
                  filled: true,
                  fillColor: const Color(0xFF1E293B),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: const Color(0xFF25D366),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _shareVideo,
                  icon: const Icon(Icons.share),
                  label: const Text('Bagikan ke WhatsApp', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Tombol Kontrol Bawah
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Color(0xFF25D366)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _isProcessing ? null : _pickVideo,
                    icon: const Icon(Icons.file_upload, color: Color(0xFF25D366)),
                    label: const Text('Pilih Video', style: TextStyle(color: Color(0xFF25D366))),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: Colors.white10,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: (_isProcessing || _inputPath == null) ? null : _processVideo,
                    icon: const Icon(Icons.flash_on, color: Color(0xFF25D366)),
                    label: const Text('Mulai Optimalkan', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}