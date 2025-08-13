import 'package:flutter/material.dart';

import 'login.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _pages = [
    {
      "image": "assets/images/animasi.png",
      "title": "Mari berkenalan dengan aplikasi kami GreensApp",
      "desc":
          "GreensApp adalah aplikasi yang bergerak di bidang jual beli seputar tanaman",
      "button": "Get Started",
    },
    {
      "image": "assets/images/animasi1.png",
      "title": "Beli Apapun di GreensApp Tanaman dan pupuk Tersedia",
      "desc":
          "Di GreensApp kamu bisa membeli kebutuhan pertanian dan sebagainya",
      "button": "Next",
    },
    {
      "image": "assets/images/animasi3.png",
      "title": "Mari memulai bersama Aplikasi GreensApp",
      "desc": "Ayo coba sekarang dan lihat produk yang kami sediakan",
      "button": "Next",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      body: SafeArea(
        child: Column(
          children: [
            // Tombol Skip di kanan atas
            Container(
              alignment: Alignment.centerRight,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: GestureDetector(
                onTap: () {
                  print("Lewati onboarding");
                },
                child: Text("Skip", style: TextStyle(color: const Color.fromARGB(255, 41, 192, 109))),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(_pages[index]['image']!, height: 250),
                        SizedBox(height: 20),
                        Text(
                          _pages[index]['title']!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            color: const Color.fromARGB(255, 0, 0, 0),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          _pages[index]['desc']!,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, color: const Color.fromARGB(179, 99, 98, 98)),
                        ),
                        SizedBox(height: 30),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 15,
                            ),
                          ),
                          onPressed: () {
                            if (_currentPage < _pages.length - 1) {
                              _pageController.nextPage(
                                duration: Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            } else {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LoginScreen(),
                                ),
                              );
                            }
                          },

                          child: Text(
                            _pages[index]['button']!,
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            // Indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  margin: EdgeInsets.symmetric(horizontal: 5),
                  width: _currentPage == index ? 16 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index ? Colors.green : Colors.grey,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
