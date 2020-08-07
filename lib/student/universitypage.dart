import 'package:http/http.dart' as http;
import '../imports.dart';
import 'home.dart';

enum ListGroup { reach, match, safety }

class UniversityPage extends StatefulWidget {
  final Map university;
  final bool starred;
  final bool rec;
  UniversityPage({@required this.university, this.starred, this.rec});
  @override
  _UniversityPageState createState() => _UniversityPageState();
}

class _UniversityPageState extends State<UniversityPage> {
  GlobalKey<ScaffoldState> _scafKey = GlobalKey<ScaffoldState>();
  List<Widget> standOutFactors;
  List<Widget> appChips;
  List<Widget> deadlines;
  List<Widget> topMajors;
  List<Widget> testingReqs;
  List<Widget> documentChips;
  String educationString = '';
  bool isStarred;
  bool inList;

  @override
  void initState() {
    super.initState();
    isStarred = widget.university['favorited_status'] ?? false;
    inList = widget.university['in_college_list'] ?? false;
    BackButtonInterceptor.add(myInterceptor);
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    Navigator.pop(context);
    return true;
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
    String tok = await getToken();
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
    String tok = await getToken();
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
        error(context);
      }
    } else {
      Navigator.pop(context);
      error(context);
    }
  }

  Future<void> add(int id, String category) async {
    String tok = await getToken();
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
        error(context);
      }
    } else {
      Navigator.pop(context);
      error(context);
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
                style: TextStyle(color: Color(0xff005fa8)),
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
                loading(context);
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
      loading(context);
      add(id, catString);
    }
  }

  @override
  Widget build(BuildContext context) {
    deadlines = [];
    appChips = [];
    topMajors = [];
    standOutFactors = [];
    testingReqs = [];
    documentChips = [];
    educationString = '';
    if (widget.university['stand_out_factors'] != null) {
      for (int i = 0; i < widget.university['stand_out_factors'].length; i++) {
        standOutFactors.add(
          Chip(
            backgroundColor: Colors.white12,
            shape: StadiumBorder(
                side: BorderSide(color: Color(0xff005fa8), width: 0.0)),
            label: Text(widget.university['stand_out_factors'][i]),
            elevation: 1,
          ),
        );
      }
    }
    if (widget.university['degree_levels'] != null) {
      for (int i = 0; i < widget.university['degree_levels'].length; i++) {
        if (i == 0) {
          educationString += '${widget.university['degree_levels'][i]}';
        } else {
          educationString += ', ${widget.university['degree_levels'][i]}';
        }
      }
    }
    if (widget.university['top_majors'] != null) {
      for (int i = 0; i < widget.university['top_majors'].length; i++) {
        topMajors.add(
          Chip(
            visualDensity: VisualDensity.compact,
            backgroundColor: Colors.white12,
            shape: StadiumBorder(
                side: BorderSide(color: Color(0xff005fa8), width: 0.0)),
            label: Text(
              widget.university['top_majors'][i],
              style:
                  TextStyle(fontSize: 11, color: Colors.black.withOpacity(0.8)),
            ),
            elevation: 1,
          ),
        );
      }
    }
    if (widget.university['testing_requirements'] != null) {
      for (int i = 0;
          i < widget.university['testing_requirements'].length;
          i++) {
        testingReqs.add(
          Chip(
            visualDensity: VisualDensity.compact,
            backgroundColor: Colors.white12,
            shape: StadiumBorder(
                side: BorderSide(color: Color(0xff005fa8), width: 0.0)),
            label: Text(
              widget.university['testing_requirements'][i],
              style:
                  TextStyle(fontSize: 11, color: Colors.black.withOpacity(0.8)),
            ),
            elevation: 1,
          ),
        );
      }
    }
    if (widget.university['document_data'] != null) {
      for (int i = 0; i < widget.university['document_data'].length; i++) {
        documentChips.add(
          ActionChip(
            avatar: Icon(
              Icons.insert_drive_file,
              size: 18,
              color: Color(0xff005fa8),
            ),
            labelPadding: EdgeInsets.only(right: 5),
            visualDensity: VisualDensity.compact,
            backgroundColor: Colors.white12,
            shape: StadiumBorder(
                side: BorderSide(color: Color(0xff005fa8), width: 0.0)),
            label: Text(
              widget.university['document_data'][i]['document_name'],
              style: TextStyle(
                  fontSize: 12.5, color: Colors.black.withOpacity(0.8)),
            ),
            elevation: 1,
            onPressed: () {
              launch(widget.university['document_data'][i]['document_url']);
            },
          ),
        );
      }
    }
    if (widget.university['application_fee'] != null) {
      appChips.add(
        Chip(
          backgroundColor: Colors.white12,
          shape: StadiumBorder(
              side: BorderSide(color: Color(0xff005fa8), width: 0.0)),
          label: Text(
            r'$' + widget.university['application_fee'].toString(),
            style: TextStyle(fontSize: 16),
          ),
          elevation: 1,
        ),
      );
    }
    if (widget.university['common_app_accepted_status'] != null) {
      appChips.add(
        Chip(
          labelPadding: EdgeInsets.only(right: 5, left: 5),
          avatar: widget.university['common_app_accepted_status']
              ? Padding(
                  padding: EdgeInsets.only(left: 2),
                  child: Icon(
                    Icons.check_circle,
                    size: 26,
                    color: Colors.green,
                  ),
                )
              : Padding(
                  padding: EdgeInsets.only(left: 2),
                  child: Icon(
                    Icons.cancel,
                    color: Colors.red,
                  ),
                ),
          backgroundColor: Colors.white12,
          shape: StadiumBorder(
              side: BorderSide(color: Color(0xff005fa8), width: 0.0)),
          label: CachedNetworkImage(
            width: 65,
            fit: BoxFit.contain,
            imageUrl:
                'https://membersupport.commonapp.org/servlet/rtaImage?eid=ka10V000001DsVb&feoid=00N0V000008rTCP&refid=0EM0V0000017WaN',
          ),
          elevation: 1,
        ),
      );
    }
    if (widget.university['coalition_app_accepted_status'] != null) {
      appChips.add(
        Chip(
          labelPadding: EdgeInsets.only(right: 5, left: 5),
          backgroundColor: Colors.white12,
          shape: StadiumBorder(
              side: BorderSide(color: Color(0xff005fa8), width: 0.0)),
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(left: 2),
                child: CachedNetworkImage(
                  width: 70,
                  fit: BoxFit.contain,
                  imageUrl:
                      'https://thebiz.bentley.edu/wp-content/uploads/2016/10/coalition-logo-simple-horz-color-01.png',
                ),
              ),
              widget.university['coalition_app_accepted_status']
                  ? Padding(
                      padding: EdgeInsets.only(left: 2),
                      child: Icon(
                        Icons.check_circle,
                        size: 26,
                        color: Colors.green,
                      ),
                    )
                  : Padding(
                      padding: EdgeInsets.only(left: 2),
                      child: Icon(
                        Icons.cancel,
                        color: Colors.red,
                      ),
                    ),
            ],
          ),
          elevation: 1,
        ),
      );
    }
    if (widget.university['application_types'] != null) {
      for (int i = 0; i < widget.university['application_types'].length; i++) {
        deadlines.add(
          Padding(
            padding: EdgeInsets.only(top: 5, left: 25),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(bottom: 1),
                  child: Text(
                    widget.university['application_types'][i].keys.first
                            .toString()
                            .toUpperCase() +
                        ':',
                    style: TextStyle(
                        color: Colors.black.withOpacity(0.65), fontSize: 12.5),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 5, top: 0.5),
                  child: Text(
                    widget.university['application_types'][i][widget
                            .university['application_types'][i].keys.first]
                        .toString(),
                    style: TextStyle(
                        color: Colors.black.withOpacity(0.8), fontSize: 18.5),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }
    return Scaffold(
      key: _scafKey,
      backgroundColor: Colors.white,
      body: CustomScrollView(
        shrinkWrap: false,
        slivers: <Widget>[
          SliverAppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            expandedHeight: 300,
            flexibleSpace: Hero(
              tag: widget.starred != null
                  ? widget.university['university_id'].toString() + 'starred'
                  : widget.rec != null
                      ? widget.university['university_id'].toString() + 'rec'
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
                          image: DecorationImage(
                            alignment: Alignment.center,
                            colorFilter: ColorFilter.mode(
                                Colors.black.withAlpha(50), BlendMode.darken),
                            image: imageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        decoration: BoxDecoration(
                          color: Color(0xff005fa8),
                          image: DecorationImage(
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
                              padding: EdgeInsets.only(bottom: 30, right: 20),
                              child: CircleAvatar(
                                backgroundImage: CachedNetworkImageProvider(
                                    widget.university['logo_url']),
                                backgroundColor: Colors.white,
                                radius: 33,
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 32),
                          child: Row(
                            children: <Widget>[
                              Spacer(),
                              Row(
                                children: <Widget>[
                                  Material(
                                    color: Colors.transparent,
                                    child: Text(
                                      widget.university['acceptance_rate']
                                          .toString()
                                          .split('.')
                                          .first,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                        fontSize: 23,
                                      ),
                                    ),
                                  ),
                                  Material(
                                    color: Colors.transparent,
                                    child: Text(
                                      '%',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              right: widget.university['selectivity']
                                          .toString()
                                          .toUpperCase() ==
                                      'MOST SELECTIVE'
                                  ? 15
                                  : widget.university['selectivity']
                                              .toString()
                                              .toUpperCase() ==
                                          'MORE SELECTIVE'
                                      ? 15
                                      : 30,
                              bottom: 31),
                          child: Row(
                            children: <Widget>[
                              Spacer(),
                              Material(
                                color: Colors.transparent,
                                child: Text(
                                  widget.university['selectivity']
                                      .toString()
                                      .toUpperCase(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                    fontSize: 9,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        Row(
                          children: <Widget>[
                            Spacer(),
                            Padding(
                              padding: EdgeInsets.only(right: 25, bottom: 18),
                              child: CircularPercentIndicator(
                                footer: Text(
                                  'MATCH',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                    fontSize: 9,
                                  ),
                                ),
                                radius: 58,
                                lineWidth: 2.5,
                                animation: true,
                                percent:
                                    widget.university["match_rating"] / 100,
                                center: Text(
                                  " ${widget.university["match_rating"].toString().substring(0, 4)}%",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                    fontSize: 14.1,
                                  ),
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
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 20),
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
                                  color: Color(0xff005fa8),
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
                      padding: EdgeInsets.only(left: 22, top: 5),
                      child: Icon(
                        Icons.location_on,
                        color: Colors.black54,
                        size: 22,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 6, top: 4),
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
                      padding: EdgeInsets.only(left: 22, top: 4),
                      child: Icon(
                        Icons.show_chart,
                        color: Colors.black54,
                        size: 22,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 6, top: 4),
                      child: Text(
                        widget.university['usnews_ranking'].toString(),
                        style: TextStyle(color: Colors.black54, fontSize: 15),
                      ),
                    ),
                    Text(
                      widget.university['usnews_ranking']
                                  .toString()
                                  .endsWith('1') &&
                              widget.university['usnews_ranking'] != 11
                          ? 'st'
                          : widget.university['usnews_ranking']
                                      .toString()
                                      .endsWith('2') &&
                                  widget.university['usnews_ranking'] != 12
                              ? 'nd'
                              : widget.university['usnews_ranking']
                                          .toString()
                                          .endsWith('3') &&
                                      widget.university['usnews_ranking'] != 13
                                  ? 'rd'
                                  : 'th',
                      style: TextStyle(color: Colors.black54, fontSize: 13),
                    )
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(left: 22, top: 5),
                      child: Icon(
                        widget.university['research_or_not']
                            ? IconData(0xF0093, fontFamily: 'maticons')
                            : IconData(0xF13F4, fontFamily: 'maticons'),
                        color: Colors.black54,
                        size: 22,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 6, top: 5),
                      child: widget.university['research_or_not']
                          ? Text(
                              'Research Intensive',
                              style: TextStyle(
                                  color: Colors.black54, fontSize: 15),
                            )
                          : Text(
                              'No Research',
                              style: TextStyle(
                                  color: Colors.black54, fontSize: 15),
                            ),
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(left: 22, top: 8),
                      child: Icon(
                        Icons.school,
                        color: Colors.black54,
                        size: 22,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 6, top: 9),
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: Text(
                          educationString,
                          softWrap: true,
                          style: TextStyle(color: Colors.black54, fontSize: 15),
                        ),
                      ),
                    ),
                  ],
                ),
                if (widget.university['university_rep'] !=
                        'college_genie_representative' &&
                    widget.university['university_rep'] != null) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(left: 22, top: 5),
                        child: Icon(
                          Icons.person,
                          color: Colors.black54,
                          size: 22,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 5, top: 5),
                        child: InkWell(
                          child: Text(
                            '@' + widget.university['university_rep'],
                            style: TextStyle(color: Color(0xff005fa8)),
                          ),
                          onTap: () {},
                        ),
                      ),
                    ],
                  ),
                ],
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(left: 22, top: 5),
                      child: Icon(
                        Icons.link,
                        color: Colors.black54,
                        size: 22,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 6, top: 5),
                      child: InkWell(
                        child: Text(
                          'Visit Website',
                          style: TextStyle(color: Color(0xff005fa8)),
                        ),
                        onTap: () {
                          launch(widget.university['website_url']);
                        },
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(left: 16, top: 15, right: 16),
                  child: Wrap(
                    spacing: 8,
                    direction: Axis.horizontal,
                    children: standOutFactors,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 12, left: 18),
                  child: Text(
                    'About',
                    style: TextStyle(color: Colors.black87, fontSize: 20),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 2, left: 19, right: 18),
                  child: Text(
                    widget.university['university_description'] ?? '',
                    maxLines: 100,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: Colors.black.withOpacity(0.7), fontSize: 15),
                  ),
                ),
                if (topMajors.isNotEmpty) ...[
                  Padding(
                    padding: EdgeInsets.only(top: 15, left: 18),
                    child: Text(
                      'Top Majors',
                      style: TextStyle(color: Colors.black87, fontSize: 20),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        left: 22, top: 2, right: 16, bottom: 15),
                    child: Wrap(
                      spacing: 4,
                      direction: Axis.horizontal,
                      children: topMajors,
                    ),
                  ),
                ],
                Padding(
                  padding: EdgeInsets.only(left: 18),
                  child: Text(
                    'Cost',
                    style: TextStyle(color: Colors.black87, fontSize: 20),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 5, left: 25),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        'IN STATE:',
                        style: TextStyle(
                            color: Colors.black.withOpacity(0.65),
                            fontSize: 13),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 5),
                        child: Text(
                          r'$' + '${widget.university['in_state_cost']}',
                          style: TextStyle(
                              color: Colors.black.withOpacity(0.8),
                              fontSize: 18.5),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 5, left: 25),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        'OUT OF STATE:',
                        style: TextStyle(
                            color: Colors.black.withOpacity(0.65),
                            fontSize: 13),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 5),
                        child: Text(
                          r'$' + '${widget.university['out_of_state_cost']}',
                          style: TextStyle(
                              color: Colors.black.withOpacity(0.8),
                              fontSize: 18.5),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 5, left: 25, bottom: 15),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        'INTERNATIONAL:',
                        style: TextStyle(
                            color: Colors.black.withOpacity(0.65),
                            fontSize: 13),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 5),
                        child: Text(
                          r'$' + '${widget.university['international_cost']}',
                          style: TextStyle(
                              color: Colors.black.withOpacity(0.8),
                              fontSize: 18.5),
                        ),
                      ),
                    ],
                  ),
                ),
                if (testingReqs.isNotEmpty) ...[
                  Padding(
                    padding: EdgeInsets.only(left: 18),
                    child: Text(
                      'Testing',
                      style: TextStyle(color: Colors.black87, fontSize: 20),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        left: 22, top: 2, right: 16, bottom: 15),
                    child: Container(
                      child: Wrap(
                        spacing: 4,
                        direction: Axis.horizontal,
                        children: testingReqs,
                      ),
                    ),
                  ),
                ],
                Padding(
                  padding: EdgeInsets.only(left: 18),
                  child: Text(
                    'Application & Dates',
                    style: TextStyle(color: Colors.black87, fontSize: 20),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 23, top: 1, right: 16),
                  child: Container(
                    child: Wrap(
                      spacing: 4,
                      direction: Axis.horizontal,
                      children: appChips,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 15),
                  child: Column(
                    children: deadlines,
                  ),
                ),
                if (documentChips.isNotEmpty) ...[
                  Padding(
                    padding: EdgeInsets.only(left: 18),
                    child: Text(
                      'Documents',
                      style: TextStyle(color: Colors.black87, fontSize: 20),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        left: 22, top: 2, right: 16, bottom: 25),
                    child: Wrap(
                        spacing: 4,
                        direction: Axis.horizontal,
                        children: documentChips),
                  ),
                ]
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
                    activeColor: Color(0xff005fa8),
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
                    activeColor: Color(0xff005fa8),
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
                    activeColor: Color(0xff005fa8),
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
            style: TextStyle(color: Color(0xff005fa8)),
          ),
          onPressed: () {
            Navigator.pop(context, _listGroup);
          },
        ),
      ],
    );
  }
}
