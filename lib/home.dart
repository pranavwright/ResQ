import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _currentIndex = 0;
  final List<String> _images = [
    'assets/images/WhatsApp Image 2025-03-10 at 7.00.53 PM.jpeg',
    'assets/images/WhatsApp Image 2025-03-10 at 7.01.00 PM.jpeg',
    'assets/images/WhatsApp Image 2025-03-10 at 7.01.10 PM.jpeg',
  ];

  void _nextImage() {
    setState(() {
      _currentIndex = (_currentIndex + 1) % _images.length;
    });
  }

  void _previousImage() {
    setState(() {
      _currentIndex = (_currentIndex - 1 + _images.length) % _images.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    Color baseColor = Color.fromARGB(255, 251, 254, 255);

    return Scaffold(
      appBar: AppBar(
        title: Text('REALSQ'),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(_images[1]), // Use the first image as the app bar background
              fit: BoxFit.fill,
              colorFilter: ColorFilter.mode(Colors.blue.withOpacity(0.6), BlendMode.lighten),
            ),
          ),
        ),
        backgroundColor: baseColor,
        elevation: 5,
        leading: IconButton(
          icon: Icon(Icons.menu, size: 30),
          onPressed: () {
            // Add your action for the menu button here
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle, size: 30),
            onPressed: () {
              // Add your action for the profile button here
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [baseColor, baseColor.withOpacity(0.6)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    // Stack for image with arrow buttons
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.asset(
                            _images[_currentIndex],
                            width: double.infinity,
                            height: 400,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          left: 16,
                          top: 180,
                          child: IconButton(
                            icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                            onPressed: _previousImage,
                          ),
                        ),
                        Positioned(
                          right: 16,
                          top: 180,
                          child: IconButton(
                            icon: Icon(Icons.arrow_forward_ios, color: Colors.white),
                            onPressed: _nextImage,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),

                    // Text sections
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        "Welcome to the Home Page",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 29, 28, 28),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        "This is a beautiful page with a profile icon and an attractive UI.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Color.fromARGB(255, 31, 29, 29),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),

                    // Horizontal ListView of Cards
                    SizedBox(
                      height: 220,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: 5,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Card(
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Container(
                                width: 150,
                                padding: EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.asset(
                                        _images[0],
                                        fit: BoxFit.cover,
                                        height: 120,
                                        width: double.infinity,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Card Title $index',
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'This is an example card description. You can add more content here.',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 20), // Add some padding at the bottom
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
