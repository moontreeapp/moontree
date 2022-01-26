library identicon;

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:image/image.dart';

var colorCache = Map<String, List<List<int>>>();

class Identicon {
  final int rows;
  final int cols;

  Function(List<int>) digest;

  late List<int>? foregroundColor;
  late List<int>? backgroundColor;

  late String name;
  late String hashedName;

  Identicon({
    this.rows = 6,
    this.cols = 6,
  }) : this.digest = md5.convert;

  void _generateColors() {
    var lightenPercent = _getShade();
    if (name.startsWith('MOONTREE') || name.startsWith('MT/')) {
      foregroundColor = _getGreenColorShade(lightenPercent);
      backgroundColor = _getWhiteColorShade(lightenPercent);
    } else {
      foregroundColor = _getOrangeColorShade(lightenPercent);
      backgroundColor = _getBlueColorShade(lightenPercent);
    }
  }

  List<int> _getPastelColor({int lighten = 127}) {
    var r = () => Random().nextInt(128) + lighten;
    return [r(), r(), r()];
  }

  List<int> _getBlueColorShade(double lightenPercent) {
    return [
      (92 - 46) + (lightenPercent * (255 - (92 - 46))).toInt(),
      (107 - 46) + (lightenPercent * (255 - (107 - 46))).toInt(),
      (192 - 46) + (lightenPercent * (255 - (192 - 46))).toInt(),
    ];
  }

  List<int> _getOrangeColorShade(double lightenPercent) {
    return [
      245 + (lightenPercent * (255 - 245)).toInt(),
      125 + (lightenPercent * (255 - 125)).toInt(),
      0 + (lightenPercent * (255 - 0)).toInt(),
    ];
  }

  List<int> _getGreenColorShade(double lightenPercent) {
    return [
      120 + (lightenPercent * (255 - 120)).toInt(),
      215 + (lightenPercent * (255 - 215)).toInt(),
      0 + (lightenPercent * (255 - 0)).toInt(),
    ];
  }

  List<int> _getWhiteColorShade(double lightenPercent) {
    if (lightenPercent >= .333) {
      return [33, 33, 33];
    } else {
      return [255, 255, 255];
    }
  }

  double _getShade() {
    var lighten = int.parse(hashedName.substring(0, 2), radix: 16) / 1.5;
    return lighten / 255;
  }

  bool _bitIsOne(int n, List<int> hashBytes) {
    var scale = 16;
    return hashBytes[n ~/ (scale / 2)] >>
                ((scale / 2) - ((n % (scale / 2)) + 1)).toInt() &
            1 ==
        1;
  }

  List<int> _createImage(
      List<List<bool>> matrix, int width, int height, int pad) {
    var image = Image.rgb(width + (pad * 2), height + (pad * 2));
    image.fill(Color.fromRgb(
      backgroundColor![0],
      backgroundColor![1],
      backgroundColor![2],
    ));

    var blockWidth = width ~/ cols;
    var blockHeight = height ~/ rows;

    for (int r = 0; r < matrix.length; r++) {
      for (int c = 0; c < matrix[r].length; c++) {
        if (matrix[r][c]) {
          fillRect(
            image,
            pad + c * blockWidth,
            pad + r * blockHeight,
            pad + (c + 1) * blockWidth - 1,
            pad + (r + 1) * blockHeight - 1,
            Color.fromRgb(
              foregroundColor![0],
              foregroundColor![1],
              foregroundColor![2],
            ),
          );
        }
      }
    }
    return writePng(image);
  }

  List<List<bool>> _createMatrix(List<int> byteList) {
    var cells = (rows * cols / 2 + cols % 2).toInt();
    var matrix = List.generate(rows, (_) => List.generate(cols, (_) => false));

    for (int n = 0; n < cells; n++) {
      if (_bitIsOne(n, byteList.getRange(1, byteList.length).toList())) {
        var r = n % rows;
        var c = n ~/ cols;
        matrix[r][cols - c - 1] = true;
        matrix[r][c] = true;
      }
    }
    return matrix;
  }

  Uint8List generate(String text) {
    name = text;
    var size = rows * cols;
    var bytesLength = 16;
    var hexDigest = digest(utf8.encode(name)).toString();
    hashedName = hexDigest;
    var hexDigestByteList = List<int>.generate(bytesLength, (int i) {
      return int.parse(hexDigest.substring(i * 2, i * 2 + 2),
          radix: bytesLength);
    });
    _generateColors();
    var matrix = _createMatrix(hexDigestByteList);
    return Uint8List.fromList(
        _createImage(matrix, size, size, (size * 0.1).toInt()));
  }
}
