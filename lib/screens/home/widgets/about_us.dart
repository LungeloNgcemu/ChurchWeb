import 'package:flutter/material.dart';
import 'package:master/providers/url_provider.dart';
import 'package:master/theme/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:readmore/readmore.dart';
import '../../../classes/church_init.dart';
import '../church_screen.dart';

class AboutUs extends StatelessWidget {
  const AboutUs({super.key});

  @override
  Widget build(BuildContext context) {
    final vision = Provider.of<christProvider>(context, listen: false)
            .myMap?['Project']?['Read'] ?? '';
    final about = Provider.of<christProvider>(context, listen: false)
            .myMap?['Project']?['About'] ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Vision & Mission section
        _AboutSection(
          icon: Icons.visibility_outlined,
          title: 'Vision & Mission',
          content: vision,
        ),
        const SizedBox(height: 12),
        // About section
        if (about.isNotEmpty)
          _AboutSection(
            icon: Icons.info_outline_rounded,
            title: 'About Us',
            content: about,
          ),
      ],
    );
  }
}

class _AboutSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;
  const _AboutSection({required this.icon, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Color(0x0F000000), blurRadius: 6, offset: Offset(0, 1)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.purpleTint,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 16, color: AppColors.purple),
              ),
              const SizedBox(width: 10),
              Text(title, style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              )),
            ],
          ),
          const SizedBox(height: 12),
          if (content.isNotEmpty)
            ReadMoreText(
              content,
              trimLines: 3,
              colorClickableText: AppColors.purple,
              trimMode: TrimMode.Line,
              trimCollapsedText: 'Show more',
              trimExpandedText: ' Show less',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                height: 1.6,
                color: AppColors.textSecondary,
              ),
              moreStyle: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.purple,
              ),
              lessStyle: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.purple,
              ),
            )
          else
            Text(
              'No information available yet.',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: AppColors.textMuted,
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }
}
