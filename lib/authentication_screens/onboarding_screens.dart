import 'package:flats_app/authentication_screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

final PageController _controller = PageController();

class OnboardingScreen extends StatefulWidget {
  static String id = 'OnboardingScreen';

  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int currentPage = 0;

  @override
  void initState() {
    _controller.addListener(() {
      setState(() {
        currentPage = _controller.page!.round();
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void nextPage() {
    _controller.nextPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void previousPage() {
    _controller.previousPage(
      duration: Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.center,
                end: Alignment.bottomCenter,
                stops: [0.0, 0.4, 1.0],
                colors: [
                  Colors.blue.shade50,
                  Colors.blue.shade50,
                  Colors.blue.shade100,
                ],
              ),
            ),
          ),
          Column(
            children: [
              Expanded(
                child: PageView(
                  controller: _controller,
                  children: const [
                    OnboardPage(
                      title: 'Discover smart housing solutions',
                      subtitle:
                          'Find the right place or share your property with a platform designed for everyone.',
                      image: 'assets/undraw_social-friends_mt6k.png',
                    ),
                    OnboardPage(
                      title: 'Find Your Ideal Apartment',
                      subtitle:
                          'Discover places that fit your needs—location, price, and comfort all in one place.',
                      image: 'assets/undraw_booking_1ztt.png',
                    ),
                    OnboardPage(
                      title: 'List your property with confidence',
                      subtitle:
                          'Post your apartment, set your price, and reach trusted renters quickly and safely.',
                      image: 'assets/undraw_post_eok2.png',
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (currentPage != 0)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.blue.shade700,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: () {
                            previousPage();
                          },
                          icon: Icon(Icons.arrow_back, color: Colors.white),
                        ),
                      )
                    else
                      SizedBox(width: 20),
                    if (currentPage != 2)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.blue.shade700,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: () {
                            nextPage();
                          },
                          icon: Icon(Icons.arrow_forward, color: Colors.white),
                        ),
                      )
                    else
                      TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 14,
                          ),
                        ),
                        onPressed: () {
                          Navigator.pushReplacementNamed(
                            context,
                            LoginScreen.id,
                          );
                        },
                        child: Text("Get started"),
                      ),
                  ],
                ),
              ),
              Dots(),
            ],
          ),
          if (currentPage != 2)
            Positioned(
              right: 20,
              top: 50,
              child: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                ),
                onPressed: () {
                  Navigator.pushReplacementNamed(context, LoginScreen.id);
                },
                child: Text("Skip"),
              ),
            ),
        ],
      ),
    );
  }
}

class OnboardPage extends StatelessWidget {
  final String title;
  final String subtitle;
  final String image;
  final bool isLastPage;
  final bool isFirstPage;

  const OnboardPage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.image,
    this.isLastPage = false,
    this.isFirstPage = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(50.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(child: Image.asset(image, fit: BoxFit.contain)),
          Text(
            title,
            style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 18, color: Colors.black54),
          ),
          // Row(
          //   children: [
          //     !isFirstPage
          //         ? IconButton(
          //             onPressed: () {},
          //             icon: Icon(Icons.arrow_back, color: Colors.white),
          //           )
          //         : null,
          //     !isLastPage
          //         ? IconButton(
          //             onPressed: () {},
          //             icon: Icon(Icons.arrow_back, color: Colors.white),
          //           )
          //         : null,
          //   ],
          // ),
        ],
      ),
    );
  }
}

class Dots extends StatelessWidget {
  const Dots({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 50),
      child: SmoothPageIndicator(
        controller: _controller,
        count: 3,
        effect: ExpandingDotsEffect(
          spacing: 8,
          dotColor: Colors.grey.shade400,
          activeDotColor: Colors.blue.shade700,
          dotHeight: 10,
          dotWidth: 10,
        ),
      ),
    );
  }
}
