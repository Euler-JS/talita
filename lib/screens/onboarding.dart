import 'package:flutter/material.dart';
import 'package:movie_app_ui/movie.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
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
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _floatingAnimation;
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
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _floatingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 1.0, curve: Curves.elasticOut),
    ));

    _floatingAnimation = Tween<double>(
      begin: 0.0,
      end: 10.0,
    ).animate(CurvedAnimation(
      parent: _floatingController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
    _floatingController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _floatingController.dispose();
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
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Toggle LOGIN/SIGN UP
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: (){ setModalState(() => _isLogin = true); _clearFields();},
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _isLogin ? const Color(0xFFE53E3E) : Colors.transparent,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Text(
                            'LOGIN',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _isLogin ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {setModalState(() => _isLogin = false); _clearFields();},
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: !_isLogin ? const Color(0xFFE53E3E) : Colors.transparent,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Text(
                            'SIGN UP',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: !_isLogin ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
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
              
              // Action button
              Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE53E3E), Color(0xFFD53F8C)],
                  ),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: ElevatedButton(
                  onPressed: _isLoading ? null :() {
                    if (_isLogin) {
                      _login();
                    } else {
                      _signUp();
                    }
                    // Navigator.pop(context);
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(builder: (context) => const MovieDisplay()),
                    // );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  ),
                  child: Text(
                    _isLogin ? 'LOGIN' : 'SIGN UP',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
    return Stack(
      children: [
        Positioned(top: 50, left: 50, child: _buildStar(8)),
        Positioned(top: 100, right: 80, child: _buildStar(6)),
        Positioned(top: 200, left: 30, child: _buildStar(4)),
        Positioned(top: 250, right: 40, child: _buildStar(10)),
        Positioned(top: 350, left: 80, child: _buildStar(6)),
        Positioned(top: 400, right: 100, child: _buildStar(8)),
        Positioned(bottom: 100, left: 60, child: _buildStar(5)),
        Positioned(bottom: 150, right: 50, child: _buildStar(7)),
      ],
    );
  }

  Widget _buildStar(double size) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.pink.withOpacity(0.6),
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Widget _buildCentralIllustration() {
    return Center(
      child: AnimatedBuilder(
        animation: _floatingAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _floatingAnimation.value),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                width: 300,
                height: 300,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Base platform
                    Positioned(
                      bottom: 20,
                      child: Container(
                        width: 280,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD4A574),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              offset: const Offset(0, 10),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Popcorn container
                    Positioned(
                      top: 30,
                      right: 40,
                      child: _buildPopcornContainer(),
                    ),
                    
                    // Drink cup
                    Positioned(
                      top: 80,
                      left: 50,
                      child: _buildDrinkCup(),
                    ),
                    
                    // Cinema seat
                    Positioned(
                      bottom: 60,
                      child: _buildCinemaSeat(),
                    ),
                    
                    // People figures
                    Positioned(
                      bottom: 40,
                      left: 80,
                      child: _buildPersonFigure(Colors.blue),
                    ),
                    Positioned(
                      bottom: 40,
                      right: 100,
                      child: _buildPersonFigure(Colors.orange),
                    ),
                    
                    // Cinema ticket
                    Positioned(
                      bottom: 80,
                      right: 60,
                      child: _buildCinemaTicket(),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
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
      color: const Color(0xFF2D2D2D),
      borderRadius: BorderRadius.circular(25),
    ),
    child: TextField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        suffixIcon: Icon(icon, color: Colors.grey),
      ),
    ),
  );
}


}