import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ihc_marketplace/models/profile.dart';

class UserService {
  final _supabase = Supabase.instance.client;

  Future<Profile?> getUserProfile(String userId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();
      return Profile.fromJson(response);
    } catch (e) {
      // Em um ambiente de produção, adicione tratamento de erro ou logging
      debugPrint('Erro ao buscar perfil do usuário: $e');
      return null;
    }
  }

  Future<void> updateUserProfile({
    required String userId,
    String? username,
    String? avatarUrl,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (username != null) {
        updates['username'] = username;
      }
      if (avatarUrl != null) {
        updates['avatar_url'] = avatarUrl;
      }
      await _supabase.from('profiles').update(updates).eq('id', userId);
    } catch (e) {
      debugPrint('Erro ao atualizar perfil do usuário: $e');
      rethrow;
    }
  }
}
