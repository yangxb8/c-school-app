import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:c_school_app/app/model/class.dart';
import 'package:c_school_app/service/class_service.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:supercharged/supercharged.dart';
import './review_words_theme.dart';

class CSchoolClassListView extends StatefulWidget {
  const CSchoolClassListView({Key key, this.callBack}) : super(key: key);

  final Function callBack;
  @override
  _CSchoolClassListViewState createState() => _CSchoolClassListViewState();
}

class _CSchoolClassListViewState extends State<CSchoolClassListView>
    with TickerProviderStateMixin {
  AnimationController animationController;
  List<CSchoolClass> allClasses;

  @override
  void initState() {
    animationController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);
    allClasses = ClassService.allClasses;
    super.initState();
  }

  Future<bool> getData() async {
    await Future<dynamic>.delayed(const Duration(milliseconds: 200));
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: FutureBuilder<bool>(
        future: getData(),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (!snapshot.hasData) {
            return const SizedBox();
          } else {
            return GridView(
              padding: const EdgeInsets.all(8),
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.vertical,
              children: List<Widget>.generate(
                allClasses.length,
                (int index) {
                  final count = allClasses.length;
                  final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
                    CurvedAnimation(
                      parent: animationController,
                      curve: Interval((1 / count) * index, 1.0,
                          curve: Curves.fastOutSlowIn),
                    ),
                  );
                  animationController.forward();
                  return CSchoolClassView(
                    callback: widget.callBack,
                    cschoolClass: allClasses[index],
                    animation: animation,
                    animationController: animationController,
                  );
                },
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 32.0,
                crossAxisSpacing: 32.0,
                childAspectRatio: 0.8,
              ),
            );
          }
        },
      ),
    );
  }
}

class CSchoolClassView extends StatelessWidget {
  const CSchoolClassView(
      {Key key,
      this.cschoolClass,
      this.animationController,
      this.animation,
      this.callback})
      : super(key: key);

  static const DEFAULT_IMAGE = 'assets/discover_panel/interFace3.png';
  final Function callback;
  final CSchoolClass cschoolClass;
  final AnimationController animationController;
  final Animation<dynamic> animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController,
      builder: (BuildContext context, Widget child) {
        return FadeTransition(
          opacity: animation,
          child: Transform(
            transform: Matrix4.translationValues(
                0.0, 50 * (1.0 - animation.value), 0.0),
            child: ClassCard(
                callback: callback,
                cschoolClass: cschoolClass,
                DEFAULT_IMAGE: DEFAULT_IMAGE),
          ),
        );
      },
    );
  }
}

class ClassCard extends StatelessWidget {
  const ClassCard({
    Key key,
    @required this.callback,
    @required this.cschoolClass,
    @required this.DEFAULT_IMAGE,
  }) : super(key: key);

  final Function callback;
  final CSchoolClass cschoolClass;
  final String DEFAULT_IMAGE;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.transparent,
      onTap: () {
        callback(cschoolClass);
      },
      child: SizedBox(
        height: 280,
        child: Stack(
          alignment: AlignmentDirectional.bottomCenter,
          children: <Widget>[
            Container(
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: '#F8FAFB'.toColor(),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(16.0)),
                        // border: new Border.all(
                        //     color: DesignCourseAppTheme.notWhite),
                      ),
                      child: Column(
                        children: <Widget>[
                          Expanded(
                            child: Container(
                              child: Column(
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 16, left: 16, right: 16),
                                    child: Text(
                                      cschoolClass.title,
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                        letterSpacing: 0.27,
                                        color: ReviewWordsTheme.darkerText,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 8, left: 16, right: 16, bottom: 8),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Row(
                                          children: [
                                            Text(
                                              '${cschoolClass.words.length}',
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w200,
                                                fontSize: 12,
                                                letterSpacing: 0.27,
                                                color: ReviewWordsTheme.grey,
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 6.0),
                                              child: Icon(
                                                Icons.menu_book,
                                                color:
                                                    ReviewWordsTheme.nearlyBlue,
                                                size: 20,
                                              ),
                                            )
                                          ],
                                        ),
                                        Container(
                                          child: Row(
                                            children: <Widget>[
                                              Text(
                                                '100',
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w200,
                                                  fontSize: 14,
                                                  letterSpacing: 0.27,
                                                  color: ReviewWordsTheme.grey,
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 6.0),
                                                child: Icon(
                                                  Icons.remove_red_eye,
                                                  color: ReviewWordsTheme
                                                      .nearlyBlue,
                                                  size: 20,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 48,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 48,
                  ),
                ],
              ),
            ),
            Container(
              child: Padding(
                padding: const EdgeInsets.only(top: 24, right: 16, left: 16),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(16.0)),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                          color: ReviewWordsTheme.grey.withOpacity(0.2),
                          offset: const Offset(0.0, 0.0),
                          blurRadius: 6.0),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(16.0)),
                    child: AspectRatio(
                        aspectRatio: 1.28,
                        child: cschoolClass.pic?.url == null
                            ? Image.asset(DEFAULT_IMAGE)
                            : CachedNetworkImage(
                                imageUrl: cschoolClass.pic.url,
                                placeholder: (context, url) => SizedBox(
                                      width: 200.0,
                                      height: 100.0,
                                      child:
                                          BlurHash(hash: cschoolClass.picHash),
                                    ),
                                errorWidget: (context, url, error) =>
                                    Image.asset(DEFAULT_IMAGE))),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
