import 'package:http/http.dart' as http;
import '../imports.dart';
import 'home.dart';

class DashBoard extends StatefulWidget {
  final User user;
  DashBoard({this.user});

  @override
  _DashBoardState createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  TextEditingController studentnotes = TextEditingController();
  int userId;
  bool saved = false;
  bool saving = true;
  bool savingfailed = false;

  Future repNotes;

  @override
  void initState() {
    super.initState();
  }

  Future<void> getRepNotes() async {
    String tok = await getToken();
    saving = true;
    final response = await http.get(dom + 'authenticate/get-notes', headers: {
      HttpHeaders.authorizationHeader: 'Token $tok',
    });
    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      userId = json.decode(response.body)['user_id'];
      if (result['response'] == 'Access Denied.') {
        setState(() {
          saving = false;
          savingfailed = true;
        });
        throw ('error');
      } else {
        String notes = json.decode(response.body)['notes'];
        setState(() {
          saving = false;
          saved = true;
          studentnotes.text = notes;
        });
        return notes;
      }
    } else {
      setState(() {
        saving = false;
        savingfailed = true;
      });
      throw ('error');
    }
  }

  Future<void> editRepNotes() async {
    String tok = await getToken();
    final response = await http.put(
      dom + 'authenticate/edit-notes',
      headers: {
        HttpHeaders.authorizationHeader: "Token $tok",
        'Content-Type': 'application/json; charset=UTF-8'
      },
      body: jsonEncode(
        <String, dynamic>{"user_id": userId, "notes": studentnotes.text},
      ),
    );
    if (response.statusCode == 200) {
      if (json.decode(response.body)['response'] ==
          'Notes Successfuly Updated.') {
        setState(() {
          saving = false;
          saved = true;
        });
      } else {
        setState(() {
          saving = false;
          savingfailed = true;
        });
        error(context);
      }
    } else {
      setState(() {
        saving = false;
        savingfailed = true;
      });
      error(context);
    }
  }

  _editRepNotes() {
    setState(() {
      saved = false;
      saving = true;
    });
    editRepNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
