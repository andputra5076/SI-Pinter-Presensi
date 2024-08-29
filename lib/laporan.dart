import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart' as excel;
import 'package:sipinter_admin/datagurubk.dart';
import 'package:sipinter_admin/datakelas.dart';
import 'package:sipinter_admin/datapelanggaran.dart';
import 'package:sipinter_admin/datasiswa.dart';
import 'package:sipinter_admin/datawalikelas.dart';
import 'package:sipinter_admin/laporanpoin.dart';
import 'package:sipinter_admin/tahunpelajaran.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

class Laporan extends StatefulWidget {
  const Laporan({Key? key}) : super(key: key);

  @override
  State<Laporan> createState() => _LaporanState();
}

class _LaporanState extends State<Laporan> {
  bool _draggingOver = false;

  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedKelas = 'Semua Kelas';
  int _currentPage = 1;
  int _rowsPerPage = 10;
  String _activeMenuItem = 'LAPORAN PRESENSI SISWA';
  List<DropdownMenuItem<String>> tahunAjaranOptions = [];
  String? selectedTahunAjaran;

  // Sample data for demonstration
  final List<Map<String, dynamic>> _data = List.generate(
    50,
    (index) => {
      'no': index + 1,
      'nis': '12345${index}',
      'nisn': '54321${index}',
      'nama': 'Nama ${index}',
      'kelas': 'Kelas ${index % 5}',
      'tahun_ajaran': 'Tahun ${index % 3}',
    },
  );
  
  // Function to launch the URL
  void _ExportKU(String id) async {
    var url = '192.168.1.9/pesantrenadmin/laporanpresensi.php?id_tahun_ajaran=$id';
    final Uri uri = Uri.parse(url);
    
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }
  Future<void> fetchDropdownOptions() async {
    try {
      final kelasResponse = await http
          .get(Uri.parse('192.168.1.9/pesantrenadmin/api/get-kelas'));
      final tahunAjaranResponse = await http
          .get(Uri.parse('192.168.1.9/pesantrenadmin/api/get-tahun-ajaran'));

      if (kelasResponse.statusCode == 200 &&
          tahunAjaranResponse.statusCode == 200) {
        final kelasJson =
            json.decode(kelasResponse.body) as Map<String, dynamic>;
        final tahunAjaranJson =
            json.decode(tahunAjaranResponse.body) as Map<String, dynamic>;

        final kelasData = (kelasJson['data'] as List<dynamic>).map((item) {
          return {
            'id': item['id'] as String,
            'name': item['kelas'] as String,
          };
        }).toList();

        final tahunAjaranData =
            (tahunAjaranJson['data'] as List<dynamic>).map((item) {
          return {
            'id': item['id'] as String,
            'name': item['nama'] as String,
          };
        }).toList();

        setState(() {
          tahunAjaranOptions = tahunAjaranData.map((item) {
            return DropdownMenuItem<String>(
              value: item['id'],
              child: Text(item['name']!),
            );
          }).toList();
        });
      } else {
        print('Failed to fetch options.');
      }
    } catch (e) {
      print('Error fetching options: $e');
    }
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchDropdownOptions();
  }

  
  @override
  Widget build(BuildContext context) {
    final filteredData = _data.where((item) {
      final query = _searchQuery.toLowerCase();
      
      final tahunAjaranFilter = selectedTahunAjaran == null ||
          selectedTahunAjaran == 'Semua Tahun Ajaran' ||
          item['tahun_ajaran']
              .toString()
              .toLowerCase()
              .contains(selectedTahunAjaran!.toLowerCase());

      return item['nama'].toString().toLowerCase().contains(query) &&
          tahunAjaranFilter;
    }).toList();

    final totalRows = filteredData.length;
    final pageCount = (totalRows / _rowsPerPage).ceil();
    final displayedData = filteredData
        .skip((_currentPage - 1) * _rowsPerPage)
        .take(_rowsPerPage)
        .toList();

    return Scaffold(
      backgroundColor: Color(0xFFE0E7FF),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with title, logo and back button
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back),
                      onPressed: () {
                        Navigator.pop(context); // Go back to dashboard
                      },
                    ),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Laporan Presensi Siswa',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Image.asset(
                      "assets/image/logo.png",
                      width: 80,
                      height: 80,
                    ),
                  ],
                ),
                SizedBox(height: 20),

                // Menu above search field with animation
                SizedBox(
                  height: 50,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _animatedMenuItem(
                          'DATA PELANGGARAN SISWA', Colors.red.shade700),
                      _animatedMenuItem('TAHUN AJARAN', Colors.blue.shade700),
                      _animatedMenuItem('DATA SISWA', Colors.green.shade700),
                      _animatedMenuItem('LAPORAN PRESENSI SISWA', Colors.orange.shade700),
                      _animatedMenuItem(
                          'PILIH WALI KELAS', Colors.purple.shade700),
                      _animatedMenuItem('DATA GURU BK', Colors.teal.shade700),
                      _animatedMenuItem('DATA KELAS', Colors.brown.shade700),
                      _animatedMenuItem(
                          'INFO PENGGUNAAN', Colors.pink.shade700),
                    ],
                  ),
                ),
                SizedBox(height: 16),

                // Search fields and import button
                Row(
                  children: [
                  
                    Expanded(
                      flex: 1,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: DropdownButtonFormField<String>(
                          isExpanded: true,
                          value: selectedTahunAjaran,
                          hint: Text(
                            'Pilih Tahun Ajaran',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                          ),
                          items: tahunAjaranOptions,
                          onChanged: (newValue) {
                            setState(() {
                              selectedTahunAjaran = newValue;
                            });
                          },
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                  ],
                ),
                SizedBox(height: 16),

                // Export to Excel button with icon and text
                Center(
                  child: Container(
                    padding: EdgeInsets.all(16),
                    child: ElevatedButton.icon(
                      onPressed: (){
                        _ExportKU(selectedTahunAjaran!);
                      } ,
                      icon: Icon(Icons.download, size: 24, color: Colors.white),
                      label: Text(
                        'Export to PDF',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                        minimumSize: Size(200, 60), 
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          height: 60.0,
          color: Colors.blue,
          child: Center(
            child: Text(
              '©2024 PT. RONSTUDIO DIGITAL GROUP, All rights reserved',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _animatedMenuItem(String text, Color color) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _activeMenuItem = text;
        });
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        margin: EdgeInsets.only(right: 8.0),
        decoration: BoxDecoration(
          color: _activeMenuItem == text ? color : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: _activeMenuItem == text
              ? [BoxShadow(color: Colors.black26, blurRadius: 6.0)]
              : [],
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: _activeMenuItem == text ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
