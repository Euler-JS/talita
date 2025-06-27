import 'package:flutter/material.dart';
import 'package:movie_app_ui/movie.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:math' as math;
import 'package:shared_preferences/shared_preferences.dart';


class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _floatingController;
  late AnimationController _rotationController;
  late AnimationController _starPulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _floatingAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _starPulseAnimation;
  late Animation<double> _scaleAnimation;
  bool _isLogin = true; 
  // Controllers para os campos
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

// Estados de loading e erro
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 4500),
      vsync: this,
    );
    
    _floatingController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _rotationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _starPulseController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOutCirc),
    ));

    _slideAnimation = Tween<double>(
      begin: 100.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 1.0, curve: Curves.elasticOut),
    ));

    _floatingAnimation = Tween<double>(
      begin: -25.0,
      end: 25.0,
    ).animate(CurvedAnimation(
      parent: _floatingController,
      curve: Curves.easeInOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * 3.14159, // Rotação completa
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));

// Animação de pulsação para as estrelas
    _starPulseAnimation = Tween<double>(
      begin: 0.3,
      end: 1.8,
    ).animate(CurvedAnimation(
      parent: _starPulseController,
      curve: Curves.elasticInOut,
    ));

// Animação de escala para entrada dramática
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.8, curve: Curves.elasticOut),
    ));

    _animationController.forward();
    _floatingController.repeat(reverse: true);
    _rotationController.repeat();
    _starPulseController.repeat(reverse: true);

  }

  @override
  void dispose() {
    _animationController.dispose();
    _floatingController.dispose();
    _rotationController.dispose();
    _starPulseController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
  setState(() {
    _isLoading = true;
    _errorMessage = null;
  });

  // Validações básicas
  if (_passwordController.text != _confirmPasswordController.text) {
    setState(() {
      _errorMessage = 'Senhas não coincidem';
      _isLoading = false;
    });
    return;
  }

  try {
    final response = await http.post(
      Uri.parse('http://localhost:3000/api/auth/register'), // substitua SEU_IP
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'firstName': _nameController.text.split(' ').first,
        'lastName': _nameController.text.split(' ').length > 1 ? _nameController.text.split(' ').last : '',
        'email': _emailController.text,
        'password': _passwordController.text,
      }),
    );

    if (response.statusCode == 201) {
      // Sucesso - mostrar mensagem e mudar para login
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Conta criada com sucesso! Faça login.')),
      );
      setState(() {
        _isLogin = true; // muda para modo login
      });
    } else {
      final error = json.decode(response.body);
      setState(() {
        _errorMessage = error['error'] ?? 'Erro ao criar conta';
      });
    }
  } catch (e) {
    setState(() {
      _errorMessage = 'Erro de conexão';
    });
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}

Future<void> _login() async {
  setState(() {
    _isLoading = true;
    _errorMessage = null;
  });

  try {
    final response = await http.post(
      Uri.parse('http://localhost:3000/api/auth/login'), // substitua SEU_IP
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': _emailController.text,
        'password': _passwordController.text,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      
      // Sucesso - salvar dados do usuário (opcional)
      // Você pode usar SharedPreferences ou apenas manter em memória
      
        // Mostrar mensagem de sucesso
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login realizado com sucesso!')),
      );
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_data', json.encode(data['user']));
      await prefs.setBool('is_logged_in', true);

      // Fechar modal e navegar
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MovieDisplay()),
      );
      
    
    } else {
      final error = json.decode(response.body);
      setState(() {
        _errorMessage = error['error'] ?? 'Email ou senha incorretos';
      });
    }
  } catch (e) {
    setState(() {
      _errorMessage = 'Erro de conexão';
    });
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}

void _clearFields() {
  _emailController.clear();
  _passwordController.clear();
  _confirmPasswordController.clear();
  _nameController.clear();
  setState(() {
    _errorMessage = null;
  });
}

