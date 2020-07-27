import 'package:http/http.dart' as http;
import 'package:dio/dio.dart' as dio;
import 'package:intl/intl.dart';
import '../imports.dart';
import 'home.dart';

class TestScoresScreen extends StatefulWidget {
  @override
  _TestScoresScreenState createState() => _TestScoresScreenState();
}

class _TestScoresScreenState extends State<TestScoresScreen> {
  var refreshKey = GlobalKey<RefreshIndicatorState>();
  List<Widget> scoreCards;
  Future<List> scores;

  @override
  void initState() {
    super.initState();
    BackButtonInterceptor.add(myInterceptor);
    scores = getScores();
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent) {
    curPage = StudentHomeScreen(user: newUser);
    Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.fade,
            child: StudentHomeScreen(user: newUser)));
    return true;
  }

  Future<List> getScores() async {
    String tok = await getToken();
    final response = await http.get(
      dom + 'api/student/get-my-test-scores',
      headers: {HttpHeaders.authorizationHeader: "Token $tok"},
    );
    if (response.statusCode == 200) {
      return json.decode(response.body)['test_score_data'];
    } else {
      throw 'failed';
    }
  }

  Future<void> deleteScore(int id) async {
    String tok = await getToken();
    final response = await http.delete(
      dom + 'api/student/delete-test-score/$id',
      headers: {HttpHeaders.authorizationHeader: "Token $tok"},
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['Response'] == 'Test score successfully deleted.') {
        Navigator.pop(context);
        success(
            context, 'Test score successfully deleted\nTap + to add a new one');
        refresh();
      } else {
        Navigator.pop(context);
        error(context);
      }
    } else {
      Navigator.pop(context);
      error(context);
    }
  }

  Future<void> uploadTestSCore(String op, int id, int score, String type,
      DateTime testDate, File report) async {}

  _deleteScore(int id) {
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
                    'Are you sure you want to delete\nthis test score?',
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
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.pop(context);
                deleteScore(id);
                loading(context);
              },
            ),
          ],
        );
      },
    );
  }

  void refresh() {
    setState(() {
      scores = getScores();
    });
  }

  Widget buildScoreCard(test) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 4,
      margin: EdgeInsets.only(top: 5, left: 15, right: 15, bottom: 5),
      shape: RoundedRectangleBorder(
          side: BorderSide(color: Color(0xff005fa8), width: 0.1),
          borderRadius: BorderRadius.all(Radius.circular(10))),
      child: InkWell(
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(left: 4, top: 2),
                child: Row(
                  children: <Widget>[
                    SizedBox(
                      width: 100,
                      child: Image.network(
                        test['test_type'] == 'Advanced Placement'
                            ? 'https://d31kydh6n6r5j5.cloudfront.net/uploads/sites/202/2020/01/cb-ap-logo.png'
                            : test['test_type'] == 'SAT'
                                ? 'https://p15cdn4static.sharpschool.com/UserFiles/Servers/Server_68836/Image/College%20Board%20SAT.jpg'
                                : test['test_type'] == 'ACT'
                                    ? 'https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcTSaMTwrkbcLq4PZGW_Z8vcmrL8UEENzymwBA&usqp=CAU'
                                    : test['test_type'] == 'TOEFL'
                                        ? 'https://upload.wikimedia.org/wikipedia/commons/thumb/9/9c/TOEFL_Logo.svg/1280px-TOEFL_Logo.svg.png'
                                        : test['test_type'] == 'IELTS'
                                            ? 'https://upload.wikimedia.org/wikipedia/commons/thumb/7/7f/IELTS_logo.svg/1280px-IELTS_logo.svg.png'
                                            : null,
                        fit: BoxFit.contain,
                      ),
                    ),
                    Spacer(),
                    Padding(
                      padding: EdgeInsets.only(top: 5, right: 5),
                      child: PopupMenuButton(
                        child: Icon(Icons.more_vert),
                        itemBuilder: (BuildContext context) {
                          return {'Edit', 'Delete'}.map((String choice) {
                            return PopupMenuItem<String>(
                              height: 35,
                              value: choice,
                              child: Text(choice,
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w400)),
                            );
                          }).toList();
                        },
                        onSelected: (value) async {
                          switch (value) {
                            case 'Edit':
                              // final List details = await Navigator.push(
                              //     context,
                              //     MaterialPageRoute(
                              //         builder: (context) => NewEssayScreen(
                              //             op: 'Edit',
                              //             title: essay['essay_title'],
                              //             prompt: essay['essay_prompt'])));
                              // editEssayDetails(essay, details[0], details[1]);
                              // loading(context);
                              break;
                            case 'Delete':
                              _deleteScore(test['test_score_id']);
                              break;
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 8, left: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      test['score'].toString(),
                      style: TextStyle(fontSize: 30),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Text(
                        '/' + test['max_score'].toString(),
                        style: TextStyle(fontSize: 20, color: Colors.black54),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 2, left: 5),
                child: Text(
                  DateFormat.yMMMMd('en_US').format(
                    DateTime.parse(test['date_of_test'] + 'T00:00:00Z'),
                  ),
                  style: TextStyle(
                      fontSize: 13, color: Colors.black.withOpacity(0.65)),
                ),
              ),
            ],
          ),
        ),
        onTap: () {
          launch(test['document_url']);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xff005fa8),
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 8),
            child: IconButton(
              icon: Icon(
                Icons.add,
                color: Colors.white,
                size: 26,
              ),
              onPressed: () async {
                final List details = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => NewScoreScreen(op: 'Create')));
                // createEssay(details[0], details[1]);
                // loading(context);
              },
            ),
          )
        ],
        title: Text(
          'My Test Scores',
          maxLines: 1,
        ),
      ),
      drawer: NavDrawer(
          user: newUser,
          name: newUser.firstname + ' ' + newUser.lastname,
          email: newUser.email),
      body: RefreshIndicator(
        key: refreshKey,
        onRefresh: () {
          refresh();
          return scores;
        },
        child: FutureBuilder(
          future: scores.timeout(Duration(seconds: 10)),
          builder: (context, snapshot) {
            scoreCards = [];
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
                      Padding(
                        padding: EdgeInsets.only(top: 10),
                        child: Text(
                          'Unable to establish a connection with our servers.\nCheck your connection and try again later.',
                          style: TextStyle(color: Colors.black54),
                          textAlign: TextAlign.center,
                        ),
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
                        Padding(
                            padding:
                                EdgeInsets.only(top: 5, left: 30, right: 30),
                            child: Text(
                              "Looks like you haven't added\nany test scores yet",
                              style: TextStyle(color: Colors.black54),
                              textAlign: TextAlign.center,
                            )),
                        Padding(
                          padding: EdgeInsets.only(top: 3),
                          child: Text(
                            "Tap '+' to add one in no time",
                            style: TextStyle(color: Colors.black54),
                            textAlign: TextAlign.center,
                          ),
                        )
                      ],
                    ),
                  ),
                );
              } else {
                for (int i = 0; i < snapshot.data.length; i++) {
                  scoreCards.add(buildScoreCard(snapshot.data[i]));
                }
                return ListView(
                  padding: EdgeInsets.only(top: 10),
                  children: scoreCards,
                );
              }
            }
            return Center(
              child: SpinKitWave(color: Colors.grey, size: 40),
            );
          },
        ),
      ),
    );
  }
}

