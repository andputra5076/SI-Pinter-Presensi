import 'package:file_picker/file_picker.dart';
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
import 'package:flutter_dropzone/flutter_dropzone.dart';

class DataWalikelas extends StatefulWidget {
  const DataWalikelas({Key? key}) : super(key: key);

  @override
  State<DataWalikelas> createState() => _DataWalikelasState();
}

class _DataWalikelasState extends State<DataWalikelas> {
  late DropzoneViewController controller;
  String? _selectedFileName;

  void _uploadFile() async {
    // This method can be used to show a dialog for file selection
    // or any other logic needed to handle the file upload.
  }
  // Variables for dropdown options
  List<Map<String, String>> kelasOptions = [];
  List<Map<String, String>> tahunAjaranOptions = [];
  List<DropdownMenuItem<String>> tahunAjaranOptions2 = [];

  // Variables for managing dropdown selection
  String? selectedKelas;
  String? selectedTahunAjaran;

  // Controllers for dialog input fields
  final TextEditingController _searchController = TextEditingController();

  final TextEditingController namaController = TextEditingController();
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
          kelasOptions = kelasData;
          tahunAjaranOptions = tahunAjaranData;
          tahunAjaranOptions2 = tahunAjaranData.map((item) {
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

  late Future<List<Map<String, dynamic>>> _futureData;
  int _currentPage = 1;
  final int _rowsPerPage = 14;
  int get pageCount => (_data.length / _rowsPerPage).ceil();
  List<Map<String, dynamic>> _data = [];
  late Future<List<Map<String, dynamic>>> futureDataWalikelas;
  Future<List<Map<String, dynamic>>> fetchDataWalikelas() async {
    final response =
        await http.get(Uri.parse('192.168.1.9/pesantrenadmin/api/get-guru'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data['data']);
    } else {
      throw Exception('Failed to load data');
    }
  }

  String _searchQuery = '';
  String _selectedKelas = 'Semua Kelas';
  String _activeMenuItem = 'PILIH WALI KELAS';
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
    fetchDropdownOptions();
  }

  Future<List<Map<String, dynamic>>> fetchTahunKelas() async {
    final response =
        await http.get(Uri.parse("192.168.1.9/pesantrenadmin/api/get-guru"));

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
      final kelasFilter = selectedKelas == null ||
          selectedKelas == 'Semua Kelas' ||
          item['kelas']
              .toString()
              .toLowerCase()
              .contains(selectedKelas!.toLowerCase());
      final tahunAjaranFilter = selectedTahunAjaran == null ||
          selectedTahunAjaran == 'Semua Tahun Ajaran' ||
          item['tahun_ajaran']
              .toString()
              .toLowerCase()
              .contains(selectedTahunAjaran!.toLowerCase());

      return item['nama'].toString().toLowerCase().contains(query) &&
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
                // Header with title, logo, and back button
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back),
                      onPressed: () {
                        Navigator.pop(
                            context); // Go back to the previous screen
                      },
                    ),
                    Expanded(
                      flex: 1,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Pilih Wali Kelas',
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
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(
                        horizontal: 8.0), // Add horizontal padding
                    child: Row(
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
                ),

                SizedBox(height: 16),

                // Search fields and dropdown
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
                          hintText: 'Cari Data Wali Kelas...',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
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
                          items: tahunAjaranOptions2,
                          onChanged: (newValue) {
                            setState(() {
                              selectedTahunAjaran = newValue;
                            });
                          },
                        ),
                      ),
                    ),
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
                                    final isMobile = constraints.maxWidth <
                                        600; // Adjust this threshold as needed
                                    final double columnWidth = isMobile
                                        ? constraints.maxWidth /
                                            7 // Distribute available width for mobile
                                        : constraints.maxWidth /
                                            8; // Distribute available width for larger screens

                                    return SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: ConstrainedBox(
                                        constraints: BoxConstraints(
                                          minWidth: constraints.maxWidth,
                                        ),
                                        child: DataTable(
                                          columnSpacing:
                                              8.0, // Adjust column spacing if needed
                                          headingRowHeight: 40,
                                          dataRowHeight: 40,
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
                                                    'ID Guru',
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
                                                    'Nama',
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
                                                    'Username',
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
                                                width: columnWidth *
                                                    1.5, // Wider for 'Tahun Ajaran'
                                                child: Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Text(
                                                    'Tahun Ajaran',
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
                                                child: Text(
                                                    item['no'].toString(),
                                                    overflow:
                                                        TextOverflow.ellipsis),
                                              )),
                                              DataCell(Container(
                                                width: columnWidth,
                                                child: Text(
                                                    item['idguru'].toString(),
                                                    overflow:
                                                        TextOverflow.ellipsis),
                                              )),
                                              DataCell(Container(
                                                width: columnWidth,
                                                child: Text(item['nama'],
                                                    overflow:
                                                        TextOverflow.ellipsis),
                                              )),
                                              DataCell(Container(
                                                width: columnWidth,
                                                child: Text(item['username'],
                                                    overflow:
                                                        TextOverflow.ellipsis),
                                              )),
                                              DataCell(Container(
                                                width: columnWidth,
                                                child: Text(
                                                    item['nama_kelas']
                                                        .toString(),
                                                    overflow:
                                                        TextOverflow.ellipsis),
                                              )),
                                              DataCell(Container(
                                                width: columnWidth *
                                                    1.5, // Wider for 'Tahun Ajaran'
                                                child: Text(
                                                    item['nama_tahun_ajaran']
                                                        .toString(),
                                                    overflow:
                                                        TextOverflow.ellipsis),
                                              )),
                                              DataCell(Container(
                                                width: columnWidth,
                                                alignment: Alignment.center,
                                                child: isMobile
                                                    ? PopupMenuButton<String>(
                                                        icon: Icon(
                                                            Icons.more_vert),
                                                        onSelected: (value) {
                                                          if (value == 'edit') {
                                                            _showEditDialog(
                                                                item);
                                                          } else if (value ==
                                                              'delete') {
                                                            _showDeleteDialog(
                                                                item);
                                                          }
                                                        },
                                                        itemBuilder:
                                                            (context) => [
                                                          PopupMenuItem(
                                                            value: 'edit',
                                                            child: Text('Edit'),
                                                          ),
                                                          PopupMenuItem(
                                                            value: 'delete',
                                                            child:
                                                                Text('Delete'),
                                                          ),
                                                        ],
                                                      )
                                                    : Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          IconButton(
                                                            icon: Icon(
                                                                Icons.edit),
                                                            onPressed: () {
                                                              _showEditDialog(
                                                                  item);
                                                            },
                                                          ),
                                                          IconButton(
                                                            icon: Icon(
                                                                Icons.delete),
                                                            onPressed: () {
                                                              _showDeleteDialog(
                                                                  item);
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
                )
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: Align(
        alignment: Alignment.bottomRight, // Posisi tombol di bagian bawah kanan
        child: Row(
          mainAxisSize: MainAxisSize
              .min, // Menyesuaikan ukuran baris dengan ukuran tombol
          children: [
            // FloatingActionButton untuk menambah data
            Padding(
              padding:
                  const EdgeInsets.only(bottom: 16.0), // Jarak dari tepi bawah
              child: FloatingActionButton(
                heroTag: "btn50",
                onPressed: () {
                  _showImportDialog(); // _showImportDialog();
                },
                child: Icon(
                  Icons.file_upload,
                  color: Colors.white,
                ),
                tooltip: 'Import Excel',
                backgroundColor: Colors.green,
                elevation: 8.0,
              ),
            ),
            SizedBox(width: 10.0),
            Padding(
              padding: const EdgeInsets.only(
                  left: 8.0, bottom: 16.0), // Jarak antar tombol dan tepi bawah
              child: FloatingActionButton.extended(
                heroTag: "btn51",
                onPressed: () {
                  _showAddDialog();
                },
                icon: Icon(
                  Icons.add,
                  color: Colors.white,
                ),
                label: Text(
                  'Tambah Data',
                  style: TextStyle(color: Colors.white),
                ),
                backgroundColor: Colors.blue,
                elevation: 8.0,
              ),
            ),
            // FloatingActionButton untuk mengimpor Excel
          ],
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
    final guruController = TextEditingController(text: item['nama']);
    final id = item['id'].toString();
    String? selectedKelas = item['id_kelas'];
    String? selectedTahunAjaran = item['tahun_ajaran_id'];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            // Fetch data when dialog is built

            return AlertDialog(
              title: Text(
                'Edit Data Wali Kelas',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Nama Input
                    TextField(
                      controller: guruController,
                      decoration: InputDecoration(
                        labelText: 'Nama Kelas',
                        border: OutlineInputBorder(),
                      ),
                    ),

                    // Kelas Dropdown
                    Container(
                      margin: EdgeInsets.only(top: 16),
                      child: DropdownButtonFormField<String>(
                        value: selectedKelas,
                        hint: Text('Pilih Kelas'),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        items: kelasOptions.map((kelas) {
                          return DropdownMenuItem<String>(
                            value: kelas['id'],
                            child: Text(kelas['name']!),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            selectedKelas = newValue;
                          });
                        },
                      ),
                    ),

                    // Tahun Ajaran Dropdown
                    Container(
                      margin: EdgeInsets.only(top: 16),
                      child: DropdownButtonFormField<String>(
                        value: selectedTahunAjaran,
                        hint: Text('Pilih Tahun Ajaran'),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        items: tahunAjaranOptions.map((tahunAjaran) {
                          return DropdownMenuItem<String>(
                            value: tahunAjaran['id'],
                            child: Text(tahunAjaran['name']!),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            selectedTahunAjaran = newValue;
                          });
                        },
                      ),
                    ),
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
                      'id': id,
                      'nama': guruController.text,
                      'id_kelas': selectedKelas,
                      'tahun_ajaran_id': selectedTahunAjaran,
                    };

                    // Send POST request
                    final response = await http.post(
                      Uri.parse('192.168.1.9/pesantrenadmin/api/edit-guru'),
                      headers: {
                        'Content-Type': 'application/x-www-form-urlencoded',
                      },
                      body: data,
                    );

                    if (response.statusCode == 200) {
                      Navigator.of(context).pop();
                      print(response.body);
                      setState(() {
                        _futureData = fetchTahunKelas(); // Refresh data
                      });
                    } else {
                      print(
                          'Failed to update data. Error: ${response.reasonPhrase}');
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
    var url = Uri.parse('192.168.1.9/pesantrenadmin/api/hapus-guru');

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
            'Hapus Data Wali Kelas',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          content: Text('Apakah Anda yakin ingin menghapus data ini?'),
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
                final response = await http.post(
                  Uri.parse('192.168.1.9/pesantrenadmin/api/hapus-guru'),
                  headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                  },
                  body: {
                    'id': item['id'],
                  },
                );

                if (response.statusCode == 200) {
                  // If the server returns a 200 OK response, then proceed
                  setState(() {
                    _data.remove(item);
                  });
                  Navigator.of(context).pop();
                  print('Data deleted successfully');
                } else {
                  // If the server did not return a 200 OK response, throw an exception
                  print(
                      'Failed to delete data. Error: ${response.reasonPhrase}');
                }
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

  void _showImportDialog() {
    String? _selectedFileName;
    var _selectedFilePath;
    String? _selectedTahunAjaran;
    var disable = false;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Import Excel'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_selectedFileName != null) SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: _selectedTahunAjaran,
                    hint: Text('Pilih Tahun Ajaran'),
                    items: tahunAjaranOptions.map((tahun) {
                      return DropdownMenuItem<String>(
                        value: tahun['id'],
                        child: Text(tahun['name']!),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedTahunAjaran = value;
                      });
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    ),
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      // Pick a file
                      final result = await FilePicker.platform.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: ['xlsx', 'xls'],
                      );
                      if (result != null) {
                        final file = result.files.first;
                        setState(() {
                          _selectedFileName = file.name;
                          _selectedFilePath = file.path;
                          print(_selectedFilePath);
                        });
                      }
                    },
                    child: Text(_selectedFileName ?? 'Pilih File Excel'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.green, // Button text color
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      textStyle: TextStyle(fontSize: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Batal'),
            ),
            ElevatedButton(
              
              onPressed: () async {
                if (disable == false) {
                  disable = true;
                  if (_selectedFileName != null && _selectedTahunAjaran != null) {
                  // Send data to API
                  final uri =
                      Uri.parse('192.168.1.9/pesantrenadmin/api/tambah-guru');
                  final request = http.MultipartRequest('POST', uri)
                    ..fields['id_tahun_ajaran'] = _selectedTahunAjaran!
                    ..files.add(await http.MultipartFile.fromPath(
                        'file_excel', _selectedFilePath!,
                        filename: 'kkkk'));
                  final response = await request.send();

                  if (response.statusCode == 200) {
                    Navigator.of(context).pop();
                    print('Data added successfully');
                    setState(() {
                      _futureData = fetchTahunKelas(); // Refresh data
                    });
                  } else {
                    print(response);
                  }
                }
                } 
              },
              child: Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  void _showAddDialog() {
    final idGuruController = TextEditingController();
    final namaController = TextEditingController();
    String? selectedKelas;
    String? selectedTahunAjaran;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                'Tambah Data Wali Kelas',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.blueGrey.shade900, // Adjust title color
                ),
              ),
              content: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 0), // Padding for sides
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment
                        .stretch, // Ensure widgets take full width
                    children: [
                      // ID Guru Input
                      Container(
                        margin:
                            EdgeInsets.only(bottom: 16), // Space between fields
                        child: TextField(
                          controller: idGuruController,
                          decoration: InputDecoration(
                            labelText: 'ID Guru',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                          ),
                        ),
                      ),

                      // Nama Input
                      Container(
                        margin:
                            EdgeInsets.only(bottom: 16), // Space between fields
                        child: TextField(
                          controller: namaController,
                          decoration: InputDecoration(
                            labelText: 'Nama',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                          ),
                        ),
                      ),

                      // Kelas Dropdown
                      Container(
                        margin:
                            EdgeInsets.only(bottom: 16), // Space between fields
                        child: DropdownButtonFormField<String>(
                          value: selectedKelas,
                          hint: Text('Pilih Kelas'),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                          ),
                          items: kelasOptions.map((kelas) {
                            return DropdownMenuItem<String>(
                              value: kelas['id'],
                              child: Text(kelas['name']!),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              selectedKelas = newValue;
                            });
                          },
                        ),
                      ),

                      // Tahun Ajaran Dropdown
                      Container(
                        margin:
                            EdgeInsets.only(bottom: 16), // Space between fields
                        child: DropdownButtonFormField<String>(
                          value: selectedTahunAjaran,
                          hint: Text('Pilih Tahun Ajaran'),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                          ),
                          items: tahunAjaranOptions.map((tahunAjaran) {
                            return DropdownMenuItem<String>(
                              value: tahunAjaran['id'],
                              child: Text(tahunAjaran['name']!),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              selectedTahunAjaran = newValue;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.grey, // Text color
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    // Prepare data for POST request
                    final data = {
                      'idguru': idGuruController.text,
                      'nama': namaController.text,
                      'id_kelas': selectedKelas,
                      'tahun_ajaran_id': selectedTahunAjaran,
                    };

                    // Send POST request
                    final response = await http.post(
                      Uri.parse(
                          '192.168.1.9/pesantrenadmin/api/tambah-guru-satuan'),
                      headers: {
                        'Content-Type': 'application/x-www-form-urlencoded',
                      },
                      body: data,
                    );

                    if (response.statusCode == 200) {
                      Navigator.of(context).pop();
                      print('Data added successfully');
                      setState(() {
                        _futureData = fetchTahunKelas(); // Refresh data
                      });
                    } else {
                      print(
                          'Failed to add data. Error: ${response.reasonPhrase}');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.green, // Text color
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
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
