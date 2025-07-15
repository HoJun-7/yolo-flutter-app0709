import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
<<<<<<< HEAD
import 'package:flutter/foundation.dart' show kIsWeb; // 웹 환경 확인을 위해 추가
import 'dart:typed_data'; // Uint8List 사용을 위해 추가

class UploadScreen extends StatefulWidget {
  final String userId;
=======
import 'package:path/path.dart' as path;
import 'package:http_parser/http_parser.dart';
import 'package:provider/provider.dart';

import '/presentation/viewmodel/auth_viewmodel.dart';
import 'doctor/d_result_detail_screen.dart';

class UploadScreen extends StatefulWidget {
>>>>>>> 1e416c1e1b853d4b9002ccb658fa7671afba6713
  final String baseUrl;

  const UploadScreen({
    super.key,
    required this.userId,
    required this.baseUrl,
  });

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
<<<<<<< HEAD
  // 웹과 모바일/데스크톱 환경에 따라 다른 이미지 데이터 타입을 저장합니다.
  File? _selectedImageFile; // 모바일/데스크톱용 File 객체
  Uint8List? _selectedImageBytes; // 웹용 이미지 바이트 데이터
=======
  File? _imageFile;
  Uint8List? _webImage;
  bool _isLoading = false;
>>>>>>> 1e416c1e1b853d4b9002ccb658fa7671afba6713

  bool _loading = false; // 로딩 상태를 관리합니다.

  // 이미지 선택 모달을 표시하는 함수입니다.
  Future<void> _selectImage() async {
    print("🖼 이미지 선택창 열기");
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('갤러리에서 선택'),
                onTap: () {
                  Navigator.pop(context); // 모달 닫기
                  _pickImage(ImageSource.gallery); // 갤러리에서 이미지 선택
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('카메라로 촬영'),
                onTap: () {
                  Navigator.pop(context); // 모달 닫기
                  _pickImage(ImageSource.camera); // 카메라로 이미지 촬영
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // ImagePicker를 사용하여 이미지를 선택하고 저장하는 함수입니다.
  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

<<<<<<< HEAD
    if (pickedFile != null) {
      print("✅ 이미지 선택됨: ${pickedFile.path}");
      if (kIsWeb) {
        // 현재 플랫폼이 웹인 경우, 이미지를 바이트 데이터로 읽어옵니다.
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _selectedImageBytes = bytes; // 웹용 바이트 데이터에 저장
          _selectedImageFile = null; // File 객체는 웹에서 사용하지 않으므로 null로 설정
        });
      } else {
        // 현재 플랫폼이 모바일/데스크톱인 경우, File 객체로 저장합니다.
        setState(() {
          _selectedImageFile = File(pickedFile.path); // 모바일/데스크톱용 File 객체에 저장
          _selectedImageBytes = null; // 바이트 데이터는 사용하지 않으므로 null로 설정
        });
      }
    } else {
      print("⚠️ 이미지 선택 취소됨");
=======
    setState(() {
      _webImage = null;
      _imageFile = null;
    });

    if (kIsWeb) {
      final bytes = await picked.readAsBytes();
      setState(() {
        _webImage = bytes;
      });
    } else {
      setState(() {
        _imageFile = File(picked.path);
      });
>>>>>>> 1e416c1e1b853d4b9002ccb658fa7671afba6713
    }
  }

  // 선택된 이미지를 서버에 진단 요청으로 제출하는 함수입니다.
  Future<void> _submitDiagnosis() async {
    // 이미지가 선택되었는지 확인합니다 (웹 또는 모바일/데스크톱 모두).
    if (_selectedImageFile == null && _selectedImageBytes == null) {
      print("❗ 이미지가 선택되지 않았습니다.");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("진단할 사진을 먼저 선택해주세요.")),
      );
      return;
    }

    print("📤 진단 요청 시작");
    setState(() {
      _loading = true; // 로딩 상태 시작
    });

    try {
      // 💡💡💡 이 URL이 백엔드 Flask 서버의 실제 이미지 업로드 라우트와 정확히 일치해야 합니다. 💡💡💡
      // 백엔드 app.py 또는 routes/upload_routes.py 파일을 확인하세요.
      // 예: /api/upload_image, /api/upload, /upload_image 등
      final uri = Uri.parse("${widget.baseUrl}/api/upload_image"); // 현재 설정된 URL
      print("진단 요청 URL: $uri"); // 디버깅을 위해 최종 요청 URL을 출력합니다.

      final request = http.MultipartRequest('POST', uri);
<<<<<<< HEAD

      // 현재 플랫폼에 따라 이미지 데이터를 요청에 추가합니다.
      if (kIsWeb && _selectedImageBytes != null) {
        // 웹인 경우, 바이트 데이터로 MultipartFile을 생성합니다.
=======
      request.fields['user_id'] = registerId;

      if (_imageFile != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'file',
          _imageFile!.path,
          contentType: MediaType('image', 'png'),
        ));
      } else if (_webImage != null) {
>>>>>>> 1e416c1e1b853d4b9002ccb658fa7671afba6713
        request.files.add(http.MultipartFile.fromBytes(
          'file', // 서버에서 기대하는 필드 이름 (백엔드와 일치해야 함)
          _selectedImageBytes!,
          filename: 'upload.jpg', // 웹에서는 파일 이름이 필요합니다.
        ));
      } else if (_selectedImageFile != null) {
        // 모바일/데스크톱인 경우, File 객체 경로로 MultipartFile을 생성합니다.
        request.files.add(await http.MultipartFile.fromPath(
          'file', // 서버에서 기대하는 필드 이름 (백엔드와 일치해야 함)
          _selectedImageFile!.path,
        ));
      } else {
        // 이미지 데이터가 유효하지 않은 경우 예외를 발생시킵니다.
        throw Exception("이미지 데이터가 유효하지 않습니다.");
      }

