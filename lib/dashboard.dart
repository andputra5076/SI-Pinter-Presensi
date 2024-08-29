import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart'; // For mouse cursor
import 'package:sipinter_admin/datagurubk.dart';
import 'package:sipinter_admin/datakelas.dart';
import 'package:sipinter_admin/datapelanggaran.dart';
import 'package:sipinter_admin/datasiswa.dart';
import 'package:sipinter_admin/datawalikelas.dart';
import 'package:sipinter_admin/informasi.dart';
import 'package:sipinter_admin/laporan.dart';
import 'package:sipinter_admin/laporanpoin.dart';
import 'package:sipinter_admin/login.dart';
import 'package:sipinter_admin/tahunpelajaran.dart';
import 'package:sipinter_admin/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class MyDashboard extends StatefulWidget {
  @override
  _MyDashboardState createState() => _MyDashboardState();
}


class _MyDashboardState extends State<MyDashboard> {
  final _formKey = GlobalKey<FormState>();
  String _newPassword = '';
  String? _avatarFuture;
  String? _namaFuture;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getAvatar();
  }

Future<String?> _getAvatar() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  setState(() {
    _avatarFuture = prefs.getString('avatar')!;
    _namaFuture = prefs.getString('nama')!;
  });
  return prefs.getString('avatar');
  return prefs.getString('nama');
}

