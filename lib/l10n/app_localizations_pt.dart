// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Marketplace do Condomínio';

  @override
  String get loginTitle => 'Bem-vindo de volta!';

  @override
  String get loginButton => 'Entrar';

  @override
  String get signupButton => 'Criar Conta';

  @override
  String get emailLabel => 'E-mail';

  @override
  String get passwordLabel => 'Senha';

  @override
  String get productPriceText => 'Preço';

  @override
  String get productStatusAvailable => 'Disponível';

  @override
  String get productStatusSold => 'Vendido';

  @override
  String welcomeMessage(String userName) {
    return 'Olá $userName!';
  }
}
