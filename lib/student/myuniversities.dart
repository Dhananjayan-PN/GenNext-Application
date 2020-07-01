import 'package:flutter/material.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:page_transition/page_transition.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'package:checklist/checklist.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import '../universitypage.dart';
import '../shimmer_skeleton.dart';
import 'home.dart';

class MyUniversitiesScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MyUniversitiesScreenState();
}

class MyUniversitiesScreenState extends State<MyUniversitiesScreen> {
  GlobalKey<ScaffoldState> _scafKey = GlobalKey<ScaffoldState>();
  var refreshKey2 = GlobalKey<RefreshIndicatorState>();
  TextEditingController controller1 = TextEditingController();
  TextEditingController controller2 = TextEditingController();
  ScrollController scrollController = ScrollController();
  String filter1;
  String filter2;
  List unis;
  bool isStarred;

  Future collegeList;
  Future favoritedList;

  List categories = ['Reach', 'Match', 'Safety'];

  @override
  void initState() {
    super.initState();
    BackButtonInterceptor.add(myInterceptor);
    controller1.addListener(() {
      setState(() {
        filter1 = controller1.text.toLowerCase();
      });
    });
    controller2.addListener(() {
      setState(() {
        filter2 = controller2.text.toLowerCase();
      });
    });
    collegeList = getCollegeList();
    favoritedList = getFavorited();
  }

