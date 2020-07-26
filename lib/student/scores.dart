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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar('My Test Scores'),
      drawer: NavDrawer(
          user: newUser,
          name: newUser.firstname + ' ' + newUser.lastname,
          email: newUser.email),
      body: Center(
        child: Text('Test Scores'),
      ),
    );
  }
}
