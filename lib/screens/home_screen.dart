import 'package:flutter/material.dart';
import 'package:weather_app/models/weather_model.dart';
import 'package:weather_app/services/weather_services.dart';
import 'package:weather_app/widgets/weather_card.dart';
import 'package:weather_app/widgets/weather_animation.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final WeatherServices _weatherServices = WeatherServices();
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;
  Weather? _weather;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  void _getWeather() async {
    if (_controller.text.trim().isEmpty) {
      _showSnackBar('Please enter a city name', Colors.orange);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final weather = await _weatherServices.fetchWeather(_controller.text.trim());
      setState(() {
        _weather = weather;
        _isLoading = false;
      });
      _animationController.forward();
      _showSnackBar('Weather data loaded successfully!', Colors.green);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showSnackBar('Error: Could not fetch weather data. Please check the city name.', Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Color _getGradientStartColor() {
    if (_weather == null) return const Color(0xFF1976D2);
    
    final description = _weather!.description.toLowerCase();
    if (description.contains('rain') || description.contains('drizzle')) {
      return const Color(0xFF424242);
    } else if (description.contains('clear') || description.contains('sunny')) {
      return const Color(0xFFFF9800);
    } else if (description.contains('cloud')) {
      return const Color(0xFF607D8B);
    } else if (description.contains('snow')) {
      return const Color(0xFFB0BEC5);
    } else if (description.contains('thunder')) {
      return const Color(0xFF37474F);
    } else {
      return const Color(0xFF1976D2);
    }
  }

  Color _getGradientEndColor() {
    if (_weather == null) return const Color(0xFF42A5F5);
    
    final description = _weather!.description.toLowerCase();
    if (description.contains('rain') || description.contains('drizzle')) {
      return const Color(0xFF78909C);
    } else if (description.contains('clear') || description.contains('sunny')) {
      return const Color(0xFF1976D2);
    } else if (description.contains('cloud')) {
      return const Color(0xFF90A4AE);
    } else if (description.contains('snow')) {
      return const Color(0xFFECEFF1);
    } else if (description.contains('thunder')) {
      return const Color(0xFF546E7A);
    } else {
      return const Color(0xFF42A5F5);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 1000),
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [_getGradientStartColor(), _getGradientEndColor()],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            // Weather Animation Background
            if (_weather != null)
              Positioned.fill(
                child: WeatherAnimation(
                  weatherDescription: _weather!.description,
                ),
              ),
            
            // Main Content
            SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      
                      // App Title with Animation
                      TweenAnimationBuilder(
                        duration: const Duration(milliseconds: 1000),
                        tween: Tween<double>(begin: 0, end: 1),
                        builder: (context, double value, child) {
                          return Transform.scale(
                            scale: value,
                            child: const Text(
                              'Weather App',
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1.5,
                                shadows: [
                                  Shadow(
                                    offset: Offset(0, 2),
                                    blurRadius: 4,
                                    color: Colors.black26,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // Search Card
                      Card(
                        elevation: 8,
                        color: Colors.white.withOpacity(0.15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              // Search TextField
                              TextField(
                                controller: _controller,
                                decoration: InputDecoration(
                                  hintText: 'Enter city name...',
                                  hintStyle: const TextStyle(color: Colors.white60),
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.2),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  prefixIcon: const Icon(
                                    Icons.location_city,
                                    color: Colors.white,
                                  ),
                                  suffixIcon: _controller.text.isNotEmpty
                                      ? IconButton(
                                          icon: const Icon(Icons.clear, color: Colors.white),
                                          onPressed: () {
                                            _controller.clear();
                                            setState(() {});
                                          },
                                        )
                                      : null,
                                ),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                                onSubmitted: (_) => _getWeather(),
                                onChanged: (value) => setState(() {}),
                              ),
                              
                              const SizedBox(height: 20),
                              
                              // Search Button
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _getWeather,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white.withOpacity(0.9),
                                    foregroundColor: _getGradientStartColor(),
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 4,
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                                          ),
                                        )
                                      : const Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.search, size: 20),
                                            SizedBox(width: 8),
                                            Text(
                                              'Get Weather',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 30),
                      
                      // Weather Information
                      if (_weather != null) ...[
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: WeatherCard(weather: _weather!),
                        ),
                      ] else if (!_isLoading) ...[
                        Card(
                          elevation: 6,
                          color: Colors.white.withOpacity(0.1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(40),
                            child: Column(
                              children: [
                                TweenAnimationBuilder(
                                  duration: const Duration(seconds: 2),
                                  tween: Tween<double>(begin: 0, end: 1),
                                  builder: (context, double value, child) {
                                    return Transform.rotate(
                                      angle: value * 2 * 3.14159,
                                      child: const Icon(
                                        Icons.cloud_outlined,
                                        size: 80,
                                        color: Colors.white54,
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 20),
                                const Text(
                                  'Welcome to Weather App!',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  'Enter a city name above to get current weather information',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white70,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      
                      const SizedBox(height: 20),
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

  @override
  void dispose() {
    _controller.dispose();
    _animationController.dispose();
    super.dispose();
  }
}