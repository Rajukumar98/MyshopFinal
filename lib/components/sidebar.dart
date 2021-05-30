import '../components/modals/internetConnection.dart';
import 'package:flutter/material.dart';
import '../sizeConfig.dart';
import '../components/loader.dart';
import '../services/userService.dart';
import '../services/profileService.dart';
import '../services/checkoutService.dart';

Widget sidebar(BuildContext context) {
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();
  UserService _userService = new UserService();
  ProfileService _profileService = new ProfileService();
  CheckoutService _checkoutService = new CheckoutService();

  return SafeArea(
      child: Drawer(
      child: Container( 
        color: Colors.white,
        child: Column(
          children: [
            Image.asset('assets/sIcon.png',
                  height: SizeConfig.safeBlockVertical * 25),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                ListView(
                  shrinkWrap: true,
                  children: <Widget>[
                    ListTile(
                      leading: Icon(Icons.home,color: Color(0xffed1164),),
                      title: Text(
                        'HOME',
                        style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0),
                      ),
                      onTap: () {
                        Navigator.popAndPushNamed(context, '/home');
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.search,color: Color(0xffed1164),),
                      title: Text(
                        'SEARCH',
                        style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0),
                      ),
                    ),
                    ListTile(
                      leading: Icon(Icons.local_shipping,color: Color(0xffed1164),),
                      title: Text(
                        'ORDERS',
                        style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0),
                      ),
                      onTap: () async {
                        bool connectionStatus =
                            await _userService.checkInternetConnectivity();

                        if (connectionStatus) {
                          Loader.showLoadingScreen(context, _keyLoader);
                          List orderData = await _checkoutService.listPlacedOrder();
                          Navigator.of(_keyLoader.currentContext, rootNavigator: true)
                              .pop();
                          Navigator.popAndPushNamed(context, '/placedOrder',
                              arguments: {'data': orderData});
                        } else {
                          internetConnectionDialog(context);
                        }
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.favorite_border,color: Color(0xffed1164),),
                      title: Text(
                        'WISHLIST',
                        style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0),
                      ),
                      
                    ),
                    ListTile(
                      leading: Icon(Icons.person,color: Color(0xffed1164),),
                      title: Text(
                        'PROFILE',
                        style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0),
                      ),
                      onTap: () async {
                        bool connectionStatus =
                            await _userService.checkInternetConnectivity();

                        if (connectionStatus) {
                          Loader.showLoadingScreen(context, _keyLoader);
                          Map userProfile = await _profileService.getUserProfile();
                          Navigator.of(_keyLoader.currentContext, rootNavigator: true)
                              .pop();
                          Navigator.popAndPushNamed(context, '/profile',
                              arguments: userProfile);
                        } else {
                          internetConnectionDialog(context);
                        }
                      },
                    ),
                    ListTile(
                      leading: new Icon(Icons.exit_to_app,color: Color(0xffed1164),),
                      title: Text(
                        'LOGOUT',
                        style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0),
                      ),
                      onTap: () async {
                        bool connectionStatus =
                            await _userService.checkInternetConnectivity();

                        if (connectionStatus) {
                          _userService.logOut(context);
                        } else {
                          internetConnectionDialog(context);
                        }
                      },
                    )
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
