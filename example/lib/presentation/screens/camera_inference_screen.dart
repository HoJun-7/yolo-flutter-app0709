import 'package:flutter/material.dart';
import 'package:ultralytics_yolo/yolo.dart';
import 'package:ultralytics_yolo/yolo_result.dart';
import 'package:ultralytics_yolo/yolo_view.dart';
import '/models/model_type.dart';
import '/models/slider_type.dart';
import '/services/model_manager.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http; // Import for HTTP requests

class CameraInferenceScreen extends StatefulWidget {
  // userId와 baseUrl을 받도록 생성자 추가
  final String userId;
  final String baseUrl; // ✅ main.dart로부터 baseUrl을 받기 위한 필드 추가

  const CameraInferenceScreen({
    super.key,
    required this.userId,
    required this.baseUrl, // ✅ 생성자에 baseUrl 추가
  });

  @override
  State<CameraInferenceScreen> createState() => _CameraInferenceScreenState();
}

class _CameraInferenceScreenState extends State<CameraInferenceScreen> {
  List<String> _classifications = [];
  int _detectionCount = 0;
  double _confidenceThreshold = 0.5;
  double _iouThreshold = 0.45;
  int _numItemsThreshold = 30;
  double _currentFps = 0.0;
  int _frameCount = 0;
  DateTime _lastFpsUpdate = DateTime.now();

  SliderType _activeSlider = SliderType.none;
  ModelType _selectedModel = ModelType.segment; // Set initial model to segment
  bool _isModelLoading = false;
  String? _modelPath;
  String _loadingMessage = '';
  double _downloadProgress = 0.0;
  double _currentZoomLevel = 1.0;
  bool _isFrontCamera = false;

  final _yoloController = YOLOViewController();
  final _yoloViewKey = GlobalKey<YOLOViewState>();
  final bool _useController = true;

  late final ModelManager _modelManager;

