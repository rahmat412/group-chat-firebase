import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:group_chat/features/presentation/cubit/auth/auth_cubit.dart';
import 'package:group_chat/features/presentation/cubit/chat/chat_cubit.dart';
import 'package:group_chat/features/presentation/cubit/group/group_cubit.dart';
import 'package:group_chat/features/presentation/cubit/user/user_cubit.dart';
import 'package:group_chat/features/presentation/pages/all_users_page.dart';
import 'package:group_chat/features/presentation/pages/groups_page.dart';
import 'package:group_chat/features/presentation/pages/profile_page.dart';
import 'package:group_chat/features/presentation/widgets/customTabBar.dart';
import 'package:group_chat/features/presentation/widgets/theme/style.dart';
import '../../../app_const.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  final String uid;

  const HomePage({Key? key, required this.uid}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController _searchTextController = TextEditingController();
  PageController _pageController = PageController(initialPage: 0);
  int _totalNotifications = 0;
  PushNotification? _notificationInfo;

  List<Widget> get pages => [
        GroupsPage(
          uid: widget.uid,
          query: _searchTextController.text,
        ),
        AllUsersPage(
          uid: widget.uid,
          query: _searchTextController.text,
        ),
        ProfilePage(
          uid: widget.uid,
        )
      ];

  int _currentPageIndex = 0;

  bool _isSearch = false;

  @override
  void dispose() {
    _searchTextController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    BlocProvider.of<UserCubit>(context).getUsers();
    BlocProvider.of<GroupCubit>(context).getGroups();
    requestAndRegisterNotification();
    _notificationInfo = PushNotification(
      title: "no notification",
      body: "no notification",
    );
    _searchTextController.addListener(() {
      setState(() {});
    });
  }

  _buildSearchField() {
    return Container(
      margin: EdgeInsets.only(top: 25),
      height: 40,
      decoration: BoxDecoration(color: Colors.white, boxShadow: [
        BoxShadow(
            color: Colors.black.withOpacity(.3),
            spreadRadius: 1,
            offset: Offset(0, 0.50))
      ]),
      child: TextField(
        controller: _searchTextController,
        decoration: InputDecoration(
          hintText: "Search...",
          border: InputBorder.none,
          prefixIcon: InkWell(
              onTap: () {
                setState(() {
                  _isSearch = false;
                });
              },
              child: Icon(
                Icons.arrow_back,
                size: 25,
                color: primaryColor,
              )),
          hintStyle: TextStyle(),
        ),
        style: TextStyle(fontSize: 16.0),
      ),
    );
  }

  void requestAndRegisterNotification() async {
    final _messaging = FirebaseMessaging.instance;
    String? token = await _messaging.getToken();
    print("The token is " + token!);
    // For handling the received notifications
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Parse the message received
      PushNotification notification = PushNotification(
        title: message.notification?.title,
        body: message.notification?.body,
      );

      setState(() {
        _notificationInfo = notification;
        _totalNotifications++;
      });
      print("count:  ${_totalNotifications}");
      if (message.notification != null) {
        // For displaying the notification as an overlay
        print(message.notification);
      }
    });
  }

  static sendNotificationToDriver(String? token, context) async {
    if (token == null) {
      print('Unable to send FCM message, no token exists.');
      return;
    }

    try {
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization':
              'key=AAAANu_3qbc:APA91bGbbZOiW6BtM_FaezhWcL_72aSJ0cZvQBVPE8PC2yBiD48Rs6KHE0dcVkdxx3QGL3F59QZk1CFu-tK7rCDE64h82zQv0vrxUSUMKvn34o4ftRBQMJbubFWt5qsUL2kAbL3Yebxc',
        },
        body: constructFCMPayload(token),
      );
      print('FCM request for device sent!');
    } catch (e) {
      print(e);
    }
  }

  static String constructFCMPayload(String token) {
    var res = jsonEncode({
      'token': token,
      'notification': {
        "body": "this is body from firebase",
        "title": "this is title from firebase"
      },
      "priority": "high",
      'data': {
        "click_action": "FLUTTER_NOTIFIATION_CLICK",
        "id": "1",
        "status": "done",
      },
      'to': token,
    });

    print(res.toString());
    return res;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: _isSearch == false ? primaryColor : Colors.transparent,
        title: _isSearch == false
            ? Text("${AppConst.appName}")
            : Container(
                height: 0.0,
                width: 0.0,
              ),
        flexibleSpace: _isSearch == true
            ? _buildSearchField()
            : Container(
                height: 0.0,
                width: 0.0,
              ),
        actions: _isSearch == false
            ? [
                InkWell(
                  onTap: () {
                    setState(() {
                      _isSearch = true;
                    });
                  },
                  child: Icon(Icons.search),
                ),
                SizedBox(
                  width: 15,
                ),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    new Icon(Icons.notifications),
                    new Positioned(
                      right: 0,
                      top: 15,
                      child: new Container(
                        padding: EdgeInsets.all(1),
                        decoration: new BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        constraints: BoxConstraints(
                          minWidth: 12,
                          minHeight: 12,
                        ),
                        child: new Text(
                          _totalNotifications.toString(),
                          style: new TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(
                  width: 5,
                ),
                PopupMenuButton(
                  icon: Icon(Icons.more_vert),
                  itemBuilder: (BuildContext context) {
                    return [
                      PopupMenuItem(
                        child: InkWell(
                            onTap: () {
                              Navigator.pop(context);
                              BlocProvider.of<AuthCubit>(context).loggedOut();
                            },
                            child: Text("logout")),
                        enabled: true,
                      ),
                    ];
                  },
                ),
              ]
            : [],
      ),
      body: Container(
        child: Column(
          children: [
            _isSearch == false
                ? CustomTabBar(
                    index: _currentPageIndex,
                    tabClickListener: (index) {
                      print(index);
                      _currentPageIndex = index;
                      _pageController.jumpToPage(index);
                    },
                  )
                : Container(
                    width: 0.0,
                    height: 0.0,
                  ),
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'This is Notification',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TITLE: ${_notificationInfo!.title}',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16.0,
                            ),
                          ),
                          SizedBox(height: 8.0),
                          Text(
                            'BODY: ${_notificationInfo!.body}',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16.0,
                            ),
                          ),
                        ],
                      ),
                      InkWell(
                        onTap: () async {
                          String? token =
                              await FirebaseMessaging.instance.getToken();
                          sendNotificationToDriver(token, context);
                        },
                        child: Icon(Icons.add),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPageIndex = index;
                  });
                },
                itemCount: pages.length,
                itemBuilder: (_, index) {
                  return pages[index];
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PushNotification {
  String? title;
  String? body;
  PushNotification({
    this.title,
    this.body,
  });
}