void _showLoginModal() {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) => StatefulBuilder(
      builder: (context, setModalState) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
  margin: const EdgeInsets.all(20),
  padding: const EdgeInsets.all(28),
  decoration: BoxDecoration(
    gradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF2D1B3D),
        Color(0xFF1A0D26),
        Color(0xFF0F0515),
      ],
    ),
    borderRadius: BorderRadius.circular(24),
    border: Border.all(
      color: Colors.pink.withOpacity(0.3),
      width: 1,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.pink.withOpacity(0.2),
        blurRadius: 20,
        spreadRadius: 2,
        offset: const Offset(0, 8),
      ),
      BoxShadow(
        color: Colors.black.withOpacity(0.5),
        blurRadius: 30,
        spreadRadius: -5,
        offset: const Offset(0, 15),
      ),
    ],
  ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Toggle LOGIN/SIGN UP
              Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [Colors.white.withOpacity(0.9), Colors.white.withOpacity(0.7)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(30),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
    ],
  ),
  child: Row(
    children: [
      Expanded(
        child: GestureDetector(
          onTap: (){ setModalState(() => _isLogin = true); _clearFields();},
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              gradient: _isLogin ? const LinearGradient(
                colors: [Color(0xFFFF6B9D), Color(0xFFE91E63)],
              ) : null,
              borderRadius: BorderRadius.circular(30),
              boxShadow: _isLogin ? [
                BoxShadow(
                  color: const Color(0xFFE91E63).withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ] : null,
            ),
            child: Text(
              'LOGIN',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _isLogin ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
      Expanded(
        child: GestureDetector(
          onTap: () {setModalState(() => _isLogin = false); _clearFields();},
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              gradient: !_isLogin ? const LinearGradient(
                colors: [Color(0xFFFF6B9D), Color(0xFFE91E63)],
              ) : null,
              borderRadius: BorderRadius.circular(30),
              boxShadow: !_isLogin ? [
                BoxShadow(
                  color: const Color(0xFFE91E63).withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ] : null,
            ),
            child: Text(
              'SIGN UP',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: !_isLogin ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    ],
  ),
),
              
              const SizedBox(height: 30),
              
              // Campos do formulário
              if (_isLogin) ...[
                // LOGIN FORM
                _buildTextField('Enter your email', Icons.email_outlined, controller: _emailController),
                const SizedBox(height: 16),
                _buildTextField('Enter your password', Icons.visibility_off, isPassword: true, controller: _passwordController),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () { },
                    child: const Text('Forgot Password?', style: TextStyle(color: Colors.grey)),
                  ),
                ),
              ] else ...[
                // SIGN UP FORM
                _buildTextField('User Name', Icons.person_outline, controller: _nameController),
                const SizedBox(height: 16),
                _buildTextField('Enter your email', Icons.email_outlined, controller: _emailController),
                const SizedBox(height: 16),
                _buildTextField('Password', Icons.visibility_off, isPassword: true, controller: _passwordController),
                const SizedBox(height: 16),
                _buildTextField('Confirm Password', Icons.visibility_off, isPassword: true, controller: _confirmPasswordController),
                const SizedBox(height: 16),
                _buildTextField('Terms and Services (21 Y/o)', Icons.visibility_off, isPassword: true),
              ],
              
              const SizedBox(height: 20),
              if (_errorMessage != null) ...[
  const SizedBox(height: 12),
  Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      color: Colors.red.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.red.withOpacity(0.3)),
    ),
    child: Row(
      children: [
        Icon(Icons.error_outline, color: Colors.red.shade300, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            _errorMessage!,
            style: TextStyle(
              color: Colors.red.shade300,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    ),
  ),
],
              // Action button
              
Container(
  width: double.infinity,
  height: 54,
  decoration: BoxDecoration(
    gradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFFFF6B9D),
        Color(0xFFE91E63),
        Color(0xFFD81B60),
      ],
    ),
    borderRadius: BorderRadius.circular(27),
    boxShadow: [
      BoxShadow(
        color: const Color(0xFFE91E63).withOpacity(0.4),
        blurRadius: 12,
        spreadRadius: 1,
        offset: const Offset(0, 6),
      ),
      BoxShadow(
        color: Colors.black.withOpacity(0.2),
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
    ],
  ),
  child: ElevatedButton(
    onPressed: _isLoading ? null : () {
      if (_isLogin) {
        _login();
      } else {
        _signUp();
      }
    },
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.transparent,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(27)),
      elevation: 0,
    ),
    child: _isLoading 
      ? const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            strokeWidth: 2,
          ),
        )
      : Text(
          _isLogin ? 'LOGIN' : 'SIGN UP',
          style: const TextStyle(
            color: Colors.white, 
            fontWeight: FontWeight.bold,
            fontSize: 16,
            letterSpacing: 1,
          ),
        ),
  ),
),

              const SizedBox(height: 20),
              const Text('or with', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 16),
              
              // Social login buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: const BoxDecoration(
                      color: Color(0xFF2D2D2D),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.g_mobiledata, color: Colors.white, size: 30),
                  ),
                  const SizedBox(width: 20),
                  Container(
                    width: 50,
                    height: 50,
                    decoration: const BoxDecoration(
                      color: Color(0xFF2D2D2D),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.apple, color: Colors.white, size: 24),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
 
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.5,
            colors: [
              Color(0xFF2D1B3D),
              Color(0xFF1A0D26),
              Color(0xFF0F0515),
            ],
          ),
        ),
       child: Container(
        width: double.infinity,
              height: double.infinity,
         child: SafeArea(
           child: SingleChildScrollView(
             child: Column(
               children: [
          // Estrelas no fundo
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: Stack(
              children: [
                _buildStars(),
                _buildCentralIllustration(),
              ],
            ),
          ),
         
          // Texto e botão
          AnimatedBuilder(
            animation: _slideAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _slideAnimation.value),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'TALITA',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 6,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 40),
                        const Text(
                          'TEATRO,JOGOS, SHOWS...!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Compre Bilhetes de forma fácil e rápida... E reserve o teu lugar!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 40),
                        _buildStartButton(),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
               ],
             ),
           ),
         ),
       ),

      ),
    );
  }

  Widget _buildStars() {
  return AnimatedBuilder(
    animation: _starPulseAnimation,
    builder: (context, child) {
      return Stack(
        children: [
          Positioned(
            top: 50, 
            left: 50, 
            child: Transform.scale(
              scale: _starPulseAnimation.value,
              child: _buildStar(12, Colors.pink, 0.0),
            ),
          ),
          Positioned(
            top: 100, 
            right: 80, 
            child: Transform.scale(
              scale: _starPulseAnimation.value * 0.8,
              child: _buildStar(10, Colors.purple, 0.5),
            ),
          ),
          Positioned(
            top: 200, 
            left: 30, 
            child: Transform.scale(
              scale: _starPulseAnimation.value * 1.1,
              child: _buildStar(8, Colors.blue, 1.0),
            ),
          ),
          Positioned(
            top: 250, 
            right: 40, 
            child: Transform.scale(
              scale: _starPulseAnimation.value * 0.9,
              child: _buildStar(14, Colors.orange, 1.5),
            ),
          ),
          Positioned(
            top: 350, 
            left: 80, 
            child: Transform.scale(
              scale: _starPulseAnimation.value,
              child: _buildStar(10, Colors.teal, 2.0),
            ),
          ),
          Positioned(
            top: 400, 
            right: 100, 
            child: Transform.scale(
              scale: _starPulseAnimation.value * 1.2,
              child: _buildStar(12, Colors.red, 2.5),
            ),
          ),
          Positioned(
            bottom: 100, 
            left: 60, 
            child: Transform.scale(
              scale: _starPulseAnimation.value * 0.7,
              child: _buildStar(9, Colors.green, 3.0),
            ),
          ),
          Positioned(
            bottom: 150, 
            right: 50, 
            child: Transform.scale(
              scale: _starPulseAnimation.value * 1.1,
              child: _buildStar(11, Colors.amber, 3.5),
            ),
          ),
        ],
      );
    },
  );
}

