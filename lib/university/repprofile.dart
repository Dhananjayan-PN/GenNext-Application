import 'user.dart' as universityglobals;
import '../imports.dart';
import 'home.dart';

class RepProfileScreen extends StatefulWidget {
  @override
  _RepProfileScreenState createState() => _RepProfileScreenState();
}

class _RepProfileScreenState extends State<RepProfileScreen> {
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

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    return true;
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: NavDrawer(),
      appBar: CustomAppBar('Profile'),
      body: Padding(
        padding: EdgeInsets.only(top: 15, left: 10, right: 10),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
          ),
          elevation: 6,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: CircleAvatar(
                  backgroundImage:
                      CachedNetworkImageProvider(universityglobals.user.dp),
                  backgroundColor: Colors.blue[800],
                  radius: 29,
                ),
                title: Padding(
                  padding: EdgeInsets.only(top: 5),
                  child: Text(
                    universityglobals.user.firstname +
                        ' ' +
                        universityglobals.user.lastname,
                    style: TextStyle(fontSize: 17),
                  ),
                ),
                subtitle: Text('University Representative'),
                /*
                trailing: Padding(
                  padding: EdgeInsets.all(0),
                  child: IconButton(
                    icon: Icon(
                      Icons.edit,
                      color: Color(0xff005fa8),
                    ),
                    onPressed: () {},
                  ),
                ),
                */
              ),
              Divider(
                thickness: 1,
                indent: 20,
                endIndent: 20,
              ),
              Padding(
                padding: EdgeInsets.only(top: 5, left: 20),
                child: Row(
                  children: <Widget>[
                    Text(
                      'Username: ',
                    ),
                    Text(
                      '@' + universityglobals.user.username,
                      style: TextStyle(color: Colors.black54),
                    )
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 15, left: 20),
                child: Row(
                  children: <Widget>[
                    Text(
                      'Email ID: ',
                    ),
                    Text(
                      universityglobals.user.email,
                      style: TextStyle(color: Colors.black54),
                    )
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 15, left: 20, bottom: 15),
                child: Row(
                  children: <Widget>[
                    Text(
                      'Country: ',
                    ),
                    Text(
                      universityglobals.user.country,
                      style: TextStyle(color: Colors.black54),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