  @override
  void initState() {
    super.initState();

    // Initialize ModelManager
    _modelManager = ModelManager(
      onDownloadProgress: (progress) {
        if (mounted) {
          setState(() {
            _downloadProgress = progress;
          });
        }
      },
      onStatusUpdate: (message) {
        if (mounted) {
          setState(() {
            _loadingMessage = message;
          });
        }
      },
    );

    // Load initial model
    _loadModelForPlatform();

    // Set initial thresholds after frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_useController) {
        _yoloController.setThresholds(
          confidenceThreshold: _confidenceThreshold,
          iouThreshold: _iouThreshold,
          numItemsThreshold: _numItemsThreshold,
        );
      } else {
        _yoloViewKey.currentState?.setThresholds(
          confidenceThreshold: _confidenceThreshold,
          iouThreshold: _iouThreshold,
          numItemsThreshold: _numItemsThreshold,
        );
      }
    });
  }

  void _onDetectionResults(List<YOLOResult> results) {
    print('🟦 onDetectionResults called: ${results.length}개');
    results.asMap().forEach((i, r) => print(' - $i: ${r.className} (${r.confidence})'));
    if (!mounted) return;

    // Update FPS counter
    _frameCount++;
    final now = DateTime.now();
    final elapsed = now.difference(_lastFpsUpdate).inMilliseconds;
    if (elapsed >= 1000) {
      _currentFps = _frameCount * 1000 / elapsed;
      _frameCount = 0;
      _lastFpsUpdate = now;
      debugPrint('Calculated FPS: ${_currentFps.toStringAsFixed(1)}');
    }

    // Update the UI with the new count
    setState(() {
      _detectionCount = results.length;
      // 분류(Classification) 모드일 때: top 뽑아서 사용!
      if (_selectedModel.task == ModelType.classify) {
        for (final r in results) {
          debugPrint('${r.className} (${(r.confidence * 100).toStringAsFixed(1)}%)');
        }
        // 분류 결과 3개까지
        _classifications = results
            .take(3)
            .map((r) => r.confidence < 0.5
                ? "알 수 없음"
                : "${r.className} ${(r.confidence * 100).toStringAsFixed(1)}%")
            .toList();
      } else {
        // detect/segment: 분류 정보 필요 없음
        _classifications = [];
      }
      print('_classifications: $_classifications'); // 👈 이 한 줄 추가!
    });
  }

  /// Captures the current camera frame and sends it to a server.
  Future<void> _captureAndSendToServer() async {
    try {
      setState(() {
        _loadingMessage = 'Capturing image...';
        _isModelLoading = true; // Use this to show loading overlay
      });

      final Uint8List? imageData = await _yoloController.captureFrame();

      if (imageData != null) {
        setState(() {
          _loadingMessage = 'Sending image to server...';
        });

        final String serverUrl = '${widget.baseUrl}/upload_image'; // <-- 올바른 엔드포인트 사용

        var request = http.MultipartRequest('POST', Uri.parse(serverUrl))
          ..fields['user_id'] = widget.userId; // 👈 로그인된 사용자 ID를 필드로 추가

        request.files.add(http.MultipartFile.fromBytes(
          'image', // 백엔드에서 request.files['image']로 받을 키 이름
          imageData,
          filename: 'camera_capture.jpg', // 파일명 설정
          // contentType: MediaType('image', 'jpeg'), // 선택 사항: 필요한 경우 콘텐츠 유형 지정
        ));

        var response = await request.send();

        if (response.statusCode == 200) {
          debugPrint('Image sent successfully!');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Image sent successfully!')),
            );
          }
        } else {
          final responseBody = await response.stream.bytesToString();
          debugPrint('Failed to send image. Status: ${response.statusCode}, Body: $responseBody');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to send image: ${response.statusCode}')),
            );
          }
        }
      } else {
        debugPrint('No image data captured.');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to capture image.')),
          );
        }
      }
    } catch (e) {
      debugPrint('Error capturing or sending image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isModelLoading = false;
          _loadingMessage = '';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    final isLandscape = orientation == Orientation.landscape;

    return Scaffold(
      body: Stack(
        children: [
          // YOLO View: must be at back
          if (_modelPath != null && !_isModelLoading)
            YOLOView(
              key: _useController
                  ? const ValueKey('yolo_view_static')
                  : _yoloViewKey,
              controller: _useController ? _yoloController : null,
              modelPath: _modelPath!,
              task: _selectedModel.task,
              onResult: _onDetectionResults,
              onPerformanceMetrics: (metrics) {
                if (mounted) {
                  setState(() {
                    _currentFps = metrics.fps;
                  });
                }
              },
              onZoomChanged: (zoomLevel) {
                if (mounted) {
                  setState(() {
                    _currentZoomLevel = zoomLevel;
                  });
                }
                },
            )
          else if (_isModelLoading)
            IgnorePointer(
              child: Container(
                color: Colors.black87,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Ultralytics logo
                      Image.asset(
                        'assets/logo.png',
                        width: 120,
                        height: 120,
                        color: Colors.white.withAlpha(204), // Corrected alpha usage
                      ),
                      const SizedBox(height: 32),
                      // Loading message
                      Text(
                        _loadingMessage,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      // Progress indicator
                      if (_downloadProgress > 0)
                        Column(
                          children: [
                            SizedBox(
                              width: 200,
                              child: LinearProgressIndicator(
                                value: _downloadProgress,
                                backgroundColor: Colors.white24,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                                minHeight: 4,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '${(_downloadProgress * 100).toStringAsFixed(1)}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            )
          else
            const Center(
              child: Text(
                'No model loaded',
                style: TextStyle(color: Colors.white),
              ),
            ),

          if (_classifications.isNotEmpty)
            Positioned(
              top: 80,
              left: 0,
              right: 0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: _classifications.map((txt) =>
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 24),
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                      child: Text(
                        txt,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ).toList(),
              ),
            ),

          // Top info pills (detection, FPS, and current threshold)
          Positioned(
            top: MediaQuery.of(context).padding.top + (isLandscape ? 8 : 16),
            left: isLandscape ? 8 : 16,
            right: isLandscape ? 8 : 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Model selector - REMOVED
                // _buildModelSelector(),
                SizedBox(height: isLandscape ? 8 : 12),
                IgnorePointer(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'DETECTIONS: $_detectionCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'FPS: ${_currentFps.toStringAsFixed(1)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                if (_activeSlider == SliderType.confidence)
                  _buildTopPill(
                    'CONFIDENCE THRESHOLD: ${_confidenceThreshold.toStringAsFixed(2)}',
                  ),
                if (_activeSlider == SliderType.iou)
                  _buildTopPill(
                    'IOU THRESHOLD: ${_iouThreshold.toStringAsFixed(2)}',
                  ),
                if (_activeSlider == SliderType.numItems)
                  _buildTopPill('ITEMS MAX: $_numItemsThreshold'),
              ],
            ),
          ),

          // Center logo - only show when camera is active
          if (_modelPath != null && !_isModelLoading)
            Positioned.fill(
              child: IgnorePointer(
                child: Align(
                  alignment: Alignment.center,
                  child: FractionallySizedBox(
                    widthFactor: isLandscape ? 0.3 : 0.5,
                    heightFactor: isLandscape ? 0.3 : 0.5,
                    child: Image.asset(
                      'assets/logo.png',
                      color: Colors.white.withAlpha(102), // Corrected alpha usage
                    ),
                  ),
                ),
              ),
            ),

          // Control buttons
          Positioned(
            bottom: isLandscape ? 16 : 32,
            right: isLandscape ? 8 : 16,
            child: Column(
              children: [
                if (!_isFrontCamera) ...[
                  _buildCircleButton(
                    '${_currentZoomLevel.toStringAsFixed(1)}x',
                    onPressed: () {
                      // Cycle through zoom levels: 0.5x -> 1.0x -> 3.0x -> 0.5x
                      double nextZoom;
                      if (_currentZoomLevel < 0.75) {
                        nextZoom = 1.0;
                      } else if (_currentZoomLevel < 2.0) {
                        nextZoom = 3.0;
                      } else {
                        nextZoom = 0.5;
                      }
                      _setZoomLevel(nextZoom);
                    },
                  ),
                  SizedBox(height: isLandscape ? 8 : 12),
                ],
                _buildIconButton(Icons.layers, () {
                  _toggleSlider(SliderType.numItems);
                }),
                SizedBox(height: isLandscape ? 8 : 12),
                _buildIconButton(Icons.adjust, () {
                  _toggleSlider(SliderType.confidence);
                }),
                SizedBox(height: isLandscape ? 8 : 12),
                _buildIconButton('assets/iou.png', () {
                  _toggleSlider(SliderType.iou);
                }),
                SizedBox(height: isLandscape ? 16 : 40),
                // NEW: Capture button
                _buildCaptureButton(),
              ],
            ),
          ),

          // Bottom slider overlay
          if (_activeSlider != SliderType.none)
            Positioned(
              left: 0,
              right: 0,
              bottom: isLandscape ? 40 : 80,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isLandscape ? 16 : 24,
                  vertical: isLandscape ? 8 : 12,
                ),
                color: Colors.black.withAlpha(204), // Corrected alpha usage
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: Colors.yellow,
                    inactiveTrackColor: Colors.white.withAlpha(76), // Corrected alpha usage
                    thumbColor: Colors.yellow,
                    overlayColor: Colors.yellow.withAlpha(51), // Corrected alpha usage
                  ),
                  child: Slider(
                    value: _getSliderValue(),
                    min: _getSliderMin(),
                    max: _getSliderMax(),
                    divisions: _getSliderDivisions(),
                    label: _getSliderLabel(),
                    onChanged: (value) {
                      setState(() {
                        _updateSliderValue(value);
                      });
                    },
                  ),
                ),
              ),
            ),

          // Camera flip top-right
          Positioned(
            top: MediaQuery.of(context).padding.top + (isLandscape ? 8 : 16),
            right: isLandscape ? 8 : 16,
            child: CircleAvatar(
              radius: isLandscape ? 20 : 24,
              backgroundColor: Colors.black.withAlpha(127), // Corrected alpha usage
              child: IconButton(
                icon: const Icon(Icons.flip_camera_ios, color: Colors.white),
                onPressed: () {
                  setState(() {
                    _isFrontCamera = !_isFrontCamera;
                    // Reset zoom level when switching to front camera
                    if (_isFrontCamera) {
                      _currentZoomLevel = 1.0;
                    }
                  });
                  if (_useController) {
                    _yoloController.switchCamera();
                  } else {
                    _yoloViewKey.currentState?.switchCamera();
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a circular button with an icon or image
  ///
  /// [iconOrAsset] can be either an IconData or an asset path string
  /// [onPressed] is called when the button is tapped
  Widget _buildIconButton(dynamic iconOrAsset, VoidCallback onPressed) {
    return CircleAvatar(
      radius: 24,
      backgroundColor: Colors.black.withAlpha(51), // Corrected alpha usage
      child: IconButton(
        icon: iconOrAsset is IconData
            ? Icon(iconOrAsset, color: Colors.white)
            : Image.asset(
                iconOrAsset,
                width: 24,
                height: 24,
                color: Colors.white,
              ),
        onPressed: onPressed,
      ),
    );
  }

  /// Builds a circular button with text
  ///
  /// [label] is the text to display in the button
  /// [onPressed] is called when the button is tapped
  Widget _buildCircleButton(String label, {required VoidCallback onPressed}) {
    return CircleAvatar(
      radius: 24,
      backgroundColor: Colors.black.withAlpha(51), // Corrected alpha usage
      child: TextButton(
        onPressed: onPressed,
        child: Text(label, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  /// NEW: Builds the circular capture button
  Widget _buildCaptureButton() {
    return FloatingActionButton(
      onPressed: _captureAndSendToServer,
      backgroundColor: Colors.yellow,
      child: const Icon(Icons.camera_alt, color: Colors.black),
    );
  }

  /// Toggles the active slider type
  ///
  /// If the same slider type is selected again, it will be hidden.
  /// Otherwise, the new slider type will be shown.
  void _toggleSlider(SliderType type) {
    setState(() {
      _activeSlider = (_activeSlider == type) ? SliderType.none : type;
    });
  }

  /// Builds a pill-shaped container with text
  ///
  /// [label] is the text to display in the pill
  Widget _buildTopPill(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(153), // Corrected alpha usage
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// Gets the current value for the active slider
  double _getSliderValue() {
    switch (_activeSlider) {
      case SliderType.numItems:
        return _numItemsThreshold.toDouble();
      case SliderType.confidence:
        return _confidenceThreshold;
      case SliderType.iou:
        return _iouThreshold;
      default:
        return 0;
    }
  }

  /// Gets the minimum value for the active slider
  double _getSliderMin() => _activeSlider == SliderType.numItems ? 5 : 0.1;

  /// Gets the maximum value for the active slider
  double _getSliderMax() => _activeSlider == SliderType.numItems ? 50 : 0.9;

  /// Gets the number of divisions for the active slider
  int _getSliderDivisions() => _activeSlider == SliderType.numItems ? 9 : 8;

  /// Gets the label text for the active slider
  String _getSliderLabel() {
    switch (_activeSlider) {
      case SliderType.numItems:
        return '$_numItemsThreshold';
      case SliderType.confidence:
        return _confidenceThreshold.toStringAsFixed(1);
      case SliderType.iou:
        return _iouThreshold.toStringAsFixed(1);
      default:
        return '';
    }
  }

  /// Updates the value of the active slider
  ///
  /// This method updates both the UI state and the YOLO view controller
  /// with the new threshold value.
  void _updateSliderValue(double value) {
    setState(() {
      switch (_activeSlider) {
        case SliderType.numItems:
          _numItemsThreshold = value.toInt();
          if (_useController) {
            _yoloController.setNumItemsThreshold(_numItemsThreshold);
          } else {
            _yoloViewKey.currentState?.setNumItemsThreshold(_numItemsThreshold);
          }
          break;
        case SliderType.confidence:
          _confidenceThreshold = value;
          if (_useController) {
            _yoloController.setConfidenceThreshold(value);
          } else {
            _yoloViewKey.currentState?.setConfidenceThreshold(value);
          }
          break;
        case SliderType.iou:
          _iouThreshold = value;
          if (_useController) {
            _yoloController.setIoUThreshold(value);
          } else {
            _yoloViewKey.currentState?.setIoUThreshold(value);
          }
          break;
        default:
          break;
      }
    });
  }

  /// Sets the camera zoom level
  ///
  /// Updates both the UI state and the YOLO view controller with the new zoom level.
  void _setZoomLevel(double zoomLevel) {
    setState(() {
      _currentZoomLevel = zoomLevel;
    });
    if (_useController) {
      _yoloController.setZoomLevel(zoomLevel);
    } else {
      _yoloViewKey.currentState?.setZoomLevel(zoomLevel);
    }
  }

  /// Builds the model selector widget
  ///
  /// Creates a row of buttons for selecting different YOLO model types.
  /// Each button shows the model type name and highlights the selected model.
  Widget _buildModelSelector() {
    return Container(
      height: 36,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(153), // Corrected alpha usage
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: ModelType.values.map((model) {
          final isSelected = _selectedModel == model;
          return GestureDetector(
            onTap: () {
              if (!_isModelLoading && model != _selectedModel) {
                setState(() {
                  _selectedModel = model;
                });
                _loadModelForPlatform();
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                model.name.toUpperCase(),
                style: TextStyle(
                  color: isSelected ? Colors.black : Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _getModelFileName(ModelType modelType) {
    switch (modelType) {
      case ModelType.detect:
        return 'best_8n_float16.tflite';
      case ModelType.segment:
        return 'dental_best_float16.tflite'; // This will be the only one used
      case ModelType.classify:
        return 'yolo11n-cls.tflite';

      default:
        return 'pill_best_float16.tflite';
    }
  }

  Future<void> _loadModelForPlatform() async {
    setState(() {
      _isModelLoading = true;
      _loadingMessage = 'Loading ${_selectedModel.modelName} model...';
      _downloadProgress = 0.0;
      _detectionCount = 0;
      _currentFps = 0.0;
      _frameCount = 0;
      _lastFpsUpdate = DateTime.now();
    });

    try {
      final fileName = _getModelFileName(_selectedModel);
      final ByteData data = await rootBundle.load('assets/models/$fileName');

      final Directory appDir = await getApplicationDocumentsDirectory();
      final Directory modelDir = Directory('${appDir.path}/assets/models');
      if (!await modelDir.exists()) {
        await modelDir.create(recursive: true);
      }

      final File file = File('${modelDir.path}/$fileName');
      if (!await file.exists()) {
        await file.writeAsBytes(data.buffer.asUint8List());
      }

      final modelPath = file.path;

      if (mounted) {
        setState(() {
          _modelPath = modelPath;
          _isModelLoading = false;
          _loadingMessage = '';
          _downloadProgress = 0.0;
        });

        debugPrint('CameraInferenceScreen: Model path set to: $modelPath');
      }
    } catch (e) {
      debugPrint('Error loading model: $e');
      if (mounted) {
        setState(() {
          _isModelLoading = false;
          _loadingMessage = 'Failed to load model';
          _downloadProgress = 0.0;
        });
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Model Loading Error'),
            content: Text(
              'Failed to load ${_selectedModel.modelName} model: ${e.toString()}',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }
}