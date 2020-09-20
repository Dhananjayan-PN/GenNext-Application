import 'package:http/http.dart' as http;
import '../imports.dart';
import 'home.dart';

enum ListGroup { reach, match, safety }

class AllSchoolsScreen extends StatefulWidget {
  @override
  _AllSchoolsScreenState createState() => _AllSchoolsScreenState();
}

class _AllSchoolsScreenState extends State<AllSchoolsScreen> {
  GlobalKey<ScaffoldState> _scafKey = GlobalKey<ScaffoldState>();
  var refreshKey1 = GlobalKey<RefreshIndicatorState>();
  TextEditingController controller = TextEditingController();
  String filter;
  List unis;
  Future allSchoolsList;

  @override
  void initState() {
    super.initState();
    BackButtonInterceptor.add(myInterceptor);
    controller.addListener(() {
      setState(() {
        filter = controller.text.toLowerCase();
      });
    });
    allSchoolsList = getAllSchools();
  }

  @override
  void dispose() {
    controller.dispose();
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    return true;
  }

  Future<void> getAllSchools() async {
    String tok = await getToken();
    final response = await http.get(
      dom + 'api/university/get-all-schools',
      headers: {HttpHeaders.authorizationHeader: "Token $tok"},
    );
    if (response.statusCode == 200) {
      return json.decode(response.body)['school_data'];
    } else {
      throw 'failed';
    }
  }

  void refresh() {
    setState(() {
      allSchoolsList = getAllSchools();
    });
  }

  Widget buildCard(school) {
    return Card(
      margin: EdgeInsets.only(top: 5, left: 15, right: 15, bottom: 5),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10))),
      elevation: 6,
      child: ListTile(
        isThreeLine: true,
        title: Padding(
          padding: EdgeInsets.only(left: 3.5, top: 5),
          child: Text(
            school['school'] ?? '',
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w500,
                fontSize: 18.5),
          ),
        ),
        subtitle: Padding(
          padding: EdgeInsets.only(top: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(
                    Icons.location_on,
                    color: Colors.black38,
                    size: 16,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 1),
                    child: Text(
                      school['country'] ?? '',
                      style: TextStyle(color: Colors.black54),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(top: 3),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.person,
                      color: Colors.black38,
                      size: 16,
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 2, left: 1),
                      child: Text(
                        school['counselor_name'] ?? '',
                        style: TextStyle(color: Colors.black54),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        trailing: Padding(
          padding: EdgeInsets.only(top: 10, right: 5),
          child: ClipOval(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                child: Icon(
                  Icons.mail,
                  color: Color(0xff005fa8),
                  size: 30,
                ),
                onTap: () {},
              ),
            ),
          ),
        ),
        onTap: () async {
          if (await canLaunch('mailto:${school['counselor_email']}')) {
            launch('mailto:${school['counselor_email']}');
          } else {
            await ClipboardManager.copyToClipBoard(school['counselor_email']);
            _scafKey.currentState.showSnackBar(
              SnackBar(
                content: Text(
                  'Unable to open mail. Email copied to clipboard.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
        },
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
        drawer: NavDrawer(),
        appBar: AppBar(
          backgroundColor: Color(0xff005fa8),
          elevation: 6,
          title: Text(
            'All Schools',
          ),
        ),
        body: RefreshIndicator(
          key: refreshKey1,
          onRefresh: () {
            refresh();
            return allSchoolsList;
          },
          child: FutureBuilder(
            future: allSchoolsList.timeout(Duration(seconds: 10)),
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
                          Padding(
                              padding:
                                  EdgeInsets.only(top: 5, left: 30, right: 30),
                              child: Text(
                                "Looks like there aren't any\nchools in our database yet",
                                style: TextStyle(color: Colors.black54),
                                textAlign: TextAlign.center,
                              )),
                          Padding(
                            padding: EdgeInsets.only(top: 3),
                            child: Text("Come back later to see them all!",
                                style: TextStyle(color: Colors.black54),
                                textAlign: TextAlign.center),
                          )
                        ],
                      ),
                    ),
                  );
                } else {
                  return Scrollbar(
                    child: ListView.builder(
                      primary: true,
                      scrollDirection: Axis.vertical,
                      itemCount: snapshot.data.length + 1,
                      itemBuilder: (BuildContext context, int index) {
                        if (index == 0) {
                          return Padding(
                            padding: EdgeInsets.only(
                                top: 5, left: 18, right: 30, bottom: 20),
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
                          );
                        }
                        return filter == null || filter == ""
                            ? buildCard(snapshot.data[index - 1])
                            : snapshot.data[index - 1]['school']
                                    .toLowerCase()
                                    .contains(filter)
                                ? buildCard(snapshot.data[index - 1])
                                : snapshot.data[index - 1]['counselor_name']
                                        .toLowerCase()
                                        .contains(filter)
                                    ? buildCard(snapshot.data[index - 1])
                                    : Container();
                      },
                    ),
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
