import 'dart:core';
import 'dart:typed_data';
import 'dart:convert';
import 'utils/script.dart' as bscript;
import 'utils/constants/op.dart';

const List<int> RVN_rvn = [ 0x72, 0x76, 0x6e ];
const List<int> RVN_t = [ 0x74 ]; 

bool is_asset_name_good(String asset_name) {
    return true;
}

Uint8List generate_asset_transfer_script(Uint8List standard_script, String asset_name, int amount, Uint8List? ipfs_data) {
    // ORIGINAL | OP_RVN_ASSET | OP_PUSH  ( b'rvnt' | var_int (asset_name) | sats | ipfs_data? ) | OP_DROP
    if (!is_asset_name_good(asset_name)) {
        throw new ArgumentError('Invalid asset name');
    }
    if (amount < 0 || amount > 21000000000) {
        throw new ArgumentError('Invalid asset amount');
    }
    if (ipfs_data?.length != null && ipfs_data?.length != 34) {
        throw new ArgumentError('Invalid IPFS data');
    }
    final amount_data = ByteData(8);
    amount_data.setUint64(0, amount, Endian.little);

    final internal_builder = new BytesBuilder();
    internal_builder.add(RVN_rvn);
    internal_builder.add(RVN_t);
    internal_builder.addByte(asset_name.length);
    internal_builder.add(utf8.encode(asset_name));
    internal_builder.add(amount_data.buffer.asUint8List());
    if (ipfs_data != null) {
        internal_builder.add(ipfs_data);
    }

    // OP_PUSH  ( b'rvnt' | var_int (asset_name) | sats | ipfs_data? )
    final internal_script = bscript.compile([internal_builder.takeBytes()]);
    
    internal_builder.add(standard_script);
    internal_builder.addByte(OPS['OP_RVN_ASSET']!);
    internal_builder.add(internal_script!);
    internal_builder.addByte(OPS['OP_DROP']!);

    final complete_script = internal_builder.toBytes();
    return bscript.compile([complete_script])!;
}