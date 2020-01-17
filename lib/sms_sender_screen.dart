import 'package:flutter/material.dart';
//import 'package:flutter_sms/flutter_sms.dart';
import 'package:sms/sms.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wifi_configuration/wifi_configuration.dart';

class SmsSenderScreen extends StatefulWidget {
  SmsSenderScreen({Key key}) : super(key: key);

  @override
  _SmsSenderScreenState createState() => _SmsSenderScreenState();
}

class _SmsSenderScreenState extends State<SmsSenderScreen> {
  String _recipient;

  Future<void> _sendSMS(
      BuildContext context, String content, String recipent) async {
    SimCardsProvider provider = new SimCardsProvider();
    SimCard card;
    await provider.getSimCards().then((list) {
      card = list[1];
    }).catchError((e) => throw e);

    SmsSender sender = new SmsSender();
    SmsMessage message = new SmsMessage(recipent, content);

    message.onStateChanged.listen((state) {
      String notification;
      if (state == SmsMessageState.Delivered) {
        notification = 'Tin nhắn đã được gửi';
      } else if (state == SmsMessageState.Sending) {
        notification = 'Tin nhắn đang được gửi';
      } else if (state == SmsMessageState.Fail) {
        notification = 'Tin nhắn không gửi được ';
      } else if (state == SmsMessageState.Sent) {
        notification = 'Tin nhắn đã đươc gửi';
      }
      showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
                title: Text('Thông báo'),
                content: Text(notification),
                actions: <Widget>[
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      size: 60,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ));
    });
    sender.sendSms(message, simCard: card);
  }

  _wifiConnection() async {
    // String ssid = await Wifi.ssid;
    // int level = await Wifi.level;
    // String ip = await Wifi.ip;
    String ssid = 'Dung@';
    String password = '11111111';
    //final notification = await WifiConfiguration.connectedToWifi();
    final status  =await WifiConfiguration.connectToWifi(ssid, password, "com.example.mommy_app");
    String notification;
    switch (status) {

      case WifiConnectionStatus.connected:
        notification = 'Đã kết nối wifi';
        break;

      case WifiConnectionStatus.alreadyConnected:
        notification = 'Wifi được kết nối rồi';
      break;

      case WifiConnectionStatus.platformNotSupported:
        notification = 'Nền tảng không được hỗ trợ';
      break;

      case WifiConnectionStatus.notConnected:
        notification = 'Wifi không được kết nối';
      break;
      case WifiConnectionStatus.profileAlreadyInstalled:
      break;
      case WifiConnectionStatus.locationNotAllowed:
      break;

    }
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              title: Text('Thông báo'),
              content: Text(notification),
              actions: <Widget>[
                IconButton(
                  icon: Icon(
                    Icons.close,
                    size: 60,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ));
    //});
  }

  @override
  void initState() {
    // TODO: implement initState
    _loadRecipent();

    super.initState();
  }

  _loadRecipent() async {
    SharedPreferences p = await SharedPreferences.getInstance();
    setState(() {
      String defaultNumber = '0971663834';
      _recipient = p.getString('number') ?? defaultNumber;
    });
  }

  _changeRecipent(String number) async {
    SharedPreferences p = await SharedPreferences.getInstance();
    setState(() {
      p.setString('number', number);
      _recipient = number;
    });
  }

  @override
  Widget build(BuildContext context) {
    //TODO
    final numberFieldController = TextEditingController();
    print(_recipient);
    return Scaffold(
        resizeToAvoidBottomPadding: false,
        appBar: buildAppBar(context, numberFieldController),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              _buidButton(context, 10),
              _buidButton(context, 15),
              _buidButton(context, 20),
              _buidButton(context, 25),
              _buidButton(context, 30),
              _buidButton(context, 35),
              RaisedButton(
                child: Text('Karaoke'),
                onPressed: () {
                  _wifiConnection();
                },
              )
            ],
          ),
        ));
  }

  AppBar buildAppBar(
      BuildContext context, TextEditingController numberFieldController) {
    return AppBar(
      title: Text('Nhắn cá thác lác cho bà ngoại bé Na'),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.edit),
          onPressed: () {
            showDialog(
              context: context,
              builder: (ctx) => SingleChildScrollView(
                child: SimpleDialog(
                  children: <Widget>[
                    TextField(
                      controller: numberFieldController,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(10),
                        hintText: 'Nhập vào số điện thoại cần thay đổi',
                      ),
                      onSubmitted: (_) {
                        Navigator.of(context).pop();
                        _changeRecipent(numberFieldController.text);
                      },
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
            );
          },
        )
      ],
    );
  }

  Widget _buidButton(BuildContext context, int kg) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            Color.fromRGBO(100, 20, 160, 1),
            Color.fromRGBO(100, 20, 160, 0.7),
            Color.fromRGBO(100, 20, 160, 0.5),
            Color.fromRGBO(100, 20, 160, 0.2)
          ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
              width: 2,
              style: BorderStyle.solid,
              color: Theme.of(context).accentColor),
        ),
        child: FlatButton(
          child: Text('$kg kí',
              style: TextStyle(
                  fontSize: 40, color: Theme.of(context).accentColor)),
          onPressed: () => _sendSMSWidget(context, kg),
        ),
      ),
    );
  }

  Future<void> _sendSMSWidget(BuildContext context, int kg) async {
    try {
      await _sendSMS(context, 'Lấy cho chị bảy $kg cá nha', _recipient);
    } catch (e) {
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Có lỗi xẩy ra '),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        ),
      );
    }
  }
}
