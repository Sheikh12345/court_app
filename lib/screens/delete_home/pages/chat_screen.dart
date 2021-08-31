import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import '../screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:court_app/utils/constants.dart';

final _firestore = FirebaseFirestore.instance;
User loggedInUser;

class ChatScreen extends StatefulWidget {
  static const String routeName = 'chat_screen';

  ChatScreen({this.receiverEmail});

  final String receiverEmail;

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messageTextController = TextEditingController();
  final _auth = FirebaseAuth.instance;

  String messageText;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getCurrentUser();
  }

  void getCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
        //  print(loggedInUser.email);
        // print(loggedInUser.uid);
        //  print(loggedInUser.displayName);
        print(loggedInUser.metadata.toString());
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final receiverEmail = ModalRoute.of(context).settings.arguments;

    //print("receiver email from chat screen : ${receiverEmail}");
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              //Implement logout functionality
              // try{
              //messageStream();
              // _auth.signOut();
              // Navigator.pushNamed(context, WelcomeScreen.id);

              // } catch(e){
              //   print(e);
              // }
              // getMessages();
            },
          ),
        ],
        title: Text('⚡️Chat', style: TextStyle(color: Colors.white)),
        backgroundColor: kPrimaryColor,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessageStream(
              receiver: receiverEmail,
            ),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageTextController,
                      onChanged: (_value) {
                        //Do something with the user input.
                        messageText = _value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  MaterialButton(
                    onPressed: () {
                      //print(receiverEmail.toString());
                      //Implement send functionality.
                      messageTextController.clear();
                      _firestore
                          .collection('messages')
                          //sender
                          .doc(loggedInUser.email)
                          // receiver
                          .collection(receiverEmail)
                          .add(
                        {
                          'text': messageText.toString(),
                          'sender': loggedInUser.email.toString(),
                          'receiver': receiverEmail,
                          'date': DateTime.now(),
                        },
                      );

                      _firestore
                          .collection('messages')
                          //sender
                          .doc(receiverEmail)
                          // receiver
                          .collection(loggedInUser.email)
                          .add(
                        {
                          'text': messageText.toString(),
                          'sender': loggedInUser.email.toString(),
                          'receiver': receiverEmail,
                          'date': DateTime.now(),
                        },
                      );

                      _firestore
                          .collection('notifications')
                          //sender
                          .doc(receiverEmail)
                          // receiver
                          .collection('notifications')
                          .doc(loggedInUser.email)
                          .set(
                        {
                          // 'text': messageText.toString(),
                          // 'sender': loggedInUser.email.toString(),
                          // 'receiver': receiverEmail,
                          'email': loggedInUser.email.toString(),
                          'date': DateTime.now(),
                        },
                      );
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageStream extends StatelessWidget {
  final String receiver;

  MessageStream({this.receiver});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('messages')
            .doc(FirebaseAuth.instance.currentUser.email)
            .collection(receiver)
            .orderBy('date', descending: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(
                backgroundColor: Colors.lightBlueAccent,
              ),
            );
          }
          final messages = snapshot.data.docs.reversed;
          List<MessageBubble> messageBubbles = [];

          for (var message in messages) {
            // final messageText = message.data['text'];
            final messageText = message.get('text');
            //print(messageText);
//TODO: change these data()
            //final messageSender = message.data()['sender'];
            final messageSender = message.get('sender');
            final currentUser = loggedInUser.email;

            if (currentUser == messageSender) {
              // The message from logged in User

            }

            final messageBubble = MessageBubble(
              sender: messageSender,
              text: messageText.toString(),
              isMe: currentUser == messageSender,
            );
            print("currentUser $currentUser messageSender $messageSender");
            messageBubbles.add(messageBubble);
          }
          return Expanded(
            child: ListView(
              shrinkWrap: false,
              reverse: false,
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
    return Padding(
      padding: EdgeInsets.all(10.0),
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
                      color: isMe ? Colors.grey : Colors.redAccent,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 10.0,
                          horizontal: 20.0,
                        ),
                        child: Text(
                          '$text',
                          style: TextStyle(
                            fontSize: 15.0,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 1,
                    ),
                    CircleAvatar(
                      backgroundColor: isMe ? Colors.grey : Colors.redAccent,
                      child: Text(sender.substring(0, 1).toUpperCase()),
                    ),
                  ]
                : [
                    CircleAvatar(
                      backgroundColor:
                          isMe ? Colors.lightBlueAccent : Colors.redAccent,
                      child: Text(sender.substring(0, 1).toUpperCase()),
                    ),
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
                        // child: Text(
                        //   '$text',
                        //   style: TextStyle(
                        //     fontSize: 15.0,
                        //     color: Colors.white,
                        //   ),
                        // ),
                      ),
                    ),
                  ],
          ),
        ],
      ),
    );
  }
}
