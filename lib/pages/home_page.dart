
import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:message_me/models/user.dart';
import 'package:message_me/widgets/progress_widget.dart';

import 'accountsettingpage.dart';
import 'chatting_page.dart';


class HomeScreen extends StatefulWidget {
  final String currentUserId;
  HomeScreen({Key key,@required this.currentUserId}):super(key: key);
  @override
  _HomeScreenState createState() => _HomeScreenState(
    currentUserId:currentUserId
  );
}

class _HomeScreenState extends State<HomeScreen> {
  _HomeScreenState({Key key, @required this.currentUserId});

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging();
  TextEditingController searchTextEditingController=TextEditingController();
  Future<QuerySnapshot> futureSearchResult;
  final String currentUserId;

// create notification
  @override
  void initState() {
    super.initState();
    registerNotification();
    configLocalNotification();
  }


  void registerNotification() {
    firebaseMessaging.requestNotificationPermissions();

    firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) {
      print('onMessage: $message');
      Platform.isAndroid
          ? showNotification(message['notification'])
          : showNotification(message['aps']['alert']);
      return;
    }, onResume: (Map<String, dynamic> message) {
      print('onResume: $message');
      return;
    }, onLaunch: (Map<String, dynamic> message) {
      print('onLaunch: $message');
      return;
    });

    firebaseMessaging.getToken().then((token) {
      print('token: $token');
      Firestore.instance
          .collection('users')
          .document(currentUserId)
          .updateData({'pushToken': token});
    }).catchError((err) {
      Fluttertoast.showToast(msg: err.message.toString());
    });
  }

  void configLocalNotification() {
    var initializationSettingsAndroid =
    new AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void showNotification(message) async {
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
      Platform.isAndroid
          ? 'com.example.message_me'
          : 'com.example.message_me',
      'Flutter Message me',
      'your channel description',
      playSound: true,
      enableVibration: true,
      importance: Importance.max,
      priority: Priority.high,
    );
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        android: androidPlatformChannelSpecifics, iOS: iOSPlatformChannelSpecifics);

    print(message);
    print(message['body'].toString());
    print(json.encode(message));

    await flutterLocalNotificationsPlugin.show(0, message['title'].toString(),
        message['body'].toString(), platformChannelSpecifics,
        payload: json.encode(message));

  }

  // this method for create content of appBar
  HomePageHeader()
  {
    return AppBar(
      automaticallyImplyLeading: false,//remove the back button
      actions: [
        IconButton(icon: Icon(Icons.settings),iconSize: 30.0,color: Colors.white,
            onPressed:(){
          Navigator.push(context,MaterialPageRoute(builder: (context)=>Setting()));
            })
      ],
      backgroundColor: Color(0xFF253d53),
      title: Container(
        margin: EdgeInsets.only(bottom: 4.0),
        child: TextFormField(
          style: TextStyle(fontSize: 18.0,color: Colors.white),
          controller: searchTextEditingController,
          decoration: InputDecoration(
          hintText: 'Search here...',
          hintStyle: TextStyle(color: Colors.white),
          enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
           ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
            filled: true,
            prefixIcon: Icon(Icons.person,color: Colors.white,size: 30.0,),
            suffixIcon: IconButton(icon: Icon(Icons.close,color: Colors.white,),
            onPressed: emptyTextFormField,)
        ),onFieldSubmitted: controlSearching,
      ),),
    );
  }

  controlSearching(String str){
    Future<QuerySnapshot> allFoundUsers=Firestore.instance.collection('users')
        .where('nickName',isGreaterThanOrEqualTo: str).getDocuments();
    setState(() {
      futureSearchResult=allFoundUsers;
    });
  }

  emptyTextFormField()
  {
    searchTextEditingController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
      appBar: HomePageHeader(),
 body: futureSearchResult==null?displayNoSearchResultScreen():displayUserFoundScreen(),
    );
  }
   displayNoSearchResultScreen()
  {
    final Orientation orientation = MediaQuery.of(context).orientation;
    return Container(
      child: Center(
          child: ListView(
            shrinkWrap: true,
            children: [
              Icon(
                Icons.group,
                color: Color(0xFF193044),
                size: 200,
              ),
              Text('Search User',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Color(0xFF193044),
                      fontWeight: FontWeight.bold,
                      fontSize: 45.0)),
            ],
          )),
    );
  }
  displayUserFoundScreen()
  {
    return FutureBuilder<QuerySnapshot>(
      future: futureSearchResult,
      builder: (context, dataSnapshot) {
        if (!dataSnapshot.hasData) {
          return circularProgres();
        }
        List<UserResult> searchUserResult = [];
        dataSnapshot.data.documents.forEach((document) {
          User eachUser = User.fromDocument(document);
          UserResult userResult = UserResult(eachUser);
          if(currentUserId !=document['id'])
          {
            searchUserResult.add(userResult);
          }
        });
        return ListView(
          children: searchUserResult,
        );
      },
    );
  }

}




class UserResult extends StatelessWidget {
  final User eachUser;
  UserResult(this.eachUser);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(4.0),
      child: Container(
        color: Colors.white,
        child: Column(
          children: <Widget>[
            GestureDetector(
               onTap: () => sendUserToChatPage(context),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.black,
                  backgroundImage:
                                   CachedNetworkImageProvider(eachUser.photoUrl),
                ),
                title: Text(
                  eachUser.nickName,

                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Joind:'+ DateFormat('dd MMMM,yyyy -hh:mm:aa')
                .format(DateTime.parse(eachUser.createdAt)),
                style:TextStyle(
                 color: Colors.grey,fontSize: 14.0,fontStyle: FontStyle.italic
                ) ,
              ),
               ),
            ),
          ],
        ),
      ),
    );
  }
  sendUserToChatPage(BuildContext context)
  {
    Navigator.push(context, MaterialPageRoute(builder: (context){
      return
        Chat(receiverId:eachUser.id,receiverAvatar:eachUser.photoUrl,receiverName:eachUser.nickName);
    }));
  }
}

