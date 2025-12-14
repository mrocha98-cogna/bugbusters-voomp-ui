import 'package:flutter/material.dart';
import 'package:voomp_sellers_rebranding/src/core/features/auth/presentation/widgets/registration_form_card.dart';

class RegistrationScreen extends StatelessWidget {
  const RegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 800) {
            return const _DesktopLayout();
          } else {
            return const _MobileLayout();
          }
        },
      ),
    );
  }
}

class _DesktopLayout extends StatelessWidget {
  const _DesktopLayout();

  @override
  Widget build(BuildContext context) {
    const double formAreaWidth = 550;
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            'assets/capa.png',
            fit: BoxFit.contain,
            alignment: Alignment.centerRight,
          ),
        ),
        Positioned(
          top: 0, bottom: 0, left: 0, width: formAreaWidth,
          child: Container(
            color: Colors.white,
            child: const Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 60),
                child: RegistrationFormCard(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MobileLayout extends StatelessWidget {
  const _MobileLayout();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            'assets/capa.png',
            fit: BoxFit.fitHeight,
            color: Colors.black.withOpacity(0.5),
            colorBlendMode: BlendMode.darken,
          ),
        ),
        const Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: RegistrationFormCard(),
          ),
        ),
      ],
    );
  }
}
