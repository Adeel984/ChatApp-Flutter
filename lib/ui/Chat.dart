import 'package:chat_app/utils/FirebaseHelper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Chat extends StatefulWidget {
  const Chat({super.key});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  var chatController = TextEditingController();
  late Stream<QuerySnapshot> _messagesStream;
  bool streamInitialized = false;

  void sendMessage() {
    var message = chatController.text;
    if (message.isNotEmpty) {
      var timeStamp = DateTime.now().millisecondsSinceEpoch;
      var fromId = FirebaseHelper().getLoggedInUser()!.uid;
      var otherUser =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      var toId = otherUser["uid"];
      var firstChatId = "${fromId}-${toId}";
      var secondChatId = "${toId}-${fromId}";

      FirebaseHelper().addChat(message, timeStamp, fromId, toId, firstChatId);
      FirebaseHelper().addChat(message, timeStamp, fromId, toId, secondChatId);
      chatController.clear();
    }
  }

  Widget ChatItem(item, index) {
    bool isMyMessage =
        item["fromId"] == FirebaseHelper().getLoggedInUser()!.uid;
    ;
    return Container(
      padding: EdgeInsets.only(left: 14, right: 14, top: 10, bottom: 10),
      child: Align(
        alignment: (!isMyMessage ? Alignment.topLeft : Alignment.topRight),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: (!isMyMessage ? Colors.grey.shade200 : Colors.blue[200]),
          ),
          padding: EdgeInsets.all(16),
          child: Text(
            item["message"],
            style: TextStyle(fontSize: 15),
          ),
        ),
      ),
    );
  }

  void initializeStream() {
    var fromId = FirebaseHelper().getLoggedInUser()!.uid;
    var otherUser =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    var toId = otherUser["uid"];
    var firstChatId = "${fromId}-${toId}";
    _messagesStream = FirebaseFirestore.instance
        .collection('Chats')
        .doc(firstChatId)
        .collection("messages")
        .snapshots();

    // Strem initalized
    setState(() {
      streamInitialized = true;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration(seconds: 2), () {
      initializeStream();
    });
  }

  @override
  Widget build(BuildContext context) {
    var user =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          flexibleSpace: SafeArea(
            child: Container(
              padding: EdgeInsets.only(right: 16),
              child: Row(
                children: <Widget>[
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(
                      Icons.arrow_back,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(
                    width: 2,
                  ),
                  CircleAvatar(
                    backgroundImage: user["image"] != null
                        ? NetworkImage(user["image"])
                        : null,
                    maxRadius: 20,
                  ),
                  SizedBox(
                    width: 12,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          user["name"],
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        SizedBox(
                          height: 6,
                        ),
                        Text(
                          "Online",
                          style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.settings,
                    color: Colors.black54,
                  ),
                ],
              ),
            ),
          ),
        ),
        body: streamInitialized
            ? Stack(
                children: <Widget>[
                  StreamBuilder<QuerySnapshot>(
                      stream: _messagesStream,
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.hasData) {
                          var messageList = snapshot.data!.docs;

                          return ListView.builder(
                            itemCount: messageList.length,
                            shrinkWrap: true,
                            padding: EdgeInsets.only(top: 10, bottom: 10),
                            physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              var item = messageList[index].data()
                                  as Map<String, dynamic>;
                              return ChatItem(item, index);
                            },
                          );
                        }
                        return CircularProgressIndicator();
                      }),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Container(
                      padding: EdgeInsets.only(left: 10, bottom: 10, top: 10),
                      height: 60,
                      width: double.infinity,
                      color: Colors.white,
                      child: Row(
                        children: <Widget>[
                          GestureDetector(
                            onTap: () {},
                            child: Container(
                              height: 30,
                              width: 30,
                              decoration: BoxDecoration(
                                color: Colors.lightBlue,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 15,
                          ),
                          Expanded(
                            child: TextField(
                              controller: chatController,
                              decoration: InputDecoration(
                                  hintText: "Write message...",
                                  hintStyle: TextStyle(color: Colors.black54),
                                  border: InputBorder.none),
                            ),
                          ),
                          SizedBox(
                            width: 15,
                          ),
                          FloatingActionButton(
                            onPressed: sendMessage,
                            child: Icon(
                              Icons.send,
                              color: Colors.white,
                              size: 18,
                            ),
                            backgroundColor: Colors.blue,
                            elevation: 0,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : Text("Please wait..."));
  }
}
