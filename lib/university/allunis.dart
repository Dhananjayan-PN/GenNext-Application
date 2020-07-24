import 'package:http/http.dart' as http;
import '../imports.dart';
import 'home.dart';

enum ListGroup { reach, match, safety }

class AllUniversitiesScreen extends StatefulWidget {
  @override
  _AllUniversitiesScreenState createState() => _AllUniversitiesScreenState();
}

class _AllUniversitiesScreenState extends State<AllUniversitiesScreen> {
  GlobalKey<ScaffoldState> _scafKey = GlobalKey<ScaffoldState>();
  var refreshKey1 = GlobalKey<RefreshIndicatorState>();
  TextEditingController controller = TextEditingController();
  String filter;
  List unis;
  Future allUniList;

  @override
  void initState() {
    super.initState();
    BackButtonInterceptor.add(myInterceptor);
    controller.addListener(() {
      setState(() {
        filter = controller.text;
      });
    });
    allUniList = getAllUniversities();
  }

  @override
  void dispose() {
    controller.dispose();
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent) {
    curPage = UniHomeScreen(user: newUser);
    Navigator.push(
      context,
      PageTransition(
        type: PageTransitionType.fade,
        child: UniHomeScreen(
          user: newUser,
        ),
      ),
    );
    return true;
  }

  Future<void> getAllUniversities() async {
    final response = await http.get(
      dom + 'api/university/get-all-universities',
      headers: {HttpHeaders.authorizationHeader: "Token $tok"},
    );
    if (response.statusCode == 200) {
      return json.decode(response.body)['university_data'];
    } else {
      throw 'failed';
    }
  }

  void refresh() {
    setState(() {
      allUniList = getAllUniversities();
    });
  }

