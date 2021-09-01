import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'chat_screen.dart';

final _fireStore = FirebaseFirestore.instance;
User loggedInUser;

class InboxScreenAdmin extends StatefulWidget {
  static const String routeName = 'online_users_screen';
  final String topHeading;

  const InboxScreenAdmin({Key key, this.topHeading}) : super(key: key);
  @override
  _InboxScreenAdminState createState() => _InboxScreenAdminState();
}

class _InboxScreenAdminState extends State<InboxScreenAdmin> {
  final messageTextController = TextEditingController();
  final _auth = FirebaseAuth.instance;

  String messageText;

  @override
  void initState() {
    super.initState();

    getCurrentUser();
  }

  void getCurrentUser() async {
    try {
      // ignore: await_only_futures
      final user = await _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        title: Text(
          '⚡️ ${widget.topHeading}',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.redAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessageStream(),
          ],
        ),
      ),
    );
  }
}

Stream<dynamic> dataFun() {
  var myData = _fireStore
      .collection('notifications')
      .doc('hassankhanarif@gmail.com')
      .collection('notifications')
      .snapshots();
  return myData;
}

class MessageStream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: dataFun(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(
                backgroundColor: Colors.lightBlueAccent,
              ),
            );
          }
          print('${snapshot.data.docs.length}');
          final messages = snapshot.data.docs.reversed;
          //print("here is my snapshot "+messages);
          List<MessageBubble> messageBubbles = [];

          for (var message in messages) {
            // final messageText = message.data['text'];
            final messageEmail = message.get('email');
            print(
                "messageEmail: $messageEmail currentUser ${loggedInUser.email}");
//TODO: change these data()
            //final messageSender = message.data()['sender'];

            DateTime dateTime = message.get('date').toDate();
            final messageDate =
                DateFormat.yMEd().add_jms().format(dateTime).toString();
            final currentUser = loggedInUser.email;
            // ignore: unused_local_variable
            final currentUserUid = loggedInUser.uid;
            // ignore: unused_local_variable
            final currentUserPic = loggedInUser.photoURL;
            if (currentUser == messageEmail) {
              // The message from logged in Use
            }

            final messageBubble = MessageBubble(
              sender: messageEmail,
              text: messageDate.toString(),
              isMe: currentUser == messageEmail,
            );
            messageBubbles.add(messageBubble);
          }

          return Expanded(
            child: ListView(
              // reverse: true,
              padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
              children: messageBubbles,
            ),
          );
        });
  }
}

class MessageBubble extends StatelessWidget {
  final String sender;
  final String text;
  final bool isMe;

  MessageBubble({this.sender, this.text, this.isMe});

  @override
  Widget build(BuildContext context) {
    //print("sender : ${sender} text: ${text}");

    return Padding(
      padding: EdgeInsets.all(10.0),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, 'chat_screen', arguments: sender);
        },
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              sender,
              style: TextStyle(
                fontSize: 12.0,
                color: Colors.black54,
              ),
            ),
            Row(
              //crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              mainAxisAlignment:
                  isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
              children: isMe
                  ? [
                      Material(
                        elevation: 5.0,
                        borderRadius: isMe
                            ? BorderRadius.only(
                                topLeft: Radius.circular(30.0),
                                bottomLeft: Radius.circular(30.0),
                                bottomRight: Radius.circular(30.0),
                              )
                            : BorderRadius.only(
                                topRight: Radius.circular(30.0),
                                bottomLeft: Radius.circular(30.0),
                                bottomRight: Radius.circular(30.0),
                              ),
                        color: isMe ? Colors.lightBlueAccent : Colors.redAccent,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 10.0,
                            horizontal: 20.0,
                          ),
                          child: Text(
                            isMe ? "You" : '$text',
                            style: TextStyle(
                              fontSize: 15.0,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      // CircleAvatar(
                      //   backgroundColor:
                      //       isMe ? Colors.lightBlueAccent : Colors.redAccent,
                      //   child: Text(sender.substring(0, 1).toUpperCase()),
                      // ),
                    ]
                  : [
                      // CircleAvatar(
                      //   backgroundColor:
                      //       isMe ? Colors.lightBlueAccent : Colors.redAccent,
                      //   child: Text(sender.substring(0, 1).toUpperCase()),
                      // ),
                      Material(
                        elevation: 5.0,
                        borderRadius: isMe
                            ? BorderRadius.only(
                                topLeft: Radius.circular(30.0),
                                bottomLeft: Radius.circular(30.0),
                                bottomRight: Radius.circular(30.0),
                              )
                            : BorderRadius.only(
                                topRight: Radius.circular(30.0),
                                bottomLeft: Radius.circular(30.0),
                                bottomRight: Radius.circular(30.0),
                              ),
                        color: isMe ? Colors.lightBlueAccent : Colors.redAccent,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 10.0,
                            horizontal: 20.0,
                          ),
                          child: Text(
                            '$text',
                            style: TextStyle(
                              fontSize: 10.0,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
            ),
          ],
        ),
      ),
    );
  }
}

// To parse this JSON data, do
//
//     final message = messageFromJson(jsonString);
