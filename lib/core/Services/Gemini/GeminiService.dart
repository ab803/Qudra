import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  static const _apiKey = 'AIzaSyDhC4JBEsWMOOMyyJ5LK6dqrPqOQ84rgB8'; // 🔑 replace with your key

  late final GenerativeModel _model;
  late ChatSession _chat;

  GeminiService() {
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: _apiKey,
      systemInstruction: Content.system(
        '''You are Qudra AI, a compassionate and knowledgeable assistant 
        designed specifically to help people with disabilities. 
        You help users find accessible services, nearby institutions, 
        emergency assistance, and provide general support. 
        Always be clear, empathetic, and concise in your responses.''',
      ),
    );
    // ✅ Maintains full conversation history automatically
    _chat = _model.startChat();
  }

  Future<String> sendMessage(String message) async {
    try {
      final response = await _chat.sendMessage(Content.text(message));
      return response.text ?? 'Sorry, I could not generate a response.';
    } on GenerativeAIException catch (e) {
      throw Exception('Gemini error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  // ✅ Reset conversation history
  void resetChat() {
    _chat = _model.startChat();
  }
}