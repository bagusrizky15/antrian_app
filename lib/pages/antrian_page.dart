import 'package:antrian_app/data/datasources/antrian_local_datasources.dart';
import 'package:antrian_app/data/models/antrian.dart';
import 'package:antrian_app/pages/printer_page.dart';
import 'package:flutter/material.dart';

class AntrianPage extends StatefulWidget {
  const AntrianPage({super.key});

  @override
  State<AntrianPage> createState() => _AntrianPageState();
}

class _AntrianPageState extends State<AntrianPage> {
  final _nameController = TextEditingController();
  final _noAntrianController = TextEditingController();

  List<Antrian> listAntrian = [];

  Future<void> getAntrian() async {
    final result = await AntrianLocalDatasource.instance.getAllAntrian();
    setState(() {
      listAntrian = result;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAntrian();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.print,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const PrinterPage()));
            },
          )
        ],
        backgroundColor: Colors.blue,
        title: const Text('Kelola Antrian', style: TextStyle(color: Colors.white)),
      ),
      body: listAntrian.isEmpty ? const Center(child: Text('Tidak ada data')) : _buildAntrianList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Tambah Antrian'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Nama Antrian'),
                    ),
                    TextField(
                      controller: _noAntrianController,
                      decoration: const InputDecoration(labelText: 'Nomor Antrian'),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      _nameController.clear();
                      _noAntrianController.clear();
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel', style: TextStyle(color: Colors.red)),
                  ),
                  TextButton(
                    onPressed: () {
                      AntrianLocalDatasource.instance.saveAntrian(
                        Antrian(nama: _nameController.text, noAntrian: _noAntrianController.text, isActive: true),
                      );
                      getAntrian();
                      _nameController.clear();
                      _noAntrianController.clear();
                      Navigator.pop(context);
                    },
                    child: const Text('Simpan', style: TextStyle(color: Colors.blue)),
                  ),
                ],
              );
            },
          );
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildAntrianList() {
    return Padding(
      padding: const EdgeInsets.only(top: 5, left: 10, right: 10),
      child: ListView.builder(
        itemCount: listAntrian.length,
        itemBuilder: (context, index) {
          var data = listAntrian[index];
          return Card(
            child: InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    _nameController.text = data.nama;
                    _noAntrianController.text = data.noAntrian;
                    return AlertDialog(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Ubah Antrian'),
                          InkWell(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: const Text('x', style: TextStyle(color: Colors.red)),
                          )
                        ],
                      ),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: _nameController,
                            decoration: const InputDecoration(labelText: 'Nama Antrian'),
                            onChanged: (value) {},
                          ),
                          TextField(
                            controller: _noAntrianController,
                            decoration: const InputDecoration(labelText: 'Nomor Antrian'),
                            onChanged: (value) {},
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            setState(() {
                              AntrianLocalDatasource.instance.deleteAntrian(data.id!);
                            });
                            getAntrian();
                            Navigator.pop(context);
                          },
                          child: const Text('Delete', style: TextStyle(color: Colors.red)),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              AntrianLocalDatasource.instance.updateAntrian(
                                Antrian(
                                  id: data.id,
                                  nama: _nameController.text,
                                  noAntrian: _noAntrianController.text,
                                  isActive: true,
                                ),
                              );
                            });
                            getAntrian();
                            Navigator.pop(context);
                          },
                          child: const Text('Simpan', style: TextStyle(color: Colors.blue)),
                        ),
                      ],
                    );
                  },
                );
              },
              child: ListTile(
                title: Text(data.nama, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                subtitle: Text(data.noAntrian),
                trailing: const Icon(
                  (Icons.arrow_forward_ios),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
