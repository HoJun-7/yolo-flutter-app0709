import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter/foundation.dart' show kDebugMode;

// 챗봇 메시지 모델
class ChatMessage {
  final String role; // 'user' 또는 'bot'
  final String content;

  ChatMessage({required this.role, required this.content});
}

class ChatbotViewModel extends ChangeNotifier {
  final GenerativeModel _model;
  final String baseUrl; // baseUrl은 현재 챗봇 로직에서는 직접 사용되지 않지만, main.dart에서 주입하도록 되어 있으므로 필드로 유지합니다.

  final List<ChatMessage> _messages = []; // 챗봇 대화 목록

  List<ChatMessage> get messages => List.unmodifiable(_messages);

  // ✅ 생성자 수정: apiKey 매개변수 추가 및 _model 초기화에 사용
  // 이 부분이 사용자님의 로컬 파일과 정확히 일치해야 합니다.
  ChatbotViewModel({required String apiKey, required this.baseUrl})
      : _model = GenerativeModel(
          model: 'gemini-1.5-flash', // 사용하려는 Gemini 모델명
          apiKey: apiKey, // ✅ 여기에 apiKey 사용
          generationConfig: GenerationConfig(maxOutputTokens: 200), // 응답 토큰 제한
        ) {
    // 챗봇 초기 메시지 설정
    _messages.add(ChatMessage(role: 'bot', content: '안녕하세요! 어떤 치아 고민이 있으신가요?'));
  }

  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) return; // 빈 메시지는 전송하지 않음

    // 사용자 메시지 추가
    _messages.add(ChatMessage(role: 'user', content: message));
    notifyListeners(); // UI 업데이트

    try {
      // Gemini API 호출을 위한 Content 객체 생성
      final contents = [Content.text(message)];
      final response = await _model.generateContent(contents);
      final botText = response.text ?? '응답이 없습니다.'; // 응답이 없으면 기본 메시지

      // 챗봇 응답 메시지 추가
      _messages.add(ChatMessage(role: 'bot', content: botText));
    } catch (e) {
      if (kDebugMode) {
        print('Gemini 호출 오류: $e');
      }
      _messages.add(ChatMessage(role: 'bot', content: 'AI 호출 중 오류가 발생했습니다. 잠시 후 다시 시도해주세요.'));
    } finally {
      notifyListeners(); // UI 업데이트
    }
  }
}
