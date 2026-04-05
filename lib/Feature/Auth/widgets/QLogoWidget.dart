import 'package:flutter/material.dart';

class LoginLogo extends StatelessWidget {
  const LoginLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140, width: 140,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(20)),
            child: const Center(child: Text('Q', style: TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold))),
          ),
          _orbit(Icons.touch_app, const Color(0xFFD1F2D9), top: 0, left: 30),
          _orbit(Icons.psychology, const Color(0xFFD6E4FF), top: 10, right: 10),
          _orbit(Icons.hearing, const Color(0xFFD1F2EB), bottom: 20, right: 0),
          _orbit(Icons.visibility, const Color(0xFFFCF3CF), bottom: 10, left: 0),
          _orbit(Icons.accessible, const Color(0xFFFDEBD0), top: 40, left: 0),
        ],
      ),
    );
  }

  Widget _orbit(IconData icon, Color color, {double? top, double? bottom, double? left, double? right}) {
    return Positioned(top: top, bottom: bottom, left: left, right: right,
        child: Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(icon, size: 16, color: Colors.black87)));
  }
}