class NewScoreScreen extends StatefulWidget {
  final String op;
  final int score;
  final String type;
  final DateTime date;
  final File report;
  NewScoreScreen(
      {@required this.op, this.score, this.type, this.date, this.report});
  @override
  _NewScoreScreenState createState() => _NewScoreScreenState();
}

class _NewScoreScreenState extends State<NewScoreScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _score = TextEditingController();
  TextEditingController _dateController = TextEditingController();
  DateTime _testDate;
  File _report;
  String _type;

  @override
  void initState() {
    super.initState();
    _score.text = widget.op == 'Edit' ? widget.score.toString() : '';
    _type = widget.type;
    if (widget.date != null) {
      _testDate = widget.date;
      _dateController.text = DateFormat.yMMMMd().format(widget.date);
    }
    _report = widget.report;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Color(0xff005fa8),
          actions: <Widget>[
            FlatButton(
              child: Text(
                widget.op == 'Edit' ? 'SAVE' : 'ADD',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
              ),
              onPressed: () {
                if (_formKey.currentState.validate() &&
                    _testDate != null &&
                    _report != null) {
                  List data = [
                    int.parse(_score.text),
                    _type,
                    _testDate,
                    _report
                  ];
                  Navigator.pop(context, data);
                }
              },
            )
          ],
          title: Text(
            widget.op == 'Edit' ? 'Edit Test Score' : 'Add Test Score',
            maxLines: 1,
          ),
        ),
        body: Padding(
          padding: EdgeInsets.all(25),
          child: Form(
            key: _formKey,
            child: ListView(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 5),
                  child: Text(
                    'Test Type',
                    style: TextStyle(fontSize: 23, color: Colors.black87),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 1, right: 45),
                  child: DropdownButtonFormField(
                    hint: Text(
                      "Type of Test",
                      style: TextStyle(color: Colors.black54, fontSize: 16),
                    ),
                    itemHeight: kMinInteractiveDimension,
                    items: [
                      DropdownMenuItem(
                          child: Text(
                            'SAT',
                            style: TextStyle(fontSize: 16),
                          ),
                          value: 'SAT'),
                      DropdownMenuItem(
                          child: Text(
                            'ACT',
                            style: TextStyle(fontSize: 16),
                          ),
                          value: 'ACT'),
                      DropdownMenuItem(
                          child: Text(
                            'TOEFL iBT',
                            style: TextStyle(fontSize: 16),
                          ),
                          value: 'TOEFL'),
                      DropdownMenuItem(
                          child: Text(
                            'IELTS',
                            style: TextStyle(fontSize: 16),
                          ),
                          value: 'IELTS'),
                      DropdownMenuItem(
                          child: Text(
                            'Advanced Placement',
                            style: TextStyle(fontSize: 16),
                          ),
                          value: 'Advanced Placement'),
                    ],
                    value: _type,
                    validator: (value) => value == null
                        ? 'Do tell us what type of test this is'
                        : null,
                    isExpanded: true,
                    onChanged: (value) {
                      setState(() {
                        _type = value;
                      });
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 30),
                  child: Text(
                    'Score',
                    style: TextStyle(fontSize: 22, color: Colors.black87),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 1, right: 45),
                  child: TextFormField(
                    cursorColor: Color(0xff005fa8),
                    controller: _score,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == '') {
                        return 'Enter a score';
                      }
                      if (_type == 'SAT' &&
                          (int.parse(value) < 200 || int.parse(value) > 1600)) {
                        return 'The SAT is scored on a scale of 200 to 1600';
                      } else if (_type == 'ACT' &&
                          (int.parse(value) < 1 || int.parse(value) > 36)) {
                        return 'The ACT is scored on a scale of 1 to 36';
                      } else if (_type == 'TOEFL' &&
                          (int.parse(value) < 0 || int.parse(value) > 120)) {
                        return 'The TOEFL iBT is scored on a scale of 0 to 120';
                      } else if (_type == 'IELTS' &&
                          (int.parse(value) < 1 || int.parse(value) > 9)) {
                        return 'The IELTS is scored on a scale of 1 to 9';
                      } else if (_type == 'Advanced Placement' &&
                          (int.parse(value) < 1 || int.parse(value) > 5)) {
                        return 'AP Exams are scored on a scale of 1 to 5';
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 30),
                  child: Text(
                    'Test Date',
                    style: TextStyle(fontSize: 23, color: Colors.black87),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 1, right: 45),
                  child: Theme(
                    data: ThemeData(primaryColor: Color(0xff005fa8)),
                    child: DateTimeField(
                      cursorColor: Color(0xff005fa8),
                      initialValue: widget.date ?? null,
                      controller: _dateController,
                      decoration: InputDecoration(
                        border: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Color(0xff005fa8), width: 0.0),
                        ),
                      ),
                      format: DateFormat.yMMMMd(),
                      onChanged: (value) {
                        setState(() {
                          _testDate = value;
                        });
                      },
                      validator: (value) => value == null
                          ? 'Do tell us when you took this test'
                          : null,
                      onShowPicker: (context, currentValue) async {
                        final _date = await showDatePicker(
                          context: context,
                          firstDate: DateTime(1900),
                          initialDate:
                              currentValue ?? widget.date ?? DateTime.now(),
                          lastDate: DateTime.now(),
                          builder: (context, child) {
                            return Theme(
                              data: ThemeData(
                                  colorScheme: ColorScheme(
                                      brightness: Brightness.light,
                                      error: Color(0xff005fa8),
                                      onError: Colors.red,
                                      background: Color(0xff005fa8),
                                      primary: Color(0xff005fa8),
                                      primaryVariant: Color(0xff005fa8),
                                      secondary: Color(0xff005fa8),
                                      secondaryVariant: Color(0xff005fa8),
                                      onPrimary: Colors.white,
                                      surface: Color(0xff005fa8),
                                      onSecondary: Colors.black,
                                      onSurface: Colors.black,
                                      onBackground: Colors.black)),
                              child: child,
                            );
                          },
                        );
                        if (_date != null) {
                          return _date;
                        } else {
                          return currentValue;
                        }
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 30),
                  child: Text(
                    'Score Report',
                    style: TextStyle(fontSize: 23, color: Colors.black87),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 1, right: 25, top: 10),
                  child: Row(
                    children: <Widget>[
                      RaisedButton(
                        elevation: 2,
                        color: Colors.grey[50],
                        textColor: Color(0xff005fa8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(5))),
                        child: Text('Choose File'),
                        onPressed: () async {
                          File file = await FilePicker.getFile(
                            type: FileType.any,
                          );
                          if (file != null) {
                            setState(() {
                              _report = file;
                            });
                          }
                        },
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: _report == null
                            ? Text(
                                'No file chosen',
                                style: TextStyle(color: Colors.red),
                              )
                            : Text(_report?.path?.split('/')?.last),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
