import 'dart:typed_data';
import 'package:convert/convert.dart';

import 'package:bip32/src/utils/ecurve.dart' show isPoint;
import 'package:bs58check/bs58check.dart' as bs58check;

import '../crypto.dart';
import '../models/networks.dart';
import '../payments/index.dart' show PaymentData;
import '../utils/script.dart' as bscript;
import '../utils/constants/op.dart';

class P2PKH {
  late PaymentData data;
  late NetworkType network;
  P2PKH({required data, this.network = mainnet}) {
    this.data = data;
    _init();
  }
  _init() {
    if (data.address != null) {
      _getDataFromAddress(data.address!);
      _getDataFromHash();
    } else if (data.memo != null) {
      _getDataFromMemo(data.memo!);
      _getDataFromHashMemo();
    } else if (data.hash != null) {
      _getDataFromHash();
    } else if (data.output != null) {
      if (!isValidOutput(data.output!))
        throw new ArgumentError('Output is invalid');
      data.hash = data.output!.sublist(3, 23);
      _getDataFromHash();
    } else if (data.pubkey != null) {
      data.hash = hash160(data.pubkey!);
      _getDataFromHash();
      _getDataFromChunk();
    } else if (data.input != null) {
      List<dynamic> _chunks = bscript.decompile(data.input)!;
      _getDataFromChunk(_chunks);
      if (_chunks.length != 2) throw new ArgumentError('Input is invalid');
      if (!bscript.isCanonicalScriptSignature(_chunks[0]))
        throw new ArgumentError('Input has invalid signature');
      if (!isPoint(_chunks[1]))
        throw new ArgumentError('Input has invalid pubkey');
    } else {
      throw new ArgumentError('Not enough data');
    }
  }

  void _getDataFromChunk([List<dynamic>? _chunks]) {
    if (data.pubkey == null && _chunks != null) {
      data.pubkey = (_chunks[1] is int)
          ? new Uint8List.fromList([_chunks[1]])
          : _chunks[1];
      data.hash = hash160(data.pubkey!);
      _getDataFromHash();
    }
    if (data.signature == null && _chunks != null)
      data.signature = (_chunks[0] is int)
          ? new Uint8List.fromList([_chunks[0]])
          : _chunks[0];
    if (data.input == null && data.pubkey != null && data.signature != null) {
      data.input = bscript.compile([data.signature, data.pubkey]);
    }
  }

