// dart test test/sandbox/encrypt.dart
import 'dart:typed_data';

import 'package:ravencoin_back/security/cipher_aes.dart';
import 'package:test/test.dart';
import 'package:convert/convert.dart';
import 'package:ravencoin_back/utilities/hex.dart' as hexx;

void main() {
  test('string to hexString', () {
    var hexString = hex.encode('{"accounts": {"a":"b"}}'.codeUnits);
    print(hexString);
    expect(hexString, '7b226163636f756e7473223a207b2261223a2262227d7d');
  });
  test('decrypt string', () {
    var string =
        'c845a5a98c85df51f18976cac800347ed5da458fb6a630b4ce0115fde5a804bccaf9aefe9aa5cf855502589208a2ef48efcddc10cc6980b2861f7e643d15190a002de4b2466926a85bfa752f786c6462e26333f9f2b725b842b7289f31b8ed58e2644c5554bc84652bff4ce89c79823c0b2988874268ab9eb4d28867c8d7371e9332cee89e8d8516959ecfe92f9b0955b72036d558098286abd33eaca509ad0f7e37e67857bb6e0f0303d258671ccaa51e726d868dbd9875b967faaf1159c332cedc5ac97425184bec0cb419d19dd63d9ad94c2aa9599a8aaa3b52becbac64e8b4914221cc9a3af33a41813be82ccea3d0cf92a223b16405291ae41d1bce37808a8bd1b20799aa01f4d90541d886a131217e29dc248affaf985823b69f202dad32ddbff8b83584e3be46834d8f0a3ad2252acd658174502fd4c7a10a4e5bd270f4ad9ff2de747c0d9b9dd801436fa534f116123996e2a850536abd6da4fa5888bcdb4e0342f16896c18f9b233c18bdb8c3158cda1094eb1ea5f432a9fb557ae73e17c4c4d7da3c8a23b83072eae29412ac917db47983e3626c9b57eb8df328a2b6984bb51cb2c379569658a5563e8d9d50122b42245b3435b8ba05be1c855e84ef589e32a9d6a55e2e65fdc6c3ef1826da346881bb3d181821b77177a7393504d286d18451f0db30c1332a1cf7b898ebb06ac07acd06b783094f71f6d462ca0c077aa152b1dc0737fa24689b4b5f393f578897ebeab6e409c71c70f077c979f30a5a577bc1b0d9d87ba7c7d8bc5d7c54b9a6ff1b3aa6fdec75f9c13cb7320b283636f11ec8582ebcefb91bb24f38a7497493d7a1b71a8e0d5eb6de78055a6ae1094e04203b3fb948bfcc9f10d7d20c73b7198319ddfb32b67b10f020a2d2fbcb4cbeddc3afa2bb0ef146ef54f73ed219cfd733d8442a12a528d148517a25c635a6e45fcf570fafb0e282562ad2ee34aad6ee361f077967d120a472bc4fca90944f8dbb072a0f2667d493efcd80f9b5b6e7388bbea7f981ce04beb449ff2b256068b63140e34bab9ffecb22aee68d646c7bed655318a044f8db1466e4504f0f79b4d2cd45db374cf752ae7f11a746963369aaa50460f301b3e49cb674dcf45f900f504d7eb72b702f0531462e12bf1775e7151a40eba2b6ee7ac56fbfb109c15d8e64f2378150bd1b3ca06fb07eacaa4bb896e03108bb3f3759e13cc23c318c620ca636da4ff2ccee23a6dd3148e20d6a132fa65ba6cd9846aa9a294f55e7cdfd30520ac7923a613cd15f1f5563f987299b8045b0d8c4f853615a5adbefc93ee09701f462ec551af01285d82d4c3a70cfc53f31735532ffba32f9ae8242bf858b03795f6f686e610be0a68aabab1feb10e016738cda650e473a48c4c0a46ffc189535d89cfd9c051079eeda1e7825cff782433f0bd9e39531ab9915517be45070f5f9c46fd3a3dc263eb00e427b86d7da5ba904b67694318e28045296dad9b42438d1142f58a522c9c396ac125091f72c2e863c5df1322956c0f700187fa5b6dca4be39aeebafad96e6d30c50b34a6eddb83e82552ad5911667e9d245b0d3987fbf954ac97b56acdc6b798a8ad0d33429dee316128110181c9343ad44f8d9cf8e528664f7b145c595abda521d1ecf5df9541ef83847f86ba7c3a594ab93c28b89c00126acca4715504c17cb32af6a676d41f1c1fe6c402fda3f9fed8834ac534d0ce5e019fdb8d1cd84ac0f6a4d448f96d381275cacbf9349762a2c40b6fe6fee4804098504ebcda089fbe14370995de2314a9015d9b3bb2544cffc3f734243f157a5f7516b915613150959eff96841ad0c8743b52105baf69a9978ebc5e768ce3e9a4160aa348989a90264424959c447cdb8fcbf7385d63be5d6d654bfaa51ca00b1180c87eb6a15ee5607146330f841d189ff8dd96dc128b2a348c35f00f064fcc7c8df78427f2ccf33e92e93908ea684319e3734720ca3a9a21b671fd487b3bfc58153b04192f9eb166ade722c1f0f493f44e43d4aaf9fa628aa5abce00b85477123937029966f3daf967041faa0aa2b019f8936964850ef5471730cf366ef3fb90eba1509ec8108ed1d05ad991800fa6452fa5515c9d5c8027865eb4212eb24daec88ba402dac11663fdea0f0863b6275500c833f5a82a393d44b703de1c79c46edd6674f7014dc534103c43a1ab8292a39a55f68b3eedd8ef9f869e053bbef4f484261385faa3a25f5a23194c2654a858fed854e915356c0a3e29a57acea944036eb2a9114c10ec38a8b645b7126b030c57efc5aa2363f8b0ea80a29074682929a6ef4f6c7c49f90173fa1b9ad1f8f929b650cfd7d1a5f075682017486b569b19a16ffba654f22840fa8b6ba54fcbe7a2fc9e09c06cacac60401d31510bb1588cbe457e3c25b2fc365d9a90fa35099cc4b80d36936007bf5d05fb9dbb65e4d117f6a939e3ab0d13086966cd3c5f6c422cc21cfc817477b3d655f01283b8fe133a6b49c84b23952d2e8913eafde24';
    var cipher = CipherAES(Uint8List.fromList('asdfasdfasdf1'.codeUnits));
    var decryptedHex = hexx.decrypt(string, cipher);
    expect(decryptedHex,
        '7b226163636f756e7473223a7b2230223a7b226e616d65223a225072696d617279222c226e6574223a224e65742e54657374227d7d2c2277616c6c657473223a7b22303263353866353739663166613232663264353937326264653430366231343133376335653232336230656239653466313331373230363535336531633663316161223a7b226163636f756e744964223a2230222c22736563726574223a226f72636861726420626c65616b20706c617920737465616b20636976696c207365656420736368656d6520626565662074616e6b20736f6170207374726174656779207a6f6e65222c2274797065223a224c6561646572222c22636970686572557064617465223a7b2243697068657254797065223a22414553222c2250617373776f72644964223a2230227d7d2c22303332303935353432386664346534373330653361643930613962623732663834646633616532623034383530653466376237356133316463353235316161393835223a7b226163636f756e744964223a2230222c22736563726574223a226b69636b20686f7065206c616e6775616765206b69636b2061686561642061696d20726f7365206d6178696d756d20746f72636820646f6e6b657920636f7572736520726f6164222c2274797065223a224c6561646572222c22636970686572557064617465223a7b2243697068657254797065223a22414553222c2250617373776f72644964223a2230227d7d2c22303335613632356261666538356631303637656332613833613366373062316539643736623531356433663637353761323531643630383038323033353836653861223a7b226163636f756e744964223a2230222c22736563726574223a22687572742066617469677565206365696c696e67207375676765737420736e617020706f6c617220666565206d6f72652065786563757465207265666f726d2072656d656d626572206e6172726f77222c2274797065223a224c6561646572222c22636970686572557064617465223a7b2243697068657254797065223a22414553222c2250617373776f72644964223a2230227d7d2c22303339633934386234363035663365323236396539383236376265323466376435336435656435303036313663663136333638613764383161323035613538323031223a7b226163636f756e744964223a2230222c22736563726574223a2273656c6c20707261697365206265666f726520686f6c6520676c696d707365206a756e6b206c616d702068756e64726564206a756e676c6520636c69656e7420736967687420626f72646572222c2274797065223a224c6561646572222c22636970686572557064617465223a7b2243697068657254797065223a22414553222c2250617373776f72644964223a2230227d7d2c22303361336465353764333266613562613137343733666638663861373764303531626363366566643835663737346330336137613233313432353534393135626161223a7b226163636f756e744964223a2230222c22736563726574223a22636173746c652073746166662070616e7468657220666163756c7479207370656369616c2074686f75676874207573652073706f6f6e207061706572207265706f727420656e6c697374206f63637572222c2274797065223a224c6561646572222c22636970686572557064617465223a7b2243697068657254797065223a22414553222c2250617373776f72644964223a2230227d7d2c22303364303139306230306339616434363937613236646165653036303064373138333633656463323962653137353263656138623265636265373135643261326363223a7b226163636f756e744964223a2230222c22736563726574223a22776f6e646572206d61736b2064657374726f7920726f626f7420696d70726f7665207365656b20637275656c2073717561726520666c6967687420696e73616e6520676f6c642073686564222c2274797065223a224c6561646572222c22636970686572557064617465223a7b2243697068657254797065223a22414553222c2250617373776f72644964223a2230227d7d2c22303364393932663232643965313738613464653032653939666666666538383562643531333565363564313833323030646133623536363530326563613739333432223a7b226163636f756e744964223a2230222c22736563726574223a22626f617264206c65697375726520696d706f736520626c65616b20726163652065676720616275736520736572696573207365617420616368696576652066616e20636f6c756d6e222c2274797065223a224c6561646572222c22636970686572557064617465223a7b2243697068657254797065223a22414553222c2250617373776f72644964223a2230227d7d7d7d');
    expect(hexx.hexToAscii(decryptedHex),
        '{"accounts":{"0":{"name":"Primary","net":"Net.test"}},"wallets":{"02c58f579f1fa22f2d5972bde406b14137c5e223b0eb9e4f1317206553e1c6c1aa":{"accountId":"0","secret":"orchard bleak play steak civil seed scheme beef tank soap strategy zone","type":"Leader","cipherUpdate":{"CipherType":"AES","PasswordId":"0"}},"0320955428fd4e4730e3ad90a9bb72f84df3ae2b04850e4f7b75a31dc5251aa985":{"accountId":"0","secret":"kick hope language kick ahead aim rose maximum torch donkey course road","type":"Leader","cipherUpdate":{"CipherType":"AES","PasswordId":"0"}},"035a625bafe85f1067ec2a83a3f70b1e9d76b515d3f6757a251d60808203586e8a":{"accountId":"0","secret":"hurt fatigue ceiling suggest snap polar fee more execute reform remember narrow","type":"Leader","cipherUpdate":{"CipherType":"AES","PasswordId":"0"}},"039c948b4605f3e2269e98267be24f7d53d5ed500616cf16368a7d81a205a58201":{"accountId":"0","secret":"sell praise before hole glimpse junk lamp hundred jungle client sight border","type":"Leader","cipherUpdate":{"CipherType":"AES","PasswordId":"0"}},"03a3de57d32fa5ba17473ff8f8a77d051bcc6efd85f774c03a7a23142554915baa":{"accountId":"0","secret":"castle staff panther faculty special thought use spoon paper report enlist occur","type":"Leader","cipherUpdate":{"CipherType":"AES","PasswordId":"0"}},"03d0190b00c9ad4697a26daee0600d718363edc29be1752cea8b2ecbe715d2a2cc":{"accountId":"0","secret":"wonder mask destroy robot improve seek cruel square flight insane gold shed","type":"Leader","cipherUpdate":{"CipherType":"AES","PasswordId":"0"}},"03d992f22d9e178a4de02e99ffffe885bd5135e65d183200da3b566502eca79342":{"accountId":"0","secret":"board leisure impose bleak race egg abuse series seat achieve fan column","type":"Leader","cipherUpdate":{"CipherType":"AES","PasswordId":"0"}}}}');
  });
}
