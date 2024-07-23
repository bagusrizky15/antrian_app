import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

import '../core/constants/colors.dart';
import 'widgets/menu_printer_button.dart';
import 'widgets/menu_printer_content.dart';

class PrinterPage extends StatefulWidget {
  const PrinterPage({super.key});

  @override
  State<PrinterPage> createState() => _PrinterPageState();
}

class _PrinterPageState extends State<PrinterPage> {
  int selectedIndex = 0;

  String macName = '';
  String? macConnected;

  bool connected = false;
  bool _isLoading = false;
  List<BluetoothInfo> items = [];

  String optionprinttype = "58 mm";
  List<String> options = ["58 mm", "80 mm"];

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    String platformVersion;
    int porcentbatery = 0;

    try {
      platformVersion = await PrintBluetoothThermal.platformVersion;

      porcentbatery = await PrintBluetoothThermal.batteryLevel;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    if (!mounted) return;
  }

  Future<bool> isBluetoothEnabled() async {
      final bool result = await PrintBluetoothThermal.bluetoothEnabled;
      return result;
    }

  Future<void> getBluetooth() async {    
    setState(() {
      items = [];
    });
    var status2 = await Permission.bluetoothScan.status;
    if (status2.isDenied) {
      await Permission.bluetoothScan.request();
    }
    var status = await Permission.bluetoothConnect.status;
    if (status.isDenied) {
      await Permission.bluetoothConnect.request();
    }

    final List<BluetoothInfo> listResult = await PrintBluetoothThermal.pairedBluetooths;

    setState(() {
      items = listResult;
    });
  }

  Future<void> connect(String mac, String macName) async {

    setState(() {
      _isLoading = true;
    });

    disconnect();
    final bool result = await PrintBluetoothThermal.connect(macPrinterAddress: mac);

    setState(() {
      _isLoading = false;
    });

    if (result) {
      connected = true;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Printer connected with $macName'),
          backgroundColor: AppColors.primary,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Printer tidak tersedia'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> disconnect() async {
    await PrintBluetoothThermal.disconnect;
    setState(() {
      connected = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        centerTitle: true,
        title: const Text(
          'Kelola Printer',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          Row(
            children: [
              MenuPrinterButton(
                label: 'Cari printer',
                onPressed: () {
                  isBluetoothEnabled().then((value) {
                    if (value) {
                      getBluetooth();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Bluetooth belum aktif'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  });
                },
                isActive: connected,
              ),
            ],
          ),
          const SizedBox(height: 34.0),
          if (_isLoading) Center(child: const CircularProgressIndicator()),
          if (!_isLoading)
          _Body(
            macName: macName,
            datas: items,
            clickHandler: (mac) async {
              macName = mac;
              await connect(mac, items.firstWhere((element) => element.macAdress == mac).name);
              setState(() {

              });
            },
          ),
        ],
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final String macName;
  final List<BluetoothInfo> datas;

  final Function(String) clickHandler;

  const _Body({
    required this.macName,
    required this.datas,
    required this.clickHandler,
  });

  @override
  Widget build(BuildContext context) {
    if (datas.isEmpty) {
      return const Text('No data available');
    } else {
      return Container(
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.card, width: 2),
          borderRadius: BorderRadius.circular(6),
        ),
        child: ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: datas.length,
          separatorBuilder: (context, index) => const SizedBox(width: 16.0),
          itemBuilder: (context, index) => InkWell(
            onTap: () {
              clickHandler(datas[index].macAdress);
            },
            child: MenuPrinterContent(
              isSelected: macName == datas[index].macAdress,
              data: datas[index],
            ),
          ),
        ),
      );
    }
  }
}
