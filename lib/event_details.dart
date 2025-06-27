import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EventDetailsPage extends StatefulWidget {
  final Map<String, dynamic> eventData;

  const EventDetailsPage({super.key, required this.eventData});

  @override
  State<EventDetailsPage> createState() => _EventDetailsPageState();
}

class _EventDetailsPageState extends State<EventDetailsPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

    String _getImageUrl() {
    return widget.eventData['poster_url'] ?? 
           'https://via.placeholder.com/400x600?text=No+Image';
  }

  String _getTitle() {
    return widget.eventData['title'] ?? 'Event Title';
  }

  String _getDescription() {
    return widget.eventData['description'] ?? 
           'No description available for this event.';
  }

  String _getEventYear() {
    try {
      final startDate = widget.eventData['start_date_time'];
      if (startDate != null) {
        return DateTime.parse(startDate).year.toString();
      }
    } catch (e) {
      // ignore
    }
    return '2024';
  }

  String _getEventGenre() {
    return widget.eventData['type'] ?? 'Event';
  }

  String _getDuration() {
     try {
      
    final start = DateTime.parse(widget.eventData['start_date_time']);
    
    // Formato: "04 Dez" ou "4 Dec" dependendo da localização
    return DateFormat('d MMM', 'pt_BR').format(start);
    // return '${start.day.toString().padLeft(2, '0')}/${start.month.toString().padLeft(2, '0')}';
    
  } catch (e) {
    print(e);
    return 'N/A';
  }
  }

  String _getRating() {
    // Como não temos rating na API, vamos gerar baseado no preço ou usar padrão
    final price = double.tryParse(widget.eventData['price']?.toString() ?? '0') ?? 0;
    if (price > 100) return '9.2';
    if (price > 50) return '8.5';
    return '7.8';
  }

  String _getVenueName() {
    return widget.eventData['venues']?['name'] ?? 'Venue Name';
  }

  String _getPrice() {
    final price = widget.eventData['price']?.toString() ?? '0';
    final currency = widget.eventData['currency'] ?? 'MT';
    return '$currency $price';
  }

  String _getAvailableTickets() {
    final availableTickets = widget.eventData['available_tickets']?.toString() ?? '0';
    return '$availableTickets';
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: CustomScrollView(
        slivers: [
          // Header com imagem de fundo melhorado
          SliverAppBar(
            expandedHeight: screenHeight * 0.65,
            pinned: true,
            backgroundColor: const Color(0xFF0A0A0A),
            leading: Container(
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, 
                        color: Colors.white, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Imagem de fundo
                  Image.network(
                    _getImageUrl(),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.grey[800]!,
                              Colors.grey[900]!,
                            ],
                          ),
                        ),
                        child: const Icon(
                          Icons.movie_outlined,
                          size: 120,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
                  // Gradient overlay melhorado
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.05),
                          Colors.black.withOpacity(0.2),
                          Colors.black.withOpacity(0.5),
                          Colors.black.withOpacity(0.8),
                          const Color(0xFF0A0A0A),
                        ],
                        stops: const [0.0, 0.3, 0.5, 0.7, 0.9, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Conteúdo principal melhorado
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                color: const Color(0xFF0A0A0A),
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badge "On Trending" modernizado
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFE50914),
                            const Color(0xFFB91C1C),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFE50914).withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${_getEventGenre().toUpperCase()}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                              
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Título melhorado
                    Text(
                      _getTitle(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                        letterSpacing: -0.5,
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Rating e informações modernizadas
                    Row(
                      children: [
                        _buildInfoChip(_getPrice(), Icons.money),
                        const SizedBox(width: 12),
                        _buildInfoChip(_getAvailableTickets(), Icons.confirmation_number_outlined),
                        const SizedBox(width: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFD700).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xFFFFD700).withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.calendar_month_outlined, 
                                  color: Color(0xFFFFD700), size: 16),
                              const SizedBox(width: 4),
                              Text(
                                _getDuration().toUpperCase(),
                                style: const TextStyle(
                                  color: Color(0xFFFFD700), 
                                  fontSize: 14, 
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Info do filme melhorada
                    Text(
                      '${_getEventYear()} • ${_getEventGenre().toUpperCase()}}',
                      style: TextStyle(
                        color: Colors.grey[400], 
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.3,
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Botão principal melhorado
                    Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFE50914), Color(0xFFB91C1C)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFE50914).withOpacity(0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            HapticFeedback.mediumImpact();
                            _showTicketDialog(context);
                          },
                          child: const Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.confirmation_number_outlined, 
                                    color: Colors.white, size: 22),
                                SizedBox(width: 12),
                                Text(
                                  'Comprar Bilhete',
                                  style: TextStyle(
                                    color: Colors.white, 
                                    fontSize: 16, 
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 28),
                    
                    // Descrição melhorada
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.05),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Detalhes',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                           _getDescription(),
                           style: TextStyle(
                              color: Colors.grey[300], 
                              fontSize: 15, 
                              height: 1.6,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 6),
          Text(
            text, 
            style: const TextStyle(
              color: Colors.white, 
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showTicketDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => TicketPurchaseForm(eventData: widget.eventData),
    );
  }
}

class TicketPurchaseForm extends StatefulWidget {
  final Map<String, dynamic> eventData;

  const TicketPurchaseForm({super.key, required this.eventData});

  @override
  State<TicketPurchaseForm> createState() => _TicketPurchaseFormState();
}

class _TicketPurchaseFormState extends State<TicketPurchaseForm>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();
  
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  
  int _ticketQuantity = 1;
  double _ticketPrice = 0.0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _ticketPrice = _getEventPrice();
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    _slideController.forward();

  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> _createBooking() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = await prefs.getString('user_data');
    final userData = jsonDecode(userDataString!);
    

    final bookingData = {
      'event_id': widget.eventData['id'],
      'user_id': userData['id'],
      'quantity': _ticketQuantity,
      'customer_notes': _notesController.text.trim().isNotEmpty 
          ? _notesController.text.trim() 
          : null,
    };

    final response = await http.post(
      Uri.parse('http://localhost:3000/api/bookings'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: json.encode(bookingData),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      final error = json.decode(response.body);
      throw Exception(error['error'] ?? 'Erro ao criar reserva');
    }
  }

  // ADICIONAR métodos auxiliares:
  String _getEventTitle() {
    return widget.eventData['title'] ?? 'Event';
  }

  String _getEventId() {
    return widget.eventData['id']?.toString() ?? '';
  }

  double _getEventPrice() {
    return double.tryParse(widget.eventData['price']?.toString() ?? '0') ?? 25.0;
  }

  double get _totalPrice => _ticketQuantity * _ticketPrice;

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header melhorado
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF0F0F0F),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                children: [
                  // Handle melhorado
                  Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[500],
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE50914).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.confirmation_number_outlined, 
                          color: Color(0xFFE50914), 
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Comprar Bilhete',
                              style: TextStyle(
                                color: Colors.white, 
                                fontSize: 22, 
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _getEventTitle(),
                              style: TextStyle(
                                color: Colors.grey[400], 
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Form Content melhorado
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nome completo
                      _buildInputSection(
                        'Nome Completo',
                        _nameController,
                        'Digite seu nome completo',
                        Icons.person_outline,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Nome é obrigatório';
                          }
                          if (value.trim().length < 2) {
                            return 'Nome deve ter pelo menos 2 caracteres';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Número de celular
                      _buildInputSection(
                        'Número de Celular',
                        _phoneController,
                        '+258 XX XXX XXXX',
                        Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(15),
                        ],
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Número de celular é obrigatório';
                          }
                          if (value.length < 9) {
                            return 'Número de celular inválido';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Quantidade de tickets melhorado
                      const Text(
                        'Quantidade de Tickets',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF2A2A2A),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        child: Row(
                          children: [
                            _buildQuantityButton(
                              Icons.remove,
                              _ticketQuantity > 1,
                              () => setState(() => _ticketQuantity--),
                            ),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                child: Column(
                                  children: [
                                    Text(
                                      '$_ticketQuantity',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      'Ticket${_ticketQuantity > 1 ? 's' : ''}',
                                      style: TextStyle(
                                        color: Colors.grey[400],
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            _buildQuantityButton(
                              Icons.add,
                              _ticketQuantity < 10,
                              () => setState(() => _ticketQuantity++),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Resumo do preço melhorado
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF2A2A2A),
                              const Color(0xFF1F1F1F),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        child: Column(
                          children: [
                            _buildPriceRow(
                              'Preço por ticket:', 
                              'MT ${_ticketPrice.toStringAsFixed(2)}',
                              false,
                            ),
                            const SizedBox(height: 12),
                            _buildPriceRow(
                              'Quantidade:', 
                              '$_ticketQuantity ticket${_ticketQuantity > 1 ? 's' : ''}',
                              false,
                            ),
                            const SizedBox(height: 16),
                            Container(
                              height: 1,
                              color: Colors.white.withOpacity(0.1),
                            ),
                            const SizedBox(height: 16),
                            _buildPriceRow(
                              'Total:', 
                              'MT ${_totalPrice.toStringAsFixed(2)}',
                              true,
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Notas adicionais
                      _buildInputSection(
                        'Notas Adicionais (Opcional)',
                        _notesController,
                        'Alguma observação especial?',
                        Icons.notes_outlined,
                        maxLines: 3,
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Botão de confirmação melhorado
                      Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: _isLoading 
                                ? [Colors.grey[600]!, Colors.grey[700]!]
                                : [const Color(0xFFE50914), const Color(0xFFB91C1C)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: _isLoading ? [] : [
                            BoxShadow(
                              color: const Color(0xFFE50914).withOpacity(0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: _isLoading ? null : _handlePurchase,
                            child: Center(
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      'Confirmar Compra - MT ${_totalPrice.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputSection(
    String label,
    TextEditingController controller,
    String hint,
    IconData icon, {
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[500]),
            filled: true,
            fillColor: const Color(0xFF2A2A2A),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE50914), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            prefixIcon: Icon(icon, color: Colors.grey[500]),
            contentPadding: const EdgeInsets.all(16),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildQuantityButton(IconData icon, bool enabled, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: enabled ? onTap : null,
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Icon(
            icon,
            color: enabled ? Colors.white : Colors.grey[600],
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, bool isTotal) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isTotal ? Colors.white : Colors.grey[400],
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isTotal ? const Color(0xFFE50914) : Colors.white,
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }



void _handlePurchase() async {
  if (!_formKey.currentState!.validate()) return;

  // Verificar se temos ID do evento
  if (_getEventId().isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.error, color: Colors.white),
            SizedBox(width: 12),
            Text('Erro: ID do evento não encontrado'),
          ],
        ),
        backgroundColor: Colors.red[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
    return;
  }

  setState(() {
    _isLoading = true;
  });

  try {
    final result = await _createBooking();

    if (!mounted) return;

    // Mostra o diálogo de sucesso primeiro e aguarda o botão "OK"
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _buildSuccessDialog(result),
    );

    // Depois que o usuário fecha o diálogo, volta para a tela anterior
    if (mounted) {
      Navigator.pop(context);
    }

  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text('Erro: ${e.toString()}')),
            ],
          ),
          backgroundColor: Colors.red[600],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  } finally {
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }
}


// ADICIONAR este método para o dialog de sucesso:
Widget _buildSuccessDialog(Map<String, dynamic> booking) {
  return AlertDialog(
    backgroundColor: const Color(0xFF1A1A1A),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    title: const Row(
      children: [
        Icon(Icons.check_circle, color: Colors.green, size: 28),
        SizedBox(width: 12),
        Text(
          'Reserva Criada!',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ],
    ),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sua reserva foi criada com sucesso.',
          style: TextStyle(color: Colors.grey[300], fontSize: 16),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow(
                'Número da Reserva:', 
                booking['booking']?['booking_number'] ?? 'N/A'
              ),
              const SizedBox(height: 8),
              _buildDetailRow(
                'Evento:', 
                _getEventTitle()
              ),
              const SizedBox(height: 8),
              _buildDetailRow(
                'Quantidade:', 
                '$_ticketQuantity ticket${_ticketQuantity > 1 ? 's' : ''}'
              ),
              const SizedBox(height: 8),
              _buildDetailRow(
                'Total:', 
                'MT ${_totalPrice.toStringAsFixed(2)}'
              ),
            ],
          ),
        ),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text(
          'OK',
          style: TextStyle(color: Color(0xFFE50914), fontSize: 16),
        ),
      ),
    ],
  );
}

// ADICIONAR este método auxiliar:
Widget _buildDetailRow(String label, String value) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        label,
        style: TextStyle(color: Colors.grey[400], fontSize: 14),
      ),
      Text(
        value,
        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
      ),
    ],
  );
}
  
}