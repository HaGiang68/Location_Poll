import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';

class TokenMonitor extends StatefulWidget {
  TokenMonitor(this.builder);

  final Widget Function(String? token) builder;

  @override
  State<StatefulWidget> createState() => _TokenMonitor();
}

class _TokenMonitor extends State<TokenMonitor> {
  String? _token;

  /// late modifier means “enforce this variable’s constraints at runtime instead of at compile time”
  late Stream<String> _tokenStream;

  void setToken(String? token) {
    print('Token: $token');
    setState(() {
      _token = token;
    });
  }

  @override
  void initState() {
    super.initState();

    ///"Voluntary Application Server Identification"
    FirebaseMessaging.instance
        .getToken(
            vapidKey:
                'BHRk7zoWgZKevmxj7xacjk6WrsdRTabQcdj4b6oCwMWxoH_bB2j82_UfGd9-rPykJnRha8Sh7wpHhfUmGnROGrY')
        .then(setToken);
    _tokenStream = FirebaseMessaging.instance.onTokenRefresh;
    _tokenStream.listen(setToken);
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(_token);
  }
}
