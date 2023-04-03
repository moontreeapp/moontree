library identicon;

import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart' as material show Color;
import 'package:image/image.dart';
import 'package:client_front/presentation/theme/colors.dart';

Map<String, List<List<int>>> colorCache = <String, List<List<int>>>{};

class Identicon {
  Identicon({
    this.rows = 6,
    this.cols = 6,
    material.Color? foreground,
    material.Color? background,
  })  : digest = md5.convert,
        foregroundColor = foreground != null ? AppColors.rgb(foreground) : null,
        backgroundColor = background != null ? AppColors.rgb(background) : null;
  final int rows;
  final int cols;

  Function(List<int>) digest;

  late List<int>? foregroundColor;
  late List<int>? backgroundColor;

  late String name;
  late String hashedName;

  void _generateColors() {
    backgroundColor =
        backgroundColor ?? AppColors.rgb(AppColors.backgroundColor(name));
    foregroundColor =
        foregroundColor ?? AppColors.rgb(AppColors.foregroundColor(name));
  }

  bool _bitIsOne(int n, List<int> hashBytes) {
    const int scale = 16;
    return hashBytes[n ~/ (scale / 2)] >>
                ((scale / 2) - ((n % (scale / 2)) + 1)).toInt() &
            1 ==
        1;
  }

  List<int> _createImage(
      List<List<bool>> matrix, int width, int height, int pad) {
    final Image image = Image.rgb(width + (pad * 2), height + (pad * 2));
    image.fill(Color.fromRgb(
      backgroundColor![0],
      backgroundColor![1],
      backgroundColor![2],
    ));

    final int blockWidth = width ~/ cols;
    final int blockHeight = height ~/ rows;

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
    final int cells = (rows * cols / 2 + cols % 2).toInt();
    final List<List<bool>> matrix = List<List<bool>>.generate(
        rows, (_) => List<bool>.generate(cols, (_) => false));

    for (int n = 0; n < cells; n++) {
      if (_bitIsOne(n, byteList.getRange(1, byteList.length).toList())) {
        final int r = n % rows;
        final int c = n ~/ cols;
        matrix[r][cols - c - 1] = true;
        matrix[r][c] = true;
      }
    }
    return matrix;
  }

  String baseName() => name.startsWith('#') || name.startsWith('\$')
      ? name.substring(1, name.length)
      : name.endsWith('!')
          ? name.substring(0, name.length - 1)
          : name;

  // same between main asset and admin asset
  String commonName() =>
      name.endsWith('!') ? name.substring(0, name.length - 1) : name;

  ImageDetails generate(String text) {
    name = text;
    name = commonName();
    hashedName = digest(utf8.encode(name)).toString();
    _generateColors();
    const int bytesLength = 16;
    final List<int> hexDigestByteList =
        List<int>.generate(bytesLength, (int i) {
      return int.parse(hashedName.substring(i * 2, i * 2 + 2),
          radix: bytesLength);
    });
    final List<List<bool>> matrix = _createMatrix(hexDigestByteList);
    final int size = rows * cols;

    return ImageDetails(
        image: Uint8List.fromList(
            _createImage(matrix, size, size, (size * 0.1).toInt())),
        foreground: foregroundColor!,
        background: backgroundColor!);
  }
}

class ImageDetails {
  ImageDetails({
    required this.image,
    required this.foreground,
    required this.background,
  });
  Uint8List image;
  List<int> foreground;
  List<int> background;
}
