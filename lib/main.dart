import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

void main() => runApp(const MarsheePetTech());

class MarsheePetTech extends StatelessWidget {
  const MarsheePetTech({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: BeaconScannerScreen(),
    );
  }
}

class BeaconScannerScreen extends StatefulWidget {
  const BeaconScannerScreen({super.key});

  @override
  _BeaconScannerScreenState createState() => _BeaconScannerScreenState();
}

class _BeaconScannerScreenState extends State<BeaconScannerScreen> {
  FlutterBluePlus flutterBlue = FlutterBluePlus();
  List<BluetoothDevice> devicesList = [];
  @override
  void initState() {
    super.initState();
    _checkBluetoothStatus();
    startScanning();
  }

  void _checkBluetoothStatus() async {
    final isAvailable = await FlutterBluePlus.isAvailable;
    final isOn = await FlutterBluePlus.isOn;

    if (!isAvailable) {
      _showBluetoothErrorDialog('Bluetooth is not supported on this device.');
      return;
    }

    if (!isOn) {
      _promptEnableBluetooth();
    } else {}
  }

  void _promptEnableBluetooth() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enable Bluetooth'),
          content: const Text('Please turn on Bluetooth to use this feature.'),
          actions: [
            TextButton(
              child: const Text('Settings'),
              onPressed: () async => await AppSettings.openAppSettings(
                  type: AppSettingsType.bluetooth),
            ),
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showBluetoothErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void startScanning() {
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));
    FlutterBluePlus.scanResults.listen((results) {
      for (ScanResult r in results) {
        setState(() {
          if (!devicesList.contains(r.device)) {
            devicesList.add(r.device);
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Marshee Pet Tech Task'),
      ),
      body: ListView.builder(
        itemCount: devicesList.length,
        itemBuilder: (context, index) {
          BluetoothDevice device = devicesList[index];
          return ListTile(
            title: Text(device.name.isEmpty ? 'Unknown Device' : device.name),
            subtitle: Text(device.id.toString()),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: startScanning,
        child: const Icon(Icons.bluetooth),
      ),
    );
  }
}
