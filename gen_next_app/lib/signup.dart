import 'package:flutter/cupertino.dart';
//import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
//import 'package:page_transition/page_transition.dart';
//import 'student/home.dart';

class SignUpPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SignUpPageState();
}

class SignUpPageState extends State<SignUpPage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    List<Widget> _pageOptions = <Widget>[
      Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.bottomLeft, end: Alignment.topRight, colors: [Colors.cyan[300], Colors.blueGrey[800]]),
        ),
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 200),
              child: Text(
                "Hi there !",
                style: TextStyle(color: Colors.white, fontSize: 50, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 10, left: 10, right: 10),
              child: Text(
                "Welcome to Gen Next Edu's App !",
                style: TextStyle(color: Colors.white, fontSize: 23),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 10, left: 20, right: 20),
              child: Text(
                "Our goal is to help students like you dash through the college admission process, with the help of our talented team and this feature-packed app",
                style: TextStyle(color: Colors.white, fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 50, left: 10, right: 10),
              child: Text(
                "Click start to begin your journey with us.\nBear in mind that none of your information\nwill be released without your permission",
                style: TextStyle(color: Colors.white70, fontSize: 15),
                textAlign: TextAlign.center,
              ),
            ),
            Row(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 30, left: 130),
                  child: Text(
                    "START",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 30, right: 15),
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_forward,
                      size: 30,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        _selectedIndex += 1;
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.bottomLeft, end: Alignment.topRight, colors: [Colors.cyan[300], Colors.blueGrey[800]]),
        ),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 300),
              child: Center(
                child: Text(
                  'Page 2',
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 310, bottom: 5),
              child: Row(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: IconButton(
                          icon: Icon(
                            Icons.arrow_back,
                            size: 30,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            setState(() {
                              _selectedIndex -= 1;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(0),
                        child: Text(
                          "BACK",
                          style: TextStyle(color: Colors.white70, fontSize: 15),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(left: 160, right: 0),
                        child: Text(
                          "NEXT",
                          style: TextStyle(color: Colors.white70, fontSize: 15),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(right: 10),
                        child: IconButton(
                          icon: Icon(
                            Icons.arrow_forward,
                            size: 30,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            setState(() {
                              _selectedIndex += 1;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.bottomLeft, end: Alignment.topRight, colors: [Colors.cyan[300], Colors.blueGrey[800]]),
        ),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 300),
              child: Center(
                child: Text(
                  'Page 3',
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 310, bottom: 5),
              child: Row(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: IconButton(
                          icon: Icon(
                            Icons.arrow_back,
                            size: 30,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            setState(() {
                              _selectedIndex -= 1;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(0),
                        child: Text(
                          "BACK",
                          style: TextStyle(color: Colors.white70, fontSize: 15),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(left: 160, right: 0),
                        child: Text(
                          "NEXT",
                          style: TextStyle(color: Colors.white70, fontSize: 15),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(right: 10),
                        child: IconButton(
                          icon: Icon(
                            Icons.arrow_forward,
                            size: 30,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            setState(() {
                              _selectedIndex += 1;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.bottomLeft, end: Alignment.topRight, colors: [Colors.cyan[300], Colors.blueGrey[800]]),
        ),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 300),
              child: Center(
                child: Text(
                  'Page 4',
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 310, bottom: 5),
              child: Row(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: IconButton(
                          icon: Icon(
                            Icons.arrow_back,
                            size: 30,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            setState(() {
                              _selectedIndex -= 1;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(0),
                        child: Text(
                          "BACK",
                          style: TextStyle(color: Colors.white70, fontSize: 15),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(left: 155, right: 0),
                        child: Text(
                          "FINISH",
                          style: TextStyle(color: Colors.white70, fontSize: 15),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(right: 10),
                        child: IconButton(
                          icon: Icon(
                            Icons.arrow_forward,
                            size: 30,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            setState(() {
                              _selectedIndex += 0;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    ];

    return Scaffold(
      body: _pageOptions.elementAt(_selectedIndex),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(canvasColor: Colors.cyan[500]),
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.fiber_manual_record),
              title: Text(''),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.fiber_manual_record),
              title: Text(''),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.fiber_manual_record),
              title: Text(''),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.fiber_manual_record),
              title: Text(''),
            ),
          ],
          unselectedItemColor: Colors.cyan[200],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.cyan[900],
        ),
      ),
    );
  }
}
