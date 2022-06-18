//github.com/LYF1314/metamask_token
import 'package:walletconnect_dart/walletconnect_dart.dart';

class Web3Service {
  final connector = WalletConnect(
    bridge: 'https://bridge.walletconnect.org',
    clientMeta: PeerMeta(
      name: 'WalletConnect',
      description: 'WalletConnect Developer App',
      url: 'https://walletconnect.org',
      icons: [
        'https://gblobscdn.gitbook.com/spaces%2F-LJJeCjcLrr53DcT1Ml7%2Favatar.png?alt=media'
      ],
    ),
  );

  String connectionUri = "";

  Web3Service() {
    connector.on('connect', (session) => print(session));
    connector.on('session_request', (payload) => print(payload));
    connector.on('disconnect', (session) => print(session));
  }

  Future<void> generateUri() async {
    if (!connector.connected) {
      final session = await connector.createSession(
          chainId: 4160, onDisplayUri: (uri) => setUri(uri));
    }
  }

  setUri(String uri) {
    this.connectionUri = uri;
  }
}
