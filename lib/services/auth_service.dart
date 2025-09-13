import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final supabase = Supabase.instance.client;

  /// Tenta logar o usuário com e-mail e senha.
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Tenta cadastrar um novo usuário com e-mail e senha.
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Tenta logar o usuário com a conta do Google.
  Future<void> signInWithGoogle() async {
    try {
      // Cria uma instância do GoogleSignIn.
      final googleSignIn = GoogleSignIn(
        clientId:
            'SEU_CLIENT_ID_DO_GOOGLE', // Substitua pelo seu ID do cliente.
      );

      // Inicia o fluxo de autenticação do Google.
      final googleUser = await googleSignIn.signIn();
      final googleAuth = await googleUser?.authentication;

      if (googleAuth?.idToken == null) {
        throw 'Token de ID do Google não encontrado.';
      }

      // Autentica o usuário no Supabase usando o token do Google.
      await supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: googleAuth!.idToken!,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Faz o logout do usuário.
  Future<void> signOut() async {
    await supabase.auth.signOut();
  }
}
