enum WalletExposure { Internal, External }

String exposureToDerivationPathPart(WalletExposure exposure) {
  switch (exposure) {
    case WalletExposure.External:
      return '0';
    case WalletExposure.Internal:
      return '1';
  }
}
