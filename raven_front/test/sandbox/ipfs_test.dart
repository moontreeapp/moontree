import 'package:flutter_test/flutter_test.dart';
//import 'package:test/test.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html';

void main() {
  test('testing ipfs ', () async {
    // image
    //print(await HttpRequest.getString(
    //    'https://gateway.ipfs.io/ipfs/QmRAQB6YaCyidP37UdDnjFY5vQuiBrcqdyoW1CuDgwxkD4'));
    // text
    print(await HttpRequest.getString(
        'https://gateway.ipfs.io/ipfs/bafkreievfjy5oqcpwj7464wt6gvkjfbd6jr2w7a6wnhzde2yslrmhfoc4e'));
  });
}