  void _getDataFromHash() {
    if (data.address == null) {
      print('in first if ${data.address}');
      final payload = new Uint8List(21);
      payload.buffer.asByteData().setUint8(0, network.pubKeyHash);
      payload.setRange(1, payload.length, data.hash!);
      data.address = bs58check.encode(payload);
    }
    //Uint8List decode(String encoded) => Uint8List.fromList(hex.decode(encoded));
    if (data.output == null) {
      print('in second if ${data.output}');
      data.output = bscript.compile([
        OPS['OP_DUP'],
        OPS['OP_HASH160'],
        data.hash,
        OPS['OP_EQUALVERIFY'],
        OPS['OP_CHECKSIG'],

        /// is this how we add a memo?
        //OPS['OP_RETURN'],
        //////Uint8List.fromList([0, 1, 2, 3, 4, 5, 6, 7]) // in theory data.memo
        //////Uint8List.fromList(hex.decode('testMemo'))
        //////'testMemo'
        //////Uint8List.fromList([74,65,73,74,4d,65,6d,6f])
        ////Uint8List.fromList([116, 101, 115, 116, 77, 101, 109, 111])
        //////mxQtbqouKFcFK7Tf98PVnmig1jgJ8LB38Q
      ]);
    }
    print('final ${data}');
  }
/* on send with the op return and memo specified - also fails on merely op return

op return and Uint8List.fromList([116, 101, 115, 116, 77, 101, 109, 111]):
final PaymentData{address: muby9GjSWZjn6TWoSdMSwgEjvfzixrkA5Y, hash: [154, 132, 140, 148, 219, 149, 147, 47, 90, 108, 217, 85, 54, 189, 1, 250, 21, 96, 166, 174], output: [118, 169, 20, 154, 132, 140, 148, 219, 149, 147, 47, 90, 108, 217, 85, 54, 189, 1, 250, 21, 96, 166, 174, 136, 172, 106, 8, 116, 101, 115, 116, 77, 101, 109, 111], signature: [48, 68, 2, 32, 4, 147, 180, 17, 60, 208, 201, 69, 114, 253, 141, 158, 248, 106, 242, 227, 64, 255, 23, 217, 121, 146, 37, 233, 144, 118, 76, 181, 148, 47, 83, 107, 2, 32, 2, 202, 189, 135, 101, 68, 61, 234, 224, 70, 211, 156, 120, 180, 221, 
230, 246, 230, 94, 134, 90, 223, 48, 227, 57, 211, 213, 188, 26, 128, 58, 68, 1], pubkey: [3, 175, 57, 231, 103, 11, 163, 71, 174, 40, 161, 84, 49, 211, 166, 185, 25, 96, 107, 32, 92, 51, 183, 128, 186, 33, 255, 245, 135, 228, 193, 93, 50], input: null, witness: null}

E/flutter ( 6815): [ERROR:flutter/lib/ui/ui_dart_state.cc(209)] Unhandled Exception: JSON-RPC error 1: the transaction was rejected by network rules.
E/flutter ( 6815): 
E/flutter ( 6815): 16: mandatory-script-verify-flag-failed (Signature must be zero for failed CHECK(MULTI)SIG operation)
E/flutter ( 6815): [01000000012a87a6cdaeb894a29d2f26f39f3a2202cb5a24b9bcaae317dd2ee026fd13a902000000006a47304402200493b4113cd0c94572fd8d9ef86af2e340ff17d9799225e990764cb5942f536b022002cabd8765443deae046d39c78b4dde6f6e65e865adf30e339d3d5bc1a803a44012103af39e7670ba347ae28a15431d3a6b919606b205c33b780ba21fff587e4c15d32ffffffff01ec88a2df8b0400002376a914b9548f3de0c477738bce40bb042a833cb419d71888ac6a08746573744d656d6f00000000]
E/flutter ( 6815): package:json_rpc_2/src/client.dart 121:62                              Client.sendRequest
E/flutter ( 6815): package:json_rpc_2/src/peer.dart 98:15                                 Peer.sendRequest
E/flutter ( 6815): package:raven_electrum_client/client/base_client.dart 52:23            BaseClient.request
E/flutter ( 6815): package:raven_electrum_client/methods/transaction/broadcast.dart 4:68  BroadcastTransactionMethod.broadcastTransaction
E/flutter ( 6815): package:raven/services/client.dart 92:36                               ClientService.sendTransaction
E/flutter ( 6815): package:raven_mobile/pages/transaction/send.dart 612:40                _SendState.attemptSend
E/flutter ( 6815): package:raven_mobile/pages/transaction/send.dart 575:54                _SendState.confirmMessage.<fn>.<fn>
E/flutter ( 6815): package:raven_mobile/pages/transaction/send.dart 575:36                _SendState.confirmMessage.<fn>.<fn>
E/flutter ( 6815): package:flutter/src/material/ink_well.dart 989:21                      _InkResponseState._handleTap
E/flutter ( 6815): package:flutter/src/gestures/recognizer.dart 198:24                    GestureRecognizer.invokeCallback
E/flutter ( 6815): package:flutter/src/gestures/tap.dart 608:11                           TapGestureRecognizer.handleTapUp
E/flutter ( 6815): package:flutter/src/gestures/tap.dart 296:5                            BaseTapGestureRecognizer._checkUp
E/flutter ( 6815): package:flutter/src/gestures/tap.dart 230:7                            BaseTapGestureRecognizer.handlePrimaryPointer
E/flutter ( 6815): package:flutter/src/gestures/recognizer.dart 563:9                     PrimaryPointerGestureRecognizer.handleEvent
E/flutter ( 6815): package:flutter/src/gestures/pointer_router.dart 94:12                 PointerRouter._dispatch
E/flutter ( 6815): package:flutter/src/gestures/pointer_router.dart 139:9                 PointerRouter._dispatchEventToRoutes.<fn>
E/flutter ( 6815): dart:collection-patch/compact_hash.dart 525:8                          _LinkedHashMapMixin.forEach
E/flutter ( 6815): package:flutter/src/gestures/pointer_router.dart 137:18                PointerRouter._dispatchEventToRoutes
E/flutter ( 6815): package:flutter/src/gestures/pointer_router.dart 123:7                 PointerRouter.route
E/flutter ( 6815): package:flutter/src/gestures/binding.dart 440:19                       GestureBinding.handleEvent
E/flutter ( 6815): package:flutter/src/gestures/binding.dart 420:22                       GestureBinding.dispatchEvent
E/flutter ( 6815): package:flutter/src/rendering/binding.dart 278:11                      RendererBinding.dispatchEvent
E/flutter ( 6815): package:flutter/src/gestures/binding.dart 374:7                        GestureBinding._handlePointerEventImmediately
E/flutter ( 6815): package:flutter/src/gestures/binding.dart 338:5                        GestureBinding.handlePointerEvent
E/flutter ( 6815): package:flutter/src/gestures/binding.dart 296:7                        GestureBinding._flushPointerEventQueue
E/flutter ( 6815): package:flutter/src/gestures/binding.dart 279:7                        GestureBinding._handlePointerDataPacket
E/flutter ( 6815): dart:async/zone.dart 1444:13                                           _rootRunUnary
E/flutter ( 6815): dart:async/zone.dart 1335:19                                           _CustomZone.runUnary
E/flutter ( 6815): dart:async/zone.dart 1244:7                                            _CustomZone.runUnaryGuarded
E/flutter ( 6815): dart:ui/hooks.dart 169:10                                              _invoke1
E/flutter ( 6815): dart:ui/platform_dispatcher.dart 293:7                                 PlatformDispatcher._dispatchPointerDataPacket
E/flutter ( 6815): dart:ui/hooks.dart 88:31                                               _dispatchPointerDataPacket
E/flutter ( 6815):

just op return 
I/flutter ( 6815): final PaymentData{address: muby9GjSWZjn6TWoSdMSwgEjvfzixrkA5Y, hash: [154, 132, 140, 148, 219, 149, 147, 47, 90, 108, 217, 85, 54, 189, 1, 250, 21, 96, 166, 174], output: [118, 169, 20, 154, 132, 140, 148, 219, 149, 147, 47, 90, 108, 217, 85, 54, 189, 1, 250, 21, 96, 166, 174, 136, 172, 106], signature: [48, 69, 2, 33, 0, 176, 213, 142, 168, 189, 28, 250, 140, 227, 126, 153, 59, 63, 251, 7, 185, 219, 244, 38, 50, 75, 115, 215, 158, 9, 165, 175, 1, 68, 239, 173, 46, 2, 32, 67, 118, 25, 17, 99, 234, 199, 68, 14, 57, 202, 158, 64, 27, 52, 130, 161, 74, 217, 217, 111, 198, 241, 152, 187, 199, 88, 152, 91, 80, 104, 243, 1], pubkey: [3, 175, 57, 231, 103, 11, 163, 71, 174, 40, 161, 84, 49, 211, 166, 185, 25, 96, 107, 32, 92, 51, 183, 128, 186, 33, 255, 245, 135, 228, 193, 93, 50], input: null, witness: null}
*/

