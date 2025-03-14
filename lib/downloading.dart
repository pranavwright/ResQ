import 'package:flutter/material.dart';

class Downloading extends StatefulWidget {
  const Downloading ({super.key});

  @override
  _DownloadingState createState() => _DownloadingState();
}

class _DownloadingState extends State<Downloading> {
  bool isDownloading = false; // To track the download status
  double downloadProgress = 0.0; // To track download progress
  String platform = ''; // To track the selected platform

  // Method to simulate the download process for each platform
  void startDownload(String selectedPlatform) {
    setState(() {
      isDownloading = true;
      platform = selectedPlatform; // Set the selected platform
    });

    // Simulate download progress
    Future.delayed(Duration(milliseconds: 100), () {
      downloadProgress = 0.1;
      setState(() {});

      Future.delayed(Duration(milliseconds: 500), () {
        downloadProgress = 0.3;
        setState(() {});

        Future.delayed(Duration(milliseconds: 500), () {
          downloadProgress = 0.5;
          setState(() {});

          Future.delayed(Duration(milliseconds: 500), () {
            downloadProgress = 0.7;
            setState(() {});

            Future.delayed(Duration(milliseconds: 500), () {
              downloadProgress = 1.0;
              isDownloading = false; // Mark download as complete
              setState(() {});
            });
          });
        });
      });
    });
  }

  // Navigate back when the back arrow is pressed
  void _goBack() {
    Navigator.pop(context); // Pop the current screen to go back
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'REalSQ',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white), // Back arrow icon
          onPressed: _goBack,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.download, color: Colors.white),
            onPressed: () {}, // Action for the appbar download button
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blueAccent, const Color.fromARGB(255, 214, 103, 234)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Image with a rounded corner effect in a card
                Card(
                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 10,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.asset(
                      'assets/images/Untitled-1og (1).jpg',
                      width: 250, // Optional width for better image size on web
                      height: 250, // Optional height for better image size on web
                      fit: BoxFit.cover, // To adjust the image aspect ratio
                    ),
                  ),
                ),
                SizedBox(height: 30), // Space between image and download progress

                if (isDownloading)
                  // Show downloading progress when downloading
                  Column(
                    children: [
                      CircularProgressIndicator(
                        value: downloadProgress,
                        strokeWidth: 6,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.greenAccent),
                      ),
                      SizedBox(height: 20),
                      Text(
                        "Downloading $platform... ${(downloadProgress * 100).toStringAsFixed(0)}%",
                        style: TextStyle(
                          fontSize: 20,
                          color: const Color.fromARGB(255, 0, 0, 0),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  )
                else
                  // Show the three platform-specific download buttons when not downloading
                  Column(
                    children: [
                      // Wrap the Row in a SingleChildScrollView to enable horizontal scrolling if necessary
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // iOS Download Button
                            Container(
                              width: 120, // Reduced width for each button
                              child: ElevatedButton.icon(
                                icon: Icon(Icons.apple, color: Colors.white), // iOS icon
                                label: Text('iOS'),
                                onPressed: () => startDownload("iOS"), // Trigger iOS download
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black, // Set background color to black
                                  foregroundColor: Colors.white, // Set text color to white
                                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                                  textStyle: TextStyle(fontSize: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 20), // Add some space between the buttons

                            // Windows Download Button
                            Container(
                              width: 120, // Reduced width for each button
                              child: ElevatedButton.icon(
                                icon: Icon(Icons.desktop_windows, color: const Color.fromARGB(255, 132, 228, 249)), // Windows icon
                                label: Text('Windows'),
                                onPressed: () => startDownload("Windows"), // Trigger Windows download
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black, // Set background color to black
                                  foregroundColor: Colors.white, // Set text color to white
                                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                                  textStyle: TextStyle(fontSize: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 20), // Add some space between the buttons

                            // Android Download Button
                            Container(
                              width: 120, // Reduced width for each button
                              child: ElevatedButton.icon(
                                icon: Icon(Icons.android, color: const Color.fromARGB(255, 81, 228, 73)), // Android icon
                                label: Text('Android'),
                                onPressed: () => startDownload("Android"), // Trigger Android download
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black, // Set background color to black
                                  foregroundColor: Colors.white, // Set text color to white
                                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                                  textStyle: TextStyle(fontSize: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 30), // Space after the buttons

                      // Title text about REalSQ or the platform information
                      Text(
                        'REalSQ', // Change this text to your desired title
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 15), // Space between title and description

                      // Description text
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Text(
                          'REalSQ is a platform where users can download applications for iOS, Android, and Windows platforms. Choose the platform and start your download!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Text(
                          'CONTACT',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            color: const Color.fromARGB(137, 0, 0, 0),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
