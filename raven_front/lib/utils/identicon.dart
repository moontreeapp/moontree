library identicon;

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:image/image.dart';

var colourCache = Map<String, List<List<int>>>();

class Identicon {
  int rows;
  int cols;

  Function(List<int>) digest;

  List<int>? foregroundColor;
  List<int>? backgroundColor;

  Identicon({
    this.rows = 6,
    this.cols = 6,
    this.foregroundColor,
    this.backgroundColor,
  }) : this.digest = md5.convert;

  _generateColours(String cacheKey) {
    var coloursOk = false;

    if (colourCache.containsKey(cacheKey)) {
      this.foregroundColor = colourCache[cacheKey]![0];
      this.backgroundColor = colourCache[cacheKey]![1];
    } else {
      while (!coloursOk) {
        this.foregroundColor = this._getPastelColour();
        if (this.backgroundColor == null) {
          this.backgroundColor = this._getPastelColour(lighten: 80);

          var fgLum = this._luminance(this.foregroundColor) + 0.05;
          var bgLum = this._luminance(this.backgroundColor) + 0.05;
          if (fgLum / bgLum > 1.20) {
            coloursOk = true;
          }
        } else {
          coloursOk = true;
        }
      }
      colourCache[cacheKey] = [this.foregroundColor!, this.backgroundColor!];
    }
  }

  _getPastelColour({int lighten = 127}) {
    var r = () => Random().nextInt(128) + lighten;
    return [r(), r(), r()];
  }

  _luminance(rgb) {
    var a = [];
    for (var v in rgb) {
      v = v / 255.0;
      var result = (v < 0.03928) ? v / 12.92 : pow(((v + 0.055) / 1.055), 2.4);
      a.add(result);
    }

    return a[0] * 0.2126 + a[1] * 0.7152 + a[2] * 0.0722;
  }

  _bitIsOne(int n, List<int> hashBytes) {
    var scale = 16;
    return hashBytes[n ~/ (scale / 2)] >>
                ((scale / 2) - ((n % (scale / 2)) + 1)).toInt() &
            1 ==
        1;
  }

  _createImage(List<List<bool>> matrix, int width, int height, int pad) {
    var image = Image.rgb(width + (pad * 2), height + (pad * 2));
    image.fill(Color.fromRgb(this.backgroundColor![0], this.backgroundColor![1],
        this.backgroundColor![2]));

    var blockWidth = width ~/ this.cols;
    var blockHeight = height ~/ this.rows;

    for (int row = 0; row < matrix.length; row++) {
      for (int col = 0; col < matrix[row].length; col++) {
        if (matrix[row][col]) {
          fillRect(
            image,
            pad + col * blockWidth,
            pad + row * blockHeight,
            pad + (col + 1) * blockWidth - 1,
            pad + (row + 1) * blockHeight - 1,
            Color.fromRgb(this.foregroundColor![0], this.foregroundColor![1],
                this.foregroundColor![2]),
          );
        }
      }
    }
    return writePng(image);
  }

  _createMatrix(List<int> byteList) {
    var cells = (this.rows * this.cols / 2 + this.cols % 2).toInt();
    var matrix =
        List.generate(this.rows, (_) => List.generate(this.cols, (_) => false));

    for (int n = 0; n < cells; n++) {
      if (this._bitIsOne(n, byteList.getRange(1, byteList.length).toList())) {
        var row = n % this.rows;
        var col = n ~/ this.cols;
        matrix[row][this.cols - col - 1] = true;
        matrix[row][col] = true;
      }
    }
    return matrix;
  }

  Uint8List generate(String text, {int size = 36}) {
    var bytesLength = 16;
    var hexDigest = this.digest(utf8.encode(text)).toString();

    var hexDigestByteList = List<int>.generate(bytesLength, (int i) {
      return int.parse(hexDigest.substring(i * 2, i * 2 + 2),
          radix: bytesLength);
    });

    this._generateColours(hexDigest);

    var matrix = this._createMatrix(hexDigestByteList);
    return this._createImage(matrix, size, size, (size * 0.1).toInt());
  }
}
