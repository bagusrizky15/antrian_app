import 'package:antrian_app/data/models/antrian.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';

class AntrianPrint {
  AntrianPrint._init();

  static final AntrianPrint instance = AntrianPrint._init();

  Future<List<int>> printAntrian(
    Antrian antrian,
  ) async {
    List<int> bytes = [];

    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);

    // Load and decode the logo image
    final ByteData data = await rootBundle.load('assets/images/logoblack.jpg');
    final Uint8List bytesData = data.buffer.asUint8List();
    final img.Image? originalImage = img.decodeImage(bytesData);

    if (originalImage != null) {
      final img.Image grayscaleImage = img.grayscale(originalImage);
      final img.Image resizedImage = img.copyResize(grayscaleImage, width: 384);
      bytes += generator.image(resizedImage);
    }

    bytes += generator.reset();

    bytes += generator.text('Kartu Antrian',
        styles: const PosStyles(
          bold: true,
          align: PosAlign.center,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
        ));

    bytes += generator.text('Tanggal : ${DateFormat('dd-MM-yyyy HH:mm').format(DateTime.now())}',
        styles: const PosStyles(bold: false, align: PosAlign.center));

    bytes += generator.feed(1);
    //nama antrian
    bytes += generator.text(antrian.nama,
        styles: const PosStyles(
          bold: false,
          align: PosAlign.center,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
        ));
    bytes += generator.feed(1);
    //no antrian
    bytes += generator.text('No Antrian : ${antrian.noAntrian.split('-').last}',
        styles: const PosStyles(
          bold: true,
          align: PosAlign.center,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
        ));

    bytes += generator.feed(3);

    bytes += generator.text(
      '--------------------------------',
      styles: const PosStyles(align: PosAlign.center),
      linesAfter: 1,
    );

    bytes += generator.feed(2);

    return bytes;
  }
}
