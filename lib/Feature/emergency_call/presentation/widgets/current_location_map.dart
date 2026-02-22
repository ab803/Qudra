import 'package:flutter/material.dart';
import 'package:qudra_0/core/Styles/AppColors.dart';
import 'package:qudra_0/core/Styles/AppTextsyles.dart';

class CurrentLocationMap extends StatelessWidget {
  const CurrentLocationMap({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Container(
            height: 160,
            width: double.infinity,
            color: Colors.grey.shade300,
            alignment: Alignment.center,
            child: const Icon(Icons.map, size: 40, color: Colors.black54),
          ),
        ),
        const Positioned.fill(
          child: Align(
            alignment: Alignment.center,
            child: _MapMarker(),
          ),
        ),
        const Positioned(
          left: 14,
          right: 14,
          bottom: 10,
          child: _CurrentLocationCard(),
        ),
      ],
    );
  }
}

class _MapMarker extends StatelessWidget {
  const _MapMarker();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.black,
        shape: BoxShape.circle,
      ),
      child: const Padding(
        padding: EdgeInsets.all(6),
        child: Icon(Icons.location_on, color: Colors.white, size: 18),
      ),
    );
  }
}

class _CurrentLocationCard extends StatelessWidget {
  const _CurrentLocationCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Appcolors.backgroundColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.my_location, size: 18, color: Appcolors.primaryColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CURRENT LOCATION',
                  style: AppTextStyles.body.copyWith(
                    fontSize: 10,
                    letterSpacing: 1.4,
                    fontWeight: FontWeight.w700,
                    color: Appcolors.secondaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '725 5th Ave, New York, NY 10022',
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Appcolors.primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}