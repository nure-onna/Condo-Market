import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ihc_marketplace/models/chat_message.dart';
import 'package:ihc_marketplace/models/chat_session.dart';

class ChatScreen extends StatefulWidget {
  final int productId;
  final String sellerId;

  const ChatScreen({
    super.key,
    required this.productId,
    required this.sellerId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _supabase = Supabase.instance.client;
  int? _chatId;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _getOrCreateChatSession();
  }

  Future<void> _getOrCreateChatSession() async {
    _currentUserId = _supabase.auth.currentUser?.id;
    if (_currentUserId == null) return;

    final response = await _supabase
        .from('chat_sessions')
        .select()
        .eq('product_id', widget.productId)
        .eq('buyer_id', _currentUserId!)
        .eq('seller_id', widget.sellerId)
        .single()
        .limit(1);

    if (response.isNotEmpty) {
      setState(() {
        _chatId = ChatSession.fromJson(response).id;
      });
    } else {
      final newChat = ChatSession(
        id: -1, // ID temporário, será sobrescrito pelo Supabase
        productId: widget.productId,
        sellerId: widget.sellerId,
        buyerId: _currentUserId!,
        createdAt: DateTime.now(),
      );

      final newSession = await _supabase
          .from('chat_sessions')
          .insert(newChat.toJson())
          .select()
          .single();
      setState(() {
        _chatId = ChatSession.fromJson(newSession).id;
      });
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.isEmpty || _chatId == null) return;

    final messageText = _messageController.text;
    _messageController.clear();

    final newMessage = ChatMessage(
      id: -1,
      chatId: _chatId!,
      senderId: _currentUserId!,
      message: messageText,
      createdAt: DateTime.now(),
    );

    await _supabase.from('chat_messages').insert(newMessage.toJson());
  }

  @override
  Widget build(BuildContext context) {
    if (_chatId == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _supabase
                  .from('chat_messages')
                  .stream(primaryKey: ['id'])
                  .eq('chat_id', _chatId!)
                  .order('created_at', ascending: true),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Erro: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Inicie a conversa...'));
                }

                final messages = snapshot.data!
                    .map((data) => ChatMessage.fromJson(data))
                    .toList();

                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.senderId == _currentUserId;

                    return Align(
                      alignment: isMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          vertical: 4.0,
                          horizontal: 8.0,
                        ),
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: isMe
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey[300],
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: isMe
                                ? const Radius.circular(16)
                                : const Radius.circular(0),
                            bottomRight: isMe
                                ? const Radius.circular(0)
                                : const Radius.circular(16),
                          ),
                        ),
                        child: Text(
                          message.message,
                          style: TextStyle(
                            color: isMe ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                    );
                  },
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
                      hintText: 'Digite sua mensagem...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  onPressed: _sendMessage,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  child: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
