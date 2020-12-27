

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:message_me/widgets/full_image_widget.dart';
import 'package:message_me/widgets/progress_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Chat extends StatelessWidget {
  final String receiverId;
  final String receiverAvatar;
  final String receiverName;
  Chat({Key key,@required this.receiverId,@required this.receiverAvatar,@required this.receiverName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFF193044),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundColor: Color(0xFF253d53),
              backgroundImage: CachedNetworkImageProvider(receiverAvatar),

            ),
          )
        ],
        iconTheme: IconThemeData(
          color: Colors.white
        ),
        title: Text(receiverName,style: TextStyle(
          color: Colors.white,fontWeight: FontWeight.bold
        ),
        ),
        centerTitle: true,
       ),
      body: ChatScreen(receiverId:receiverId,receiverAvatar:receiverAvatar),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final String receiverId;
  final String receiverAvatar;
  ChatScreen(
      {Key key,@required this.receiverId,
        @required this.receiverAvatar}):super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState(receiverId:receiverId,receiverAvatar:receiverAvatar);
}

class _ChatScreenState extends State<ChatScreen> {

  final TextEditingController textEditingController=TextEditingController();
  final ScrollController listScrollController=ScrollController();
  final FocusNode focusNode=FocusNode();
  final String receiverId;
  final String receiverAvatar;
  bool isDisplaySticker;
bool isLoading;
File imageFile;
String imageUrl;
String chatId;
SharedPreferences preferences;
String id;
var listMessage;

  @override
  void initState() {
    super.initState();
    isLoading=false;
    isDisplaySticker=false;
    focusNode.addListener(onFocusChange);
    chatId='';
    readLocal();
  }

  readLocal()async
  {
    preferences=await SharedPreferences.getInstance();
    id=preferences.getString('id')??'';
    if(id.hashCode <= receiverId.hashCode)
      {
        chatId='$id-$receiverId';
      }
    else
      {
        chatId='$receiverId-$id';
      }
    Firestore.instance.collection('users').document(id).updateData({'chattingWith':receiverId});
    setState(() {

    });
  }

  onFocusChange()
  {
    if(focusNode.hasFocus)
      {
        //hide sticker whenever the keyboard appers
        setState(() {
          isDisplaySticker=false;
        });
      }
  }