String getGreeting() {
    final now = DateTime.now();
    final hour = now.hour;

    if (hour >= 6 && hour < 11) {
      return 'Selamat Pagi';
    } else if (hour >= 11 && hour < 14) {
      return 'Selamat Siang';
    } else if (hour >= 14 && hour < 18) {
      return 'Selamat Sore';
    } else {
      return 'Selamat Malam';
    }
  }
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = screenWidth < 600 ? 2 : 4;

    return Scaffold(
      backgroundColor: Color(0xFFE0E7FF),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            double availableHeight = constraints.maxHeight;
            double availableWidth = constraints.maxWidth;
            double gridHeight = availableHeight * 0.5;
            double itemHeight = gridHeight / (crossAxisCount / 2) - 20;
            double itemWidth = availableWidth / crossAxisCount - 20;

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Container(
                            height: 50,
                            child: ScrollingText(
                              text: '${getGreeting()}.. ${_namaFuture}. ',
                              style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold
                              ),
                            ),
                          )
                        ),
                        Image.asset(
                          "assets/image/logo.png",
                          width: 80,
                          height: 80,
                        ),
                      ],
                    ),
                    SizedBox(height: 20),

                    // Stats Row
                    LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth > 600) {
                          // Desktop view
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                             
                            ],
                          );
                        } else {
                          // Mobile view
                          return Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildStatItem(Icons.person,
                                      '750\nJumlah Siswa', Colors.blue),
                                  _buildStatItem(Icons.person_pin,
                                      '21\nJumlah Wali Kelas', Colors.green),
                                ],
                              ),
                              SizedBox(height: 16),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: FractionallySizedBox(
                                  widthFactor: 1.0,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      _buildStatItem(Icons.school,
                                          '5\nJumlah Guru BK', Colors.purple),
                                      _buildStatItem(Icons.class_,
                                          '21\nJumlah Kelas', Colors.teal),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          );
                        }
                      },
                    ),

                    SizedBox(height: 20),

                    // Grid Section
                    Container(
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio:
                              (screenWidth / crossAxisCount - 20) / 200,
                        ),
                        itemCount: 8,
                        itemBuilder: (context, index) {
                          List<String> titles = [
                            '1. TAHUN AJARAN',
                            '3. PILIH WALI KELAS',
                            'LAPORAN PRESENSI SISWA',
                            'DATA PELANGGARAN SISWA',
                            '2. DATA KELAS',
                            '4. DATA SISWA',
                            'DATA GURU BK',
                            'INFO PENGGUNAAN',
                          ];
                          List<Color> shadowColors = [
                            Colors.blue.shade700,
                            Colors.green.shade700,
                            Colors.orange.shade700,
                            Colors.red.shade700,
                            Colors.purple.shade700,
                            Colors.teal.shade700,
                            Colors.brown.shade700,
                            Colors.pink.shade700,
                          ];
                          List<Color> colors = [
                            Colors.green.shade700,
                            Colors.orange.shade700,
                            Colors.red.shade700,
                            Colors.blue.shade700,
                            Colors.purple.shade700,
                            Colors.teal.shade700,
                            Colors.brown.shade700,
                            Colors.pink.shade700,
                          ];
                          List<Widget> pages = [
                            Tahunpelajaran(),
                            DataWalikelas(),
                            Laporan(),
                            Datapelanggaran(),
                            Datakelas(),
                            DataSiswa(),
                            Datagurubk(),
                            LaporanPOIN(),
                          ];
                          List<String> backgroundImages = [
                            'assets/image/background1.png',
                            'assets/image/background2.png',
                            'assets/image/background3.png',
                            'assets/image/background4.png',
                            'assets/image/background5.png',
                            'assets/image/background6.png',
                            'assets/image/background7.png',
                            'assets/image/background8.png',
                          ];
                          List<Color> textColors = [
                            Colors.white,
                            Colors.white,
                            Colors.white,
                            Colors.white,
                            Colors.white,
                            Colors.white,
                            Colors.white,
                            Colors.white,
                          ];
                          return ZoomInGridItem(
                            title: titles[index],
                            color: colors[index],
                            page: pages[index],
                            context: context,
                            backgroundImage: backgroundImages[index],
                            textColor: textColors[index],
                            shadowColor: shadowColors[index],
                          );
                        },
                      ),
                    ),

                    SizedBox(height: 20),

                    // Footer Row
                    Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildFooterItem(
                                context,
                                'Profil',
                                _avatarFuture??
                                    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSaAeoVCGBGNoRvUmQRVva9iRwju0kNncqqcg&s',
                                25,
                              ),
                              SizedBox(width: 40),
                              _buildFooterItem(
                                context,
                                'Ubah Password',
                                Icons.lock,
                                50,
                                onTap: () => _showChangePasswordDialog(context),
                              ),
                              SizedBox(width: 40),
                              _buildFooterItem(
                                context,
                                'Keluar',
                                Icons.exit_to_app,
                                50,
                                color: Colors.red,
                                onTap: () => _showLogoutDialog(context),
                              ),
                            ],
                          ),
                    SizedBox(height: 20),

                    // Copyright
                    Center(
                      child: Text(
                        '©2024 PT. RONSTUDIO DIGITAL GROUP, All rights reserved',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 40, color: color),
          SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterItem(
    BuildContext context,
    String title,
    dynamic icon,
    double size, {
    Color color = Colors.blue,
    VoidCallback? onTap,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            icon is String
                ? AnimatedSwitcher(
                    duration: Duration(milliseconds: 300),
                    child: CircleAvatar(
                      key: ValueKey(icon),
                      radius: size,
                      backgroundImage: NetworkImage(icon),
                    ),
                  )
                : AnimatedSwitcher(
                    duration: Duration(milliseconds: 300),
                    child: Icon(
                      icon,
                      key: ValueKey(icon),
                      size: size,
                      color: color,
                    ),
                  ),
            SizedBox(height: 8),
            Text(title,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final _newPasswordController = TextEditingController();
    final _confirmPasswordController = TextEditingController();
    String newPassword = '';
    bool _obscureTextNewPassword = true;
    bool _obscureTextConfirmPassword = true;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Ubah Password'),
              content: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _newPasswordController,
                      obscureText: _obscureTextNewPassword,
                      decoration: InputDecoration(
                        labelText: 'Password Baru',
                        border: OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureTextNewPassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureTextNewPassword =
                                  !_obscureTextNewPassword;
                            });
                          },
                        ),
                      ),
                      onChanged: (value) {
                        newPassword = value;
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Harap masukkan Password Baru';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureTextConfirmPassword,
                      decoration: InputDecoration(
                        labelText: 'Konfirmasi Password Baru',
                        border: OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureTextConfirmPassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureTextConfirmPassword =
                                  !_obscureTextConfirmPassword;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Harap masukkan Konfirmasi Password Baru';
                        }
                        if (value != newPassword) {
                          return 'Konfirmasi password tidak sesuai';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _changePassword(_newPasswordController.text, context);
                    }
                  },
                  child: Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('OK'),
          ),
        ],
      );
    },
  );
}


  Future<void> _changePassword(String newPassword, BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final String? username = prefs.getString('username');

    if (username == null) {
      _showErrorDialog(context,'Username tidak ditemukan.');
      return;
    }

    final client = http.Client();

    try {
      final response = await client.post(
        Uri.parse('192.168.1.9/pesantrenadmin/api/ubahpassword'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'username': username,
          'password': newPassword,
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        if (responseData['status'] == 'success') {
          Navigator.of(context).pop();
          _showSuccessDialog(context);
        } else {
          _showErrorDialog(context,responseData['message']);
        }
      } else {
        _showErrorDialog(context,'Failed to connect to the server');
      }
    } catch (e) {
      _showErrorDialog(context,'An error occurred: $e');
    } finally {
      client.close();
    }
  }
  

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Success'),
          content: const Text('Password berhasil diubah.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _clearSessionData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.of(context).pop();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
    // Implement logout logic here if needed
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Konfirmasi'),
          content: Text('Apakah Anda yakin ingin keluar?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                _clearSessionData();
              },
              child: Text('Keluar'),
            ),
          ],
        );
      },
    );
  }
}

