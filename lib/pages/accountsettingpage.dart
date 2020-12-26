
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:message_me/widgets/progress_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';

class Setting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: IconThemeData(
            color: Colors.white
        ),
        backgroundColor: Color(0xFF253d53),
        title: Text('Account Setting ', style: TextStyle(
            fontWeight: FontWeight.bold, color: Colors.white
        ),
        ),
        centerTitle: true,
      ),
      body: Settingscreen(),
    );
  }
}

  class Settingscreen extends StatefulWidget {
  @override
  _SettingscreenState createState() => _SettingscreenState();
  }

  class _SettingscreenState extends State<Settingscreen> {
  TextEditingController nickNameTextEditingController;
  TextEditingController aboutMeTextEditingController;
  SharedPreferences preferences;
  String id = '';
  String nickName = '';
  String photoUrl = '';
  String aboutMe = '';
  File imageFileAvatar;
  bool isLoading=false;
  final FocusNode nickNameFocusNode = FocusNode();
  final FocusNode aboutMeFocusNode = FocusNode();


  @override
  void initState() {
  super.initState();
  readdataFromLocal();
  }

  void readdataFromLocal() async
  {
  preferences = await SharedPreferences.getInstance();
  nickName = preferences.getString('nickName');
  photoUrl = preferences.getString('photoUrl');
  aboutMe = preferences.getString('aboutMe');
  id = preferences.getString('id');
  nickNameTextEditingController = TextEditingController(text: nickName);
  aboutMeTextEditingController = TextEditingController(text: aboutMe);
  setState(() {

  });
  }

  Future getImage() async
  {
  File newImageFile = await ImagePicker.pickImage(
  source: ImageSource.gallery);
  if (newImageFile != null) {
  setState(() {
  this.imageFileAvatar = newImageFile;
  isLoading = true;
  });
  }
  uploadImageToFireStoreAndAndStorage();
  }

  Future uploadImageToFireStoreAndAndStorage()async
  {
    String mFileName=id;
    StorageReference  reference=FirebaseStorage.instance.ref().child(mFileName);
    StorageUploadTask uploadTask=reference.putFile(imageFileAvatar);
    StorageTaskSnapshot taskSnapshot;
    uploadTask.onComplete.then((value){
  if(value.error==null)
    {
     taskSnapshot=value;
     taskSnapshot.ref.getDownloadURL().then((newImageDownLoad){
        photoUrl=newImageDownLoad;
        Firestore.instance.collection('users').document(id).updateData({
          'photoUrl':photoUrl,
          'nickName':nickName,
          'aboutMe':aboutMe
        }).then((data) async{
          await preferences.setString('photoUrl', photoUrl);
          setState(() {
            isLoading=false;
          });
          Fluttertoast.showToast(msg: 'Updated Successfully');
        });
     },
         onError:(errorMsg){
           setState(() {
             isLoading=false;
           });
           Fluttertoast.showToast(msg: 'Error ocurred in getting  Download Url');} );
    }
    },onError: (errorMsg){
      setState(() {
        isLoading=false;
      });
      Fluttertoast.showToast(msg: errorMsg.toString());
    });

  }

  @override
  Widget build(BuildContext context) {
  return Stack(
  children: [
  SingleChildScrollView(
  child: Column(
  children: [
  // profile image avatar
  Container(
  child: Center(
  child: Stack(
  children: [
  (imageFileAvatar == null ? (photoUrl != '') ?
  Material(
  // display already existing _old image file
  child: CachedNetworkImage(
  placeholder: (context, url) =>
  Container(
  child: CircularProgressIndicator(
  strokeWidth: 2.0,
  valueColor: AlwaysStoppedAnimation<Color>(
  Colors.lightBlueAccent),
  ),
  width: 200, height: 200,
  padding: EdgeInsets.all(20.0),
  ),
  imageUrl: photoUrl,
  width: 200.0,
  height: 200.0,
  fit: BoxFit.cover,
  ),
  borderRadius: BorderRadius.all(Radius.circular(125.0)),
  clipBehavior: Clip.hardEdge,
  ) :
  Icon(
  Icons.account_circle, size: 90.0, color: Colors.grey,) :
  Material(
  //display the new updated image file
  child: Image.file(imageFileAvatar,
  width: 200.0, height: 200.0,
  fit: BoxFit.cover,),
  borderRadius: BorderRadius.all(Radius.circular(125.0)),
  clipBehavior: Clip.hardEdge,
  )
  ),
  IconButton
  (icon: Icon(Icons.camera_alt, size: 100,
  color: Colors.white54.withOpacity(0.3),)
  ,
  onPressed: getImage,
  padding: EdgeInsets.all(0.0),
  splashColor: Colors.transparent,
  highlightColor: Colors.grey,
  iconSize: 200.0,),
  ],
  ),
  ),
  width: double.infinity,
  margin: EdgeInsets.all(20.0),
  ),
  // Entry info for nickname and bio
  Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
  Padding(padding: EdgeInsets.all(1.0),
  child: isLoading ? circularProgres() : Container(),
  ),
  Container(
  child: Text('Profile Name :',
  style: TextStyle(fontStyle: FontStyle.italic,
  fontWeight: FontWeight.bold,
  color: Color(0xFFffcb2e)),
  ),
  margin: EdgeInsets.only(
  left: 10.0, bottom: 10.0, top: 10.0),
  ),
  Container(
  child: Theme(
  data: Theme.of(context).copyWith(
  primaryColor: Colors.lightBlueAccent),
  child: TextField(
  decoration: InputDecoration(
  hintText: 'E.g Mohammed ...',
  contentPadding: EdgeInsets.all(5.0),
  hintStyle: TextStyle(color: Colors.grey),
  ),
  controller: nickNameTextEditingController,
  onChanged: (value) {
  nickName = value;
  },
  focusNode: nickNameFocusNode,
  ),

  ),
  margin: EdgeInsets.only(left: 30.0, right: 30.0),
  ),
  Container(
  child: Text('About me',
  style: TextStyle(fontStyle: FontStyle.italic,
  fontWeight: FontWeight.bold,
  color: Color(0xFFffcb2e)),
  ),
  margin: EdgeInsets.only(left: 10.0, bottom: 5.0, top: 30.0),
  ),
  Container(
  child: Theme(
  data: Theme.of(context).copyWith(
  primaryColor: Colors.lightBlueAccent),
  child: TextField(
  decoration: InputDecoration(
  hintText: 'Bio ...',
  contentPadding: EdgeInsets.all(5.0),
  hintStyle: TextStyle(color: Colors.grey),
  ),
  controller: aboutMeTextEditingController,
  onChanged: (value) {
  aboutMe = value;
  },
  focusNode: aboutMeFocusNode,
  ),

  ),
  margin: EdgeInsets.only(left: 30.0, right: 30.0),
  ),
  ],
  ),
  Container(
  child: FlatButton(
  onPressed: updateData,
  child: Text(
  'Update', style: TextStyle(fontSize: 16.0),
  ),
  color: Color(0xFF253d53),
  highlightColor: Colors.grey,
  splashColor: Colors.transparent,
  textColor: Colors.white,
  padding: EdgeInsets.fromLTRB(30.0, 10.0, 30.0, 10.0),
  ), margin: EdgeInsets.only(top: 50.0, bottom: 1.0),
  ),
  Padding(
  padding: EdgeInsets.only(left: 50.0, right: 50.0),
  child: RaisedButton(color: Colors.red,
  child: Text('Logout', style: TextStyle(
  color: Colors.white, fontSize: 14.0
  ),
  ), onPressed: logoOutUser
  ,),
  ),

  ],
  ),
  padding: EdgeInsets.only(left: 15.0, right: 15.0),
  ),
  ],
  );
  }
  final GoogleSignIn googleSignIn= GoogleSignIn();
  Future<Null> logoOutUser()async
  {
  await FirebaseAuth.instance.signOut();
  await googleSignIn.disconnect();
  await googleSignIn.signOut();
   setState(() {
  isLoading=false;
  });
  Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context)=>MyApp()),(Route<dynamic> route)=>false);
  }
  void updateData()
  {
    nickNameFocusNode.unfocus();
    aboutMeFocusNode.unfocus();
    setState(() {
      isLoading=false;
    });
    Firestore.instance.collection('users').document(id).updateData({
      'photoUrl':photoUrl,
      'nickName':nickName,
      'aboutMe':aboutMe
    }).then((data) async{
      await preferences.setString('photoUrl', photoUrl);
      await preferences.setString('nickName', nickName);
      await preferences.setString('aboutMe', aboutMe);
      setState(() {
        isLoading=false;
      });
      Fluttertoast.showToast(msg: 'Updated Successfully');
    });
  }
}