  _ChatScreenState(
      {Key key,@required this.receiverId,
        @required this.receiverAvatar});


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onBackPress,
        child: Stack(
          children: [
         Column(
           children: [
             //create list of messages
             createListMessages(),

             //show sticker
             (isDisplaySticker?createStikers():Container()),

             //Input controller
             createInput(),

           ],
         ),
            createLoading(),
          ],
        ), );
  }

  createLoading()
  {
    return Positioned(child: isLoading?circularProgres():Container());
  }

  Future<bool> onBackPress()
  {
    if(isDisplaySticker)
      {
        setState(() {
          isDisplaySticker=false;
        });
      }
    else{
      Navigator.pop(context);
    }
    return Future.value(false);
  }

  createStikers()
  {
    return Container(
      child: ListView(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
             Row(
               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
               children: [
               FlatButton(
                 onPressed:()=> onSendMessage('1',2),
                 child: Image.asset('images/1.gif',
                   width: 50.0,
                   height: 50.0,
                   fit: BoxFit.cover,),
               ),
               FlatButton(
                 onPressed: ()=>onSendMessage('2',2),
                 child: Image.asset('images/2.gif',
                   width: 50.0,
                   height: 50.0,
                   fit: BoxFit.cover,),
               ),
               FlatButton(
                 onPressed:()=> onSendMessage('3',2),
                 child: Image.asset('images/3.gif',
                   width: 50.0,
                   height: 50.0,
                   fit: BoxFit.cover,),
               ),
             ],),
              SizedBox(height: 12.0,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                FlatButton(
                  onPressed: ()=>onSendMessage('4',2),
                  child: Image.asset('images/4.gif',
                    width: 50.0,
                    height: 50.0,
                    fit: BoxFit.cover,),
                ),
                FlatButton(
                  onPressed:()=> onSendMessage('5',2),
                  child: Image.asset('images/5.gif',
                    width: 50.0,
                    height: 50.0,
                    fit: BoxFit.cover,),
                ),
                FlatButton(
                  onPressed: ()=>onSendMessage('6',2),
                  child: Image.asset('images/6.gif',
                    width: 50.0,
                    height: 50.0,
                    fit: BoxFit.cover,),
                ),
              ],),
              SizedBox(height: 12.0,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                FlatButton(
                  onPressed:()=> onSendMessage('7',2),
                  child: Image.asset('images/7.gif',
                    width: 50.0,
                    height: 50.0,
                    fit: BoxFit.cover,),
                ),
                FlatButton(
                  onPressed:()=> onSendMessage('8',2),
                  child: Image.asset('images/8.gif',
                    width: 50.0,
                    height: 50.0,
                    fit: BoxFit.cover,),
                ),
                FlatButton(
                  onPressed:()=> onSendMessage('9',2),
                  child: Image.asset('images/9.gif',
                    width: 50.0,
                    height: 50.0,
                    fit: BoxFit.cover,),
                ),
              ],),
              SizedBox(height: 12.0,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FlatButton(

                    onPressed:()=> onSendMessage('10',2),
                    child: Image.asset('images/10.gif',
                      width: 50.0,
                      height: 50.0,
                      fit: BoxFit.cover,),
                  ) ,

                ],
              )





            ],
          ),
        ],
      ),
      decoration: BoxDecoration(border: Border(
        top: BorderSide(color: Colors.grey,width: 0.5)
      ),color: Colors.white),
      padding: EdgeInsets.all(5.0),
      height: 180.0,
    );
  }

  createListMessages()
  {
    return Flexible(
        child:chatId==''?
        Center(
        child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF193044)))):
            StreamBuilder(
              stream:  Firestore.instance.collection('messages').document(chatId).
              collection(chatId).orderBy('timeStamp',descending: true).limit(20).snapshots(),
              builder: (context,snapshot){
                if(!snapshot.hasData)
                  {
                    return  Center(
                        child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF193044))));
                  }else
                    {
                     listMessage=snapshot.data.documents;
                     return ListView.builder(
                       padding: EdgeInsets.all(10.0),
                         itemBuilder:(context,index)=>createItem(index,snapshot.data.documents[index]),
                       itemCount: snapshot.data.documents.length,
                       reverse: true,
                       controller: listScrollController,
                     );
                    }
              },
            )
  );
  }
 bool isLastMsgLeft(int index)
  {
    if((index>0 && listMessage!=null && listMessage[index-1]['idFrom']==id )|| index==0)
    {
      return true;
    }else
    {
      return false;
    }
  }

 bool isLastMsgRight(int index)
  {
    if((index>0 && listMessage!=null && listMessage[index-1]['idFrom']!=id )|| index==0)
      {
        return true;
      }else
        {
          return false;
        }
  }

  Widget createItem(int index,DocumentSnapshot document)
  {  //My messages - right side
    if(document['idFrom']==id)
      {
         return Row(
           children: [
             document['type']==0?
                 //text msg
             Container(
               child: Text(document['content'],style: TextStyle(
                 color: Colors.white,fontWeight: FontWeight.w500
               ),),
               padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
               width: 200,
               decoration: BoxDecoration(color: Colors.lightBlueAccent,
               borderRadius: BorderRadius.circular(8.0)),
               margin: EdgeInsets.only(bottom: isLastMsgRight(index)?20.0:10.0, right:10.0 ),
             ):
                 //image msg
             document['type']==1?
                 Container(
                   child: FlatButton(
                   child: Material(
                     child: CachedNetworkImage(
                       placeholder:(context,url)=>Container(
                         child: CircularProgressIndicator(
                           valueColor: AlwaysStoppedAnimation<Color>(Colors.lightBlueAccent),
                         ),
                         width: 200,height: 200,
                         padding: EdgeInsets.all(70.0),
                         decoration:BoxDecoration(color: Colors.grey,
                             borderRadius: BorderRadius.all(Radius.circular(8.0))),
                       ) ,
                       errorWidget: (context,url,error)=>
                       Material(
                         child: Image.asset('images/error.png',width: 200,height: 200,
                         fit: BoxFit.cover,
                         ),
                         borderRadius: BorderRadius.all(Radius.circular(8.0),
                       ),
                         clipBehavior: Clip.hardEdge,
                     ),
                            imageUrl: document['content'],
                       width: 200,height: 200,
                       fit: BoxFit.cover,
                   ),
                     borderRadius: BorderRadius.all(Radius.circular(8.0),
                     ),
                     clipBehavior: Clip.hardEdge,
                 ),onPressed: ()
                     {
                       Navigator.push(context, MaterialPageRoute(builder:
                       (context)=>FullPhoto(url:document['content'])
                       ),);
                     }
                     ,),
                   margin: EdgeInsets.only(bottom: isLastMsgRight(index)?20.0:10.0, right:10.0 ),
                 ):
                 //Sticker gif
             Container(
               child: Image.asset('images/${document['content']}.gif',
                 width: 100,height: 100,
               fit: BoxFit.cover,
               ),
               margin: EdgeInsets.only(bottom: isLastMsgRight(index)?20.0:10.0, right:10.0 ),

             )
           ],
           mainAxisAlignment: MainAxisAlignment.end,
         );
      }
    // reciver messages - left side
    else
      {
        return Container(
          child: Column(
            children: [
              Row(children: [
                isLastMsgLeft(index)?
                Material(
                  // display receiver profile image
                  child: CachedNetworkImage(
                    placeholder:(context,url)=>Container(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.lightBlueAccent),
                      ),
                      width: 35,height: 35,
                      padding: EdgeInsets.all(10.0),
                      decoration:BoxDecoration(color: Colors.grey,
                          borderRadius: BorderRadius.all(Radius.circular(8.0))),
                    ),
                  imageUrl: receiverAvatar,
                  width: 35.0,height: 35.0,
                  fit: BoxFit.cover,

                ),
                  borderRadius: BorderRadius.all(Radius.circular(18.0)),
                  clipBehavior: Clip.hardEdge,
                ):
                Container(
                  width: 35.0),
                // display message
                document['type']==0?
                //text msg
                Container(
                  child: Text(document['content'],style: TextStyle(
                      color: Colors.black,fontWeight: FontWeight.w500
                  ),),
                  padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                  width: 200,
                  decoration: BoxDecoration(color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8.0)),
                  margin: EdgeInsets.only(left:10.0 ),
                ):
                //image msg
                document['type']==1?
                Container(
                  child: FlatButton(
                    child: Material(
                      child: CachedNetworkImage(
                        placeholder:(context,url)=>Container(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.lightBlueAccent),
                          ),
                          width: 200,height: 200,
                          padding: EdgeInsets.all(70.0),
                          decoration:BoxDecoration(color: Colors.grey,
                              borderRadius: BorderRadius.all(Radius.circular(8.0))),
                        ) ,
                        errorWidget: (context,url,error)=>
                            Material(
                              child: Image.asset('images/error.png',width: 200,height: 200,
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.all(Radius.circular(8.0),
                              ),
                              clipBehavior: Clip.hardEdge,
                            ),
                        imageUrl: document['content'],
                        width: 200,height: 200,
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(8.0),
                      ),
                      clipBehavior: Clip.hardEdge,
                    ),onPressed: ()
                  {
                    Navigator.push(context, MaterialPageRoute(builder:
                        (context)=>FullPhoto(url:document['content'])
                    ),);
                  }
                    ,),
                  margin: EdgeInsets.only(left: 10.0 ),
                ):
                //Sticker gif
                Container(
                  child: Image.asset('images/${document['content']}.gif',
                    width: 100,height: 100,
                    fit: BoxFit.cover,
                  ),
                  margin: EdgeInsets.only(bottom: isLastMsgRight(index)?20.0:10.0, right:10.0 ),

                )
              ],),
              // msg time
              isLastMsgLeft(index)?
              Container(
                child: Text(DateFormat('dd MMMM,yyyy -hh:mm:aa')
                    .format(DateTime.fromMillisecondsSinceEpoch(int.parse(document['timeStamp']))),
              style: TextStyle(
                color: Colors.grey,fontSize: 12.0,fontStyle: FontStyle.italic
              ),
                ),
                  margin:EdgeInsets.only(left: 50.0,top: 50.0,bottom: 5.0),
              )
                  :Container()
            ],
            crossAxisAlignment: CrossAxisAlignment.start,
          ),
          margin: EdgeInsets.only(bottom: 10.0),
        );
      }
  }

  createInput()
  {
    return Container(

      child: Row(
        children: [
          // pick image icon button
          Material(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 1.0),
              child: IconButton(
                icon: Icon(Icons.image),
                color: Colors.white,
                onPressed: getImageFromGallery,
              ),
            ),
              color: Color(0xFF2a435f)
          ),
          // emoji image icon button
          Material(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 1.0),
              child: IconButton(
                icon: Icon(Icons.face),
                color: Colors.white,
                onPressed: getStiker,
              ),
            ),
              color: Color(0xFF2a435f)
          ),
          // Text field
          Flexible(
              child: Container(
                color: Color(0xFF2a435f),
                child: TextField(
                  style: TextStyle(
                    fontSize: 15.0,
                    color: Colors.white
                  ),
                  controller: textEditingController,
                  decoration: InputDecoration(
                    hintText: 'Write here...',
                    hintStyle: TextStyle(
                      color: Colors.white
                    )
                  ),
                  focusNode: focusNode,
                ),
              )),
          // send message icon button
          Material(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 8.0),
              child: IconButton(
                icon: Icon(Icons.send),
                color: Color(0xFFffcb2e),
                onPressed: ()=>onSendMessage(textEditingController.text,0),
              ),
            ),
            color: Color(0xFF2a435f),
          ),
        ],
      ),
      width: double.infinity,
      height: 50.0,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.white,
            width: 0.5
          )
        )
      ),
    );
  }

  void onSendMessage(String contentMsg,int type)
  {
     //type 0 its text msg
    //type 1 its imageFile
    //type 2 its sticker
    if(contentMsg!='')
      {
        textEditingController.clear();
        var docRef= Firestore.instance.collection('messages').document(chatId).
        collection(chatId).document(DateTime.now().millisecondsSinceEpoch.toString());
         Firestore.instance.runTransaction((transaction) async
         {
           await transaction.set(docRef,
               {
                 'idFrom':id,
                 'idTo':receiverId,
                 'timeStamp':DateTime.now().millisecondsSinceEpoch.toString(),
                 'content':contentMsg,
                 'type':type
               });
         });
         listScrollController.animateTo(0.0, duration: Duration(microseconds: 300), curve: Curves.easeOut);
      }else
        {
          Fluttertoast.showToast(msg: 'Empty message. can\'t be send');
        }
  }

 Future getImageFromGallery()async
  {
imageFile= await ImagePicker.pickImage(source: ImageSource.gallery);
if(imageFile!=null)
  {
    isLoading=true;
  }
uploadImageFile();
  }

 Future uploadImageFile()async
  {
    String fileName=DateTime.now().millisecondsSinceEpoch.toString();
    StorageReference storageReference=FirebaseStorage.instance.ref().child('Chat Image').child(fileName);
    StorageUploadTask storageUploadTask=storageReference.putFile(imageFile);
    StorageTaskSnapshot storageTaskSnapshot=await storageUploadTask.onComplete;
    storageTaskSnapshot.ref.getDownloadURL().then((downLoadUrl){
      imageUrl=downLoadUrl;
      setState(() {
        isLoading=false;
        onSendMessage(imageUrl, 1);
      });
    },onError: (error){
      setState(() {
        isLoading=false;
      });
      Fluttertoast.showToast(msg: 'Error'+error);
    });
  }
  
 void getStiker()
  {
    focusNode.unfocus();
    setState(() {
      isDisplaySticker=!isDisplaySticker;
    });
  }
}

