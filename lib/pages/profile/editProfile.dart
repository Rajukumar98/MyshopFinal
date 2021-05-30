import '../../components/modals/internetConnection.dart';
import '../../services/userService.dart';
import 'package:flutter/material.dart';

import '../../components/sidebar.dart';
import '../../components/header.dart';
import '../../components/loader.dart';
import '../../services/profileService.dart';
import '../../services/validateService.dart';
import '../../sizeConfig.dart';

class EditProfile extends StatefulWidget {
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  ValidateService _validateService = new ValidateService();
  ProfileService _profileService = new ProfileService();
  UserService _userService = new UserService();
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();
  bool showCartIcon = true;
  // ignore: unused_field
  bool _autoValidate = false;
  String fullName, mobileNumber, email;

  setProfileDetails() {
    dynamic args = ModalRoute.of(context).settings.arguments;
    setState(() {
      fullName = args['fullName'];
      mobileNumber = args['mobileNumber'];
      email = args['email'];
    });
  }

  InputDecoration customFormField(text) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      hintText: text,
      labelText: text,
      errorStyle: TextStyle(fontSize: SizeConfig.safeBlockHorizontal * 3.2),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6.0),
          borderSide: BorderSide(width: 2.0, color: Colors.black)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6.0),
          borderSide: BorderSide(width: 2.0, color: Colors.black)),
    );
  }

  validateProfile(context) async {
    if (this._formKey.currentState.validate()) {
      _formKey.currentState.save();
      bool connectionStatus = await _userService.checkInternetConnectivity();

      if (connectionStatus) {
        Loader.showLoadingScreen(context, _keyLoader);
        _profileService
            .updateAccountDetails(fullName, mobileNumber)
            .then((value) async {
          Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
          Map userData = await _profileService.getUserProfile();
          Navigator.pushReplacementNamed(context, '/profile',
              arguments: userData);
        });
      } else {
        internetConnectionDialog(context);
      }
    } else {
      setState(() {
        _autoValidate = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    setProfileDetails();
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: Colors.grey[200],
      key: _scaffoldKey,
      appBar: header('Edit Profile', _scaffoldKey, showCartIcon, context),
      drawer: sidebar(context),
      body: Container(
            ),
    );
  }
}
