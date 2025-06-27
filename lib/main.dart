import 'package:flutter/material.dart';
import 'package:movie_app_ui/movie.dart';
import 'package:movie_app_ui/screens/onboarding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
   WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar as localizações
  await initializeDateFormatting('pt_BR', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return  const MaterialApp(
      debugShowCheckedModeBanner: false,
      // home: MovieDisplay(),
      home: AuthChecker(),
    );
  }
}

class AuthChecker extends StatefulWidget { // <- ADICIONE ESTA CLASSE
  const AuthChecker({super.key});

  @override
  State<AuthChecker> createState() => _AuthCheckerState();
}

class _AuthCheckerState extends State<AuthChecker> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('is_logged_in') ?? false;

    // Aguardar um pouco para evitar flicker
    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      if (isLoggedIn) {
        // Usuário logado - ir para MovieDisplay
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MovieDisplay()),
        );
      } else {
        // Usuário não logado - ir para Onboarding
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const OnboardingScreen()),
        );
      }
    }
  }

 @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFF1A1A1A), // mesma cor do seu tema
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Logo ou nome do app (opcional)
          Text(
            'Talita',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 30),
          const CircularProgressIndicator(
            color: Color(0xFFE53E3E), // cor do seu tema
          ),
        ],
      ),
    ),
  );
}
}
