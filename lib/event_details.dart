import 'package:flutter/material.dart';

class EventDetailsPage extends StatefulWidget {
  final Map<String, dynamic> eventData;

  const EventDetailsPage({super.key, required this.eventData});

  @override
  State<EventDetailsPage> createState() => _EventDetailsPageState();
}

class _EventDetailsPageState extends State<EventDetailsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          // Header com imagem de fundo
          SliverAppBar(
            expandedHeight: screenHeight * 0.6,
            pinned: true,
            backgroundColor: Colors.black,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(25),
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Imagem de fundo
                  Image.network(
                    widget.eventData['Image'] ?? '',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[800],
                        child: const Icon(
                          Icons.movie,
                          size: 100,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                          Colors.black.withOpacity(0.9),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Conteúdo principal
          SliverToBoxAdapter(
            child: Container(
              color: Colors.black,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Trending badge e informações básicas
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Badge "On Trending"
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'On Trending',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Título e informações
                        Text(
                          widget.eventData['Title'] ?? 'Event Title',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        
                        const SizedBox(height: 8),
                        
                        // Rating, qualidade e ano
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                '4K',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            
                            const SizedBox(width: 8),
                            
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'HDR',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            
                            const SizedBox(width: 8),
                            
                            Text(
                              widget.eventData['rating'] ?? '0.0',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 8),
                        
                        // Ano, gênero e duração
                        Text(
                          '${widget.eventData['year'] ?? '2024'} • ${widget.eventData['genre'] ?? 'Action / Adventure'} • ${widget.eventData['duration'] ?? '2h 30m'}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Botão principal (Play/Buy Ticket)
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                              // Ação do botão principal
                              _showTicketDialog(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _getMainButtonIcon(),
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _getMainButtonText(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Descrição
                        Text(
                          widget.eventData['description'] ?? 
                          'After the death of his father, T\'Challa returns home to the African nation of Wakanda to take his rightful place as king...',
                          style: const TextStyle(
                            color: Colors.grey[300],
                            fontSize: 14,
                            height: 1.5,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        
                        const SizedBox(height: 8),
                        
                        GestureDetector(
                          onTap: () {
                            // Expandir descrição
                          },
                          child: const Text(
                            'Read more',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Botões de ação (List, Like, Send)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildActionButton(
                              Icons.bookmark_border,
                              'List',
                              () {
                                // Adicionar à lista
                              },
                            ),
                            _buildActionButton(
                              Icons.thumb_up_outlined,
                              'Like',
                              () {
                                // Curtir
                              },
                            ),
                            _buildActionButton(
                              Icons.share_outlined,
                              'Send',
                              () {
                                // Compartilhar
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Tabs (Episodes, Cast, Reviews, Detail)
                  Container(
                    color: Colors.black,
                    child: TabBar(
                      controller: _tabController,
                      labelColor: Colors.red,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: Colors.red,
                      indicatorWeight: 3,
                      tabs: const [
                        Tab(text: 'Episodes'),
                        Tab(text: 'Cast'),
                        Tab(text: 'Reviews'),
                        Tab(text: 'Detail'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Conteúdo das tabs
          SliverFillRemaining(
            child: Container(
              color: Colors.black,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildEpisodesTab(),
                  _buildCastTab(),
                  _buildReviewsTab(),
                  _buildDetailTab(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getMainButtonIcon() {
    final eventType = widget.eventData['type'] ?? 'movie';
    switch (eventType) {
      case 'movie':
      case 'show':
        return Icons.play_arrow;
      case 'sports':
        return Icons.sports_soccer;
      case 'concert':
        return Icons.music_note;
      default:
        return Icons.confirmation_number;
    }
  }

  String _getMainButtonText() {
    final eventType = widget.eventData['type'] ?? 'movie';
    switch (eventType) {
      case 'movie':
      case 'show':
        return 'Play Film';
      case 'sports':
        return 'Buy Ticket';
      case 'concert':
        return 'Buy Ticket';
      default:
        return 'Get Ticket';
    }
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEpisodesTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              // Thumbnail do episódio
              Container(
                width: 120,
                height: 68,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[800],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.network(
                      widget.eventData['Image'] ?? '',
                      fit: BoxFit.cover,
                      width: 120,
                      height: 68,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[800],
                          child: const Icon(
                            Icons.play_circle_outline,
                            color: Colors.white,
                            size: 30,
                          ),
                        );
                      },
                    ),
                    const Icon(
                      Icons.play_circle_outline,
                      color: Colors.white,
                      size: 30,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Informações do episódio
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.eventData['Title'] ?? 'Event'} : Episode ${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 4),
                    
                    const Text(
                      '1h 52m',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    Text(
                      'Faced with treachery and danger, the young king must rally his allies and release the full power...',
                      style: TextStyle(
                        color: Colors.grey[300],
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCastTab() {
    return const Center(
      child: Text(
        'Cast information will be displayed here',
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildReviewsTab() {
    return const Center(
      child: Text(
        'Reviews will be displayed here',
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildDetailTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow('Director', widget.eventData['Director'] ?? 'Unknown'),
          _buildDetailRow('Genre', widget.eventData['genre'] ?? 'Action / Adventure'),
          _buildDetailRow('Duration', widget.eventData['duration'] ?? '2h 30m'),
          _buildDetailRow('Rating', widget.eventData['rating'] ?? '0.0'),
          _buildDetailRow('Year', widget.eventData['year'] ?? '2024'),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showTicketDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Purchase Ticket',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'This will open the ticket purchase flow',
                style: TextStyle(
                  color: Colors.grey[300],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // Implementar lógica de compra
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}