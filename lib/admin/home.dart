import 'user.dart' as adminglobals;
import '../imports.dart';
import '../login.dart';

class AdminHomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 150, right: 20, left: 8),
            child: Image.asset(
              'images/CollegeGenieLogo-2.png',
              height: 175,
              width: 200,
              fit: BoxFit.contain,
              colorBlendMode: BlendMode.darken,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 50),
            child: Text(
              'Hey, ${adminglobals.user.firstname}!',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                  fontSize: 25),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 5, left: 40, right: 40),
            child: Text(
              'Kindly use the web portal to access\nyour admin console.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.w300,
                  fontSize: 15),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 70, left: 100, right: 100),
            child: OutlineButton(
              borderSide: BorderSide(color: Color(0xff005fa8)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: EdgeInsets.only(top: 10, bottom: 10),
                child: Text(
                  'Launch Here',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
                ),
              ),
              onPressed: () async {
                launch('https://collegegenie.org');
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 10, left: 100, right: 100),
            child: OutlineButton(
              borderSide: BorderSide(color: Color(0xff005fa8)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: EdgeInsets.only(top: 10, bottom: 10),
                child: Text(
                  'Sign Out',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
                ),
              ),
              onPressed: () async {
                try {
                  final directory = await getApplicationDocumentsDirectory();
                  final file = File('${directory.path}/tok.txt');
                  file.delete();
                  adminglobals.user = null;
                } catch (_) {
                  print('Error');
                }
                Navigator.pop(context);
                Navigator.of(context)
                    .pushAndRemoveUntil(logoutRoute(), (route) => false);
              },
            ),
          )
        ],
      ),
    );
  }
}
