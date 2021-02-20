
import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  // upload to fireStore
  final String id;
  final String nickName;
  final String createdAt;
  final String photoUrl;

  User(
      {this.id,
        this.photoUrl,
        this.createdAt,
      this.nickName});
// download from fireStore
  factory User.fromDocument(DocumentSnapshot doc) {
    return User(
      id: doc.documentID,
     createdAt: doc['createdAt'],
      photoUrl: doc['photoUrl'],
      nickName: doc['nickName'],
    );
  }
}