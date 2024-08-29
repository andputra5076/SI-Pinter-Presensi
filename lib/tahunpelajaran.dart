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

class Tahunpelajaran extends StatefulWidget {
  const Tahunpelajaran({Key? key}) : super(key: key);

  @override
  State<Tahunpelajaran> createState() => _TahunpelajaranState();
}

class _TahunpelajaranState extends State<Tahunpelajaran> {
  late Future<List<Map<String, dynamic>>> _futureData;
  int _currentPage = 1;

  List<Map<String, dynamic>> _searchResults = [];
  String _searchQuery = '';
  final int _rowsPerPage = 14;
  int get pageCount => (_data.length / _rowsPerPage).ceil();
  List<Map<String, dynamic>> _data = [];
  late Future<List<Map<String, dynamic>>> futureTahunpelajaran;
  Future<List<Map<String, dynamic>>> fetchTahunpelajaran() async {
    final response = await http
        .get(Uri.parse('192.168.1.9/pesantrenadmin/api/get-tahun-ajaran'));

    if (response.statusCode == 200) {

      final data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data['data']);
    } else {
      throw Exception('Failed to load data');
    }
  }

  final _searchController = TextEditingController();
  String _selectedKelas = 'Semua Kelas';
  String _activeMenuItem = 'TAHUN AJARAN';
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
    _futureData = fetchTahunAjaran();
  }

  Future<List<Map<String, dynamic>>> fetchTahunAjaran() async {
    

    final response = await http
        .get(Uri.parse("192.168.1.9/pesantrenadmin/api/get-tahun-ajaran"));

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
  Future<void> _fetchSearchResults(String query) async {
    setState(() {
      _searchQuery = query;
      _searchResults = _data.where((item) {
        final itemName = item['nama'].toString().toLowerCase();
        return itemName.contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredData = _searchQuery.isEmpty
        ? _data
        : _searchResults;

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
                          'Tahun Ajaran',
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
                          _fetchSearchResults(value);
                        },
                        decoration: InputDecoration(
                          hintText: 'Cari Tahun Ajaran...',
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
                                        constraints.maxWidth / 3;
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
                                                child: Text(item['nama']),
                                              )),
                                              DataCell(Container(
                                                width: columnWidth,
                                                alignment: Alignment.center,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    IconButton(
                                                      icon: Icon(Icons.edit),
                                                      onPressed: () {
                                                        _showEditDialog(item);
                                                      },
                                                    ),
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
      floatingActionButton: FloatingActionButton.extended(
        heroTag: "btn448",
        onPressed: () {
          _showAddDialog();
        },
        icon: Icon(Icons.add, color: Colors.white,),
        label: Text(
          'Tambah Data',
          style: TextStyle(color: Colors.white), // Set text color to black
        ),
        backgroundColor: Colors.blue,
        elevation: 8.0,
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
  final namaController = TextEditingController(text: item['nama']);
  int selectedYear = int.parse(item['nama'].split(' - ')[0]);
  String selectedType = item['nama'].split(' - ')[1];

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(
              'Edit Data Tahun Ajaran',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Year Picker
                  ElevatedButton(
                    onPressed: () async {
                      final currentYear = DateTime.now().year;
                      final pickedYear = await showDialog<int>(
                        context: context,
                        builder: (context) {
                          return Dialog(
                            child: YearPicker(
                              selectedDate: DateTime(selectedYear),
                              onChanged: (DateTime dateTime) {
                                Navigator.pop(context, dateTime.year);
                              },
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            ),
                          );
                        },
                      );
                      if (pickedYear != null) {
                        setState(() {
                          selectedYear = pickedYear;
                        });
                      }
                    },
                    child: Text('Selected Year: $selectedYear'),
                  ),
                  SizedBox(height: 10),
                  // Type Selection with Border
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedType = 'Ganjil';
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: selectedType == 'Ganjil'
                                  ? Colors.green.shade100
                                  : Colors.white,
                              border: Border.all(
                                color: selectedType == 'Ganjil'
                                    ? Colors.green
                                    : Colors.grey,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                'Ganjil',
                                style: TextStyle(
                                  color: selectedType == 'Ganjil'
                                      ? Colors.green
                                      : Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedType = 'Genap';
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: selectedType == 'Genap'
                                  ? Colors.green.shade100
                                  : Colors.white,
                              border: Border.all(
                                color: selectedType == 'Genap'
                                    ? Colors.green
                                    : Colors.grey,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                'Genap',
                                style: TextStyle(
                                  color: selectedType == 'Genap'
                                      ? Colors.green
                                      : Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
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
                  // Perform HTTP POST request
                  final url = '192.168.1.9/pesantrenadmin/api/edit-tahun-ajaran';
                  final response = await http.post(
                    Uri.parse(url),
                    body: {
                      'id': item['id'].toString(),
                      'tahun': selectedYear.toString(),
                      'tipe': selectedType,
                    },
                  );

                  // Handle response
                  if (response.statusCode == 200) {
                    // Successful request
                    print('Data updated successfully');
                    setState(() {
                        _futureData = fetchTahunAjaran();
                      });
                  } else {
                    // Handle error
                    print('Failed to update data. Error: ${response.reasonPhrase}');
                  }

                  // Close dialog
                  Navigator.of(context).pop();
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


void hapusTahunAjaran(String id) async {
  var url = Uri.parse('192.168.1.9/pesantrenadmin/api/hapus-tahun-ajaran');
  
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
            'Hapus Data Tahun Ajaran',
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
                hapusTahunAjaran(item['id']);
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
    final namaController = TextEditingController();
    int? selectedYear;
    String? selectedType;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                'Tambah Data Tahun Ajaran',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Year Picker
                    ElevatedButton(
                      onPressed: () async {
                        final currentYear = DateTime.now().year;
                        final pickedYear = await showDialog<int>(
                          context: context,
                          builder: (context) {
                            return Dialog(
                              child: YearPicker(
                                selectedDate: DateTime(currentYear),
                                onChanged: (DateTime dateTime) {
                                  Navigator.pop(context, dateTime.year);
                                },
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              ),
                            );
                          },
                        );
                        if (pickedYear != null) {
                          setState(() {
                            selectedYear = pickedYear;
                          });
                        }
                      },
                      child: Text(selectedYear != null
                          ? 'Selected Year: $selectedYear'
                          : 'Select Year'),
                    ),
                    SizedBox(height: 10),
                    // Type Selection with Border
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedType = 'Ganjil';
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: selectedType == 'Ganjil'
                                    ? Colors.green.shade100
                                    : Colors.white,
                                border: Border.all(
                                  color: selectedType == 'Ganjil'
                                      ? Colors.green
                                      : Colors.grey,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  'Ganjil',
                                  style: TextStyle(
                                    color: selectedType == 'Ganjil'
                                        ? Colors.green
                                        : Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedType = 'Genap';
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: selectedType == 'Genap'
                                    ? Colors.green.shade100
                                    : Colors.white,
                                border: Border.all(
                                  color: selectedType == 'Genap'
                                      ? Colors.green
                                      : Colors.grey,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  'Genap',
                                  style: TextStyle(
                                    color: selectedType == 'Genap'
                                        ? Colors.green
                                        : Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
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
                      'tahun': selectedYear.toString(),
                      'tipe': selectedType,
                    };

                    // Send POST request
                    final response = await http.post(
                      Uri.parse(
                          '192.168.1.9/pesantrenadmin/api/tambah-tahun-ajaran'),
                      headers: {
                        'Content-Type': 'application/x-www-form-urlencoded',
                      },
                      body: data,
                    );

                    if (response.statusCode == 200) {
                      // If the server returns an OK response, call fetchTahunpelajaran
                      Navigator.of(context).pop();
                      setState(() {
                        // Fetch new data after adding a new tahun ajaran
                        _futureData = fetchTahunAjaran();
                      });
                    } else {
                      // If the server did not return a 200 OK response, handle the error
                      // Handle error response here, e.g., show an error message
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
