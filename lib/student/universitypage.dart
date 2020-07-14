import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'home.dart';

enum ListGroup { reach, match, safety }

class UniversityPage extends StatefulWidget {
  final Map university;
  final bool starred;
  UniversityPage({@required this.university, this.starred});
  @override
  _UniversityPageState createState() => _UniversityPageState();
}

class _UniversityPageState extends State<UniversityPage> {
  GlobalKey<ScaffoldState> _scafKey = GlobalKey<ScaffoldState>();
  bool isStarred;
  bool inList;

  @override
  void initState() {
    super.initState();
    isStarred = widget.university['favorited_status'];
    inList = widget.university['in_college_list'];
  }

  Color colorPicker(double rating) {
    if (0 <= rating && rating < 30) {
      return Colors.red;
    } else if (30 <= rating && rating < 60) {
      return Colors.orange;
    } else if (60 <= rating && rating < 80) {
      return Colors.yellow;
    } else if (80 <= rating && rating <= 100) {
      return Colors.green;
    } else {
      return Colors.white;
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
              'University Starred',
              textAlign: TextAlign.center,
            ),
          ),
        );
        setState(() {
          isStarred = true;
        });
      } else if (result['Response'] == 'University successfully unfavorited.') {
        _scafKey.currentState.showSnackBar(
          SnackBar(
            duration: Duration(seconds: 2),
            content: Text(
              'University Unstarred',
              textAlign: TextAlign.center,
            ),
          ),
        );
        setState(() {
          isStarred = false;
        });
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
    }
  }

  Future<void> remove(int id, String category) async {
    final response = await http.delete(
      dom + 'api/student/delete-college-from-list/$id/$category',
      headers: {HttpHeaders.authorizationHeader: "Token $tok"},
    );
    print(response.body);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['Response'] == 'University successfully deleted from list.') {
        Navigator.pop(context);
        setState(() {
          inList = false;
        });
      } else {
        Navigator.pop(context);
        _error();
      }
    } else {
      Navigator.pop(context);
      _error();
    }
  }

  Future<void> add(int id, String category) async {
    final response = await http.put(dom + 'api/student/college-list/add',
        headers: {
          HttpHeaders.authorizationHeader: "Token $tok",
          'Content-Type': 'application/json; charset=UTF-8'
        },
        body: jsonEncode(<String, dynamic>{
          'student_id': newUser.id,
          'university_id': id,
          'college_category': category
        }));
    print(response.body);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['Response'] == 'University successfully added.') {
        Navigator.pop(context);
        setState(() {
          widget.university['category'] =
              category == 'R' ? 'reach' : category == 'M' ? 'match' : 'safety';
          inList = true;
        });
      } else {
        Navigator.pop(context);
        _error();
      }
    } else {
      Navigator.pop(context);
      _error();
    }
  }

  removeFromList(int id, String category) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.all(0),
          elevation: 20,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          content: Container(
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 18),
                  child: Icon(
                    Icons.delete,
                    size: 40,
                    color: Colors.red.withOpacity(0.9),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 5),
                  child: Text(
                    'Are you sure you want to remove\nthis university from your list?',
                    style: TextStyle(color: Colors.black, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                )
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.blue),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            FlatButton(
              child: Text(
                'Remove',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.pop(context);
                remove(id, category);
                _loading();
              },
            ),
          ],
        );
      },
    );
  }

  addToList(int id, String name) async {
    ListGroup data = await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AddToListDialog();
      },
    );
    if (data != null) {
      String catString =
          data == ListGroup.reach ? 'R' : data == ListGroup.match ? 'M' : 'S';
      _loading();
      add(id, catString);
    }
  }

  _loading() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.all(0),
          elevation: 20,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          content: Container(
            height: 150,
            width: 80,
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: 50,
                    width: 50,
                    child: SpinKitWave(
                      color: Colors.grey.withOpacity(0.8),
                      size: 25,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 23.0),
                    child: Text(
                      "Saving your changes",
                      style: TextStyle(color: Colors.black, fontSize: 15),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  _error([String message]) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.all(0),
          elevation: 20,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          content: Container(
            height: 150,
            width: 80,
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.error_outline,
                    size: 40,
                    color: Colors.red.withOpacity(0.9),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Text(
                      message ??
                          'Something went wrong.\nCheck your connection and try again later.',
                      style: TextStyle(color: Colors.black, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scafKey,
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            floating: true,
            expandedHeight: 300,
            flexibleSpace: Hero(
              tag: widget.starred != null
                  ? widget.university['university_id'].toString() + 'starred'
                  : widget.university['university_id'],
              child: Stack(
                children: <Widget>[
                  Positioned(
                    child: CachedNetworkImage(
                      fit: BoxFit.cover,
                      key: Key(widget.university['university_id'].toString()),
                      imageUrl: widget.university['image_url'] ??
                          'https://upload.wikimedia.org/wikipedia/commons/thumb/c/cd/Black_flag.svg/1200px-Black_flag.svg.png',
                      imageBuilder: (context, imageProvider) => Container(
                        decoration: BoxDecoration(
                          image: imageProvider != null
                              ? DecorationImage(
                                  alignment: Alignment.center,
                                  colorFilter: ColorFilter.mode(
                                      Colors.black.withAlpha(50),
                                      BlendMode.darken),
                                  image: imageProvider,
                                  fit: BoxFit.cover,
                                )
                              : DecorationImage(
                                  image: NetworkImage(
                                      'https://www.shareicon.net/data/512x512/2016/08/18/814358_school_512x512.png',
                                      scale: 6.5),
                                ),
                        ),
                      ),
                    ),
                    top: 0,
                    left: 0,
                    right: 0,
                    bottom: 0,
                  ),
                  Positioned(
                    child: Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Spacer(),
                            Padding(
                              padding: EdgeInsets.only(right: 20, bottom: 20),
                              child: CircularPercentIndicator(
                                footer: Text(
                                  'Match',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                    fontSize: 11,
                                  ),
                                ),
                                radius: 55,
                                lineWidth: 2.5,
                                animation: true,
                                percent:
                                    widget.university["match_rating"] / 100,
                                center: Text(
                                  " ${widget.university["match_rating"].toString().substring(0, 4)}%",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                      fontSize: 14),
                                ),
                                circularStrokeCap: CircularStrokeCap.round,
                                backgroundColor: Colors.white54,
                                progressColor: colorPicker(
                                    widget.university["match_rating"]),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          height: 30,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(50),
                              topRight: Radius.circular(50),
                            ),
                          ),
                        ),
                      ],
                    ),
                    bottom: -1,
                    left: 0,
                    right: 0,
                  ),
                ],
              ),
            ),
          ),
          SliverFillRemaining(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: MediaQuery.of(context).size.width * 0.70,
                        child: Text(
                          widget.university['university_name'],
                          style: TextStyle(
                              color: Colors.black87,
                              fontSize: 21.5,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                      Spacer(),
                      Padding(
                        padding: EdgeInsets.only(top: 0.5),
                        child: InkWell(
                          child: isStarred
                              ? Icon(Icons.star,
                                  size: 24.5, color: Colors.yellow[700])
                              : Icon(Icons.star_border,
                                  size: 24.5, color: Colors.yellow[700]),
                          onTap: () {
                            editFavoritedStatus(widget.university,
                                widget.university['university_id'], isStarred);
                          },
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 12, right: 20, top: 0.5),
                        child: InkWell(
                          child: inList
                              ? Icon(
                                  Icons.check,
                                  size: 25,
                                  color: Colors.green,
                                )
                              : Icon(
                                  Icons.add,
                                  size: 25,
                                  color: Colors.blue,
                                ),
                          onTap: () {
                            inList
                                ? removeFromList(
                                    widget.university['university_id'],
                                    widget.university['category'])
                                : addToList(widget.university['university_id'],
                                    widget.university['university_name']);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(left: 15, top: 3),
                      child: Icon(
                        Icons.location_on,
                        color: Colors.black54,
                        size: 22,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 6, top: 3),
                      child: Text(
                        widget.university['university_location'],
                        style: TextStyle(color: Colors.black54, fontSize: 15),
                      ),
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(left: 15, top: 3),
                      child: Icon(
                        Icons.show_chart,
                        color: Colors.black54,
                        size: 22,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        left: 6,
                        top: 3,
                      ),
                      child: Text(
                        widget.university['usnews_ranking'].toString(),
                        style: TextStyle(color: Colors.black54, fontSize: 15),
                      ),
                    ),
                    Text(
                      widget.university['usnews_ranking']
                              .toString()
                              .endsWith('1')
                          ? 'st'
                          : widget.university['usnews_ranking']
                                  .toString()
                                  .endsWith('2')
                              ? 'nd'
                              : widget.university['usnews_ranking']
                                      .toString()
                                      .endsWith('3')
                                  ? 'rd'
                                  : 'th',
                      style: TextStyle(color: Colors.black54, fontSize: 13),
                    )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AddToListDialog extends StatefulWidget {
  @override
  _AddToListDialogState createState() => _AddToListDialogState();
}

class _AddToListDialogState extends State<AddToListDialog> {
  ListGroup _listGroup = ListGroup.reach;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      titlePadding: EdgeInsets.only(top: 15),
      contentPadding: EdgeInsets.all(0),
      elevation: 20,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0))),
      title: Center(
          child: Text('Add to College List',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500))),
      content: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
        ),
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 5, left: 20, right: 20),
              child: Divider(thickness: 0),
            ),
            Padding(
              padding: EdgeInsets.only(left: 25, right: 25),
              child: Column(
                children: <Widget>[
                  RadioListTile(
                    title: Text('Reach'),
                    value: ListGroup.reach,
                    groupValue: _listGroup,
                    onChanged: (ListGroup value) {
                      setState(() {
                        _listGroup = value;
                      });
                    },
                  ),
                  RadioListTile(
                    title: Text('Match'),
                    value: ListGroup.match,
                    groupValue: _listGroup,
                    onChanged: (ListGroup value) {
                      setState(() {
                        _listGroup = value;
                      });
                    },
                  ),
                  RadioListTile(
                    title: Text('Safety'),
                    value: ListGroup.safety,
                    groupValue: _listGroup,
                    onChanged: (ListGroup value) {
                      setState(() {
                        _listGroup = value;
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        FlatButton(
          child: Text(
            'Cancel',
            style: TextStyle(color: Colors.red),
          ),
          onPressed: () {
            Navigator.pop(context, null);
          },
        ),
        FlatButton(
          child: Text(
            'Add',
            style: TextStyle(color: Colors.blue),
          ),
          onPressed: () {
            Navigator.pop(context, _listGroup);
          },
        ),
      ],
    );
  }
}
