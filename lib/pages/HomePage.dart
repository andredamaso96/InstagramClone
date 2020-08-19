import 'package:buddiesgram/models/user.dart';
import 'package:buddiesgram/pages/CreateAccountPage.dart';
import 'package:buddiesgram/pages/NotificationsPage.dart';
import 'package:buddiesgram/pages/ProfilePage.dart';
import 'package:buddiesgram/pages/SearchPage.dart';
import 'package:buddiesgram/pages/TimeLinePage.dart';
import 'package:buddiesgram/pages/UploadPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

final GoogleSignIn googleSignIn = GoogleSignIn();
final usersReference = Firestore.instance.collection("users");
final DateTime timestamp = DateTime.now();

User currentUser;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  bool isSignedIn = false;
  PageController pageController;
  int getPageIndex = 0;

  void initState(){
    super.initState();

    pageController = PageController();

    googleSignIn.onCurrentUserChanged.listen((googleSignInAccount) {
        controlSignIn(googleSignInAccount);
     }, onError: (googleError){
       print("Error Message:" + googleError);
     });

     googleSignIn.signInSilently(suppressErrors: false).then((googleSignInAccount){
       controlSignIn(googleSignInAccount);
     }).catchError((googleError){
      print("Error Message:" + googleError);
     });
  }

  controlSignIn(GoogleSignInAccount signInAccount) async{
    if(signInAccount != null){

      await saveUserInfoToFireStore();

      setState(() {
        isSignedIn = true;
      });
    }else{
      isSignedIn = false;
    }
  }

  saveUserInfoToFireStore() async {
    final GoogleSignInAccount googleCurrentUser = googleSignIn.currentUser;
    DocumentSnapshot documentSnapshot = await usersReference.document(googleCurrentUser.id).get();

    if(!documentSnapshot.exists){
      final username = await Navigator.push(context, MaterialPageRoute(builder: (context) => CreateAccountPage()));

      usersReference.document(googleCurrentUser.id).setData({
      "id" : googleCurrentUser.id,
      "profileName" : googleCurrentUser.displayName,
      "username" : username,
      "url" : googleCurrentUser.photoUrl,
      "email" : googleCurrentUser.email,
      "bio" : "",
      "timestamp" : timestamp
      
      });

      documentSnapshot = await usersReference.document(googleCurrentUser.id).get();

    }

    currentUser = User.fromDocument(documentSnapshot);
    
  }

  void dispose(){
    pageController.dispose();
    super.dispose();
  }

  loginUser(){
    googleSignIn.signIn();
  }

  logoutUser(){
    googleSignIn.signOut();
  }

  whenPageChanges(int pageIndex){
      setState(() {
        this.getPageIndex = pageIndex;
      });
  }

  onTapChangePage(int pageIndex){
    pageController.animateToPage(pageIndex, duration: Duration(milliseconds: 400), curve: Curves.bounceInOut,);

  }


  Scaffold buildHomeScreen(){
    return Scaffold(
      body: PageView(
        children: <Widget>[
          TimeLinePage(),
          SearchPage(),
          UploadPage(),
          NotificationsPage(),
          ProfilePage(),

        ],
        controller: pageController,
        onPageChanged: whenPageChanges,
        physics: NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: CupertinoTabBar(
        currentIndex: getPageIndex,
        onTap: onTapChangePage,
        backgroundColor: Theme.of(context).accentColor,
        activeColor: Colors.white,
        inactiveColor: Colors.blueGrey,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home)),
          BottomNavigationBarItem(icon: Icon(Icons.search)),
          BottomNavigationBarItem(icon: Icon(Icons.photo_camera, size: 37.0,)),
          BottomNavigationBarItem(icon: Icon(Icons.favorite)),
          BottomNavigationBarItem(icon: Icon(Icons.person)),
        ],
      ),
      );
  }

  Scaffold buildSingInScreen(){
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Theme.of(context).accentColor, Theme.of(context).primaryColor],
          )
        ),

        alignment: Alignment.center,

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              "Instagram",
              style: TextStyle(fontSize: 92.0, color: Colors.white, fontFamily: "Billabong"),
            ),
            GestureDetector(
              onTap: loginUser,
              child: Container(
                width: 270.0,
                height: 65.0,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/google_signin_button.png"),
                    fit: BoxFit.cover,
                    ),
                ),
              ),
            ),
          ],
          ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if(isSignedIn){
      return buildHomeScreen();
    }else{
      return buildSingInScreen();
    }
  }
}
