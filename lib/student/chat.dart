import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:page_transition/page_transition.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'home.dart';
//import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:intl/intl.dart';
//import 'dart:io';
//import 'dart:convert';

List chats = [
  'Chad Sprice',
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
                        child: StudentHomeScreen(
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
                    padding: EdgeInsets.only(top: 5, right: 6),
                    child: Icon(
                      Icons.search,
                      size: 30,
                      color: Colors.black54,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
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

  List messages = [
    ['Hey!', 'user'],
    ['Hello', 'me'],
    ['How has your day been going?', 'user'],
    ['Not too bad tbh', 'me'],
    ['Have you committed to any college yet?', 'user'],
  ];
  final TextEditingController textEditingController = TextEditingController();
  final FocusNode focusNode = FocusNode();
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    BackButtonInterceptor.add(myInterceptor);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent) {
    print("BACK BUTTON!");
    Navigator.pop(context);
    return true;
  }

  Widget buildMessage(index) {
    Timer(
        Duration(milliseconds: 100),
        () => _scrollController
            .jumpTo(_scrollController.position.maxScrollExtent));
    if (messages[index][1] == 'me') {
      return Column(
        children: <Widget>[
          Container(
            constraints: BoxConstraints(maxWidth: 200),
            child: Text(
              messages[index][0],
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.end,
            ),
            padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
            decoration: BoxDecoration(
                color: Colors.blue, borderRadius: BorderRadius.circular(8.0)),
            margin: EdgeInsets.only(bottom: 5.0, right: 10.0),
          ),
          if (index != (messages.length - 1) &&
              messages[index + 1][1] != messages[index][1]) ...[
            Container(
              child: Text(
                DateFormat('dd MMM kk:mm').format(DateTime.now()),
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 12.0,
                ),
              ),
              margin: EdgeInsets.only(right: 15, top: 5, bottom: 5),
            ),
          ],
          if (index == (messages.length - 1) &&
              messages[index - 1][1] == messages[index][1]) ...[
            Container(
              child: Text(
                DateFormat('dd MMM kk:mm').format(DateTime.now()),
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 12.0,
                ),
              ),
            ),
          ]
        ],
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
      );
    }
    if (messages[index][1] == 'app') {
      return Center(
        child: Padding(
          padding: EdgeInsets.only(top: 10, bottom: 10),
          child: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey[200],
            ),
            child: Text(
              messages[index][0],
              style: TextStyle(color: Colors.black54),
            ),
          ),
        ),
      );
    } else {
      return Container(
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Material(
                    child: CachedNetworkImage(
                      placeholder: (context, url) => Container(
                        child: CircularProgressIndicator(),
                        width: 35.0,
                        height: 35.0,
                        padding: EdgeInsets.all(10.0),
                      ),
                      imageUrl:
                          'https://www.pngfind.com/pngs/m/610-6104451_image-placeholder-png-user-profile-placeholder-image-png.png',
                      width: 30.0,
                      height: 30.0,
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.all(
                      Radius.circular(18.0),
                    ),
                    clipBehavior: Clip.hardEdge,
                  ),
                ),
                Container(
                  constraints: BoxConstraints(maxWidth: 200),
                  child: Text(
                    messages[index][0],
                    style: TextStyle(color: Colors.black),
                  ),
                  padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                  decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8.0)),
                  margin: EdgeInsets.only(bottom: 5, left: 10.0),
                )
              ],
            ),
            if (index != (messages.length - 1) &&
                messages[index + 1][1] != messages[index][1]) ...[
              Container(
                child: Text(
                  DateFormat('dd MMM kk:mm').format(DateTime.now()),
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 12.0,
                  ),
                ),
                margin: EdgeInsets.only(left: 50.0, top: 5.0, bottom: 5.0),
              )
            ]
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
        margin: EdgeInsets.only(bottom: 5.0),
      );
    }
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
      body: Column(
        children: <Widget>[
          Expanded(
            child: Padding(
                padding: EdgeInsets.only(top: 20, bottom: 10),
                child: Scrollbar(
                  child: ListView.builder(
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      return buildMessage(index);
                    },
                    controller: _scrollController,
                  ),
                )),
          ),
          Container(
            color: Colors.grey[100],
            width: double.infinity,
            child: Row(
              children: <Widget>[
                Material(
                  color: Colors.grey[100],
                  child: IconButton(
                    icon: Icon(Icons.insert_photo),
                    onPressed: () {},
                    color: Colors.black,
                  ),
                ),
                Flexible(
                  child: Padding(
                    padding: EdgeInsets.only(top: 5, bottom: 5),
                    child: TextField(
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      style: TextStyle(color: Colors.black, fontSize: 16.0),
                      controller: textEditingController,
                      decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black87),
                            borderRadius: BorderRadius.circular(8)),
                        contentPadding: EdgeInsets.all(5),
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black54),
                            borderRadius: BorderRadius.circular(8)),
                        hintText: 'Type your message...',
                        hintStyle: TextStyle(color: Colors.black54),
                      ),
                    ),
                  ),
                ),
                Material(
                  color: Colors.grey[100],
                  child: IconButton(
                    icon: Icon(Icons.send),
                    onPressed: () {},
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