  void _getDataFromHashMemo() {
    if (data.memo == null) {
      print('in first if MEMO ${data.memo}');
      final payload = new Uint8List(40);
      payload.buffer.asByteData().setUint8(0, network.pubKeyHash);
      payload.setRange(1, payload.length, data.hash!);
      data.memo = bs58check.encode(payload);
    }
    //Uint8List decode(String encoded) => Uint8List.fromList(hex.decode(encoded));
    if (data.output == null) {
      print('in second if MEMO ${data.output}');
      data.output = bscript.compile([
        OPS['OP_RETURN'],
        data.hash,
      ]);
    }
    print('final MEMO ${data}');
  }

  void _getDataFromAddress(String address) {
    Uint8List payload = bs58check.decode(address);
    final version = payload.buffer.asByteData().getUint8(0);
    if (version != network.pubKeyHash)
      throw new ArgumentError('Invalid version or Network mismatch');
    data.hash = payload.sublist(1);
    if (data.hash!.length != 20) throw new ArgumentError('Invalid address');
  }

  void _getDataFromMemo(String memo) {
    Uint8List payload = bs58check.decode(memo);
    final version = payload.buffer.asByteData().getUint8(0);
    if (version != network.pubKeyHash)
      throw new ArgumentError('Invalid version or Network mismatch');
    data.hash = payload.sublist(1);
    // ?? if (data.hash!.length != 20) throw new ArgumentError('Invalid address');
    assert(memo.length <= 80);
  }
}

isValidOutput(Uint8List data) {
  return data.length == 25 &&
      data[0] == OPS['OP_DUP'] &&
      data[1] == OPS['OP_HASH160'] &&
      data[2] == 0x14 &&
      data[23] == OPS['OP_EQUALVERIFY'] &&
      data[24] == OPS['OP_CHECKSIG'];
}

// Backward compatibility
@Deprecated(
    "The 'P2PKHData' class is deprecated. Use the 'PaymentData' package instead.")
class P2PKHData extends PaymentData {
  P2PKHData({address, hash, output, pubkey, input, signature, witness})
      : super(
            address: address,
            hash: hash,
            output: output,
            pubkey: pubkey,
            input: input,
            signature: signature,
            witness: witness);
}
