import 'package:test/test.dart';
//import 'dart:html' show HttpRequest;
//import 'dart:io' show HttpRequest;
import 'package:http/http.dart' as http;

void main() {
  test('testing ipfs ', () async {
    // image
    //print(await HttpRequest.getString('https://gateway.ipfs.io/ipfs/QmRAQB6YaCyidP37UdDnjFY5vQuiBrcqdyoW1CuDgwxkD4'));
    // text
    //print(await HttpRequest().getString(
    //    'https://gateway.ipfs.io/ipfs/bafkreievfjy5oqcpwj7464wt6gvkjfbd6jr2w7a6wnhzde2yslrmhfoc4e'));
    expect(
        (await http.get(
                Uri.parse(
                    'https://gateway.ipfs.io/ipfs/bafkreievfjy5oqcpwj7464wt6gvkjfbd6jr2w7a6wnhzde2yslrmhfoc4e'),
                headers: {'accept': 'application/json'}))
            .body
            .endsWith('THE END'),
        true);
    print((await http.get(
            Uri.parse(
                'https://gateway.ipfs.io/ipfs/QmRAQB6YaCyidP37UdDnjFY5vQuiBrcqdyoW1CuDgwxkD4'),
            headers: {'accept': 'application/json'}))
        .bodyBytes);
  });
}
