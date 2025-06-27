import 'dart:ui';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:movie_app_ui/Model/model.dart';
import 'package:movie_app_ui/event_details.dart';
import 'package:movie_app_ui/screens/onboarding.dart';
import 'package:movie_app_ui/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class MovieDisplay extends StatefulWidget {
  const MovieDisplay({super.key});

  @override
  State<MovieDisplay> createState() => _MovieDisplayState();
}

int current = 0;

class _MovieDisplayState extends State<MovieDisplay> {
  Map<int, bool> hoverStates = {};
  bool isLoading = false;
  List<dynamic> movies = [];
  bool isLoadingMovies = false;
  String errorMessage = '';

  DeviceType getDeviceType(double width) {
    if (width < 600) {
      return DeviceType.mobile;
    } else if (width < 1200) {
      return DeviceType.tablet;
    } else {
      return DeviceType.desktop;
    }
  }

  ResponsiveConfig getResponsiveConfig(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.mobile:
        return ResponsiveConfig(
          viewportFraction: 0.7,
          cardHeight: 580,
          imageHeight: 280,
          imageWidth: 0.5,
          titleFontSize: 20,
          directorFontSize: 15,
          detailsFontSize: 14,
          padding: 12.0,
          bottomPosition: 20,
          stackHeight: 0.7,
        );
      case DeviceType.tablet:
        return ResponsiveConfig(
          viewportFraction: 0.5,
          cardHeight: 680,
          imageHeight: 380,
          imageWidth: 0.6,
          titleFontSize: 24,
          directorFontSize: 17,
          detailsFontSize: 16,
          padding: 16.0,
          bottomPosition: 30,
          stackHeight: 0.75,
        );
      case DeviceType.desktop:
        return ResponsiveConfig(
          viewportFraction: 0.35,
          cardHeight: 780,
          imageHeight: 420,
          imageWidth: 0.7,
          titleFontSize: 26,
          directorFontSize: 19,
          detailsFontSize: 17,
          padding: 20.0,
          bottomPosition: 50,
          stackHeight: 0.8,
        );
    }
  }

  Future<void> loadMovies() async {
    setState(() {
      isLoadingMovies = true;
      errorMessage = '';
    });

    try {
      final events = await ApiService.getEvents();
      setState(() {
        movies = events;
        isLoadingMovies = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Erro ao carregar eventos: $e';
        isLoadingMovies = false;
      });
    }
  }

  void _navigateToDetails(Map<String, dynamic> movie) {
    final eventData = {
      ...movie,
      // 'type': 'movie',
      // 'year': '2024',
      // 'genre': 'Action / Adventure',
      // 'description': 'After the death of his father, T\'Challa returns home to the African nation of Wakanda to take his rightful place as king. However, when a powerful enemy suddenly reappears, T\'Challa\'s mettle as king—and as Black Panther—gets tested when he\'s drawn into a conflict that puts the fate of Wakanda and the entire world at risk.',
    };

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EventDetailsPage(eventData: eventData),
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    try {
      // Fazer logout no backend
      final response = await http.post(
        Uri.parse('http://localhost:3000/api/auth/logout'), // substitua SEU_IP
        headers: {'Content-Type': 'application/json'},
      );

      // Limpar dados locais (se estiver usando SharedPreferences)
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_data');
      await prefs.setBool('is_logged_in', false);

      // Mostrar mensagem
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout realizado com sucesso!')),
      );

      // Navegar de volta para tela inicial/login
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
            builder: (context) =>
                const OnboardingScreen()), // altere para sua tela inicial
        (route) => false, // remove todas as telas do stack
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao fazer logout')),
      );
    }
  }

  Future<bool> _checkIfLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_logged_in') ?? false;
  }

