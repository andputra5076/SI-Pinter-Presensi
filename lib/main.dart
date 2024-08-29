import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const DashboardPage(),
    );
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final List<String> _imagePaths = [
    'assets/image/tampil1.gif',
    'assets/image/tampil2.gif',
    'assets/image/tampil3.gif',
    'assets/image/tampil4.gif',
    'assets/image/tampil5.png',
    'assets/image/tampil6.gif',
    'assets/image/tampil7.gif',
    'assets/image/tampil8.gif',
    'assets/image/tampil9.gif',
    'assets/image/tampil10.gif',
    'assets/image/tampil11.gif',
    'assets/image/tampil12.gif',
    'assets/image/tampil13.png',
  ];

  late ScrollController _scrollController;
  double _scrollPercentage = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onPageScroll() {
    final totalScrollHeight = _scrollController.position.maxScrollExtent;
    final currentScrollPosition = _scrollController.position.pixels;
    final scrollPercentage = (currentScrollPosition / totalScrollHeight).clamp(0.0, 1.0) * 100;

    setState(() {
      _scrollPercentage = scrollPercentage;
    });
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0.0,
      duration: const Duration(seconds: 1),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          NotificationListener<ScrollNotification>(
            onNotification: (scrollNotification) {
              if (scrollNotification is ScrollUpdateNotification) {
                _onPageScroll();
              }
              return true;
            },
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return VisibilityDetector(
                        key: Key('image_$index'),
                        onVisibilityChanged: (VisibilityInfo info) {
                          // No animation on visibility change
                        },
                        child: Image.asset(
                          _imagePaths[index],
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                    childCount: _imagePaths.length,
                  ),
                ),
              ],
            ),
          ),
          // Sticky Transparent Header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              color: Colors.black.withOpacity(0.5), // Transparent background
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'My Dashboard',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Handle login button press
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue, // Button color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                    child: const Text('Login'),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 16.0,
            right: 16.0,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 60.0,
                  height: 60.0,
                  child: CircularProgressIndicator(
                    value: _scrollPercentage / 100,
                    strokeWidth: 4.0,
                    backgroundColor: Colors.black.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: _scrollToTop,
                    child: Container(
                      width: 50.0,
                      height: 50.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Colors.black.withOpacity(0.7), Colors.black.withOpacity(0.9)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 6.0,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          Icons.arrow_upward,
                          color: Colors.white,
                          size: 28.0,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
