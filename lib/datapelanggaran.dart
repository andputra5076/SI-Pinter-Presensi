import 'package:flutter/material.dart';
import 'package:sipinter_admin/datagurubk.dart';
import 'package:sipinter_admin/datakelas.dart';
import 'package:sipinter_admin/datapelanggaran.dart';
import 'package:sipinter_admin/datasiswa.dart';
import 'package:sipinter_admin/datawalikelas.dart';
import 'package:sipinter_admin/informasi.dart';
import 'package:sipinter_admin/laporan.dart';
import 'package:sipinter_admin/tahunpelajaran.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Datapelanggaran extends StatefulWidget {
  const Datapelanggaran({Key? key}) : super(key: key);

  @override
  State<Datapelanggaran> createState() => _DatapelanggaranState();
}

class _DatapelanggaranState extends State<Datapelanggaran> {
  late Future<List<Map<String, dynamic>>> _futureData;
  int _currentPage = 1;
  final int _rowsPerPage = 14;
  int get pageCount => (_data.length / _rowsPerPage).ceil();
  List<Map<String, dynamic>> _data = [];
  late Future<List<Map<String, dynamic>>> futureDatapelanggaran;
  Future<List<Map<String, dynamic>>> fetchDatapelanggaran() async {
    final response = await http
        .get(Uri.parse('192.168.1.9/pesantrenadmin/api/get-pelanggaran'));

    if (response.statusCode == 200) {

      final data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data['data']);
    } else {
      throw Exception('Failed to load data');
    }
  }

  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedKelas = 'Semua Kelas';
  String _activeMenuItem = 'DATA PELANGGARAN SISWA';
  int _currentPageIndex = 2;

  List<Widget> pages = [
    Tahunpelajaran(),
    DataSiswa(),
    Laporan(),
    Datapelanggaran(),
    DataWalikelas(),
    Datagurubk(),
    Datakelas(),
    Informasi(),
  ];

  @override
  void initState() {
    super.initState();
    _futureData = fetchTahunKelas();
  }

  Future<List<Map<String, dynamic>>> fetchTahunKelas() async {
    

    final response = await http
        .get(Uri.parse("192.168.1.9/pesantrenadmin/api/get-pelanggaran"));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _data = List<Map<String, dynamic>>.from(data['data']);
      });
      return _data;
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredData = _data.where((item) {
      final query = _searchQuery.toLowerCase();
      final kelasFilter = _selectedKelas == 'Semua Kelas' ||
          item['kelas'].toString() == _selectedKelas;
      return item.values
              .any((value) => value.toString().toLowerCase().contains(query)) &&
          kelasFilter;
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
                          'Data Pelanggaran Siswa',
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
                      flex: 2,
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Cari Data Pelanggaran Siswa...',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                  ],
                ),
                SizedBox(height: 16),

                // Data table with card and shadow
                Container(
                  height: 670,
                  child: Card(
                    elevation: 4.0,
                    margin: EdgeInsets.zero,
                    child: Column(
                      children: [
                        Expanded(
                          child: FutureBuilder<List<Map<String, dynamic>>>(
                            future: _futureData,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                    child: CircularProgressIndicator());
                              } else if (snapshot.hasError) {
                                return Center(
                                    child: Text('Error: ${snapshot.error}'));
                              } else if (!snapshot.hasData ||
                                  snapshot.data!.isEmpty) {
                                return Center(child: Text('No data found'));
                              } else {
                                final data = snapshot.data!;
                                final displayedData = data
                                    .skip((_currentPage - 1) * _rowsPerPage)
                                    .take(_rowsPerPage)
                                    .toList();

                                return LayoutBuilder(
                                  builder: (context, constraints) {
                                    final columnWidth =
                                        constraints.maxWidth / 7;
                                    return SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: ConstrainedBox(
                                        constraints: BoxConstraints(
                                          minWidth: constraints.maxWidth,
                                        ),
                                        child: DataTable(
                                          columnSpacing: 16.0,
                                          headingRowHeight: 56,
                                          dataRowHeight: 56,
                                          headingRowColor:
                                              MaterialStateColor.resolveWith(
                                                  (states) =>
                                                      Colors.blueGrey[100]!),
                                          columns: [
                                            DataColumn(
                                              label: Container(
                                                width: columnWidth,
                                                child: Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Text(
                                                    'No',
                                                    style: TextStyle(
                                                      color: Colors
                                                          .blueGrey.shade900,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            DataColumn(
                                              label: Container(
                                                width: columnWidth,
                                                child: Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Text(
                                                    'Nama Siswa',
                                                    style: TextStyle(
                                                      color: Colors
                                                          .blueGrey.shade900,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            DataColumn(
                                              label: Container(
                                                width: columnWidth,
                                                child: Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Text(
                                                    'Kelas',
                                                    style: TextStyle(
                                                      color: Colors
                                                          .blueGrey.shade900,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            DataColumn(
                                              label: Container(
                                                width: columnWidth,
                                                child: Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Text(
                                                    'Keterangan',
                                                    style: TextStyle(
                                                      color: Colors
                                                          .blueGrey.shade900,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            DataColumn(
                                              label: Container(
                                                width: columnWidth,
                                                child: Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Text(
                                                    'Poin',
                                                    style: TextStyle(
                                                      color: Colors
                                                          .blueGrey.shade900,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            DataColumn(
                                              label: Container(
                                                width: columnWidth,
                                                child: Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Text(
                                                    'Catatan',
                                                    style: TextStyle(
                                                      color: Colors
                                                          .blueGrey.shade900,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            DataColumn(
                                              label: Container(
                                                width: columnWidth,
                                                child: Align(
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    'Aksi',
                                                    style: TextStyle(
                                                      color: Colors
                                                          .blueGrey.shade900,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                          rows: displayedData.map((item) {
                                            return DataRow(cells: [
                                              DataCell(Container(
                                                width: columnWidth,
                                                child: Text(item['no'].toString()),
                                              )),
                                              DataCell(Container(
                                                width: columnWidth,
                                                child: Text(item['nama_siswa'].toString()),
                                              )),
                                              DataCell(Container(
                                                width: columnWidth,
                                                child: Text(item['nama_kelas'].toString()),
                                              )),
                                              DataCell(Container(
                                                width: columnWidth,
                                                child: Text(item['keterangan']),
                                              )),
                                              DataCell(Container(
                                                width: columnWidth,
                                                child: Text(item['poin']),
                                              )),
                                              DataCell(Container(
                                                width: columnWidth,
                                                child: Text(item['catatan']),
                                              )),
                                              DataCell(Container(
                                                width: columnWidth,
                                                alignment: Alignment.center,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                   
                                                    IconButton(
                                                      icon: Icon(Icons.delete),
                                                      onPressed: () {
                                                        _showDeleteDialog(item);
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              )),
                                            ]);
                                          }).toList(),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              }
                            },
                          ),
                        ),
                        // Pagination controls with distinct background
                        Container(
                          color: Colors.blueGrey[100],
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.first_page),
                                  onPressed: _currentPage > 1
                                      ? () {
                                          setState(() {
                                            _currentPage = 1;
                                          });
                                        }
                                      : null,
                                ),
                                IconButton(
                                  icon: Icon(Icons.chevron_left),
                                  onPressed: _currentPage > 1
                                      ? () {
                                          setState(() {
                                            _currentPage--;
                                          });
                                        }
                                      : null,
                                ),
                                IconButton(
                                  icon: Icon(Icons.chevron_right),
                                  onPressed: _currentPage < pageCount
                                      ? () {
                                          setState(() {
                                            _currentPage++;
                                          });
                                        }
                                      : null,
                                ),
                                IconButton(
                                  icon: Icon(Icons.last_page),
                                  onPressed: _currentPage < pageCount
                                      ? () {
                                          setState(() {
                                            _currentPage = pageCount;
                                          });
                                        }
                                      : null,
                                ),
                                SizedBox(width: 16),
                                Text('Page $_currentPage of $pageCount'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
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

  void _showEditDialog(Map<String, dynamic> item) {
  final nipController = TextEditingController(text: item['idguru']);
  final namaController = TextEditingController(text: item['nama']);
  final usernameController = TextEditingController(text: item['username']);
  final passwordController = TextEditingController();
  String? statusAktif = item['status'] == '1' ? '1' : '0'; // Default value from item
  bool _obscureText = true;

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(
              'Edit Data Pelanggaran',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // NIP Input
                  TextField(
                    controller: nipController,
                    decoration: InputDecoration(
                      labelText: 'NIP',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 10),
                  // Nama Input
                  TextField(
                    controller: namaController,
                    decoration: InputDecoration(
                      labelText: 'Nama',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 10),
                  // Username Input
                  TextField(
                    controller: usernameController,
                    decoration: InputDecoration(
                      labelText: 'Username',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 10),
                  // Password Input
                  TextField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureText ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                      ),
                    ),
                    obscureText: _obscureText, // For password input
                  ),
                  SizedBox(height: 10),
                  // Status Dropdown
                  DropdownButtonFormField<String>(
                    value: statusAktif,
                    decoration: InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      DropdownMenuItem(
                        value: '1',
                        child: Text('Aktif'),
                      ),
                      DropdownMenuItem(
                        value: '0',
                        child: Text('Tidak Aktif'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        statusAktif = value;
                      });
                    },
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.grey,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                child: Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () async {
                  // Prepare data for POST request
                  final data = {
                    'id': item['id'].toString(),  // Ensure id is included for updating
                    'idguru': nipController.text,
                    'nama': namaController.text,
                    'username': usernameController.text,
                    'password': passwordController.text.isNotEmpty ? passwordController.text : null, // Update password only if not empty
                    'status': statusAktif,
                  };

                  // Send POST request
                  final response = await http.post(
                    Uri.parse('192.168.1.9/pesantrenadmin/api/perbarui-pelanggaran'),
                    headers: {
                      'Content-Type': 'application/x-www-form-urlencoded',
                    },
                    body: data,
                  );

                  if (response.statusCode == 200) {
                    // If the server returns an OK response, call fetchTahunKelas
                    Navigator.of(context).pop();
                    print('Data updated successfully');
                    setState(() {
                      _futureData = fetchTahunKelas();
                    }); // Call your method here
                  } else {
                    // Handle error
                    print('Failed to update data. Error: ${response.reasonPhrase}');
                  }
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                child: Text('Simpan'),
              ),
            ],
          );
        },
      );
    },
  );
}



void hapusTahunKelas(String id) async {
  var url = Uri.parse('192.168.1.9/pesantrenadmin/api/hapus-pelanggaran');
  
  try {
    var response = await http.post(
      url,
      body: {'id': id},
    );

    if (response.statusCode == 200) {
      // Request berhasil
      print('Data berhasil dihapus');
    } else {
      // Request gagal
      print('Gagal menghapus data. Status code: ${response.statusCode}');
    }
  } catch (e) {
    // Error dalam melakukan request
    print('Error: $e');
  }
}
  void _showDeleteDialog(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Hapus Data Pelanggaran',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          content: Text('Apakah anda yakin ingin menghapus data ini?'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.grey,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              child: Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                hapusTahunKelas(item['id']);
                setState(() {
                  _data.remove(item);
                });
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.red,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              child: Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  void _showAddDialog() {
  final siswaController = TextEditingController();
  final nisController = TextEditingController();
  final keteranganController = TextEditingController();
  final poinController = TextEditingController();
  final catatanController = TextEditingController();
  bool _obscureText = true;

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(
              'Tambah Data Pelanggaran',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // NIP Input
                  TextField(
                    controller: siswaController,
                    decoration: InputDecoration(
                      labelText: 'NIP',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 10),
                  // Nama Input
                  TextField(
                    controller: nisController,
                    decoration: InputDecoration(
                      labelText: 'NIS',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 10),
                  // Username Input
                  TextField(
                    controller: keteranganController,
                    decoration: InputDecoration(
                      labelText: 'Keterangan',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: poinController,
                    decoration: InputDecoration(
                      labelText: 'Poin',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: catatanController,
                    decoration: InputDecoration(
                      labelText: 'Catatan',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.grey,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                child: Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () async {
                  // Prepare data for POST request
                  final data = {
                    'idsiswa': siswaController.text,
                    'nis': nisController.text,
                    'keterangan': keteranganController.text,
                    'poin': poinController.text,
                    'catatan': catatanController.text,
                  };

                  // Send POST request
                  final response = await http.post(
                    Uri.parse('192.168.1.9/pesantrenadmin/api/tambahdata-pelanggaran'),
                    headers: {
                      'Content-Type': 'application/x-www-form-urlencoded',
                    },
                    body: data,
                  );

                  if (response.statusCode == 200) {
                    // If the server returns an OK response, call fetchTahunKelas
                    Navigator.of(context).pop();
                    print('Data updated successfully');
                    setState(() {
                      _futureData = fetchTahunKelas();
                    }); // Call your method here
                  } else {
                    // Handle error
                    print('Failed to add data. Error: ${response.reasonPhrase}');
                  }
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                child: Text('Simpan'),
              ),
            ],
          );
        },
      );
    },
  );
}

}
