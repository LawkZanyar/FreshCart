import 'package:flutter/material.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../routes/routes.dart';

class OnboardingPage extends StatelessWidget {
  final IconData image;
  final String title;
  final String subtitle;
  const OnboardingPage({super.key, required this.image, required this.subtitle, required this.title});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(image, size: 120, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 32),
          Text(title, style: textTheme.headlineSmall,),
          const SizedBox(height: 8,),
          Text(subtitle, style: textTheme.bodyMedium, textAlign: TextAlign.center,)
        ],
      ),
    );
  }
}

final _pages = [
  OnboardingPage(
    image: Icons.storefront,
    title: 'FreshCart',
    subtitle: 'Groceries at your doorstep!'
  ),
  
  OnboardingPage(
    image: Icons.discount,
    title: 'Daily Discounts',
    subtitle: 'A new day,\nA new offer!'
  ),

  OnboardingPage(
    image: Icons.eco,
    title: 'Fresh Produce',
    subtitle: 'Farm-fresh fruits and veggies\ndelivered daily to your door'
  ),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  double _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() =>
        _currentPage = _controller.page ?? 0
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goToLogin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);
    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                itemBuilder: (_, index) => _pages[index],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  DotsIndicator(
                    dotsCount: _pages.length,
                    position: _currentPage,
                    decorator: DotsDecorator(
                      activeColor: scheme.primary,
                      size: const Size(8, 8),
                      activeSize: const Size(20, 8),
                      activeShape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)
                      )
                    ),
                  ),
                  const Spacer(),

                  FilledButton.icon(
                    onPressed: _goToLogin, 
                    label: const Text('Get Started'), 
                    icon: const Icon(Icons.arrow_forward),
                  )
                ],
              ),
            )
          ],
        )
      ),
    );
  }
}