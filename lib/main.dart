import 'package:flutter/material.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:ihc_marketplace/home_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'l10n/app_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:ihc_marketplace/screens/auth/login_screen.dart';
import 'package:ihc_marketplace/screens/auth/login_screen.dart';
import 'package:ihc_marketplace/models/product.dart'; // Mantém o modelo para a HomePage
// import 'package:ihc_marketplace/home_page.dart'; // Mantém a HomePage

void main() async {
  // Garante que o Flutter está pronto para a inicialização.
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: ".env"); // Load environment variables
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL']!,
      anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    );
  } catch (e) {
    throw Exception('Error loading .env file: $e'); // Print error if any
  }
  // Inicializa o Supabase.

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Marketplace de Condomínio',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6200EE),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // Inglês
        Locale('pt'), // Português
      ],
      // O widget `AuthGate` vai gerenciar a navegação.
      home: const AuthGate(),
    );
  }
}

// Este widget gerencia a navegação com base no estado de autenticação.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    // Escuta as mudanças de autenticação do Supabase.
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Mostra uma tela de carregamento enquanto o estado é verificado.
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasData && snapshot.data!.session != null) {
          // Se o usuário estiver logado, mostra a tela principal.
          return const HomePage();
        } else {
          // Se não houver usuário logado, mostra a tela de login.
          return const LoginScreen();
        }
      },
    );
  }
}
