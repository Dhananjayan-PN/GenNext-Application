import 'imports.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.close,
            size: 30,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        iconTheme: IconThemeData(
          color: Color(0xff005fa8),
        ),
      ),
      body: ListView(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 100),
            child: Text(
              'CREATE AN ACCOUNT',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xff005fa8), fontSize: 24),
            ),
          ),
          Text(
            'Answer a few questions and create an account in no time',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black87, fontSize: 12),
          ),
          Padding(
            padding: EdgeInsets.only(top: 60, left: 35, right: 35),
            child: OutlineButton(
              borderSide: BorderSide(color: Color(0xff005fa8)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: EdgeInsets.only(top: 15, bottom: 15),
                child: Text(
                  "I'm a student",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
              ),
              onPressed: () {
                launch(
                    'https://collegegenie.org/authenticate/student-registration',
                    enableJavaScript: true);
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 35, left: 35, right: 35),
            child: OutlineButton(
              borderSide: BorderSide(color: Color(0xff005fa8)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: EdgeInsets.only(top: 15, bottom: 15),
                child: Text(
                  "I'm a counselor",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
              ),
              onPressed: () {
                launch(
                    'https://collegegenie.org/authenticate/counselor-registration',
                    enableJavaScript: true);
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 35, left: 35, right: 35),
            child: OutlineButton(
              borderSide: BorderSide(color: Color(0xff005fa8)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: EdgeInsets.only(top: 15, bottom: 15),
                child: Text(
                  "I'm a representative",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
              ),
              onPressed: () {
                launch(
                    'https://collegegenie.org/authenticate/university-lookup',
                    enableJavaScript: true);
              },
            ),
          ),
        ],
      ),
    );
  }
}
