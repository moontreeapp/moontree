import 'package:raven/utils/exceptions.dart';
import 'package:raven/raven.dart';
import 'package:raven/utils/parse.dart';
import 'package:raven_electrum_client/methods/transaction/get.dart';

class VoutService {
  Vout? getVoutFrom({Vout? vout, String? hash}) {
    vout ??
        hash ??
        (() => throw OneOfMultipleMissing(
            'vout or hash required to identify record.'))();
    return vout ?? vouts.primaryIndex.getOne(hash ?? '');
  }

  // setter for note value on Vout record in reservoir
  Future<bool> saveNote(String note, {Vout? vout, String? hash}) async {
    vout = getVoutFrom(vout: vout, hash: hash);
    if (vout != null) {
      /// Here we should save a transaction and a vout?
      await vouts.save(Vout(
          addressId: vout.addressId,
          height: vout.height,
          txId: vout.txId,
          position: vout.position,
          value: vout.value,
          security: vout.security,
          note: vout.note));
      return true;
    }
    return false;
  }

  Future<String> getMemo(String txHash) async {
    return parseTxForMemo(
        await (await services.client.clientOrNull)!.getTransaction(txHash));
  }

  Future<String> saveMemo(String memo, {Vout? vout, String? hash}) async {
    vout = getVoutFrom(vout: vout, hash: hash);
    if (vout != null) {
      /// Here we should save a transaction and a vout?
      await vouts.save(Vout(
          addressId: vout.addressId,
          height: vout.height,
          txId: vout.txId,
          position: vout.position,
          value: vout.value,
          security: vout.security,
          note: vout.note,
          memo: memo));
    }
    return memo;
  }

  Future<String> getSaveMemo({Vout? vout, String? hash}) async {
    vout = getVoutFrom(vout: vout, hash: hash);
    if (vout != null) {
      return await saveMemo(await getMemo(vout.txId), hash: vout.txId);
    }
    return '';
  }
}
