// 🐦 Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 📦 Package imports:
import '../../util/utility.dart';
import 'package:get/get.dart';

// 🌎 Project imports:
import 'package:c_school_app/app/ui_view/separator.dart';
import '../../c_school_icons.dart';
import 'controller/login_controller.dart';
import 'style/login_theme.dart' as theme;
import 'utils/bubble_indication_painter.dart';
import '../ui_view/progress_hud.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final FocusNode myFocusNodeEmailLogin = FocusNode();
  final FocusNode myFocusNodePasswordLogin = FocusNode();

  final FocusNode myFocusNodePassword = FocusNode();
  final FocusNode myFocusNodeEmail = FocusNode();
  final FocusNode myFocusNodeName = FocusNode();

  final LoginController controller = Get.find();

  final passwordValidator = MultiValidator([
    RequiredValidator(errorText: 'login.common.error.required'.tr),
    MinLengthValidator(6, errorText: 'login.register.error.tooShort'.tr),
  ]);

  final emailValidator = MultiValidator([
    EmailValidator(errorText: 'login.common.error.emailFormat'.tr),
    RequiredValidator(errorText: 'login.common.error.required'.tr)
  ]);

  bool _obscureTextLogin = true;
  bool _obscureTextSignup = true;
  bool _obscureTextSignupConfirm = true;

  PageController _pageController;

  Color left = Colors.black;
  Color right = Colors.white;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: NotificationListener<OverscrollIndicatorNotification>(
          // ignore: missing_return
          onNotification: (overscroll) {
            overscroll.disallowGlow();
          },
          child: Obx(
            () => ProgressHUD(
              inAsyncCall: controller.processing.value,
              child: SingleChildScrollView(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height >= 775.0
                      ? MediaQuery.of(context).size.height
                      : 775.0,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [theme.Colors.loginGradientStart, theme.Colors.loginGradientEnd],
                        begin: const FractionalOffset(0.0, 0.0),
                        end: const FractionalOffset(1.0, 1.0),
                        stops: [0.0, 1.0],
                        tileMode: TileMode.clamp),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(top: 85.0),
                        child: Image(
                            width: 250.0,
                            height: 191.0,
                            fit: BoxFit.fill,
                            image: AssetImage('assets/login/login_logo.png')),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 20.0),
                        child: _buildMenuBar(context),
                      ),
                      Expanded(
                        flex: 2,
                        child: PageView(
                          controller: _pageController,
                          onPageChanged: (i) {
                            if (i == 0) {
                              setState(() {
                                right = Colors.white;
                                left = Colors.black;
                              });
                            } else if (i == 1) {
                              setState(() {
                                right = Colors.black;
                                left = Colors.white;
                              });
                            }
                          },
                          children: <Widget>[
                            ConstrainedBox(
                              constraints: const BoxConstraints.expand(),
                              child: _buildSignIn(context),
                            ),
                            ConstrainedBox(
                              constraints: const BoxConstraints.expand(),
                              child: _buildSignUp(context),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )),
    );
  }

  @override
  void dispose() {
    myFocusNodePassword.dispose();
    myFocusNodeEmail.dispose();
    myFocusNodeName.dispose();
    _pageController?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    _pageController = PageController();
  }

  void showInSnackBar(String value) {
    FocusScope.of(context).requestFocus(FocusNode());
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        value,
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white, fontSize: 16.0, fontFamily: 'WorkSansSemiBold'),
      ),
      backgroundColor: Colors.blue,
      duration: Duration(seconds: 3),
    ));
  }

  Widget _buildMenuBar(BuildContext context) {
    return Container(
      width: 300.0,
      height: 50.0,
      decoration: BoxDecoration(
        color: Color(0x552B2B2B),
        borderRadius: BorderRadius.all(Radius.circular(25.0)),
      ),
      child: CustomPaint(
        painter: TabIndicationPainter(pageController: _pageController),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Expanded(
              child: TextButton(
                onPressed: _onSignInButtonPress,
                child: Text(
                  'login.login.tab.title'.tr,
                  style: TextStyle(color: left, fontSize: 16.0, fontFamily: 'WorkSansSemiBold'),
                ),
              ),
            ),
            //Container(height: 33.0, width: 1.0, color: Colors.white),
            Expanded(
              child: TextButton(
                onPressed: _onSignUpButtonPress,
                child: Text(
                  'login.register.tab.title'.tr,
                  style: TextStyle(color: right, fontSize: 16.0, fontFamily: 'WorkSansSemiBold'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignIn(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 23.0),
      child: SingleChildScrollView(
          child: Column(
        children: <Widget>[
          Stack(
            alignment: Alignment.topCenter,
            clipBehavior: Clip.none,
            children: <Widget>[
              Card(
                elevation: 2.0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Container(
                  width: 300.0,
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(top: 20.0, bottom: 20.0, left: 25.0, right: 25.0),
                        child: TextFormField(
                          key: controller.loginEmailKey,
                          focusNode: myFocusNodeEmailLogin,
                          onChanged: (val) => controller.formTexts['loginEmail'] = val,
                          validator: emailValidator,
                          keyboardType: TextInputType.emailAddress,
                          style: TextStyle(
                              fontFamily: 'WorkSansSemiBold', fontSize: 16.0, color: Colors.black),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            icon: Icon(
                              CSchool.envelope,
                              color: Colors.black,
                              size: 22.0,
                            ),
                            hintText: 'login.common.email'.tr,
                            hintStyle: TextStyle(fontFamily: 'WorkSansSemiBold', fontSize: 17.0),
                          ),
                        ),
                      ),
                      Container(
                        width: 250.0,
                        height: 1.0,
                        color: Colors.grey[400],
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 20.0, bottom: 20.0, left: 25.0, right: 25.0),
                        child: TextFormField(
                          key: controller.loginPasswordKey,
                          focusNode: myFocusNodePasswordLogin,
                          onChanged: (val) => controller.formTexts['loginPassword'] = val,
                          validator: RequiredValidator(errorText: 'login.common.error.required'.tr),
                          obscureText: _obscureTextLogin,
                          style: TextStyle(
                              fontFamily: 'WorkSansSemiBold', fontSize: 16.0, color: Colors.black),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            icon: Icon(
                              CSchool.unlock_alt,
                              size: 22.0,
                              color: Colors.black,
                            ),
                            hintText: 'login.common.password'.tr,
                            hintStyle: TextStyle(fontFamily: 'WorkSansSemiBold', fontSize: 17.0),
                            suffixIcon: GestureDetector(
                              onTap: _toggleLogin,
                              child: Icon(
                                _obscureTextLogin ? CSchool.eye : CSchool.eye_slash,
                                size: 15.0,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
              padding: EdgeInsets.only(top: 20.0),
              child: Container(
                // margin: EdgeInsets.only(top: 170.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: theme.Colors.loginGradientStart,
                      offset: Offset(1.0, 6.0),
                      blurRadius: 20.0,
                    ),
                    BoxShadow(
                      color: theme.Colors.loginGradientEnd,
                      offset: Offset(1.0, 6.0),
                      blurRadius: 20.0,
                    ),
                  ],
                  gradient: LinearGradient(
                      colors: [theme.Colors.loginGradientEnd, theme.Colors.loginGradientStart],
                      begin: const FractionalOffset(0.2, 0.2),
                      end: const FractionalOffset(1.0, 1.0),
                      stops: [0.0, 1.0],
                      tileMode: TileMode.clamp),
                ),
                child: MaterialButton(
                  highlightColor: Colors.transparent,
                  splashColor: theme.Colors.loginGradientEnd,
                  //shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5.0))),

                  onPressed: () async {
                    await controller.handleEmailLogin();
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 42.0),
                    child: Text(
                      'login.login.button.login'.tr,
                      style: TextStyle(
                          color: Colors.white, fontSize: 25.0, fontFamily: 'WorkSansBold'),
                    ),
                  ),
                ),
              )),
          Padding(
            padding: EdgeInsets.only(top: 10.0),
            child: TextButton(
                onPressed: controller.handleForgetPassword,
                child: Text(
                  'login.register.button.forgotPassword'.tr,
                  style: TextStyle(
                      decoration: TextDecoration.underline,
                      color: Colors.white,
                      fontSize: 16.0,
                      fontFamily: 'WorkSansMedium'),
                )),
          ),
          Padding(
            padding: EdgeInsets.only(top: 10.0),
            child: FancySeparator(
              middleWidget: Padding(
                padding: EdgeInsets.only(left: 15.0, right: 15.0),
                child: Text(
                  'Or',
                  style:
                      TextStyle(color: Colors.white, fontSize: 16.0, fontFamily: 'WorkSansMedium'),
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: buildThirdPartyLoginRow(),
          ),
        ],
      )),
    );
  }

  List<Widget> buildThirdPartyLoginRow() {
    var thirdPartyLogin = <Widget>[
      Padding(
        padding: EdgeInsets.only(top: 10.0, right: 30.0, bottom: 20.0),
        child: GestureDetector(
          onTap: controller.handleTwitterLogin,
          child: Container(
            padding: const EdgeInsets.all(15.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: Icon(
              CSchool.twitter,
              color: Color(0xFF0084ff),
            ),
          ),
        ),
      ),
      Padding(
        padding: EdgeInsets.only(top: 10.0, right: 30.0, bottom: 20.0),
        child: GestureDetector(
          onTap: controller.handleFacebookLogin,
          child: Container(
            padding: const EdgeInsets.all(15.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: Icon(
              CSchool.facebook_f,
              color: Color(0xFF0084ff),
            ),
          ),
        ),
      ),
      Padding(
        padding: EdgeInsets.only(top: 10.0, bottom: 20.0),
        child: GestureDetector(
          onTap: controller.handleGoogleLogin,
          child: Container(
            padding: const EdgeInsets.all(15.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: Icon(
              CSchool.google,
              color: Color(0xFF0084ff),
            ),
          ),
        ),
      ),
    ];
    if (GetPlatform.isIOS) {
      thirdPartyLogin.add(Padding(
        padding: EdgeInsets.only(left: 30, top: 10.0, bottom: 20.0),
        child: GestureDetector(
          onTap: controller.handleAppleLogin,
          child: Container(
            padding: const EdgeInsets.all(15.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: Icon(
              CSchool.apple,
              color: Color(0xFF0084ff),
            ),
          ),
        ),
      ));
    }
    return thirdPartyLogin;
  }

  Widget _buildSignUp(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 23.0),
      child: SingleChildScrollView(
          child: Column(
        children: <Widget>[
          Stack(
            alignment: Alignment.topCenter,
            clipBehavior: Clip.none,
            children: <Widget>[
              Card(
                elevation: 2.0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Container(
                  width: 300.0,
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(top: 20.0, bottom: 20.0, left: 25.0, right: 25.0),
                        child: TextFormField(
                          key: controller.signupNamelKey,
                          focusNode: myFocusNodeName,
                          onChanged: (val) => controller.formTexts['signupName'] = val,
                          validator: MultiValidator([
                            RequiredValidator(errorText: 'login.common.error.required'.tr),
                            MaxLengthValidator(50, errorText: 'login.register.error.tooLong'.tr)
                          ]),
                          keyboardType: TextInputType.text,
                          textCapitalization: TextCapitalization.words,
                          style: TextStyle(
                              fontFamily: 'WorkSansSemiBold', fontSize: 16.0, color: Colors.black),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            icon: Icon(
                              CSchool.user_circle,
                              color: Colors.black,
                            ),
                            hintText: 'login.register.form.name'.tr,
                            hintStyle: TextStyle(fontFamily: 'WorkSansSemiBold', fontSize: 16.0),
                          ),
                        ),
                      ),
                      Container(
                        width: 250.0,
                        height: 1.0,
                        color: Colors.grey[400],
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 20.0, bottom: 20.0, left: 25.0, right: 25.0),
                        child: TextFormField(
                          key: controller.signupEmailKey,
                          focusNode: myFocusNodeEmail,
                          onChanged: (val) => controller.formTexts['signupEmail'] = val,
                          validator: emailValidator,
                          keyboardType: TextInputType.emailAddress,
                          style: TextStyle(
                              fontFamily: 'WorkSansSemiBold', fontSize: 16.0, color: Colors.black),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            icon: Icon(
                              CSchool.envelope,
                              color: Colors.black,
                            ),
                            hintText: 'login.common.email'.tr,
                            hintStyle: TextStyle(fontFamily: 'WorkSansSemiBold', fontSize: 16.0),
                          ),
                        ),
                      ),
                      Container(
                        width: 250.0,
                        height: 1.0,
                        color: Colors.grey[400],
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 20.0, bottom: 20.0, left: 25.0, right: 25.0),
                        child: TextFormField(
                          key: controller.signupPasswordKey,
                          focusNode: myFocusNodePassword,
                          onChanged: (val) => controller.formTexts['signupPassword'] = val,
                          validator: passwordValidator,
                          obscureText: _obscureTextSignup,
                          style: TextStyle(
                              fontFamily: 'WorkSansSemiBold', fontSize: 16.0, color: Colors.black),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            icon: Icon(
                              CSchool.unlock_alt,
                              color: Colors.black,
                            ),
                            hintText: 'login.common.password'.tr,
                            hintStyle: TextStyle(fontFamily: 'WorkSansSemiBold', fontSize: 16.0),
                            suffixIcon: GestureDetector(
                              onTap: _toggleSignup,
                              child: Icon(
                                _obscureTextSignup ? CSchool.eye : CSchool.eye_slash,
                                size: 15.0,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: 250.0,
                        height: 1.0,
                        color: Colors.grey[400],
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 20.0, bottom: 20.0, left: 25.0, right: 25.0),
                        child: TextFormField(
                          key: controller.signupConfirmPasswordlKey,
                          validator: (val) => MatchValidator(
                                  errorText: 'login.register.error.passwordConfirmError'.tr)
                              .validateMatch(val, controller.formTexts['signupPassword']),
                          obscureText: _obscureTextSignupConfirm,
                          style: TextStyle(
                              fontFamily: 'WorkSansSemiBold', fontSize: 16.0, color: Colors.black),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            icon: Icon(
                              CSchool.unlock_alt,
                              color: Colors.black,
                            ),
                            hintText: 'login.register.form.passwordConfirm'.tr,
                            hintStyle: TextStyle(fontFamily: 'WorkSansSemiBold', fontSize: 16.0),
                            suffixIcon: GestureDetector(
                              onTap: _toggleSignupConfirm,
                              child: Icon(
                                _obscureTextSignupConfirm ? CSchool.eye : CSchool.eye_slash,
                                size: 15.0,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
              padding: EdgeInsets.only(top: 1.0),
              child: Container(
                margin: EdgeInsets.only(bottom: 20.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: theme.Colors.loginGradientStart,
                      offset: Offset(1.0, 6.0),
                      blurRadius: 20.0,
                    ),
                    BoxShadow(
                      color: theme.Colors.loginGradientEnd,
                      offset: Offset(1.0, 6.0),
                      blurRadius: 20.0,
                    ),
                  ],
                  gradient: LinearGradient(
                      colors: [theme.Colors.loginGradientEnd, theme.Colors.loginGradientStart],
                      begin: const FractionalOffset(0.2, 0.2),
                      end: const FractionalOffset(1.0, 1.0),
                      stops: [0.0, 1.0],
                      tileMode: TileMode.clamp),
                ),
                child: MaterialButton(
                  highlightColor: Colors.transparent,
                  splashColor: theme.Colors.loginGradientEnd,
                  //shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5.0))),

                  onPressed: () async {
                    await controller.handleEmailSignUp();
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 42.0),
                    child: Text(
                      'login.register.button.signUp'.tr,
                      style: TextStyle(
                          color: Colors.white, fontSize: 25.0, fontFamily: 'WorkSansBold'),
                    ),
                  ),
                ),
              ))
        ],
      )),
    );
  }

  void _onSignInButtonPress() {
    _pageController.animateToPage(0,
        duration: Duration(milliseconds: 500), curve: Curves.decelerate);
  }

  void _onSignUpButtonPress() {
    _pageController?.animateToPage(1,
        duration: Duration(milliseconds: 500), curve: Curves.decelerate);
  }

  void _toggleLogin() {
    setState(() {
      _obscureTextLogin = !_obscureTextLogin;
    });
  }

  void _toggleSignup() {
    setState(() {
      _obscureTextSignup = !_obscureTextSignup;
    });
  }

  void _toggleSignupConfirm() {
    setState(() {
      _obscureTextSignupConfirm = !_obscureTextSignupConfirm;
    });
  }
}
