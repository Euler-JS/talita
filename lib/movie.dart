import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:movie_app_ui/Model/model.dart';
import 'package:movie_app_ui/event_details.dart';

// Importe a página de detalhes aqui
// import 'event_details_page.dart';

class MovieDisplay extends StatefulWidget {
  const MovieDisplay({super.key});

  @override
  State<MovieDisplay> createState() => _MovieDisplayState();
}

int current = 0;

class _MovieDisplayState extends State<MovieDisplay> {
  // Função para determinar o tipo de dispositivo baseado na largura
  DeviceType getDeviceType(double width) {
    if (width < 600) {
      return DeviceType.mobile;
    } else if (width < 1200) {
      return DeviceType.tablet;
    } else {
      return DeviceType.desktop;
    }
  }

  // Função para obter configurações responsivas
  ResponsiveConfig getResponsiveConfig(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.mobile:
        return ResponsiveConfig(
          viewportFraction: 0.7,
          cardHeight: 550,
          imageHeight: 300,
          imageWidth: 0.5,
          titleFontSize: 18,
          directorFontSize: 14,
          detailsFontSize: 13,
          padding: 8.0,
          bottomPosition: 5,
          stackHeight: 0.7,
        );
      case DeviceType.tablet:
        return ResponsiveConfig(
          viewportFraction: 0.5,
          cardHeight: 650,
          imageHeight: 400,
          imageWidth: 0.6,
          titleFontSize: 22,
          directorFontSize: 16,
          detailsFontSize: 15,
          padding: 12.0,
          bottomPosition: 20,
          stackHeight: 0.75,
        );
      case DeviceType.desktop:
        return ResponsiveConfig(
          viewportFraction: 0.35,
          cardHeight: 750,
          imageHeight: 450,
          imageWidth: 0.7,
          titleFontSize: 24,
          directorFontSize: 18,
          detailsFontSize: 16,
          padding: 16.0,
          bottomPosition: 40,
          stackHeight: 0.8,
        );
    }
  }

  // Função para navegar para a página de detalhes
  void _navigateToDetails(Map<String, dynamic> movie) {
    // Preparar dados extras para a página de detalhes
    final eventData = {
      ...movie,
      'type': 'movie', // ou 'sports', 'concert', etc.
      'year': '2024',
      'genre': 'Action / Adventure',
      'description': 'After the death of his father, T\'Challa returns home to the African nation of Wakanda to take his rightful place as king. However, when a powerful enemy suddenly reappears, T\'Challa\'s mettle as king—and as Black Panther—gets tested when he\'s drawn into a conflict that puts the fate of Wakanda and the entire world at risk.',
    };

    // Navegação para a página de detalhes
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EventDetailsPage(eventData: eventData),
      ),
    );
    
    // Por enquanto, apenas mostra um dialog
  }

 void _showDetailsDialog(Map<String, dynamic> movie) {
  showDialog(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 320),
        child: AlertDialog(
          backgroundColor: Colors.grey[900],
          contentPadding: const EdgeInsets.all(16),
          title: Text(
            movie['Title'],
            style: const TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 200,
                width: 280,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[800],
                ),
                clipBehavior: Clip.hardEdge,
                child: Image.network(
                  movie['Image'],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[800],
                      child: const Icon(Icons.movie, color: Colors.grey, size: 50),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Text(
                movie['Director'],
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.star, color: Colors.amber, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    movie['rating'],
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.access_time, color: Colors.grey, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    movie['duration'],
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Click "View Details" to see the full page with tickets, cast, reviews and more information.',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                _navigateToDetails(movie);
                // Navigator.pop(context);
                // ScaffoldMessenger.of(context).showSnackBar(
                //   const SnackBar(
                //     content: Text('Página de detalhes em desenvolvimento...'),
                //     backgroundColor: Colors.red,
                //   ),
                // );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('View Details', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final deviceType = getDeviceType(screenWidth);
    final config = getResponsiveConfig(deviceType);

    return Scaffold(
      body: SizedBox(
        height: screenHeight,
        child: Stack(
          children: [
            // Background image com melhor responsividade
            Container(
              width: double.infinity,
              height: double.infinity,
              child: Image.network(
                movies[current]['Image'],
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
            
            // Gradient overlay responsivo
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
                      Colors.grey.shade50.withOpacity(1),
                      Colors.grey.shade50.withOpacity(1),
                      Colors.grey.shade50.withOpacity(0.9),
                      Colors.grey.shade100.withOpacity(0.7),
                      Colors.grey.shade100.withOpacity(0.3),
                      Colors.grey.shade100.withOpacity(0.1),
                      Colors.grey.shade100.withOpacity(0.0),
                      Colors.grey.shade100.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),

            // Carousel responsivo
            Positioned(
              bottom: config.bottomPosition,
              height: screenHeight * config.stackHeight,
              width: screenWidth,
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: deviceType == DeviceType.desktop ? 1400 : double.infinity,
                  ),
                  child: CarouselSlider(
                    options: CarouselOptions(
                      height: config.cardHeight,
                      viewportFraction: config.viewportFraction,
                      enlargeCenterPage: true,
                      enlargeFactor: deviceType == DeviceType.desktop ? 0.2 : 0.3,
                      onPageChanged: (index, reason) {
                        setState(() {
                          current = index;
                        });
                      },
                    ),
                    items: movies.map((movie) {
                      return Builder(
                        builder: (BuildContext context) {
                          return GestureDetector(
    
                            onTap: () => _navigateToDetails(movie),
                            child: Padding(
                              padding: EdgeInsets.all(config.padding),
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 10,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      // Movie poster
                                      Container(
                                        height: config.imageHeight,
                                        width: MediaQuery.of(context).size.width * config.imageWidth,
                                        margin: const EdgeInsets.only(top: 20),
                                        clipBehavior: Clip.hardEdge,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(15),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.2),
                                              blurRadius: 8,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Image.network(
                                          movie['Image'],
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Container(
                                              color: Colors.grey[300],
                                              child: const Icon(
                                                Icons.movie,
                                                size: 50,
                                                color: Colors.grey,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      
                                      SizedBox(height: deviceType == DeviceType.desktop ? 25 : 20),
                                      
                                      // Movie title
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: deviceType == DeviceType.desktop ? 24 : 16,
                                        ),
                                        child: Text(
                                          movie['Title'],
                                          style: TextStyle(
                                            fontSize: config.titleFontSize,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      
                                      SizedBox(height: deviceType == DeviceType.desktop ? 15 : 10),
                                      
                                      // Director
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: deviceType == DeviceType.desktop ? 24 : 16,
                                        ),
                                        child: Text(
                                          movie['Director'],
                                          style: TextStyle(
                                            fontSize: config.directorFontSize,
                                            color: Colors.black54,
                                          ),
                                          textAlign: TextAlign.center,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      
                                      SizedBox(height: deviceType == DeviceType.desktop ? 25 : 20),
                                      
                                      // Movie details (rating, duration, watch)
                                      AnimatedOpacity(
                                        duration: const Duration(milliseconds: 1000),
                                        opacity: current == movies.indexOf(movie) ? 1.0 : 0.0,
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: deviceType == DeviceType.desktop ? 32 : 18,
                                            vertical: 8,
                                          ),
                                          child: deviceType == DeviceType.desktop
                                              ? _buildDesktopDetails(movie, config)
                                              : _buildMobileTabletDetails(movie, config, deviceType),
                                        ),
                                      ),
                                      
                                      SizedBox(height: deviceType == DeviceType.desktop ? 20 : 10),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Layout para desktop (mais espaçado)
  Widget _buildDesktopDetails(Map<String, dynamic> movie, ResponsiveConfig config) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildDetailItem(
              Icons.star,
              movie['rating'],
              Colors.amber,
              config.detailsFontSize,
            ),
            _buildDetailItem(
              Icons.access_time,
              movie['duration'],
              Colors.black54,
              config.detailsFontSize,
            ),
          ],
        ),
        const SizedBox(height: 15),
        _buildWatchButton(config.detailsFontSize),
      ],
    );
  }

  // Layout para mobile e tablet (em linha)
  Widget _buildMobileTabletDetails(Map<String, dynamic> movie, ResponsiveConfig config, DeviceType deviceType) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildDetailItem(
          Icons.star,
          movie['rating'],
          Colors.amber,
          config.detailsFontSize,
        ),
        _buildDetailItem(
          Icons.access_time,
          movie['duration'],
          Colors.black54,
          config.detailsFontSize,
        ),
        _buildWatchSection(config.detailsFontSize, deviceType),
      ],
    );
  }

  Widget _buildDetailItem(IconData icon, String text, Color iconColor, double fontSize) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: iconColor, size: fontSize + 5),
        const SizedBox(width: 5),
        Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            color: Colors.black54,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildWatchSection(double fontSize, DeviceType deviceType) {
    return SizedBox(
      width: deviceType == DeviceType.desktop ? 100 : 80,
      child: _buildWatchButton(fontSize),
    );
  }

  Widget _buildWatchButton(double fontSize) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.play_circle,
          color: Colors.black87,
          size: fontSize + 5,
        ),
        const SizedBox(width: 5),
        Text(
          "Watch",
          style: TextStyle(
            fontSize: fontSize,
            color: Colors.black54,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// Enums e classes para configuração responsiva
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


