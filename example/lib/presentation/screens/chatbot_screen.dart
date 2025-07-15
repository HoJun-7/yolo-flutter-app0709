import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// ✅ 임포트 경로 수정: chatbot_view.dart 대신 chatbot_viewmodel.dart를 참조하도록 변경
import 'package:ultralytics_yolo_example/presentation/viewmodel/chatbot_viewmodel.dart'; // ViewModel 임포트

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _messageController = TextEditingController();

  void _sendMessage(ChatbotViewModel viewModel) {
    if (_messageController.text.isNotEmpty) {
      viewModel.sendMessage(_messageController.text); // ViewModel의 sendMessage 호출
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    // ViewModel 인스턴스 가져오기
    final viewModel = Provider.of<ChatbotViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '치아 챗봇',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent, // 앱바 색상 변경
        elevation: 4, // 그림자 효과
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              // 대화 목록은 ViewModel에서 가져옵니다.
              itemCount: viewModel.messages.length,
              itemBuilder: (context, index) {
                final message = viewModel.messages[index];
                final isUser = message.role == 'user'; // ViewModel의 ChatMessage 모델 사용
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blue[100] : Colors.grey[200], // 메시지 배경색
                      borderRadius: BorderRadius.circular(15.0), // 둥근 모서리
                      boxShadow: [ // 그림자 추가
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 3,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75, // 메시지 최대 너비 제한
                    ),
                    child: Text(
                      message.content, // ViewModel의 ChatMessage 모델 사용
                      style: TextStyle(
                        color: isUser ? Colors.blue[900] : Colors.grey[800],
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: '메시지를 입력하세요...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0), // 둥근 입력창
                        borderSide: BorderSide.none, // 테두리 없음
                      ),
                      filled: true,
                      fillColor: Colors.grey[100], // 입력창 배경색
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                    ),
                    onSubmitted: (value) => _sendMessage(viewModel), // 엔터 키로 전송
                  ),
                ),
                const SizedBox(width: 8.0),
                FloatingActionButton(
                  onPressed: () => _sendMessage(viewModel), // 전송 버튼 클릭 시
                  backgroundColor: Colors.blueAccent, // 전송 버튼 색상
                  elevation: 2,
                  shape: const CircleBorder(), // 동그란 버튼
                  child: const Icon(Icons.send, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}
