class Nonce {
  Nonce();

  int _nonce = 0;

  int increase() => ++_nonce;

  bool shouldApplyValue(int nonce) => nonce == _nonce;
}
