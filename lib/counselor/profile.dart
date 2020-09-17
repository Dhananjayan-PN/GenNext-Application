import 'user.dart' as counselorglobals;
import '../imports.dart';
import 'home.dart';

class ProfileScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
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
      appBar: CustomAppBar('My Profile'),
      body: Padding(
        padding: EdgeInsets.only(top: 15, left: 10, right: 10),
        child: Card(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10))),
          elevation: 6,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: CircleAvatar(
                  backgroundImage:
                      CachedNetworkImageProvider(counselorglobals.user.dp),
                  backgroundColor: Color(0xff005fa8),
                  radius: 29,
                ),
                title: Padding(
                  padding: EdgeInsets.only(top: 5),
                  child: Text(
                    counselorglobals.user.firstname +
                        ' ' +
                        counselorglobals.user.lastname,
                    style: TextStyle(fontSize: 17),
                  ),
                ),
                subtitle: Text('Counselor'),
                /*trailing: Padding(
                  padding: EdgeInsets.all(0),
                  child: IconButton(
                    icon: Icon(Icons.edit, color: Color(0xff005fa8)),
                    onPressed: () {},
                  ),
                ),*/
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
                      '@' + counselorglobals.user.username,
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
                      counselorglobals.user.email,
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
                      counselorglobals.user.country,
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
