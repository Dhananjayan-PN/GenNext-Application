import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:page_transition/page_transition.dart';
import 'package:dash_chat/dash_chat.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../main.dart';
import 'home.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:io';
import 'dart:convert';

List chats = [
  'Racheal Oster',
  'Modesta Feenstra',
  'Mireille Nitti',
  'Clarice Mccracken',
  'Tyler Wedgeworth',
  'Lera Frisbie',
  'Myrna Blish',
  'Rocio Linney',
  'Lilla Horner',
  'Evangelina Stribling',
  'Cristopher Verdin',
  'Clemencia Woodrum',
  'Danna Donis',
  'Corinna Super',
  'Cristine Weatherly',
  'Arlean Garbarino',
  'Lurlene Antley',
  'Madeleine Schear',
  'Eric Speir',
  'Omer Hazell',
];

class AllChats extends StatefulWidget {
  @override
  _AllChatsState createState() => _AllChatsState();
}

class _AllChatsState extends State<AllChats> {
  var refreshKey = GlobalKey<RefreshIndicatorState>();
  TextEditingController controller = TextEditingController();
  String filter;

  @override
  void initState() {
    super.initState();
    BackButtonInterceptor.add(myInterceptor);
    controller.addListener(() {
      setState(() {
        filter = controller.text;
      });
    });
  }

  @override
  void dispose() {
    controller.dispose();
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent) {
    print("BACK BUTTON!");
    return true;
  }

  newChat() {}

  Widget buildCard(int index) {
    return Padding(
      padding: EdgeInsets.only(top: 0, left: 10, right: 10),
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(13))),
        elevation: 8,
        child: ListTile(
          leading: CircleAvatar(
            radius: 25,
            backgroundImage: CachedNetworkImageProvider(
                'https://www.pngfind.com/pngs/m/610-6104451_image-placeholder-png-user-profile-placeholder-image-png.png'),
            backgroundColor: Colors.blue[400],
          ),
          title: Text(chats[index]),
          subtitle: Row(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(right: 5),
                child: Icon(
                  Icons.done_all,
                  color: Colors.blue[200],
                  size: 18,
                ),
              ),
              Text('Hello, how are you?')
            ],
          ),
          trailing: IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () {},
          ),
          onTap: () {
            Navigator.push(
              context,
              PageTransition(
                curve: Curves.ease,
                duration: Duration(milliseconds: 500),
                type: PageTransitionType.rightToLeft,
                child: OpenChat(
                  otherUser: chats[index],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: FloatingActionButton(
            tooltip: 'New Chat',
            elevation: 10,
            backgroundColor: Colors.blue,
            splashColor: Colors.blue[900],
            child: Icon(
              Icons.add,
              size: 28,
              color: Colors.white,
            ),
            onPressed: () {
              newChat();
            }),
        backgroundColor: Colors.white,
        appBar: GradientAppBar(
          leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    PageTransition(
                        duration: Duration(milliseconds: 600),
                        type: PageTransitionType.leftToRight,
                        child: CounselorHomeScreen(
                          user: newUser,
                        )));
              }),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.more_vert),
              onPressed: () {},
            )
          ],
          centerTitle: true,
          title: Text(
            'Chats',
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xff00AEEF), Color(0xff0072BC)]),
        ),
        body: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 5, left: 18, right: 30),
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 5, right: 6),
                    child: Icon(
                      Icons.search,
                      size: 30,
                      color: Colors.black54,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      decoration: new InputDecoration(
                          labelText: "Search",
                          contentPadding: EdgeInsets.all(2)),
                      controller: controller,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(top: 15),
                child: Scrollbar(
                  child: ListView.builder(
                    itemCount: chats.length,
                    itemBuilder: (context, index) {
                      return filter == null || filter == ""
                          ? buildCard(index)
                          : chats[index].toLowerCase().contains(filter)
                              ? buildCard(index)
                              : Container();
                    },
                  ),
                ),
              ),
            ),
          ],
        ));
  }
}

class OpenChat extends StatefulWidget {
  final String otherUser;
  OpenChat({this.otherUser});

  @override
  _OpenChatState createState() => _OpenChatState(otherUser: otherUser);
}

class _OpenChatState extends State<OpenChat> {
  final String otherUser;
  _OpenChatState({this.otherUser});

  @override
  void initState() {
    super.initState();
    BackButtonInterceptor.add(myInterceptor);
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent) {
    print("BACK BUTTON!");
    Navigator.pop(context);
    return true;
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
            }),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () {},
          )
        ],
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            CircleAvatar(
              radius: 20,
              backgroundImage: CachedNetworkImageProvider(
                  'https://www.pngfind.com/pngs/m/610-6104451_image-placeholder-png-user-profile-placeholder-image-png.png'),
              backgroundColor: Colors.blue[400],
            ),
            Padding(
              padding: EdgeInsets.only(left: 15),
              child: Text(
                otherUser,
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
          ],
        ),
        gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xff00AEEF), Color(0xff0072BC)]),
      ),
      body: Container(),
    );
  }
}