// Use no initState ou onde precisar
  void _checkLoginStatus() async {
    bool isLoggedIn = await _checkIfLoggedIn();
    if (!isLoggedIn) {
      // Redirecionar para tela de login
    }
  }

  void _showDetailsDialog(Map<String, dynamic> movie) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 340),
          child: AlertDialog(
            backgroundColor: const Color(0xFF1A1A1A),
            contentPadding: const EdgeInsets.all(20),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: Text(
              movie['title'] ?? '',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 220,
                  width: 300,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.grey[800],
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: Image.network(
                    movie['poster_url'] ??
                        'https://i.ibb.co/BVff3hcS/vingadores.webp',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[800],
                        child: const Icon(Icons.movie,
                            color: Colors.grey, size: 50),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  movie['venues']?['name'] ?? 'Local não informado',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      movie['rating'] ?? '',
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                    ),
                    const SizedBox(width: 20),
                    Icon(Icons.access_time, color: Colors.grey[400], size: 18),
                    const SizedBox(width: 6),
                    Text(
                      movie['duration'] ?? '',
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'Click "View Details" to see the full page with tickets, cast, reviews and more information.',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Close',
                  style: TextStyle(color: Colors.grey[400], fontSize: 15),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE53E3E), Color(0xFFD53F8C)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ElevatedButton(
                  onPressed: () => _navigateToDetails(movie),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    'View Details',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    loadMovies();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final deviceType = getDeviceType(screenWidth);
    final config = getResponsiveConfig(deviceType);

    if (isLoadingMovies) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage.isNotEmpty) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(errorMessage),
              ElevatedButton(
                onPressed: loadMovies,
                child: Text('Tentar Novamente'),
              ),
            ],
          ),
        ),
      );
    }

    if (movies.isEmpty) {
      return Scaffold(
        body: Center(child: Text('Nenhum evento encontrado')),
      );
    }

    return Scaffold(
      body: SizedBox(
        height: screenHeight,
        child: Stack(
          children: [
            // Enhanced background with blur effect
            Container(
              width: double.infinity,
              height: double.infinity,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    child: Image.network(
                      movies[current]['poster_url'] ?? '',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.error,
                            size: 50,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
                  ),
                  // Backdrop blur effect
                  // Container(
                  //   decoration: BoxDecoration(
                  //     color: Colors.black.withOpacity(0.1),
                  //   ),
                  //   child: BackdropFilter(
                  //     filter: ImageFilter.blur(sigmaX: 1.5, sigmaY: 1.5),
                  //     child: Container(color: Colors.transparent),
                  //   ),
                  // ),
                ],
              ),
            ),

            // Enhanced gradient overlay
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.grey.shade900.withOpacity(1),
                      Colors.grey.shade900.withOpacity(1),
                      Colors.grey.shade900.withOpacity(0.9),
                      Colors.grey.shade800.withOpacity(0.7),
                      Colors.grey.shade800.withOpacity(0.3),
                      Colors.grey.shade800.withOpacity(0.1),
                      Colors.grey.shade800.withOpacity(0.0),
                      Colors.grey.shade800.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),

            // Enhanced header with better contrast
            Positioned(
              top: MediaQuery.of(context).padding.top + 20,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      PopupMenuButton<String>(
                        // <- SUBSTITUA O IconButton DO MENU
                        onSelected: (value) {
                          // <- POR ESTE PopupMenuButton
                          if (value == 'logout') {
                            _logout(context);
                          }
                        },
                        icon: const Icon(Icons.menu,
                            color: Colors.white, size: 26),
                        color: const Color(0xFF2D2D2D),
                        itemBuilder: (BuildContext context) {
                          return [
                            // const PopupMenuItem<String>(
                            //   value: 'profile',
                            //   child: Row(
                            //     children: [
                            //       Icon(Icons.person, color: Colors.white),
                            //       SizedBox(width: 8),
                            //       Text('Perfil', style: TextStyle(color: Colors.white)),
                            //     ],
                            //   ),
                            // ),
                            // const PopupMenuItem<String>(
                            //   value: 'settings',
                            //   child: Row(
                            //     children: [
                            //       Icon(Icons.settings, color: Colors.white),
                            //       SizedBox(width: 8),
                            //       Text('Configurações', style: TextStyle(color: Colors.white)),
                            //     ],
                            //   ),
                            // ),
                            const PopupMenuItem<String>(
                              value: 'logout',
                              child: Row(
                                children: [
                                  Icon(Icons.logout, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('Logout',
                                      style: TextStyle(color: Colors.red)),
                                ],
                              ),
                            ),
                          ];
                        },
                      ),
                      Expanded(
                        child: Text(
                          movies[current]['type']?.toUpperCase() ??
                                                        'EVENT',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.search,
                            color: Colors.white, size: 26),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Enhanced carousel
            Positioned(
              bottom: config.bottomPosition,
              height: screenHeight * config.stackHeight,
              width: screenWidth,
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: deviceType == DeviceType.desktop
                        ? 1400
                        : double.infinity,
                  ),
                  child: CarouselSlider(
                    options: CarouselOptions(
                      height: config.cardHeight,
                      viewportFraction: config.viewportFraction,
                      enlargeCenterPage: true,
                      enlargeFactor:
                          deviceType == DeviceType.desktop ? 0.2 : 0.3,
                      onPageChanged: (index, reason) {
                        setState(() {
                          isLoading = true;
                          current = index;
                        });

                        Future.delayed(const Duration(milliseconds: 300), () {
                          if (mounted) {
                            setState(() {
                              isLoading = false;
                            });
                          }
                        });
                      },
                    ),
                    items: movies.map((movie) {
                      return Builder(
                        builder: (BuildContext context) {
                          final movieIndex = movies.indexOf(movie);
                          final isHovered = hoverStates[movieIndex] ?? false;
                          return MouseRegion(
                              onEnter: (_) => setState(
                                  () => hoverStates[movieIndex] = true),
                              onExit: (_) => setState(
                                  () => hoverStates[movieIndex] = false),
                              child: GestureDetector(
                                  onTap: () => _navigateToDetails(movie),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    transform: Matrix4.identity()
                                      ..scale(isHovered ? 1.02 : 1.0),
                                    child: Padding(
                                      padding: EdgeInsets.all(config.padding),
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              Colors.white,
                                              Colors.grey.shade50,
                                            ],
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(24),
                                          border: Border.all(
                                            color: Colors.grey.shade200,
                                            width: 1,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black
                                                  .withOpacity(0.08),
                                              blurRadius: 20,
                                              offset: const Offset(0, 8),
                                              spreadRadius: 0,
                                            ),
                                            BoxShadow(
                                              color: Colors.black
                                                  .withOpacity(0.04),
                                              blurRadius: 40,
                                              offset: const Offset(0, 16),
                                              spreadRadius: 0,
                                            ),
                                          ],
                                        ),
                                        child: SingleChildScrollView(
                                          child: Padding(
                                            padding: const EdgeInsets.all(4.0),
                                            child: Column(
                                              children: [
                                                // Movie poster

                                                Container(
                                                  height: config.imageHeight,
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      config.imageWidth,
                                                  margin: const EdgeInsets.only(
                                                      top: 20),
                                                  clipBehavior: Clip.hardEdge,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16),
                                                    gradient: LinearGradient(
                                                      begin:
                                                          Alignment.topCenter,
                                                      end: Alignment
                                                          .bottomCenter,
                                                      colors: [
                                                        Colors.transparent,
                                                        Colors.black
                                                            .withOpacity(0.1),
                                                      ],
                                                    ),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black
                                                            .withOpacity(0.15),
                                                        blurRadius: 12,
                                                        offset:
                                                            const Offset(0, 6),
                                                        spreadRadius: -2,
                                                      ),
                                                    ],
                                                  ),
                                                  child: Stack(
                                                    children: [
                                                      Image.network(
                                                        movie['poster_url'] ??
                                                            'https://i.ibb.co/BVff3hcS/vingadores.webp',
                                                        fit: BoxFit.cover,
                                                        width: double.infinity,
                                                        height: double.infinity,
                                                        loadingBuilder: (context,
                                                            child,
                                                            loadingProgress) {
                                                          if (loadingProgress ==
                                                              null)
                                                            return child;
                                                          return Container(
                                                            color: Colors
                                                                .grey[300],
                                                            child: Center(
                                                              child:
                                                                  CircularProgressIndicator(
                                                                color:
                                                                    Colors.red,
                                                                value: loadingProgress
                                                                            .expectedTotalBytes !=
                                                                        null
                                                                    ? loadingProgress
                                                                            .cumulativeBytesLoaded /
                                                                        loadingProgress
                                                                            .expectedTotalBytes!
                                                                    : null,
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                        errorBuilder: (context,
                                                            error, stackTrace) {
                                                          return Container(
                                                            color: Colors
                                                                .grey[300],
                                                            child: const Icon(
                                                              Icons.movie,
                                                              size: 50,
                                                              color:
                                                                  Colors.grey,
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                      // OVERLAY DE LOADING GERAL:
                                                      if (isLoading &&
                                                          current ==
                                                              movies.indexOf(
                                                                  movie))
                                                        Container(
                                                          color: Colors.black
                                                              .withOpacity(0.3),
                                                          child: const Center(
                                                            child:
                                                                CircularProgressIndicator(
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                ),

                                                SizedBox(
                                                    height: deviceType ==
                                                            DeviceType.desktop
                                                        ? 25
                                                        : 20),

                                                // Movie title
                                                Padding(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: deviceType ==
                                                            DeviceType.desktop
                                                        ? 24
                                                        : 16,
                                                  ),
                                                  child: Text(
                                                    movie['title'] ??
                                                        'Título não informado',
                                                    style: TextStyle(
                                                      fontSize:
                                                          config.titleFontSize,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      color:
                                                          Colors.grey.shade800,
                                                      letterSpacing: -0.5,
                                                      height: 1.2,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),

                                                SizedBox(
                                                    height: deviceType ==
                                                            DeviceType.desktop
                                                        ? 15
                                                        : 10),

                                                // Director
                                                Padding(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: deviceType ==
                                                            DeviceType.desktop
                                                        ? 24
                                                        : 16,
                                                  ),
                                                  child: Text(
                                                    movie['venues']?['name'] ??
                                                        'Local não informado',
                                                    style: TextStyle(
                                                      color:
                                                          Colors.grey.shade600,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: config
                                                          .directorFontSize,
                                                      letterSpacing: 0.3,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),

                                                SizedBox(
                                                    height: deviceType ==
                                                            DeviceType.desktop
                                                        ? 25
                                                        : 20),

                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 14,
                                                      vertical: 6),
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      colors: [
                                                        const Color(0xFFE53E3E),
                                                        const Color(0xFFDC2626),
                                                      ],
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: const Color(
                                                                0xFFE53E3E)
                                                            .withOpacity(0.4),
                                                        blurRadius: 12,
                                                        offset:
                                                            const Offset(0, 4),
                                                      ),
                                                    ],
                                                  ),
                                                  child: Text(
                                                    movie['type']
                                                            ?.toUpperCase() ??
                                                        'EVENT',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: config
                                                              .detailsFontSize -
                                                          2,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      letterSpacing: 1.2,
                                                    ),
                                                  ),
                                                ),
                                                // Movie details (rating, duration, watch)
                                                AnimatedOpacity(
                                                  duration: const Duration(
                                                      milliseconds: 1000),
                                                  opacity: current ==
                                                          movies.indexOf(movie)
                                                      ? 1.0
                                                      : 0.0,
                                                  child: Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                      horizontal: deviceType ==
                                                              DeviceType.desktop
                                                          ? 32
                                                          : 18,
                                                      vertical: 8,
                                                    ),
                                                    child: deviceType ==
                                                            DeviceType.desktop
                                                        ? _buildDesktopDetails(
                                                            movie, config)
                                                        : _buildMobileTabletDetails(
                                                            movie,
                                                            config,
                                                            deviceType),
                                                  ),
                                                ),

                                                SizedBox(
                                                    height: deviceType ==
                                                            DeviceType.desktop
                                                        ? 20
                                                        : 10),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  )));
                        },
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),

            Positioned(
              bottom: config.bottomPosition + config.cardHeight + 40,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: movies.asMap().entries.map((entry) {
                  final isActive = current == entry.key;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOutCubic,
                    width: isActive ? 24 : 12,
                    height: 12,
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: isActive
                          ? Colors.white
                          : Colors.white.withOpacity(0.4),
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.6),
                                blurRadius: 12,
                                offset: const Offset(0, 2),
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopDetails(
      Map<String, dynamic> movie, ResponsiveConfig config) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildDetailItem(
                Icons.star,
                movie['rating'] ?? '',
                Colors.amber,
                config.detailsFontSize,
              ),
              _buildDetailItem(
                Icons.access_time,
                movie['duration'] ?? ' ',
                Colors.grey[600]!,
                config.detailsFontSize,
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildWatchButton(config.detailsFontSize),
        ],
      ),
    );
  }

  Widget _buildMobileTabletDetails(Map<String, dynamic> movie,
      ResponsiveConfig config, DeviceType deviceType) {
      return Column(
        children: [
            if (MediaQuery.of(context).size.width < 350) // ✅ ADICIONE esta condição
        Column(
          children: [
            _buildDetailItem(
              Icons.attach_money,
              '${movie['price']} ${movie['currency'] ?? 'MZN'}',
              const Color(0xFF059669),
              config.detailsFontSize,
            ),
            const SizedBox(height: 8),
            _buildDetailItem(
              Icons.access_time,
              _formatEventDuration(movie),
              Colors.blue.shade600,
              config.detailsFontSize,
            ),
          ],
        )
        else
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                flex: 1,
                child: _buildDetailItem(
                  Icons.attach_money,
                  '${movie['price']} ${movie['currency'] ?? 'MZN'}',
                  const Color(0xFF059669), // Verde para preço
                  config.detailsFontSize,
                ),
              ),
              const SizedBox(width: 8,),
              Flexible(
                flex: 1,
                child: _buildDetailItem(
                  Icons.access_time,
                  _formatEventDuration(movie),
                  Colors.blue.shade600,
                  config.detailsFontSize,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (movie['rating'] != null)
            Flexible(
              flex: 1,
              child: _buildDetailItem(
                Icons.star,
                movie['rating'].toString(),
                Colors.amber.shade600,
                config.detailsFontSize,
              ),
            ),
            const SizedBox(height: 16),
            _buildWatchButton(config.detailsFontSize),
        ],
    );
  }

  String _formatEventDuration(Map<String, dynamic> event) {
    return event['start_date_time'];
    try {
      final start = DateTime.parse(event['start_date_time']);
      final end = DateTime.parse(event['end_date_time']);
      final duration = end.difference(start);
      final hours = duration.inHours;
      final minutes = duration.inMinutes % 60;
      return '${hours}h${minutes}m';
    } catch (e) {
      return 'N/A';
    }
  }

  Widget _buildDetailItem(
      IconData icon, String text, Color iconColor, double fontSize) {
    return Flexible(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 160),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade100.withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey.shade200,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: fontSize * 0.7,
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: fontSize - 3,
                  color: Colors.grey[800],
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.1,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWatchSection(double fontSize, DeviceType deviceType) {
    return SizedBox(
      width: deviceType == DeviceType.desktop ? 120 : 100,
      child: _buildWatchButton(fontSize),
    );
  }

Widget _buildWatchButton(double fontSize) {
  return Container(
    constraints: const BoxConstraints(minWidth: 80),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          const Color(0xFFE53E3E).withOpacity(0.1),
          const Color(0xFFD53F8C).withOpacity(0.1),
        ],
      ),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: const Color(0xFFE53E3E).withOpacity(0.3),
        width: 1,
      ),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.confirmation_number_outlined,
          color: const Color(0xFFE53E3E),
          size: fontSize * 0.8,
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            "Tickets",
            style: TextStyle(
              fontSize: fontSize - 3,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFE53E3E),
              letterSpacing: 0.3,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
  );
}
}

// Enhanced responsive configuration
enum DeviceType { mobile, tablet, desktop }

class ResponsiveConfig {
  final double viewportFraction;
  final double cardHeight;
  final double imageHeight;
  final double imageWidth;
  final double titleFontSize;
  final double directorFontSize;
  final double detailsFontSize;
  final double padding;
  final double bottomPosition;
  final double stackHeight;

  ResponsiveConfig({
    required this.viewportFraction,
    required this.cardHeight,
    required this.imageHeight,
    required this.imageWidth,
    required this.titleFontSize,
    required this.directorFontSize,
    required this.detailsFontSize,
    required this.padding,
    required this.bottomPosition,
    required this.stackHeight,
  });
}
