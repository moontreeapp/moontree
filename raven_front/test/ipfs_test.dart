import 'package:flutter_test/flutter_test.dart';
//import 'package:test/test.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html';

void main() {
  test('testing ipfs ', () async {
    // image
    //print(await HttpRequest.getString('https://gateway.ipfs.io/ipfs/QmRAQB6YaCyidP37UdDnjFY5vQuiBrcqdyoW1CuDgwxkD4'));
    // text
    print(await HttpRequest.getString(
        'https://gateway.ipfs.io/ipfs/bafkreievfjy5oqcpwj7464wt6gvkjfbd6jr2w7a6wnhzde2yslrmhfoc4e'));
  });
  test('testing ipfs ', () {
    //Ipfs ipfs = Ipfs();
//
    //// This method will return a list of peers in the swarm
    //ipfs.getPeers();
//
    //// The cid or content identifier has to be of type string
    //String cid = 'bafybeifx7yeb55armcsxwwitkymga5xf53dxiarykms3ygqic223w5sk3m';
//
    //// Fetches an ipfs object
    //ipfs.getObject(cid);
//
    //// Traverses through a DAG given its root cid
    //ipfs.resolveDag(cid);
  });
}
