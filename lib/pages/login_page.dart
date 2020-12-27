

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:message_me/widgets/progress_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home_page.dart';



class LoginPage extends StatefulWidget {
  //for using all key bellow
  LoginPage({Key key}) : super(key: key);
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  //this key for start useing google_signIn
  final GoogleSignIn googleSignIn = GoogleSignIn();
  //this key for AuthFirebase
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  // this key for start using SharedPreferences for local data
  SharedPreferences preferences;
  //this bool if user is logged and found his data already in firebase for go to home page and no need save data again
  bool islogged = false;
  // this bool if app running and getting data for turn on circularProgress if not not running
  bool isloading = false;
  // for current user = id user from FireStore
  FirebaseUser currentUser;

  @override
  void initState() {
    super.initState();
    // this method if user islogged= true for puch to home page (Auto)
    isSignIned();
  }
          
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topRight,

                end: Alignment.bottomLeft,
                colors: [Color(0xFF193044), Color(0xFF2a435f)])),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

           Container(
             padding: EdgeInsets.all(0.8),
             child:  Text(
               'Message Me',
               style: TextStyle(fontSize: 55, fontFamily: 'Lobster',color: Colors.white),
             ),
           ),
            SizedBox(
              height: 20.0,
            ),
            GestureDetector(
              onTap: controalSiginIn,
              child: Center(
                child: Column(
                  children: [
                    Container(
                      height: 65.0,
                      width: 270.0,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage('images/image-3.jpg'),
                            fit: BoxFit.cover),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(1.0),
                      child: isloading ? circularProgres() : Text(''),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

// this metod for sigIn in google and Auth with firebase
  Future<Null> controalSiginIn() async {
    //for locale data
    preferences = await SharedPreferences.getInstance();
    //for turn circularProgres when click to register
    this.setState(() {
      isloading = true;
    });
    //Starting
    GoogleSignInAccount googleUser = await googleSignIn.signIn();
    GoogleSignInAuthentication googleAuthentication =
    await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
        idToken: googleAuthentication.idToken,
        accessToken: googleAuthentication.accessToken);

    FirebaseUser firebaseUser =
        (await firebaseAuth.signInWithCredential(credential)).user;
    //signIn success
    if (firebaseUser != null) {
      final QuerySnapshot resultQuery = await Firestore.instance
          .collection('users')
          .where('id', isEqualTo: firebaseUser.uid)
          .getDocuments();
      final List<DocumentSnapshot> documentSnapshot = resultQuery.documents;
      //if user new and he  is nor register before =save his data on firebaseSotre
      if (documentSnapshot.length == 0) {
        Firestore.instance
            .collection('users')
            .document(firebaseUser.uid)
            .setData({
          'id': firebaseUser.uid,
          'nickName': firebaseUser.displayName,
          'photoUrl': firebaseUser.photoUrl,
          'aboutMe': 'Available',
          'createdAt': DateTime.now().toString(),
          'chattingWith': null,
          'pushToken':null

        });
        //after set fireStore we will set data locale
        currentUser = firebaseUser;
        await preferences.setString('id', currentUser.uid);
        await preferences.setString('nickName', currentUser.displayName);
        await preferences.setString('photoUrl', currentUser.photoUrl);
      }
      // if user old and register before no need save data again just write = push to homePage
      else {
        currentUser = firebaseUser;
        await preferences.setString('id', documentSnapshot[0]['id']);
        await preferences.setString(
            'nickName', documentSnapshot[0]['nickName']);
        await preferences.setString(
            'photoUrl', documentSnapshot[0]['photoUrl']);
        await preferences.setString('aboutMe', documentSnapshot[0]['aboutMe']);
      }
      Fluttertoast.showToast(msg: 'SignIN Success');
      this.setState(() {
        isloading = false;
      });
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => HomeScreen(
                currentUserId: firebaseUser.uid,
              )));
    }
    //signin Not success=failed
    else {
      Fluttertoast.showToast(msg: 'Try again,SignIN failed');
      this.setState(() {
        isloading = false;
      });
    }
  }

// this method if user islogged= true for puch to home page  (Auto)
  void isSignIned() async {
    this.setState(() {
      islogged = true;
    });
    preferences = await SharedPreferences.getInstance();
    islogged = await googleSignIn.isSignedIn();
    //true
    if (islogged) {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        // argument currentUser id to home page
        return HomeScreen(currentUserId: preferences.getString('id'));
      }));
    }
    //turn of circularProgres
    this.setState(() {
      isloading = false;
    });
  }
}