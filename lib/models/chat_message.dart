class ChatMessage {
  final int id;
  final int chatId;
  final String senderId;
  final String message;
  final DateTime createdAt;

  ChatMessage({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.message,
    required this.createdAt,
  });

  // Construtor de fábrica para criar uma instância de ChatMessage a partir de um JSON.
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as int,
      chatId: json['chat_id'] as int,
      senderId: json['sender_id'] as String,
      message: json['message'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  // Método para converter o objeto em um JSON para ser inserido no Supabase.
  Map<String, dynamic> toJson() {
    return {'chat_id': chatId, 'sender_id': senderId, 'message': message};
  }
}
