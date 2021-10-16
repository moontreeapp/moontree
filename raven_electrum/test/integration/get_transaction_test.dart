
  test('getTransaction and parse', () async {
    var client = RavenElectrumClient(await connect('testnet.rvn.rocks'));
    await client.serverVersion(protocolVersion: '1.9');
    var tx = await client.getTransaction(
        'e86f693b46f1ca33480d904acd526079ba7585896cff6d0ae5dcef322d9dc52a');
    expect(tx.vout[0].memo),
        'aa21a9ede2f61c3f71d1defd3fa999dfa36953755c690689799962b48bebd836974e8cf9');
  });