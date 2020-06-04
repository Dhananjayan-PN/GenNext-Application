import 'package:flutter/material.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:page_transition/page_transition.dart';
import 'home.dart';

class ProfileScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
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
    Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.fade,
            child: CounselorHomeScreen(user: newUser)));
    return true;
  }

  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Colors.white,
      drawer: NavDrawer(
          name: newUser.firstname + ' ' + newUser.lastname,
          email: newUser.email),
      appBar: CustomAppBar('My Profile'),
      body: Padding(
        padding: const EdgeInsets.only(top: 15, left: 10, right: 10),
        child: Card(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(15))),
          elevation: 20,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: CircleAvatar(
                  backgroundImage: CachedNetworkImageProvider(newUser.dp),
                  backgroundColor: Colors.blue[400],
                  radius: 30,
                ),
                title: Text(
                  newUser.firstname + ' ' + newUser.lastname,
                  style: TextStyle(fontSize: 17),
                ),
                subtitle: Text('Counselor'),
                trailing: Padding(
                  padding: EdgeInsets.all(0),
                  child: IconButton(
                    icon: Icon(
                      Icons.edit,
                      color: Colors.blue,
                    ),
                    onPressed: () {},
                  ),
                ),
              ),
              Divider(
                thickness: 1,
                indent: 20,
                endIndent: 20,
              ),
              Padding(
                padding: EdgeInsets.only(top: 5, left: 20),
                child: Row(
                  children: <Widget>[
                    Text(
                      'Username: ',
                    ),
                    Text(
                      '@' + newUser.username,
                      style: TextStyle(color: Colors.black54),
                    )
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 15, left: 20),
                child: Row(
                  children: <Widget>[
                    Text(
                      'Email ID: ',
                    ),
                    Text(
                      newUser.email,
                      style: TextStyle(color: Colors.black54),
                    )
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 15, left: 20),
                child: Row(
                  children: <Widget>[
                    Text(
                      'Date of Birth: ',
                    ),
                    Text(
                      newUser.dob,
                      style: TextStyle(color: Colors.black54),
                    )
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 15, left: 20, bottom: 15),
                child: Row(
                  children: <Widget>[
                    Text(
                      'Country: ',
                    ),
                    Text(
                      newUser.country,
                      style: TextStyle(color: Colors.black54),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
