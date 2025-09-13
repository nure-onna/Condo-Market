import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ihc_marketplace/models/chat_session.dart';
import 'package:ihc_marketplace/screens/chat/chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final _supabase = Supabase.instance.client;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _currentUserId = _supabase.auth.currentUser?.id;
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUserId == null) {
      return const Center(child: Text('Faça login para ver suas conversas.'));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Conversas'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _supabase
            .from('chat_sessions')
            .stream(primaryKey: ['id'])
            // .or('seller_id.eq.$_currentUserId,buyer_id.eq.$_currentUserId')
            .order('created_at', ascending: false),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Você ainda não tem conversas.'));
          }

          final sessions = snapshot.data!
              .map((data) => ChatSession.fromJson(data))
              .toList();

          return ListView.builder(
            itemCount: sessions.length,
            itemBuilder: (context, index) {
              final session = sessions[index];
              final otherUserId = session.sellerId == _currentUserId
                  ? session.buyerId
                  : session.sellerId;

              // Futura implementação: exibir o nome do outro usuário
              return ListTile(
                title: Text(
                  'Conversa com o usuário: $otherUserId',
                ), // Placeholder
                subtitle: Text('Produto ID: ${session.productId}'),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        productId: session.productId,
                        sellerId: session.sellerId,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
