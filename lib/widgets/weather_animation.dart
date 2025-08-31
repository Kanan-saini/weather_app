import 'package:flutter/material.dart';
import 'dart:math';

class WeatherAnimation extends StatefulWidget {
  final String weatherDescription;
  
  const WeatherAnimation({
    super.key,
    required this.weatherDescription,
  });

  @override
  State<WeatherAnimation> createState() => _WeatherAnimationState();
}

class _WeatherAnimationState extends State<WeatherAnimation>
    with TickerProviderStateMixin {
  late AnimationController _rainController;
  late AnimationController _snowController;
  late AnimationController _cloudController;
  late AnimationController _sunController;
  
  List<RainDrop> rainDrops = [];
  List<SnowFlake> snowFlakes = [];
  List<Cloud> clouds = [];

  @override
  void initState() {
    super.initState();
    
    _rainController = AnimationController(
      duration: const Duration(milliseconds: 50),  // Faster update for smoother rain
      vsync: this,
    );
    
    _snowController = AnimationController(
      duration: const Duration(milliseconds: 50),  // Faster update for smoother snow
      vsync: this,
    );
    
    _cloudController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    
    _sunController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    
    _initializeWeatherElements();
    _startAnimation();
  }

  void _initializeWeatherElements() {
    final random = Random();
    
    // Initialize rain drops with more drops for better effect
    rainDrops = List.generate(100, (index) {
      return RainDrop(
        x: random.nextDouble(),
        y: random.nextDouble(),
        speed: 0.01 + random.nextDouble() * 0.02,
        length: 15 + random.nextDouble() * 15,
      );
    });
    
    // Initialize snow flakes with more flakes
    snowFlakes = List.generate(60, (index) {
      return SnowFlake(
        x: random.nextDouble(),
        y: random.nextDouble(),
        speed: 0.005 + random.nextDouble() * 0.01,
        size: 2 + random.nextDouble() * 4,
        angle: random.nextDouble() * 2 * pi,
        angleSpeed: (random.nextDouble() - 0.5) * 0.05,
      );
    });
    
    clouds = List.generate(3, (index) {
      return Cloud(
        x: random.nextDouble(),
        y: 0.1 + random.nextDouble() * 0.3,
        speed: 0.001 + random.nextDouble() * 0.002,
        scale: 0.8 + random.nextDouble() * 0.4,
      );
    });
  }

  void _startAnimation() {
    final description = widget.weatherDescription.toLowerCase();
    
    if (description.contains('rain') || description.contains('drizzle')) {
      _rainController.repeat();
    } else if (description.contains('snow')) {
      _snowController.repeat();
    } else if (description.contains('cloud')) {
      _cloudController.repeat();
    } else if (description.contains('clear') || description.contains('sunny')) {
      _sunController.repeat();
    }
  }

  @override
  Widget build(BuildContext context) {
    final description = widget.weatherDescription.toLowerCase();
    
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        children: [
          if (description.contains('rain') || description.contains('drizzle'))
            AnimatedBuilder(
              animation: _rainController,
              builder: (context, child) {
                return CustomPaint(
                  size: Size.infinite,
                  painter: RainPainter(rainDrops, _rainController.value),
                );
              },
            ),
          
          if (description.contains('snow'))
            AnimatedBuilder(
              animation: _snowController,
              builder: (context, child) {
                return CustomPaint(
                  size: Size.infinite,
                  painter: SnowPainter(snowFlakes, _snowController.value),
                );
              },
            ),
          
          if (description.contains('cloud'))
            AnimatedBuilder(
              animation: _cloudController,
              builder: (context, child) {
                return CustomPaint(
                  size: Size.infinite,
                  painter: CloudPainter(clouds, _cloudController.value),
                );
              },
            ),
          
          if (description.contains('clear') || description.contains('sunny'))
            AnimatedBuilder(
              animation: _sunController,
              builder: (context, child) {
                return CustomPaint(
                  size: Size.infinite,
                  painter: SunPainter(_sunController.value),
                );
              },
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _rainController.dispose();
    _snowController.dispose();
    _cloudController.dispose();
    _sunController.dispose();
    super.dispose();
  }
}

class RainDrop {
  double x;
  double y;
  final double speed;
  final double length;
  
  RainDrop({required this.x, required this.y, required this.speed, required this.length});
}

class SnowFlake {
  double x;
  double y;
  double angle;
  final double angleSpeed;
  final double speed;
  final double size;
  
  SnowFlake({
    required this.x, 
    required this.y, 
    required this.speed, 
    required this.size,
    required this.angle,
    required this.angleSpeed,
  });
}

class Cloud {
  double x;
  final double y;
  final double speed;
  final double scale;
  
  Cloud({required this.x, required this.y, required this.speed, required this.scale});
}

class RainPainter extends CustomPainter {
  final List<RainDrop> rainDrops;
  final double animationValue;
  
  RainPainter(this.rainDrops, this.animationValue);
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.7)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    
    for (var drop in rainDrops) {
      // Move drops down based on their speed
      drop.y += drop.speed;
      
      // Reset position when it goes off screen
      if (drop.y > 1.0) {
        drop.y = -0.1;
        drop.x = Random().nextDouble();
      }
      
      final startX = drop.x * size.width;
      final startY = drop.y * size.height;
      final endY = startY + drop.length;
      
      canvas.drawLine(
        Offset(startX, startY),
        Offset(startX - 2, endY), // Slight angle for rain
        paint,
      );
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class SnowPainter extends CustomPainter {
  final List<SnowFlake> snowFlakes;
  final double animationValue;
  
  SnowPainter(this.snowFlakes, this.animationValue);
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.9)
      ..style = PaintingStyle.fill;
    
    for (var flake in snowFlakes) {
      // Update vertical position
      flake.y += flake.speed;
      
      // Create swaying motion using sine wave based on angle
      flake.angle += flake.angleSpeed;
      flake.x += sin(flake.angle) * 0.002;
      
      // Reset position when it goes off screen
      if (flake.y > 1.0) {
        flake.y = -0.05;
        flake.x = Random().nextDouble();
      }
      
      final centerX = flake.x * size.width;
      final centerY = flake.y * size.height;
      
      // Draw snowflake (a circle)
      canvas.drawCircle(
        Offset(centerX, centerY),
        flake.size,
        paint,
      );
      
      // Add simple crystal structure for larger flakes
      if (flake.size > 3) {
        // Draw simple cross pattern for larger snowflakes
        canvas.drawLine(
          Offset(centerX - flake.size, centerY),
          Offset(centerX + flake.size, centerY),
          paint..strokeWidth = 0.8
        );
        
        canvas.drawLine(
          Offset(centerX, centerY - flake.size),
          Offset(centerX, centerY + flake.size),
          paint..strokeWidth = 0.8
        );
      }
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class CloudPainter extends CustomPainter {
  final List<Cloud> clouds;
  final double animationValue;
  
  CloudPainter(this.clouds, this.animationValue);
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    
    for (var cloud in clouds) {
      cloud.x += cloud.speed;
      if (cloud.x > 1.2) {
        cloud.x = -0.2;
      }
      
      final cloudX = cloud.x * size.width;
      final cloudY = cloud.y * size.height;
      final cloudSize = 40 * cloud.scale;
      
      canvas.drawCircle(Offset(cloudX, cloudY), cloudSize, paint);
      canvas.drawCircle(Offset(cloudX + cloudSize * 0.8, cloudY), cloudSize * 0.8, paint);
      canvas.drawCircle(Offset(cloudX + cloudSize * 1.6, cloudY), cloudSize, paint);
      canvas.drawCircle(Offset(cloudX + cloudSize * 0.8, cloudY - cloudSize * 0.5), cloudSize * 0.6, paint);
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class SunPainter extends CustomPainter {
  final double animationValue;
  
  SunPainter(this.animationValue);
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.8, size.height * 0.2);
    final sunRadius = 30.0;
    
    final rayPaint = Paint()
      ..color = Colors.yellow.withOpacity(0.6)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    
    for (int i = 0; i < 8; i++) {
      final angle = (i * 45.0 + animationValue * 360) * pi / 180;
      final startX = center.dx + cos(angle) * (sunRadius + 10);
      final startY = center.dy + sin(angle) * (sunRadius + 10);
      final endX = center.dx + cos(angle) * (sunRadius + 25);
      final endY = center.dy + sin(angle) * (sunRadius + 25);
      
      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        rayPaint,
      );
    }
    
    final sunPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.yellow.withOpacity(0.8),
          Colors.orange.withOpacity(0.6),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: sunRadius));
    
    canvas.drawCircle(center, sunRadius, sunPaint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}