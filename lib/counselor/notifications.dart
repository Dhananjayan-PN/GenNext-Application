import '../imports.dart';
import 'package:intl/intl.dart';

class BodyBuilder extends StatefulWidget {
  final List notifications;
  BodyBuilder({@required this.notifications});
  @override
  State<StatefulWidget> createState() => BodyBuilderState();
}

class BodyBuilderState extends State<BodyBuilder> {
  List notifs;

  @override
  void initState() {
    super.initState();
    notifs = widget.notifications;
  }

  @override
  Widget build(BuildContext context) {
    if (notifs.length == 0) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.thumb_up,
              size: 45,
            ),
            Text(' '),
            Text(
              "You're all caught up !",
              style: TextStyle(color: Colors.grey[800], fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    } else {
      return Center(
        child: Column(
          children: <Widget>[
            ListView.builder(
              padding: EdgeInsets.only(top: 5),
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: notifs.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(top: 3, left: 2, right: 2),
                  child: Dismissible(
                    key: Key('$index' + '$notifs[index]'),
                    background: Container(
                        child: Icon(Icons.delete), color: Colors.red[400]),
                    child: Card(
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 6,
                      child: InkWell(
                        splashColor: Color(0xff005fa8),
                        onTap: () {},
                        child: ListTile(
                          title: Text(notifs[index]['alert'],
                              style: TextStyle(fontWeight: FontWeight.w400)),
                          subtitle: Padding(
                            padding: EdgeInsets.only(left: 2, top: 5),
                            child: Text(
                              DateFormat.jm().format(
                                      DateTime.parse(notifs[index]['timestamp'])
                                          .toLocal()) +
                                  ' ' +
                                  DateFormat.yMMMd('en_US').format(
                                      DateTime.parse(notifs[index]['timestamp'])
                                          .toLocal()),
                              style: TextStyle(fontWeight: FontWeight.w300),
                            ),
                          ),
                        ),
                      ),
                    ),
                    onDismissed: (direction) {
                      notifs.removeAt(index);
                      setState(() {});
                      Scaffold.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "Notification Dismissed",
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
            Text(
              '\nSwipe on a notification to dismiss',
              style: TextStyle(fontSize: 11, color: Colors.black.withAlpha(99)),
              textAlign: TextAlign.center,
            )
          ],
        ),
      );
    }
  }
}

class NotificationScreen extends StatefulWidget {
  final List notifications;
  NotificationScreen({@required this.notifications});
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
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
    Navigator.pop(context);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xff005fa8),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Notifications',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
      body: BodyBuilder(
        notifications: widget.notifications,
      ),
    );
  }
}
