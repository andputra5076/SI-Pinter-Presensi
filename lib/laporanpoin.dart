import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart' as excel;
import 'package:sipinter_admin/datagurubk.dart';
import 'package:sipinter_admin/datakelas.dart';
import 'package:sipinter_admin/datapelanggaran.dart';
import 'package:sipinter_admin/datasiswa.dart';
import 'package:sipinter_admin/datawalikelas.dart';
import 'package:sipinter_admin/laporan.dart';
import 'package:sipinter_admin/laporanpoin.dart';
import 'package:sipinter_admin/tahunpelajaran.dart';


class LaporanPOIN extends StatefulWidget {
  const LaporanPOIN({Key? key}) : super(key: key);

  @override
  State<LaporanPOIN> createState() => _LaporanPOINState();
}

class _LaporanPOINState extends State<LaporanPOIN> {
  bool _draggingOver = false;
  String _activeMenuItem = 'INFO PENGGUNAAN';
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedKelas = 'Semua Kelas';
  String _selectedTahunAjaran = 'Semua Tahun Ajaran';
  int _currentPage = 1;
  int _rowsPerPage = 10;

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

  void _importExcel(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final excelFile = excel.Excel.decodeBytes(bytes);

      if (excelFile == null) {
        print('Failed to decode Excel file.');
        return;
      }

      for (var table in excelFile.tables.keys) {
        print('Sheet name: $table');
        final sheet = excelFile.tables[table];
        if (sheet != null) {
          for (var row in sheet.rows) {
            print('Row data: $row');
          }
          final maxCols = sheet.rows.fold<int>(
              0, (prev, row) => row.length > prev ? row.length : prev);
          final maxRows = sheet.rows.length;
          print('Number of columns: $maxCols');
          print('Number of rows: $maxRows');
        }
      }
    } catch (e) {
      print('Error importing file: $e');
    }
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
      );

      if (result == null) return;

      final file = File(result.files.single.path!);

      _importExcel(file);
    } catch (e) {
      print('Error picking file: $e');
    }
  }

  void _exportExcel() {
    final excelFile = excel.Excel.createExcel();
    final sheet = excelFile['Sheet1'];

    // Add dummy data to the sheet as an example
    

    final excelBytes = excelFile.encode();
    final directory = Directory.systemTemp;
    final file = File('${directory.path}/Laporan_Presensi_Siswa.xlsx');
    file.writeAsBytesSync(excelBytes!);
    print('Excel file exported to ${file.path}');
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

  Widget _getGuideContent(String menuItem) {
    switch (menuItem) {
      case 'DATA PELANGGARAN SISWA':
        return _buildGuideContent('Panduan Data Pelanggaran Siswa', [
          '1. Klik tombol "Tambah Pelanggaran" untuk menambahkan pelanggaran baru.',
          '2. Isi formulir dengan detail pelanggaran siswa.',
          '3. Klik tombol "Simpan" untuk menyimpan data pelanggaran.'
        ]);
      case 'TAHUN AJARAN':
        return _buildGuideContent('Panduan Tahun Ajaran', [
          '1. Klik tombol "Tambah Tahun Ajaran" untuk menambahkan tahun ajaran baru.',
          '2. Isi formulir dengan detail tahun ajaran.',
          '3. Klik tombol "Simpan" untuk menyimpan tahun ajaran.',
          '4. Tahun ajaran akan otomatis memilih data yang terbaru / terakhir kali inputkan data.',
          '5. Jika ingin menambah absen baru tambahkan data tahun ajaran baru lagi.'
        ]);
      case 'DATA SISWA':
        return _buildGuideContent('Panduan Data Siswa', [
          '1. Klik tombol "Tambah Siswa" untuk menambahkan siswa baru.',
          '2. Isi formulir dengan detail siswa.',
          '3. Klik tombol "Simpan" untuk menyimpan data siswa.'
        ]);
      case 'LAPORAN PRESENSI SISWA':
        return _buildGuideContent('Panduan Laporan Presensi Siswa', [
          '1. Pilih kelas dan tahun ajaran.',
          '2. Klik tombol "Export Excel" untuk mengunduh laporan presensi.',
        ]);
      case 'PILIH WALI KELAS':
        return _buildGuideContent('Panduan Pilih Wali Kelas', [
          '1. Klik tombol "Pilih Wali Kelas" untuk memilih wali kelas.',
          '2. Pilih wali kelas dari daftar guru.',
          '3. Klik tombol "Simpan" untuk menyimpan pilihan.'
        ]);
      case 'DATA GURU BK':
        return _buildGuideContent('Panduan Data Guru BK', [
          '1. Klik tombol "Tambah Guru BK" untuk menambahkan guru BK baru.',
          '2. Isi formulir dengan detail guru BK.',
          '3. Klik tombol "Simpan" untuk menyimpan data guru BK.'
        ]);
      case 'DATA KELAS':
        return _buildGuideContent('Panduan Data Kelas', [
          '1. Klik tombol "Tambah Kelas" untuk menambahkan kelas baru.',
          '2. Isi formulir dengan detail kelas.',
          '3. Klik tombol "Simpan" untuk menyimpan data kelas.'
        ]);
      case 'INFO PENGGUNAAN':
        return _buildGuideContent('Panduan Info Penggunaan', [
          '1. Menu ini memberikan informasi umum mengenai penggunaan aplikasi.',
        ]);
      default:
        return _buildGuideContent('Panduan', [
          'Pilih menu untuk melihat panduan penggunaan.'
        ]);
    }
  }

  Widget _buildGuideContent(String title, List<String> steps) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        ...steps.map((step) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Text(step),
        )),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredData = _data.where((item) {
      final query = _searchQuery.toLowerCase();
      final kelasFilter = _selectedKelas == 'Semua Kelas' ||
          item['kelas'].toString() == _selectedKelas;
      final tahunAjaranFilter = _selectedTahunAjaran == 'Semua Tahun Ajaran' ||
          item['tahun_ajaran'].toString() == _selectedTahunAjaran;
      return item.values
              .any((value) => value.toString().toLowerCase().contains(query)) &&
          kelasFilter &&
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
                          'Info Penggunaan',
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
                SizedBox(height: 16),
                Wrap(
                  children: [
                    _animatedMenuItem('TAHUN AJARAN', Colors.green.shade700),
                    _animatedMenuItem('DATA KELAS', Colors.brown.shade700),
                    _animatedMenuItem('PILIH WALI KELAS', Colors.purple.shade700),
                    _animatedMenuItem('DATA SISWA', Colors.orange.shade700),
                    _animatedMenuItem('DATA GURU BK', Colors.teal.shade700),
                    _animatedMenuItem('LAPORAN PRESENSI SISWA', Colors.red.shade700),
                    _animatedMenuItem('DATA PELANGGARAN SISWA', Colors.blue.shade700),
                  ],
                ),
                SizedBox(height: 16),
                AnimatedSwitcher(
                  duration: Duration(milliseconds: 300),
                  child: _getGuideContent(_activeMenuItem),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}