  @override
  void dispose() {
    controller1.dispose();
    controller2.dispose();
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent) {
    print("BACK BUTTON!");
    Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.fade,
            child: StudentHomeScreen(
              user: newUser,
            )));
    return true;
  }

  Future<void> getCollegeList() async {
    final response = await http.get(
      dom + 'api/student/get-college-list',
      headers: {HttpHeaders.authorizationHeader: "Token $tok"},
    );
    if (response.statusCode == 200) {
      List list = [];
      list.add(json.decode(response.body)['reach_college_list_data']);
      list.add(json.decode(response.body)['match_college_list_data']);
      list.add(json.decode(response.body)['safety_college_list_data']);
      return list;
    } else {
      throw 'failed';
    }
  }

  Future<void> getFavorited() async {
    final response = await http.get(
      dom + 'api/student/get-favorited-universities',
      headers: {HttpHeaders.authorizationHeader: "Token $tok"},
    );
    if (response.statusCode == 200) {
      return json.decode(response.body)['favorited_university_data'];
    } else {
      throw 'failed';
    }
  }

  Future<void> editFavoritedStatus(uni, int id, bool curStatus) async {
    final statString = curStatus ? 'unfavorite' : 'favorite';
    final response = await http.put(
      dom + 'api/student/edit-favorite-status/$id/$statString',
      headers: {HttpHeaders.authorizationHeader: "Token $tok"},
    );
    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['Response'] == 'University successfully favorited.') {
        _scafKey.currentState.showSnackBar(
          SnackBar(
            duration: Duration(seconds: 2),
            content: Text(
              'University Favorited',
              textAlign: TextAlign.center,
            ),
          ),
        );
        refresh();
      } else if (result['Response'] == 'University successfully unfavorited.') {
        _scafKey.currentState.showSnackBar(
          SnackBar(
            duration: Duration(seconds: 2),
            content: Text(
              'University Unfavorited',
              textAlign: TextAlign.center,
            ),
          ),
        );
        refresh();
      } else {
        _scafKey.currentState.showSnackBar(
          SnackBar(
            duration: Duration(seconds: 2),
            content: Text(
              'Unable to send request. Try again later.',
              textAlign: TextAlign.center,
            ),
          ),
        );
        refresh();
      }
    } else {
      _scafKey.currentState.showSnackBar(
        SnackBar(
          duration: Duration(seconds: 2),
          content: Text(
            'Unable to send request. Try again later.',
            textAlign: TextAlign.center,
          ),
        ),
      );
      refresh();
    }
  }

  editFavorited(uni) {
    Future.delayed(Duration(milliseconds: 200), () {
      editFavoritedStatus(uni, uni['university_id'], uni['favorited_status'])
          .timeout(Duration(seconds: 10));
    });
  }

  void refresh() {
    setState(() {
      favoritedList = getFavorited();
      collegeList = getCollegeList();
    });
  }

  Widget buildCard(snapshot, int index) {
    unis = snapshot;
    unis[index]['favorited_status'] = true;
    return Padding(
      padding: EdgeInsets.only(top: 5, left: 10, right: 10),
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10))),
        elevation: 6,
        child: CachedNetworkImage(
          imageUrl:
              "https://www.wpr.org/sites/default/files/bascom_hall_summer.jpg",
          placeholder: (context, url) => CardSkeleton(
            padding: 0,
            isBottomLinesActive: false,
          ),
          errorWidget: (context, url, error) {
            _scafKey.currentState.showSnackBar(
              SnackBar(
                content: Text(
                  'Failed to fetch data. Check your internet connection and try again',
                  textAlign: TextAlign.center,
                ),
              ),
            );
            return Icon(Icons.error);
          },
          imageBuilder: (context, imageProvider) => Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                alignment: Alignment.center,
                colorFilter: ColorFilter.mode(
                    Colors.black.withAlpha(160), BlendMode.darken),
                image: imageProvider,
                fit: BoxFit.cover,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: ListTile(
                key: Key(unis[index]['university_id'].toString()),
                title: Text(
                  unis[index]['university_name'],
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  unis[index]['university_location'],
                  style: TextStyle(color: Colors.white.withOpacity(0.8)),
                ),
                trailing: Wrap(
                  children: <Widget>[
                    InkWell(
                      child: Icon(Icons.star, color: Colors.white),
                      onTap: () {
                        editFavorited(unis[index]);
                      },
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: InkWell(
                        child: Icon(
                          Icons.more_vert,
                          color: Colors.white,
                        ),
                        onTap: () {},
                      ),
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    PageTransition(
                        type: PageTransitionType.fade, child: UniversityPage()),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildCollegeListCard(uni) {
    Widget uniCard = Padding(
      padding: EdgeInsets.only(top: 6, left: 10, right: 10, bottom: 2),
      child: Material(
        color: Colors.transparent,
        child: Card(
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10))),
          elevation: 6,
          child: Material(
            color: Colors.transparent,
            child: CachedNetworkImage(
              imageUrl:
                  "https://www.wpr.org/sites/default/files/bascom_hall_summer.jpg",
              placeholder: (context, url) => CardSkeleton(
                padding: 0,
                isBottomLinesActive: false,
              ),
              errorWidget: (context, url, error) {
                _scafKey.currentState.showSnackBar(
                  SnackBar(
                    content: Text(
                      'Failed to fetch data. Check your internet connection and try again',
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
                return Icon(Icons.error);
              },
              imageBuilder: (context, imageProvider) => Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    alignment: Alignment.center,
                    colorFilter: ColorFilter.mode(
                        Colors.black.withAlpha(160), BlendMode.darken),
                    image: imageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: ListTile(
                    key: Key(uni['university_id'].toString()),
                    title: Text(
                      uni['university_name'],
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      uni['university_location'],
                      style: TextStyle(color: Colors.white.withOpacity(0.8)),
                    ),
                    trailing: Wrap(
                      children: <Widget>[
                        InkWell(
                          child: uni['favorited_status']
                              ? Icon(Icons.star, color: Colors.white)
                              : Icon(Icons.star_border, color: Colors.white),
                          onTap: () {
                            editFavorited(uni);
                          },
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 8.0),
                          child: InkWell(
                            child: Icon(
                              Icons.more_vert,
                              color: Colors.white,
                            ),
                            onTap: () {},
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        PageTransition(
                            type: PageTransitionType.fade,
                            child: UniversityPage()),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    return uniCard;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        key: _scafKey,
        backgroundColor: Colors.white,
        drawer: NavDrawer(
            name: newUser.firstname + ' ' + newUser.lastname,
            email: newUser.email),
        appBar: GradientAppBar(
          elevation: 6,
          title: Text(
            'My Universities',
            style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: Platform.isIOS ? FontWeight.w500 : FontWeight.w400),
          ),
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xff00AEEF), Color(0xff0072BC)]),
          bottom: TabBar(
            tabs: [
              Tab(
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                    Icon(Icons.view_list),
                    Padding(
                      padding: EdgeInsets.only(left: 3.0),
                      child: Text('College List'),
                    )
                  ])),
              Tab(
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                    Icon(Icons.star),
                    Padding(
                      padding: EdgeInsets.only(left: 3.0),
                      child: Text('Favorited'),
                    )
                  ])),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            FutureBuilder(
              future: collegeList.timeout(Duration(seconds: 10)),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 40.0),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.error_outline,
                            size: 30,
                            color: Colors.red.withOpacity(0.9),
                          ),
                          Text(
                            'Unable to establish a connection with our servers.\nCheck your connection and try again later.',
                            style: TextStyle(color: Colors.black54),
                            textAlign: TextAlign.center,
                          )
                        ],
                      ),
                    ),
                  );
                }
                if (snapshot.hasData) {
                  if (snapshot.data.length == 0) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 100),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Padding(
                                padding: EdgeInsets.only(
                                    top: 5, left: 30, right: 30),
                                child: Text(
                                  "You haven't added any universities to your college list yet",
                                  style: TextStyle(color: Colors.black54),
                                  textAlign: TextAlign.center,
                                )),
                            Padding(
                              padding: EdgeInsets.only(top: 3),
                              child: Text(
                                  "Add a few from the 'Explore' page to\nsee them show up here!",
                                  style: TextStyle(color: Colors.black54),
                                  textAlign: TextAlign.center),
                            )
                          ],
                        ),
                      ),
                    );
                  } else {
                    List<ChecklistView> checklistsViews = [];
                    for (var i = 0; i < snapshot.data.length; i++) {
                      List<ChecklistItemView> subItems = [];
                      for (var j = 0; j < snapshot.data[i].length; j++) {
                        subItems.add(ChecklistItemView(
                          title: buildCollegeListCard(snapshot.data[i][j]),
                          onStartDragItem: (listIndex, itemIndex, state) {},
                          canDrag: true,
                          onDropItem: (oldListIndex, oldItemIndex, listIndex,
                              itemIndex, state) {},
                        ));
                      }
                      checklistsViews.add(ChecklistView(
                        items: subItems,
                        isOpen: true,
                        canDrag: false,
                        onDropChecklist: (oldIndex, newIndex, state) {},
                        title: Padding(
                          padding: EdgeInsets.only(left: 20, top: 20),
                          child: Text(categories[i],
                              style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 25,
                                  fontWeight: FontWeight.w300)),
                        ),
                      ));
                    }
                    return Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: ChecklistListView(
                        controller: scrollController,
                        checklists: checklistsViews,
                      ),
                    );
                  }
                }
                return Padding(
                  padding: EdgeInsets.only(top: 60),
                  child: CardListSkeleton(
                    isBottomLinesActive: false,
                    length: 10,
                  ),
                );
              },
            ),
            RefreshIndicator(
              key: refreshKey2,
              onRefresh: () {
                refresh();
                return collegeList;
              },
              child: FutureBuilder(
                future: favoritedList.timeout(Duration(seconds: 10)),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 40.0),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(
                              Icons.error_outline,
                              size: 30,
                              color: Colors.red.withOpacity(0.9),
                            ),
                            Text(
                              'Unable to establish a connection with our servers.\nCheck your connection and try again later.',
                              style: TextStyle(color: Colors.black54),
                              textAlign: TextAlign.center,
                            )
                          ],
                        ),
                      ),
                    );
                  }
                  if (snapshot.hasData) {
                    if (snapshot.data.length == 0) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: 70),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Opacity(
                                opacity: 0.9,
                                child: Image.asset(
                                  "images/snap.gif",
                                  height: 100.0,
                                  width: 100.0,
                                ),
                              ),
                              Text(
                                'Oh Snap!',
                                style: TextStyle(
                                    fontSize: 18, color: Colors.black54),
                              ),
                              Padding(
                                  padding: EdgeInsets.only(
                                      top: 5, left: 30, right: 30),
                                  child: Text(
                                    "Looks like you haven't\nfavorited any universites",
                                    style: TextStyle(color: Colors.black54),
                                    textAlign: TextAlign.center,
                                  )),
                              Padding(
                                padding: EdgeInsets.only(top: 3),
                                child: Text(
                                    "Head over to Explore to favorite some",
                                    style: TextStyle(color: Colors.black54),
                                    textAlign: TextAlign.center),
                              )
                            ],
                          ),
                        ),
                      );
                    } else {
                      return Column(
                        children: <Widget>[
                          Padding(
                            padding:
                                EdgeInsets.only(top: 5, left: 18, right: 30),
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
                                    controller: controller2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(top: 20.0),
                              child: Scrollbar(
                                child: ListView.builder(
                                    primary: true,
                                    scrollDirection: Axis.vertical,
                                    itemCount: snapshot.data.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return filter2 == null || filter2 == ""
                                          ? buildCard(snapshot.data, index)
                                          : snapshot.data[index]
                                                      ['university_name']
                                                  .toLowerCase()
                                                  .contains(filter2)
                                              ? buildCard(snapshot.data, index)
                                              : Container();
                                    }),
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                  }
                  return Padding(
                    padding: EdgeInsets.only(top: 60),
                    child: CardListSkeleton(
                      isBottomLinesActive: false,
                      length: 10,
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