  Widget buildCard(uni) {
    Widget cardData(ImageProvider imageProvider, bool isError) => Container(
          decoration: BoxDecoration(
            color: isError ? Color(0xff005fa8) : null,
            image: imageProvider != null
                ? DecorationImage(
                    alignment: Alignment.center,
                    colorFilter: ColorFilter.mode(
                        Colors.black.withAlpha(100), BlendMode.darken),
                    image: imageProvider,
                    fit: BoxFit.cover,
                  )
                : DecorationImage(
                    colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(0.35), BlendMode.dstIn),
                    image: NetworkImage(
                        'https://www.shareicon.net/data/512x512/2016/08/18/814358_school_512x512.png',
                        scale: 12),
                  ),
          ),
          child: Material(
            color: Colors.transparent,
            child: ListTile(
              title: Text(
                uni['university_name'],
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500),
              ),
              subtitle: Text(
                uni['university_location'],
                style: TextStyle(
                    color: Colors.white.withOpacity(0.9), fontSize: 13.5),
              ),
              onTap: () async {
                final data = await Navigator.push(
                  context,
                  PageTransition(
                    type: PageTransitionType.fade,
                    child: UniversityPage(
                      university: uni,
                    ),
                  ),
                );
              },
            ),
          ),
        );
    return Hero(
      tag: uni['university_id'],
      child: Card(
        margin: EdgeInsets.only(top: 5, left: 15, right: 15, bottom: 5),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10))),
        elevation: 6,
        child: CachedNetworkImage(
          key: Key(uni['university_id'].toString()),
          imageUrl: uni['image_url'] ??
              'https://upload.wikimedia.org/wikipedia/commons/thumb/c/cd/Black_flag.svg/1200px-Black_flag.svg.png',
          placeholder: (context, url) => CardPlaceHolder(),
          errorWidget: (context, url, error) => cardData(null, true),
          imageBuilder: (context, imageProvider) =>
              cardData(imageProvider, false),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        key: _scafKey,
        backgroundColor: Colors.white,
        drawer: NavDrawer(
            user: newUser,
            name: newUser.firstname + ' ' + newUser.lastname,
            email: newUser.email),
        appBar: AppBar(
          backgroundColor: Color(0xff005fa8),
          elevation: 6,
          title: Text(
            'All Universities',
          ),
        ),
        body: RefreshIndicator(
          key: refreshKey1,
          onRefresh: () {
            refresh();
            return allUniList;
          },
          child: FutureBuilder(
            future: allUniList.timeout(Duration(seconds: 10)),
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
                            style:
                                TextStyle(fontSize: 18, color: Colors.black54),
                          ),
                          Padding(
                              padding:
                                  EdgeInsets.only(top: 5, left: 30, right: 30),
                              child: Text(
                                "Looks like you haven't added\nany universites yet :(",
                                style: TextStyle(color: Colors.black54),
                                textAlign: TextAlign.center,
                              )),
                          Padding(
                            padding: EdgeInsets.only(top: 3),
                            child: Text(
                                "Head over to the 'Explore Universities' section to get started!",
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
                                cursorColor: Color(0xff005fa8),
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
                          padding: EdgeInsets.only(top: 20.0),
                          child: Scrollbar(
                            child: ListView.builder(
                              primary: true,
                              scrollDirection: Axis.vertical,
                              itemCount: snapshot.data.length,
                              itemBuilder: (BuildContext context, int index) {
                                return filter == null || filter == ""
                                    ? buildCard(snapshot.data[index])
                                    : snapshot.data[index]['university_name']
                                            .toLowerCase()
                                            .contains(filter)
                                        ? buildCard(snapshot.data[index])
                                        : Container();
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }
              }
              return Padding(
                padding: EdgeInsets.only(top: 70),
                child: CardListSkeleton(
                  isBottomLinesActive: false,
                  length: 10,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class UniversityPage extends StatefulWidget {
  final Map university;
  UniversityPage({@required this.university});
  @override
  _UniversityPageState createState() => _UniversityPageState();
}

class _UniversityPageState extends State<UniversityPage> {
  GlobalKey<ScaffoldState> _scafKey = GlobalKey<ScaffoldState>();
  List<Widget> standOutFactors;
  List<Widget> topMajors;
  List<Widget> testingReqs;
  List<Widget> documentChips;
  String educationString = '';
  bool descShowFull = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    topMajors = [];
    standOutFactors = [];
    testingReqs = [];
    documentChips = [];
    educationString = '';
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
    for (int i = 0; i < widget.university['degree_levels'].length; i++) {
      if (i == 0) {
        educationString += '${widget.university['degree_levels'][i]}';
      } else {
        educationString += ', ${widget.university['degree_levels'][i]}';
      }
    }
    for (int i = 0; i < 10; i++) {
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
    for (int i = 0; i < widget.university['testing_requirements'].length; i++) {
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
            style:
                TextStyle(fontSize: 12.5, color: Colors.black.withOpacity(0.8)),
          ),
          elevation: 1,
          onPressed: () {
            launch(widget.university['document_data'][i]['document_url']);
          },
        ),
      );
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
              tag: widget.university['university_id'],
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
            hasScrollBody: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 16, bottom: 3, right: 15),
                  child: Text(
                    widget.university['university_name'],
                    style: TextStyle(
                        color: Colors.black87,
                        fontSize: 21.5,
                        fontWeight: FontWeight.w500),
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(left: 18, top: 5),
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
                      padding: EdgeInsets.only(left: 18, top: 4),
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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(left: 18, top: 5),
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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(left: 18, top: 6),
                      child: Icon(
                        Icons.school,
                        color: Colors.black54,
                        size: 22,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 6, top: 7),
                      child: Text(
                        educationString,
                        style: TextStyle(color: Colors.black54, fontSize: 15),
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
                    maxLines: descShowFull ? 1000 : 10,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: Colors.black.withOpacity(0.7), fontSize: 15),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 19, right: 25),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        descShowFull = !descShowFull;
                      });
                    },
                    child: Row(
                      children: <Widget>[
                        descShowFull
                            ? Text(
                                "Less",
                                style: TextStyle(color: Color(0xff005fa8)),
                              )
                            : Text("More",
                                style: TextStyle(color: Color(0xff005fa8)))
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 15, left: 18),
                  child: Text(
                    'Top Majors',
                    style: TextStyle(color: Colors.black87, fontSize: 20),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 22, top: 2, right: 16),
                  child: Wrap(
                    spacing: 4,
                    direction: Axis.horizontal,
                    children: topMajors,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 15, left: 18),
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
                        'IN STATE',
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
                        'OUT OF STATE',
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
                  padding: EdgeInsets.only(top: 5, left: 25),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        'INTERNATIONAL',
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
                Padding(
                  padding: EdgeInsets.only(top: 15, left: 18),
                  child: Text(
                    'Testing',
                    style: TextStyle(color: Colors.black87, fontSize: 20),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 22, top: 2, right: 16),
                  child: Wrap(
                    spacing: 4,
                    direction: Axis.horizontal,
                    children: testingReqs,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 15, left: 18),
                  child: Text(
                    'Documents',
                    style: TextStyle(color: Colors.black87, fontSize: 20),
                  ),
                ),
                Padding(
                  padding:
                      EdgeInsets.only(left: 22, top: 2, right: 16, bottom: 25),
                  child: Wrap(
                    spacing: 4,
                    direction: Axis.horizontal,
                    children: documentChips,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