      // 사용자 ID 필드를 요청에 추가합니다.
      request.fields['user_id'] = widget.userId;

<<<<<<< HEAD
      // 요청을 보내고 응답을 받습니다.
      final response = await request.send();
      final resBody = await response.stream.bytesToString(); // 응답 본문을 문자열로 변환
      print("📥 서버 응답 수신 완료 (Raw): $resBody"); // 디버깅을 위해 원본 응답을 출력합니다.

      // HTTP 상태 코드를 확인하여 서버 응답이 성공적인지 판단합니다.
      if (response.statusCode != 200) {
        print("❌ 서버 응답 에러 - Status Code: ${response.statusCode}");
        print("❌ 서버 응답 내용: $resBody");
        // 서버에서 HTML 응답을 보냈을 경우 FormatException 대신 이 메시지가 표시됩니다.
        throw Exception("서버 오류: HTTP ${response.statusCode} - $resBody");
      }

      // 서버 응답 본문을 JSON으로 디코딩합니다.
      final decoded = json.decode(resBody);

      // 응답에서 이미지 URL과 추론 데이터를 추출합니다.
      final imageUrl = decoded['image_url'];
      final inferenceData = decoded['inference_data'];

      print("🖼 추론 이미지 URL: $imageUrl");
      print("📊 추론 데이터: $inferenceData");

      // 필수 데이터가 누락되었는지 확인합니다.
      if (imageUrl == null || inferenceData == null) {
        throw Exception("서버 응답 오류: 'image_url' 또는 'inference_data' 필드가 없습니다.");
      }

      // 위젯이 마운트된 상태인지 확인 후 결과 페이지로 이동합니다.
      if (mounted) {
        context.push('/result', extra: {
          'imageUrl': imageUrl, // 추론된 이미지 URL
          'inferenceData': inferenceData, // 추론 결과 데이터
          'baseUrl': widget.baseUrl, // ResultScreen에서 이미지 로드 시 필요할 수 있음
          'userId': widget.userId, // 사용자 ID
        });
=======
      if (response.statusCode == 200) {
        final responseData = json.decode(responseBody);
        final processedPath = responseData['image_url'] as String?;
        final inferenceData = responseData['inference_data'] as Map<String, dynamic>?;
        final originalPath = responseData['original_image_path'] as String?;

        if (processedPath != null && inferenceData != null && originalPath != null) {
          final baseStaticUrl = widget.baseUrl.replaceFirst('/api', '');

          final originalImageUrl = '$baseStaticUrl$originalPath';
          final processedImageUrl = '$baseStaticUrl$processedPath';

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ResultDetailScreen(
                originalImageUrl: originalImageUrl,
                processedImageUrls: {
                  1: processedImageUrl,
                },
                modelInfos: {
                  1: inferenceData,
                },
              ),
            ),
          );
        } else {
          throw Exception('image_url 또는 inference_data 없음');
        }
      } else {
        print('서버 오류: ${response.statusCode}');
        print('응답 본문: $responseBody');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('서버 오류 발생')),
        );
>>>>>>> 1e416c1e1b853d4b9002ccb658fa7671afba6713
      }
    } catch (e) {
      print("❌ 진단 요청 중 에러 발생: $e");
      // 사용자에게 스낵바를 통해 오류 메시지를 표시합니다.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("진단 요청 실패: ${e.toString()}")),
      );
    } finally {
      setState(() {
        _loading = false; // 로딩 상태 종료
      });
      print("🔁 로딩 상태 종료");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
<<<<<<< HEAD
      appBar: AppBar(
        title: const Text('AI 진단'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(), // 이전 화면으로 돌아가기
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '진단할 사진을 업로드하세요',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              // 💡💡💡 수정: 웹 환경에 따라 다른 이미지 위젯을 사용하여 미리보기를 표시합니다. 💡💡💡
              (_selectedImageFile != null || _selectedImageBytes != null)
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: kIsWeb && _selectedImageBytes != null
                          ? Image.memory(_selectedImageBytes!, width: 220, height: 220, fit: BoxFit.cover)
                          : Image.file(_selectedImageFile!, width: 220, height: 220, fit: BoxFit.cover),
                    )
                  : Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey, width: 1),
                      ),
                      child: Center(
                        child: Text(
                          '선택된 이미지 없음',
                          style: TextStyle(color: Colors.grey[600], fontSize: 16),
                        ),
                      ),
                    ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _selectImage,
                icon: const Icon(Icons.image),
                label: const Text('+ 사진 선택'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  textStyle: const TextStyle(fontSize: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                // 이미지가 선택되었고 로딩 중이 아닐 때만 버튼을 활성화합니다.
                onPressed: ((_selectedImageFile != null || _selectedImageBytes != null) && !_loading) ? _submitDiagnosis : null,
                icon: const Icon(Icons.send),
                label: _loading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('제출'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  textStyle: const TextStyle(fontSize: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
=======
      appBar: AppBar(title: const Text('사진으로 예측하기')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (_imageFile != null)
              Image.file(_imageFile!, height: 200)
            else if (_webImage != null)
              Image.memory(_webImage!, height: 200)
            else
              const Placeholder(fallbackHeight: 200),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.photo),
                  label: const Text('사진 선택'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _uploadImage,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.cloud_upload),
                  label: const Text('업로드'),
                ),
              ],
            ),
          ],
>>>>>>> 1e416c1e1b853d4b9002ccb658fa7671afba6713
        ),
      ),
    );
  }
}