// Estrela melhorada com brilho
Widget _buildStar(double size, Color color, double delay) {
  return AnimatedBuilder(
    animation: _fadeAnimation,
    builder: (context, child) {
      return FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [
                color.withOpacity(0.9),
                color.withOpacity(0.3),
                Colors.transparent,
              ],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.6),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Container(
            margin: EdgeInsets.all(size * 0.3),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.8),
                  blurRadius: 5,
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

// Ilustração central melhorada
Widget _buildCentralIllustration() {
  return Center(
    child: AnimatedBuilder(
      animation: Listenable.merge([_floatingAnimation, _scaleAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.translate(
            offset: Offset(0, _floatingAnimation.value),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                width: 320, // Ligeiramente maior
                height: 320,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Base platform com sombra melhorada
                    Positioned(
                      bottom: 20,
                      child: Container(
                        width: 300,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFD4A574), Color(0xFFB8956A)],
                          ),
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.4),
                              offset: const Offset(0, 15),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Popcorn com animação de "pop"
                    Positioned(
                      top: 30,
                      right: 40,
                      child: _buildAnimatedPopcornContainer(),
                    ),
                    
                    // Drink com bolhas animadas
                    Positioned(
                      top: 80,
                      left: 50,
                      child: _buildAnimatedDrinkCup(),
                    ),
                    
                    // Cinema seat com movimento
                    Positioned(
                      bottom: 60,
                      child: _buildAnimatedCinemaSeat(),
                    ),
                    
                    // People com movimento de aceno
                    Positioned(
                      bottom: 40,
                      left: 80,
                      child: _buildAnimatedPersonFigure(Colors.blue),
                    ),
                    Positioned(
                      bottom: 40,
                      right: 100,
                      child: _buildAnimatedPersonFigure(Colors.orange),
                    ),
                    
                    // Cinema ticket com rotação
                    Positioned(
                      bottom: 80,
                      right: 60,
                      child: _buildAnimatedCinemaTicket(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    ),
  );
}

// Popcorn animado
Widget _buildAnimatedPopcornContainer() {
  return AnimatedBuilder(
    animation: _floatingController,
    builder: (context, child) {
      return Transform.translate(
        offset: Offset(
          math.sin(_floatingController.value * 2 * math.pi) * 8,
          math.cos(_floatingController.value * 2 * math.pi) * 6,
        ),
        child: Container(
          width: 90,
          height: 110,
          child: Stack(
            children: [
              // Container base
              Positioned(
                bottom: 0,
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFFF6B6B),
                        Color(0xFFE74C3C),
                        Color(0xFFC0392B),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.5),
                        offset: const Offset(5, 8),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'POP\nCORN',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: Colors.black26,
                            offset: Offset(1, 1),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Popcorn pieces animados
              ...List.generate(5, (index) {
                return Positioned(
                  top: 5 + (index * 3).toDouble(),
                  left: 15 + (index % 2 * 30).toDouble(),
                  child: Transform.translate(
                    offset: Offset(
                      math.sin((_floatingController.value + index * 0.3) * 2 * math.pi) * 6,
                      math.cos((_floatingController.value + index * 0.2) * 2 * math.pi) * 4,
                    ),
                    child: _buildPopcornPiece(8 + (index % 3).toDouble()),
                  ),
                );
              }),
            ],
          ),
        ),
      );
    },
  );
}

// Drink animado com bolhas
Widget _buildAnimatedDrinkCup() {
  return AnimatedBuilder(
    animation: _floatingController,
    builder: (context, child) {
      return Container(
        width: 60,
        height: 80,
        child: Stack(
          children: [
            // Cup base
            Positioned(
              bottom: 0,
              child: Container(
                width: 60,
                height: 70,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF3498DB),
                      Color(0xFF2980B9),
                      Color(0xFF1F4E79),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.5),
                      offset: const Offset(5, 8),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
            // Straw animado
            Positioned(
              top: 0,
              left: 40,
              child: Transform.rotate(
                angle: math.sin(_floatingController.value * 2 * math.pi) * 0.3,
                child: Container(
                  width: 6,
                  height: 35,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE74C3C), Color(0xFFC0392B)],
                    ),
                    borderRadius: BorderRadius.circular(3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.3),
                        blurRadius: 5,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Bolhas animadas
            ...List.generate(3, (index) {
              return Positioned(
                bottom: 20 + (index * 15).toDouble(),
                left: 15 + (index * 10).toDouble(),
                child: Transform.translate(
                  offset: Offset(
                    0,
                    math.sin((_floatingController.value + index * 0.5) * 2 * math.pi) * 3,
                  ),
                  child: Container(
                    width: 4 + (index % 2).toDouble(),
                    height: 4 + (index % 2).toDouble(),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      );
    },
  );
}

// Assento animado
Widget _buildAnimatedCinemaSeat() {
  return AnimatedBuilder(
    animation: _floatingController,
    builder: (context, child) {
      return Transform.scale(
        scale: 1.0 + math.sin(_floatingController.value * 2 * math.pi) * 0.05,
        child: Container(
          width: 70,
          height: 50,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF8E44AD),
                Color(0xFF6A1B9A),
                Color(0xFF4A148C),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.purple.withOpacity(0.5),
                offset: const Offset(5, 8),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
        ),
      );
    },
  );
}

// Pessoa animada
Widget _buildAnimatedPersonFigure(Color color) {
  return AnimatedBuilder(
    animation: _floatingController,
    builder: (context, child) {
      return Transform.translate(
        offset: Offset(
          math.sin(_floatingController.value * 2 * math.pi) * 1,
          0,
        ),
        child: Container(
          width: 25,
          height: 35,
          child: Column(
            children: [
              // Head com balanço
              Transform.rotate(
                angle: math.sin(_floatingController.value * 2 * math.pi) * 0.1,
                child: Container(
                  width: 15,
                  height: 15,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFDBB5),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 3,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 2),
              // Body
              Container(
                width: 20,
                height: 18,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withOpacity(0.7)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 5,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

// Ticket com rotação
Widget _buildAnimatedCinemaTicket() {
  return AnimatedBuilder(
    animation: _rotationAnimation,
    builder: (context, child) {
      return Transform.rotate(
        angle: _rotationAnimation.value * 0.1 + 0.3,
        child: Transform.scale(
          scale: 1.0 + math.sin(_floatingController.value * 2 * math.pi) * 0.1,
          child: Container(
            width: 40,
            height: 25,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.white, Color(0xFFF5F5F5)],
              ),
              borderRadius: BorderRadius.circular(6),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  offset: const Offset(3, 5),
                  blurRadius: 10,
                ),
              ],
            ),
            child: const Center(
              child: Text(
                'CINEMA\nTICKET',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 7,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}


  Widget _buildPopcornContainer() {
    return Container(
      width: 80,
      height: 100,
      child: Stack(
        children: [
          // Container base
          Positioned(
            bottom: 0,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFFF6B6B),
                    Color(0xFFE74C3C),
                  ],
                ),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    offset: const Offset(3, 6),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  'POP\nCORN',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          // Popcorn pieces
          Positioned(
            top: 0,
            left: 10,
            child: _buildPopcornPiece(8),
          ),
          Positioned(
            top: 5,
            right: 15,
            child: _buildPopcornPiece(6),
          ),
          Positioned(
            top: 10,
            left: 25,
            child: _buildPopcornPiece(7),
          ),
        ],
      ),
    );
  }

  Widget _buildPopcornPiece(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3C7),
        borderRadius: BorderRadius.circular(size / 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            offset: const Offset(1, 2),
            blurRadius: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildDrinkCup() {
    return Container(
      width: 50,
      height: 70,
      child: Stack(
        children: [
          // Cup base
          Positioned(
            bottom: 0,
            child: Container(
              width: 50,
              height: 60,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF3498DB),
                    Color(0xFF2980B9),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(25),
                  bottomRight: Radius.circular(25),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    offset: const Offset(3, 6),
                    blurRadius: 10,
                  ),
                ],
              ),
            ),
          ),
          // Straw
          Positioned(
            top: 0,
            left: 35,
            child: Container(
              width: 4,
              height: 30,
              decoration: BoxDecoration(
                color: const Color(0xFFE74C3C),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCinemaSeat() {
    return Container(
      width: 60,
      height: 40,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF8E44AD),
            Color(0xFF6A1B9A),
          ],
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            offset: const Offset(3, 6),
            blurRadius: 10,
          ),
        ],
      ),
    );
  }

  Widget _buildPersonFigure(Color color) {
    return Container(
      width: 20,
      height: 30,
      child: Column(
        children: [
          // Head
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: const Color(0xFFFFDBB5),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(height: 2),
          // Body
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCinemaTicket() {
    return Transform.rotate(
      angle: 0.3,
      child: Container(
        width: 30,
        height: 20,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              offset: const Offset(2, 3),
              blurRadius: 5,
            ),
          ],
        ),
        child: const Center(
          child: Text(
            'CINEMA\nTICKET',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
              fontSize: 6,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStartButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFF6B9D),
            Color(0xFFE91E63),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE91E63).withOpacity(0.4),
            offset: const Offset(0, 8),
            blurRadius: 20,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: () {
            // Navegar para a próxima tela
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(
            //     builder: (context) => const MovieDisplay(),
            //   ),
            // );
            _showLoginModal();
          },
          child: const Center(
            child: Text(
              "LET'S START",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }

Widget _buildTextField(String hint, IconData icon, {bool isPassword = false, TextEditingController? controller}) {
  return Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF2D2D2D).withOpacity(0.8),
          const Color(0xFF1A1A1A).withOpacity(0.9),
        ],
      ),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: Colors.pink.withOpacity(0.2),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: Colors.pink.withOpacity(0.05),
          blurRadius: 12,
          spreadRadius: 1,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: TextField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: Colors.grey.withOpacity(0.7),
          fontSize: 15,
        ),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        suffixIcon: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.pink.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon, 
            color: Colors.pink.withOpacity(0.7),
            size: 20,
          ),
        ),
      ),
    ),
  );
}


}