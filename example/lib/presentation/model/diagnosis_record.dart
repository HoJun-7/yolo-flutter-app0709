class DiagnosisRecord {
  final String id;
  final String userId;
  final String fileName;
  final DateTime timestamp;
  final String originalImagePath;
  final String processedImagePath;

  DiagnosisRecord({
    required this.id,
    required this.userId,
    required this.fileName,
    required this.timestamp,
    required this.originalImagePath,
    required this.processedImagePath,
  });

  factory DiagnosisRecord.fromJson(Map<String, dynamic> json, String baseUrl) {
    final fileName = json['original_image_filename'] ?? '';
    final originalPath = json['original_image_path'] ?? '';
    final processedPath = json['processed_image_path'] ?? '';

    // ✅ '/api' 제거 (정적 파일 URL은 /api 없이 접근해야 함)
    final cleanedBaseUrl = baseUrl.replaceFirst(RegExp(r'/api/?$'), '');

    return DiagnosisRecord(
      id: json['_id'] ?? '',
      userId: json['user_id'] ?? '',
      fileName: fileName,
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      originalImagePath: '$cleanedBaseUrl$originalPath',
      processedImagePath: '$cleanedBaseUrl$processedPath',
    );
  }
}
