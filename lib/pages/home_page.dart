import 'package:antrian_app/data/datasources/antrian_local_datasources.dart';
import 'package:antrian_app/data/datasources/antrian_print.dart';
import 'package:antrian_app/data/models/antrian.dart';
import 'package:antrian_app/pages/antrian_page.dart';
import 'package:audio_plus/audio_plus.dart';
import 'package:flutter/material.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
        backgroundColor: Colors.blue,
        title: const Text('Daftar Antrian', style: TextStyle(color: Colors.white)),
      ),
      body: listAntrian.isEmpty ? const Center(child: Text('Tidak ada data')) : _buildAntrianGrid(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
         await Navigator.push(context, MaterialPageRoute(builder: (context) => const AntrianPage()));
          getAntrian();
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.settings, color: Colors.white),
      ),
    );
  }

  Widget _buildAntrianGrid() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.builder(
          itemCount: listAntrian.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
          itemBuilder: (context, index) {
            var data = listAntrian[index];
            return Padding(
              padding: const EdgeInsets.all(4.0),
              child: InkWell(
                onTap: () async {
                  await AudioPlus.play('assets/audio/pressed.mp3');
                  final noAntrian = data.noAntrian.split('-').last;
                  final newAntrian = data.copyWith(
                    noAntrian: '${data.noAntrian.split('-').first}-${int.parse(noAntrian)+1}',
                  );
                  final printValue = await AntrianPrint.instance.printAntrian(
                    newAntrian,
                  );
                  await PrintBluetoothThermal.writeBytes(printValue);
                  AntrianLocalDatasource.instance.updateAntrian(newAntrian);
                  getAntrian();
                },
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                    // side: const BorderSide(color: Colors.blue),
                  ),
                  color: Colors.white,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(data.nama, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const Text('Nomor Antrian:'),
                      Text(
                        data.noAntrian,
                        style: const TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
    );
  }
}
