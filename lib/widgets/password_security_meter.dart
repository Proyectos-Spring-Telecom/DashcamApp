import 'package:dashboardpro/utils/password_rules.dart';
import 'package:flutter/material.dart';

/// Semáforo de seguridad de contraseña con barra de progreso y siguiente paso.
class PasswordSecurityMeter extends StatelessWidget {
  const PasswordSecurityMeter({
    super.key,
    required this.password,
    required this.isDark,
    required this.textColor,
  });

  final String password;
  final bool isDark;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    final status = PasswordRules.evaluate(password);
    final inactiveLight = isDark ? Colors.white12 : Colors.black12;
    const redLight = Color(0xFFFF5252);
    const yellowLight = Color(0xFFFFB300);
    const greenLight = Color(0xFF66BB6A);
    final activeIndex = status.activeLightIndex;

    Color lightColor(int index, Color activeColor) {
      return activeIndex == index ? activeColor : inactiveLight;
    }

    final segmentColor = status.strengthColor;
    final inactiveSegment = isDark ? Colors.white10 : Colors.black12;
    final rules = [
      status.hasValidLength,
      status.hasNoSpaces,
      status.hasLowercase,
      status.hasNumber,
      status.hasSymbol,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Seguridad en contraseña',
                style: TextStyle(
                  color: textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            _TrafficLightDot(
              color: lightColor(0, redLight),
              isActive: activeIndex == 0,
            ),
            const SizedBox(width: 8),
            _TrafficLightDot(
              color: lightColor(1, yellowLight),
              isActive: activeIndex == 1,
            ),
            const SizedBox(width: 8),
            _TrafficLightDot(
              color: lightColor(2, greenLight),
              isActive: activeIndex == 2,
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          status.strengthLabel,
          style: TextStyle(
            color: segmentColor,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: List.generate(5, (index) {
            final isActive = rules[index];
            return Expanded(
              child: Container(
                height: 6,
                margin: EdgeInsets.only(right: index < 4 ? 6 : 0),
                decoration: BoxDecoration(
                  color: isActive ? segmentColor : inactiveSegment,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 12),
        if (status.allPassed)
          _HintBox(
            isDark: isDark,
            textColor: textColor,
            child: Text(
              'Contraseña segura. Cumple con todos los requisitos.',
              style: TextStyle(
                color: isDark ? const Color(0xFFA6CE39) : Colors.green[800],
                fontSize: 13,
              ),
            ),
          )
        else if (status.nextStepMessage != null)
          _HintBox(
            isDark: isDark,
            textColor: textColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Siguiente paso',
                  style: TextStyle(
                    color: isDark
                        ? const Color(0xFFA6CE39)
                        : textColor.withValues(alpha: 0.85),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  status.nextStepMessage!,
                  style: TextStyle(
                    color: isDark ? Colors.grey[300] : Colors.grey[800],
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _HintBox extends StatelessWidget {
  const _HintBox({
    required this.isDark,
    required this.textColor,
    required this.child,
  });

  final bool isDark;
  final Color textColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
        ),
      ),
      child: child,
    );
  }
}

class _TrafficLightDot extends StatelessWidget {
  const _TrafficLightDot({
    required this.color,
    required this.isActive,
  });

  final Color color;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.45),
                  blurRadius: 6,
                ),
              ]
            : null,
      ),
    );
  }
}
