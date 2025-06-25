import 'dart:ui';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:movie_app_ui/Model/model.dart';
import 'package:movie_app_ui/event_details.dart';

class MovieDisplay extends StatefulWidget {
  const MovieDisplay({super.key});

  @override
  State<MovieDisplay> createState() => _MovieDisplayState();
}

int current = 0;

class _MovieDisplayState extends State<MovieDisplay> {
  Map<int, bool> hoverStates = {};
  bool isLoading = false;

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

  void _navigateToDetails(Map<String, dynamic> movie) {
    final eventData = {
      ...movie,
      'type': 'movie',
      'year': '2024',
      'genre': 'Action / Adventure',
      'description': 'After the death of his father, T\'Challa returns home to the African nation of Wakanda to take his rightful place as king. However, when a powerful enemy suddenly reappears, T\'Challa\'s mettle as king—and as Black Panther—gets tested when he\'s drawn into a conflict that puts the fate of Wakanda and the entire world at risk.',
    };

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EventDetailsPage(eventData: eventData),
      ),
    );
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: Text(
              movie['Title'],
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
                const SizedBox(height: 20),
                Text(
                  movie['Director'],
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
                      movie['rating'],
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                    ),
                    const SizedBox(width: 20),
                    Icon(Icons.access_time, color: Colors.grey[400], size: 18),
                    const SizedBox(width: 6),
                    Text(
                      movie['duration'],
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
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.menu, color: Colors.white, size: 26),
                      ),
                      const Expanded(
                        child: Text(
                          "Movies & Shows",
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
                        icon: const Icon(Icons.search, color: Colors.white, size: 26),
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
                              onEnter: (_) => setState(() => hoverStates[movieIndex] = true),
                              onExit: (_) => setState(() => hoverStates[movieIndex] = false),
                             child: GestureDetector(
            onTap: () => _navigateToDetails(movie),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              transform: Matrix4.identity()..scale(isHovered ? 1.02 : 1.0),
              child: Padding(
                padding: EdgeInsets.all(config.padding),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isHovered ? 0.2 : 0.1),
                        blurRadius: isHovered ? 15 : 10,
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
                                        child: Stack(
                                          children: [
                                            Image.network(
                                              movie['Image'],
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                              height: double.infinity,
                                              loadingBuilder: (context, child, loadingProgress) {
                                                if (loadingProgress == null) return child;
                                                return Container(
                                                  color: Colors.grey[300],
                                                  child: Center(
                                                    child: CircularProgressIndicator(
                                                      color: Colors.red,
                                                      value: loadingProgress.expectedTotalBytes != null
                                                          ? loadingProgress.cumulativeBytesLoaded /
                                                              loadingProgress.expectedTotalBytes!
                                                          : null,
                                                    ),
                                                  ),
                                                );
                                              },
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
                                            // OVERLAY DE LOADING GERAL:
                                            if (isLoading && current == movies.indexOf(movie))
                                              Container(
                                                color: Colors.black.withOpacity(0.3),
                                                child: const Center(
                                                  child: CircularProgressIndicator(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                          ],
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
                                            color: Colors.black87, // MUDANÇA: era Colors.black54
                                            fontWeight: FontWeight.w500,
                                          ),
                                          textAlign: TextAlign.center,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      
                                      SizedBox(height: deviceType == DeviceType.desktop ? 25 : 20),

                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.red.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: Colors.red.withOpacity(0.3)),
                                        ),
                                        child: Text(
                                          "Action • Adventure", // ou movie['genre'] se existir
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontSize: config.detailsFontSize - 2,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      
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
                      boxShadow: isActive ? [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ] : null,
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
              Colors.grey[600]!,
              config.detailsFontSize,
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildWatchButton(config.detailsFontSize),
      ],
    );
  }

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
          Colors.grey[600]!,
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
        Icon(icon, color: iconColor, size: fontSize + 6),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            color: Colors.grey[700],
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ],
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
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE53E3E), Color(0xFFD53F8C)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE53E3E).withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        child: Text(
          "Buy Ticket",
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 0.3,
          ),
        ),
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