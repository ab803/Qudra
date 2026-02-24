import 'package:flutter/material.dart';
import '../../../core/Models/InstitutionData.dart';


final List<InstitutionData> dummyData = [
  InstitutionData(
    title: 'Al-Noor Center',
    category: 'Physical Therapy & Rehab',
    rating: 4.8,
    distance: '1.2 km',
    description: 'Specialized center for physical rehabilitation offering advanced equipment and certified...',
    tags: ['Ramp Access', 'Parking'],
    icon: Icons.accessible_forward,
    iconBgColor: const Color(0xFFDDE7FF),
    iconColor: const Color(0xFF195DFF),
  ),
  InstitutionData(
    title: 'Visionary Support',
    category: 'Blindness & Low Vision Aid',
    rating: 4.9,
    distance: '3.5 km',
    description: 'Providing braille resources, white cane training, and assistive technology workshops. Our facili...',
    tags: ['Braille', 'Guide Dog Friendly'],
    icon: Icons.visibility,
    iconBgColor: const Color(0xFFFFEBDD),
    iconColor: const Color(0xFFFF7A19),
  ),
  InstitutionData(
    title: 'Silent World Institute',
    category: 'Hearing Impairment & Sign Language',
    rating: 4.5,
    distance: '5.0 km',
    description: 'Community center for the deaf and hard of hearing. Offers sign language classes (ASL/IS...',
    tags: ['Sign Language', 'Interpreters'],
    icon: Icons.hearing_disabled,
    iconBgColor: const Color(0xFFDDF5ED),
    iconColor: const Color(0xFF19B28D),
  ),
  InstitutionData(
    title: 'Mindful Care',
    category: 'Mental Health & Counseling',
    rating: 4.7,
    distance: '2.8 km',
    description: 'Inclusive mental health support groups and individual therapy sessions. Sensory-friendly...',
    tags: ['Sensory Friendly'],
    icon: Icons.psychology,
    iconBgColor: const Color(0xFFEFE4FF),
    iconColor: const Color(0xFF8C19FF),
  ),
];