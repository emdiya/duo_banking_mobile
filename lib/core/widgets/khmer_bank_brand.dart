import 'package:flutter/material.dart';
import '../../app/localization/strings.dart';

/// Fictional Khmer Bank wordmark with a payment-focused visual identity.
class KhmerBankBrand extends StatelessWidget {
  const KhmerBankBrand({super.key, this.onDark = false});
  final bool onDark;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFE53942).withValues(alpha: .15),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFFE53942).withValues(alpha: .45),
          ),
        ),
        child: const Icon(
          Icons.qr_code_rounded,
          color: Color(0xFFE53942),
          size: 26,
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tr(context, 'Khmer Bank'),
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w800,
                letterSpacing: .3,
                color: onDark
                    ? Colors.white
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              tr(context, 'Rooted in Cambodia. Made for you.'),
              style: TextStyle(
                fontSize: 11,
                color: onDark
                    ? Colors.white70
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