class ScrollingText extends StatefulWidget {
  final String text;
  final TextStyle style;

  const ScrollingText({
    required this.text,
    required this.style,
  });

  @override
  _ScrollingTextState createState() => _ScrollingTextState();
}

class _ScrollingTextState extends State<ScrollingText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isHovered = false; // Track whether the mouse is hovering

  @override
  void initState() {
    super.initState();
    // Initialize AnimationController
    _controller = AnimationController(
      duration: Duration(seconds: 20), // Adjust the duration for speed
      vsync: this,
    )..repeat();

    // Create an animation that scrolls from 0.0 to 1.0
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _isHovered = true;
          _controller.stop(); // Stop animation when mouse enters
        });
      },
      onExit: (_) {
        setState(() {
          _isHovered = false;
          _controller.repeat(); // Resume animation when mouse exits
        });
      },
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          // Get the width of the screen
          double screenWidth = MediaQuery.of(context).size.width;

          return Container(
            width: screenWidth,
            child: Stack(
              children: [
                Positioned(
                  left: -screenWidth * _animation.value,
                  child: Text(
                    widget.text,
                    style: widget.style,
                  ),
                ),
                Positioned(
                  left: screenWidth - (screenWidth * _animation.value),
                  child: Text(
                    widget.text,
                    style: widget.style,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class ZoomInGridItem extends StatefulWidget {
  final String title;
  final Color color;
  final Widget page;
  final BuildContext context;
  final String backgroundImage; // Background image parameter
  final Color textColor; // Text color parameter
  final Color shadowColor; // Shadow color parameter

  ZoomInGridItem({
    required this.title,
    required this.color,
    required this.page,
    required this.context,
    required this.backgroundImage,
    required this.textColor,
    required this.shadowColor,
  });

  @override
  _ZoomInGridItemState createState() => _ZoomInGridItemState();
}

class _ZoomInGridItemState extends State<ZoomInGridItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  bool _hovering = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _elevationAnimation = Tween<double>(begin: 4.0, end: 12.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTap() {
    if (widget.title == 'Laporan') {
      _showLaporanDialog();
    } else {
      Navigator.push(
        widget.context,
        MaterialPageRoute(builder: (context) => widget.page),
      );
    }
  }

  void _showLaporanDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Pilih Laporan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Laporan()),
                  );
                },
                child: Text('Laporan POIN Siswa'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LaporanPOIN()),
                  );
                },
                child: Text('Laporan Presensi Siswa'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        setState(() {
          _hovering = true;
          _controller.forward();
        });
      },
      onExit: (_) {
        setState(() {
          _hovering = false;
          _controller.reverse();
        });
      },
      child: GestureDetector(
        onTap: _onTap,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: AnimatedBuilder(
            animation: _elevationAnimation,
            builder: (context, child) {
              return PhysicalModel(
                color: Colors.transparent,
                shadowColor: widget.shadowColor,
                elevation: _elevationAnimation.value,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: AssetImage(widget.backgroundImage),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(_hovering ? 0.2 : 0.4),
                        BlendMode.darken,
                      ),
                    ),
                  ),
                  child: AnimatedOpacity(
                    opacity: 1,
                    duration: Duration(milliseconds: 300),
                    child: Center(
                      child: Text(
                        widget.title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _hovering
                              ? Colors.white
                              : widget.textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}


class TriangleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
