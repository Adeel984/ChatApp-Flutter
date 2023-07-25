import 'package:chat_app/utils/FirebaseHelper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Inbox extends StatefulWidget {
  const Inbox({super.key});

  @override
  State<Inbox> createState() => _InboxState();
}

class _InboxState extends State<Inbox> {
  final Stream<QuerySnapshot> _usersStream =
      FirebaseFirestore.instance.collection('Users').snapshots();

  void logout() {
    FirebaseHelper().logoutUser();
    Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    var user = FirebaseHelper().getLoggedInUser()!;

    return Scaffold(
        appBar: AppBar(
          title: Text("Chats"),
          actions: [IconButton(onPressed: logout, icon: Icon(Icons.logout))],
        ),
        body: StreamBuilder<QuerySnapshot>(
            stream: _usersStream,
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasData) {
                var dataList = snapshot.data!.docs
                    .where((item) =>
                        (item.data() as Map<String, dynamic>)["uid"] !=
                        user.uid)
                    .toList();
                return ListView.separated(
                    separatorBuilder: (contex, index) {
                      return Divider(
                        color: Colors.black26,
                        thickness: 1,
                      );
                    },
                    itemCount: dataList.length,
                    itemBuilder: (context, index) {
                      var item = dataList[index].data() as Map<String, dynamic>;
                      return ListTile(
                        onTap: () {
                          Navigator.pushNamed(context, '/chat',
                              arguments: item);
                        },
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue,
                          radius: 30,
                          backgroundImage: item["image"] != null
                              ? NetworkImage(item["image"])
                              : null,
                        ),
                        title: Text(item["name"]),
                        subtitle: Text("Last message"),
                        trailing: Text("Today"),
                      );
                    });
              }
              return CircularProgressIndicator();
            }));
  }
}
