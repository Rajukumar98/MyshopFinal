import 'package:flutter/material.dart';

import '../../components/profileAppBar.dart';

class ContactUs extends StatefulWidget {
  @override
  _ContactUsState createState() => _ContactUsState();
}

class _ContactUsState extends State<ContactUs> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool showCartIcon = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      key: _scaffoldKey,
      appBar: ProfileAppBar('Contact Us', context),
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 40.0),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              child: Text(
                'CONTACT',
                style: TextStyle(fontSize: 15.0, letterSpacing: 1.0),
              ),
            ),
            
           
            
 
          ],
        ),
      ),
    );
  }
}
