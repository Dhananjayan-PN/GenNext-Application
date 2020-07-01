import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

Decoration myBoxDec(animation, {isCircle = false}) {
  return BoxDecoration(
    shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
    gradient: LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        Color(0xfff6f7f9),
        Color(0xffe9ebee),
        Color(0xfff6f7f9),
        // Color(0xfff6f7f9),
      ],
      stops: [
        // animation.value * 0.1,
        animation.value - 1,
        animation.value,
        animation.value + 1,
        // animation.value + 5,
        // 1.0,
      ],
    ),
  );
}

class CardSkeleton extends StatefulWidget {
  final bool isCircularImage;
  final bool isBottomLinesActive;
  final double padding;
  CardSkeleton(
      {this.padding = 10,
      this.isCircularImage = true,
      this.isBottomLinesActive = true});
  @override
  _CardSkeletonState createState() => _CardSkeletonState();
}

class _CardSkeletonState extends State<CardSkeleton>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );

    animation = Tween<double>(begin: -1.0, end: 2.0).animate(
        CurvedAnimation(curve: Curves.easeInOutSine, parent: _controller));

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) {
        _controller.repeat();
      } else if (status == AnimationStatus.dismissed) {
        _controller.forward();
      }
    });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Padding(
          padding: EdgeInsets.only(
              top: widget.padding == 0 ? 0 : widget.padding - 2,
              left: widget.padding,
              right: widget.padding),
          child: Card(
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10))),
            elevation: 6,
            child: Container(
              color: Colors.white,
              padding: EdgeInsets.all(12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    height: width * 0.13,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          height: height * 0.008,
                          width: width * 0.5,
                          decoration: myBoxDec(animation),
                        ),
                        Container(
                          height: height * 0.007,
                          width: width * 0.4,
                          decoration: myBoxDec(animation),
                        ),
                        Container(
                          height: height * 0.008,
                          width: width * 0.3,
                          decoration: myBoxDec(animation),
                        ),
                      ],
                    ),
                  ),
                  widget.isBottomLinesActive
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            SizedBox(
                              height: 20,
                            ),
                            Container(
                              height: height * 0.007,
                              width: width * 0.7,
                              decoration: myBoxDec(animation),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Container(
                              height: height * 0.007,
                              width: width * 0.8,
                              decoration: myBoxDec(animation),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Container(
                              height: height * 0.007,
                              width: width * 0.5,
                              decoration: myBoxDec(animation),
                            ),
                          ],
                        )
                      : Offstage()
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class CardListSkeleton extends StatelessWidget {
  final bool isCircularImage;
  final bool isBottomLinesActive;
  final int length;
  CardListSkeleton({
    this.isCircularImage = true,
    this.length = 10,
    this.isBottomLinesActive = true,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: length,
      itemBuilder: (BuildContext context, int index) {
        return CardSkeleton(
          isCircularImage: isCircularImage,
          isBottomLinesActive: isBottomLinesActive,
        );
      },
    );
  }
}

class DashCardSkeleton extends StatefulWidget {
  final bool isCircularImage;
  final bool isBottomLinesActive;
  final double padding;
  DashCardSkeleton(
      {this.padding = 10,
      this.isCircularImage = true,
      this.isBottomLinesActive = true});
  @override
  _DashCardSkeletonState createState() => _DashCardSkeletonState();
}

class _DashCardSkeletonState extends State<DashCardSkeleton>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );

    animation = Tween<double>(begin: -1.0, end: 2.0).animate(
        CurvedAnimation(curve: Curves.easeInOutSine, parent: _controller));

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) {
        _controller.repeat();
      } else if (status == AnimationStatus.dismissed) {
        _controller.forward();
      }
    });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Padding(
          padding: EdgeInsets.only(
              top: widget.padding == 0 ? 0 : widget.padding - 2,
              left: widget.padding,
              right: widget.padding),
          child: Card(
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10))),
            elevation: 6,
            child: Container(
              color: Colors.white,
              padding: EdgeInsets.all(12),
              child: Container(
                height: 185,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top: 60),
                      child: SpinKitWave(
                        type: SpinKitWaveType.start,
                        color: Colors.grey.withOpacity(0.15),
                        size: 40,
                      ),
                    ),
                    Spacer(),
                    Container(
                      height: height * 0.016,
                      width: width * 0.6,
                      decoration: myBoxDec(animation),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 5),
                      height: height * 0.013,
                      width: width * 0.4,
                      decoration: myBoxDec(animation),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
