bool isIPFS(String x) => x.contains(RegExp(
    r'^Qm[1-9A-HJ-NP-Za-km-z]{44}$|^b[A-Za-z2-7]{58}$|^B[A-Z2-7]{58}$|^z[1-9A-HJ-NP-Za-km-z]{48}$|^F[0-9A-F]{50}$'));

bool isAddressRVN(String x) => x.contains(RegExp(r'^$'));
bool isAddressRVNt(String x) => x.contains(RegExp(r'^$'));
bool isTxIdRVN(String x) => x.contains(RegExp(r'^$'));
bool isTxIdRVNt(String x) => x.contains(RegExp(r'^$'));
bool isTxIdFlow(String x) => x.contains(RegExp(r'^$'));
bool isAdmin(String x) => x.contains(RegExp(r'^$'));
bool isAssetPath(String x) => x.contains(RegExp(r'^$'));
bool isAsset(String x) => x.contains(RegExp(r'^$'));
bool isSubAsset(String x) => x.contains(RegExp(r'^$'));
bool isNFT(String x) => x.contains(RegExp(r'^$'));
bool isChannel(String x) => x.contains(RegExp(r'^$'));
bool isQualifier(String x) => x.contains(RegExp(r'^$'));
bool isSubQualifier(String x) => x.contains(RegExp(r'^$'));
bool isQualifierString(String x) => x.contains(RegExp(r'^$'));
bool isRestricted(String x) => x.contains(RegExp(r'^$'));
bool isVote(String x) => x.contains(RegExp(r'^$'));
bool isMemo(String x) => x.contains(RegExp(r'^$')); // byte len <80
bool isAssetMemo(String x) => isIPFS(x) || isTxIdFlow(x);
