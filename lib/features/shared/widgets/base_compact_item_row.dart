import 'package:cashify/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class BaseCompactItemRow extends StatelessWidget {
  final String title;
  final Widget subtitle;
  final Widget rightWidget;
  final Widget? leftStatusIcon;
  final List<Widget>? extraTags;
  final VoidCallback? onTap;

  const BaseCompactItemRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.rightWidget,
    this.leftStatusIcon,
    this.extraTags,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.surface,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              if (leftStatusIcon != null) ...[
                leftStatusIcon!,
                const SizedBox(width: 12),
              ],
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (extraTags != null) ...[
                          for (final tag in extraTags!) ...[
                            const SizedBox(width: 6),
                            tag,
                          ]
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    subtitle,
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: rightWidget,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
