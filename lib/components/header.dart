import '../components/modals/internetConnection.dart';
import '../services/userService.dart';
import 'package:flutter/material.dart';

import '../components/loader.dart';
import '../services/shoppingBagService.dart';
import '../sizeConfig.dart';

capitalizeHeading(String text) {
  if (text == null) {
    return text = "";
  } else {
    text = "${text[0].toUpperCase()}${text.substring(1)}";
    return text;
  }
}

Widget header(String headerText, GlobalKey<ScaffoldState> scaffoldKey,
    bool showIcon, BuildContext context) {
  final GlobalKey<State> keyLoader = new GlobalKey<State>();
  SizeConfig().init(context);
  ShoppingBagService _shoppingBagService = new ShoppingBagService();
  UserService _userService = new UserService();

  return AppBar(
    centerTitle: true,
    title: Text(
      capitalizeHeading(headerText),
      style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: SizeConfig.safeBlockHorizontal * 5,
          fontFamily: 'Lato-Regular'),
    ),
    backgroundColor: Color(0xff97144d),
    elevation: 1.0,
    automaticallyImplyLeading: false,
    leading: IconButton(
      icon: Icon(Icons.menu,
          size: SizeConfig.safeBlockHorizontal * 7, color: Colors.white),
      onPressed: () {
        if (scaffoldKey.currentState.isDrawerOpen == false) {
          scaffoldKey.currentState.openDrawer();
        } else {
          scaffoldKey.currentState.openEndDrawer();
        }
      },
    ),
    actions: <Widget>[
      Visibility(
        visible: showIcon,
        child: IconButton(
          icon: Icon(
            Icons.shopping_cart_outlined,
            size: SizeConfig.safeBlockHorizontal * 7,
            color: Colors.white,
          ),
          onPressed: () async {
            bool connectionStatus =
                await _userService.checkInternetConnectivity();
            if (connectionStatus) {
              Map<String, dynamic> args = new Map();
              Loader.showLoadingScreen(context, keyLoader);
              List bagItems = await _shoppingBagService.list();
              args['bagItems'] = bagItems;
              Navigator.of(keyLoader.currentContext, rootNavigator: true).pop();
              Navigator.pushNamed(context, '/bag', arguments: args);
            } else {
              internetConnectionDialog(context);
            }
          },
        ),
      )
    ],
  );
}
