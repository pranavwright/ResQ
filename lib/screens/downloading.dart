import 'dart:io';
import 'package:flutter/material.dart';
import 'package:resq/utils/http/token_less_http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb check
// import 'dart:html' as html;

class Downloading extends StatefulWidget {
  const Downloading({super.key});

  @override
  _DownloadingState createState() => _DownloadingState();
}

class _DownloadingState extends State<Downloading> {
  bool isDownloading = false; // To track the download status
  double downloadProgress = 0.0; // To track download progress
  String platform = ''; // To track the selected platform
  String? downloadUrl;
  String? errorMessage;

  Dio dio = Dio();

  // Method to initiate the download process
  void startDownload(String selectedPlatform) async {
    setState(() {
      isDownloading = true;
      platform = selectedPlatform;
      downloadProgress = 0.0;
      errorMessage = null;
      downloadUrl = null;
    });

    try {
      final response = await TokenLessHttp().get('/settings/getApk');

      if (response['apk']['url'] != null) {
        setState(() {
          downloadUrl = response['apk']['url'];
        });
        await _downloadFile(downloadUrl!);
      } else {
        setState(() {
          isDownloading = false;
          errorMessage = 'Download URL not found.';
        });
        print('Error: Download URL not found in the response.');
      }
    } catch (e) {
      setState(() {
        isDownloading = false;
        errorMessage = 'Failed to fetch download URL: $e';
      });
      print('Error fetching download URL: $e');
    }
  }

  Future<void> _downloadFile(String url) async {
    if (kIsWeb) {
      // For web, simply open the URL in a new tab
      print('Opening download URL in a new tab: $url');
      // You might need a package like url_launcher for more control on web
      // For a basic approach, you can use the html package:
      // html.window.open(url, '_blank');
      setState(() {
        isDownloading = false;
      });
      return;
    }

    // For mobile platforms
    PermissionStatus status;
    if (Platform.isAndroid) {
      status = await Permission.storage.request();
    } else if (Platform.isIOS) {
      status =
          await Permission.storage
              .request(); // iOS might not need explicit storage permission for app's documents directory
    } else {
      // Other platforms might have different permission requirements
      status = PermissionStatus.granted; // Assume granted for others
    }

    if (status.isGranted) {
      String savePath;
      if (Platform.isAndroid) {
        Directory? externalDir = await getExternalStorageDirectory();
        savePath = '${externalDir?.path}/REalSQ_$platform.apk';
      } else if (Platform.isIOS) {
        Directory appDocDir = await getApplicationDocumentsDirectory();
        savePath = '${appDocDir.path}/REalSQ_$platform.apk';
      } else {
        // Fallback for other platforms
        Directory tempDir = await getTemporaryDirectory();
        savePath = '${tempDir.path}/REalSQ_$platform.apk';
      }

      try {
        await dio.download(
          url,
          savePath,
          onReceiveProgress: (received, total) {
            if (total != -1) {
              setState(() {
                downloadProgress = received / total;
              });
              print('${(downloadProgress * 100).toStringAsFixed(0)}%');
            }
          },
        );
        setState(() {
          isDownloading = false;
          downloadProgress = 1.0;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'REalSQ for $platform downloaded successfully to: $savePath',
              ),
            ),
          );
          print('Download completed to: $savePath');
          // Optionally, you can trigger installation here for Android
        });
      } catch (e) {
        setState(() {
          isDownloading = false;
          errorMessage = 'Download failed: $e';
        });
        print('Download failed: $e');
      }
    } else {
      setState(() {
        isDownloading = false;
        errorMessage = 'Storage permission not granted.';
      });
      print('Storage permission not granted');
      // Optionally, open app settings to allow the user to grant permission
      openAppSettings();
    }
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
            onPressed: () {
              // You might want to show a dialog or options for manual download here
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Select a platform to start download')),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blueAccent,
              const Color.fromARGB(255, 214, 103, 234),
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Card(
                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 10,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.asset(
                      'assets/images/logo.jpg',
                      width: 250,
                      height: 250,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(height: 30),

                if (isDownloading)
                  Column(
                    children: [
                      CircularProgressIndicator(
                        value: downloadProgress,
                        strokeWidth: 6,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.greenAccent,
                        ),
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
                else if (errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      errorMessage!,
                      style: TextStyle(color: Colors.red, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  )
                else
                  Column(
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 120,
                              child: ElevatedButton.icon(
                                icon: Icon(Icons.apple, color: Colors.white),
                                label: Text('iOS'),
                                onPressed: () => startDownload("iOS"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 15,
                                  ),
                                  textStyle: TextStyle(fontSize: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 20),
                            Container(
                              width: 120,
                              child: ElevatedButton.icon(
                                icon: Icon(
                                  Icons.desktop_windows,
                                  color: const Color.fromARGB(
                                    255,
                                    132,
                                    228,
                                    249,
                                  ),
                                ),
                                label: Text('Windows'),
                                onPressed: () => startDownload("Windows"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 15,
                                  ),
                                  textStyle: TextStyle(fontSize: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 20),
                            Container(
                              width: 120,
                              child: ElevatedButton.icon(
                                icon: Icon(
                                  Icons.android,
                                  color: const Color.fromARGB(255, 81, 228, 73),
                                ),
                                label: Text('Android'),
                                onPressed: () => startDownload("Android"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 15,
                                  ),
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
                      SizedBox(height: 30),
                      Text(
                        'REalSQ',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 15),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Text(
                          'REalSQ is a platform where users can download applications for iOS, Android, and Windows platforms. Choose the platform and start your download!',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 18, color: Colors.black54),
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
