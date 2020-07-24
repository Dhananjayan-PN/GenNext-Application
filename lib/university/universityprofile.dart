import 'package:http/http.dart' as http;
import '../imports.dart';
import 'home.dart';

class UniProfileScreen extends StatefulWidget {
  @override
  _UniProfileScreenState createState() => _UniProfileScreenState();
}

class _UniProfileScreenState extends State<UniProfileScreen> {
  GlobalKey<ScaffoldState> _scafKey = GlobalKey<ScaffoldState>();
  List<Widget> standOutFactors;
  List<Widget> topMajors;
  List<Widget> testingReqs;
  List<Widget> documentChips;
  String educationString = '';
  bool descShowFull = false;
  bool isStarred;
  bool inList;

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
    curPage = UniHomeScreen(user: newUser);
    Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.fade,
            child: UniHomeScreen(user: newUser)));
    return true;
  }

  Future<void> getUniversity(int id) async {
    final response = await http.get(
      dom + 'api/university/',
      headers: {HttpHeaders.authorizationHeader: "Token $tok"},
    );
    if (response.statusCode == 200) {
      return json.decode(response.body)['recommended_universities'];
    } else {
      throw 'failed';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: NavDrawer(
          user: newUser,
          name: newUser.firstname + ' ' + newUser.lastname,
          email: newUser.email),
      appBar: CustomAppBar('Profile'),
      body: Container(),
    );
  }
}
