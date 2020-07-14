import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'home.dart';

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

  @override
  void initState() {
    super.initState();
    isStarred = widget.university['favorited_status'];
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scafKey,
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            backgroundColor: Colors.transparent,
            actions: <Widget>[],
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
                                    fontWeight: FontWeight.w400,
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
                                      fontWeight: FontWeight.w400,
                                      color: Colors.white,
                                      fontSize: 14),
                                ),
                                circularStrokeCap: CircularStrokeCap.round,
                                backgroundColor: Colors.white30,
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: MediaQuery.of(context).size.width * 0.75,
                      padding: EdgeInsets.only(left: 15),
                      child: Text(
                        widget.university['university_name'],
                        style: TextStyle(
                            color: Colors.black87,
                            fontSize: 19,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    Spacer(),
                    InkWell(
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
                    Padding(
                      padding: EdgeInsets.only(left: 8, right: 15),
                      child: InkWell(
                        child: widget.university['in_college_list']
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
                          // widget.university['in_college_list']
                          //     ? removeFromList(widget.university['university_id'],
                          //         widget.university['category'])
                          //     : addToList(widget.university['university_id'],
                          //         widget.university['university_name']);
                        },
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(left: 12, top: 3),
                      child: Icon(
                        Icons.location_on,
                        color: Colors.black54,
                        size: 20,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 4, top: 3),
                      child: Text(
                        widget.university['university_location'],
                        style: TextStyle(color: Colors.black54, fontSize: 14),
                      ),
                    ),
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
