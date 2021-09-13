/// we need a back-end module that will manage pulling rvn and assets from 
/// multiple wallets if the send amount (plus fees) is too large.

/// like transaction builder this must be a recursive function... 
/// we want to minimize our inputs in order to minimize transaction fees.
/// 
/// this is actually one extra layer of recursion on the existing set:
/// 
/// estimate total (amount + fee (assume 1 input fee))
/// start:
///   does account have enough for total?
///     no: fail error
///     yes: wallet found with just enough?
///       no: get best group of wallets (largest until satisfied) (collect addresses from)
///       yes: collect addresses from
///       address found with just enough?
///         yes: use address
///         no: get best group of addresses (largest until satisfied) add up fees
///       new total (total + new fees) < addresses balance?
///         no: use these addresses
///         yes: start over with new total

/// with this we prefer using 1 HDwallet over many, and 1 address over many, but not automatically the largest.
/// 
/// currently we're keying off account.histories... this means it could pull from multiple wallets. why does this matter?... actually it doesn't. it must be signed with the privkey of the "address" not the Leaderwallet... so it's the same fees either way...
/// 