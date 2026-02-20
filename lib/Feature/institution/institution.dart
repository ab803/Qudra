import 'package:flutter/material.dart';

/*
  Qudra App Views
  -----------------
  - InstitutionView
  - CommunityView
  - ProfileView

  Ready to plug into your Flutter project.
*/

// ======================================================
// INSTITUTION VIEW
// ======================================================

class InstitutionView extends StatelessWidget {
  const InstitutionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Support Centers'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: CircleAvatar(child: Icon(Icons.person)),
          )
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),

          // Search
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search institutions, services...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Filter chips
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: const [
                _FilterChip(label: 'All', selected: true),
                _FilterChip(label: 'Mobility'),
                _FilterChip(label: 'Vision'),
                _FilterChip(label: 'Hearing'),
                _FilterChip(label: 'Mental Health'),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Institutions list
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: const [
                InstitutionCard(
                  name: 'Al-Noor Center',
                  category: 'Physical Therapy & Rehab',
                  rating: 4.8,
                  distance: '1.2 km away',
                  tags: ['Ramp Access', 'Parking'],
                ),
                InstitutionCard(
                  name: 'Visionary Support',
                  category: 'Blindness & Low Vision Aid',
                  rating: 4.9,
                  distance: '3.5 km away',
                  tags: ['Braille', 'Guide Dog Friendly'],
                ),
                InstitutionCard(
                  name: 'Silent World Institute',
                  category: 'Hearing Impairment & Sign Language',
                  rating: 4.5,
                  distance: '5.0 km away',
                  tags: ['Sign Language', 'Interpreters'],
                ),
                InstitutionCard(
                  name: 'Mindful Care',
                  category: 'Mental Health & Counseling',
                  rating: 4.7,
                  distance: '2.8 km away',
                  tags: ['Sensory Friendly'],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class InstitutionCard extends StatelessWidget {
  final String name;
  final String category;
  final double rating;
  final String distance;
  final List<String> tags;

  const InstitutionCard({
    super.key,
    required this.name,
    required this.category,
    required this.rating,
    required this.distance,
    required this.tags,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 22,
                child: Icon(Icons.accessible),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    Text(category, style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star, size: 14, color: Colors.green),
                    const SizedBox(width: 4),
                    Text(rating.toString()),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 8),
          Text(distance, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: tags
                .map((e) => Chip(
              label: Text(e),
              backgroundColor: Colors.grey.shade100,
            ))
                .toList(),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text('Subscribe'),
            ),
          )
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;

  const _FilterChip({required this.label, this.selected = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
      ),
    );
  }
}

