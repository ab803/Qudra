import 'package:flutter/material.dart';

class CommunityAppBar extends StatelessWidget {
  const CommunityAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('Q',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 22)),
            ),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Qudra',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text('Community Feed',
                  style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          const Spacer(),
          IconButton(
              icon: const Icon(Icons.text_fields), onPressed: () {}),
          IconButton(
              icon: const Icon(Icons.notifications_none), onPressed: () {}),
          const CircleAvatar(
            radius: 16,
            backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=11'),
          ),
        ],
      ),
    );
  }
}