import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../components/header.dart';
import '../../components/item/productButton.dart';
import '../../components/item/productSize.dart';
import '../../components/sidebar.dart';
import '../../components/loader.dart';
import '../../services/shoppingBagService.dart';
import '../../components/item/colorGroupButton.dart';
import '../../sizeConfig.dart';
import '../../components/modals/internetConnection.dart';
import '../../services/userService.dart';

class ParticularItem extends StatefulWidget {
  final Map<String, dynamic> itemDetails;
  final bool editProduct;

  ParticularItem({var key, this.itemDetails, this.editProduct})
      : super(key: key);

  @override
  _ParticularItemState createState() => _ParticularItemState();
}

class _ParticularItemState extends State<ParticularItem> {
  final GlobalKey<ScaffoldState> _productScaffoldKey =
      new GlobalKey<ScaffoldState>();
  ShoppingBagService _shoppingBagService = new ShoppingBagService();
  UserService _userService = new UserService();
  final GlobalKey<State> keyLoader = new GlobalKey<State>();

  Map customDimension = new Map();
  List<Map<Color, bool>> productColors;
  List<Map<String, bool>> productSizes;
  int productQuantity = 1;

  setItemDetails(item) {
    // print('set item details');
    Map<String, dynamic> args = widget.itemDetails;
    setState(() {
      if (widget.editProduct) {
        productQuantity = widget.itemDetails['quantity'];
      }
      productColors = setColorList(args['color']);
      productSizes = setSizeList(args['size']);
    });
  }

// {
//   userId: 13YBorU6UnNamcKVcXZ5LVYXbOt2,
//   products: [
//     {quantity: 1,
//       color: dcae96, size: L, id: 0UOHpoWinWp9YLQFE8im},
//     {quantity: 2, size: L,
//       color: 252440, id: 0OR2bpoHplOpBBZ0EaRj}
//     ]
// }
  setProductQuantity(String type) {
    setState(() {
      if (type == 'inc') {
        if (productQuantity != 5) {
          productQuantity = productQuantity + 1;
        }
      } else {
        if (productQuantity != 1) {
          productQuantity = productQuantity - 1;
        }
      }
    });
  }

  void setCustomWidth(String screenSize) {
    if (screenSize == 'smallMobile') {
      customDimension['productImageHeight'] = SizeConfig.screenHeight / 2.4;
      customDimension['sizeBoxHeight'] = SizeConfig.safeBlockVertical * 7.5;
    } else if (screenSize == 'largeMobile') {
      customDimension['productImageHeight'] = SizeConfig.screenHeight / 2.2;
      customDimension['sizeBoxHeight'] = SizeConfig.safeBlockVertical * 6.5;
    } else if (screenSize == 'tablet') {
      customDimension['productImageHeight'] = SizeConfig.screenHeight / 2.3;
      customDimension['sizeBoxHeight'] = SizeConfig.safeBlockVertical * 6.5;
    }
  }

  List setColorList(List colors) {
    List<Map<Color, bool>> colorList = [];
    String selectedColor = '0xFF${widget.itemDetails['selectedColor']}';
    colors.forEach((value) {
      Map<Color, bool> colorMap = new Map();
      if (widget.editProduct && value == selectedColor) {
        colorMap[Color(int.parse(value))] = true;
        widget.itemDetails.remove('selectedColor');
      } else {
        colorMap[Color(int.parse(value))] = false;
      }
      colorList.add(colorMap);
    });
    return colorList;
  }

  void selectProductColor(int index) {
    List tempColorList = setColorList(widget.itemDetails['color']);
    Color key = tempColorList[index].keys.toList()[0];
    tempColorList[index][key] = true;
    setState(() {
      productColors = tempColorList;
    });
  }

  void selectProductSize(int index) {
    List tempSizeList = setSizeList(widget.itemDetails['size']);
    String key = tempSizeList[index].keys.toList()[0];
    tempSizeList[index][key] = true;
    setState(() {
      productSizes = tempSizeList;
    });
  }

  List<Map<String, bool>> setSizeList(List sizes) {
    List<Map<String, bool>> sizeList = [];
    String selectedSize = widget.itemDetails['selectedSize'];
    sizes.forEach((size) {
      Map<String, bool> sizeMap = new Map();
      if (widget.editProduct && selectedSize == size) {
        sizeMap[size] = true;
        widget.itemDetails.remove('selectedSize');
      } else {
        sizeMap[size] = false;
      }
      sizeList.add(sizeMap);
    });
    return sizeList;
  }

  void showInSnackBar(String msg, Color color) {
    // ignore: deprecated_member_use
    _productScaffoldKey.currentState.showSnackBar(
      SnackBar(
        backgroundColor: color,
        content: new Text(msg),
        action: SnackBarAction(
          label: 'Close',
          textColor: Colors.white,
          onPressed: () {
            // ignore: deprecated_member_use
            _productScaffoldKey.currentState.removeCurrentSnackBar();
          },
        ),
      ),
    );
  }

  checkoutProduct() async {
    String selectedSize = '';
    String selectedColor = '';
    if (productSizes.length > 0) {
      for (Map size in productSizes) {
        if (size.values.toList()[0]) selectedSize = size.keys.toList()[0];
      }
    } else {
      selectedSize = "0";
    }

    if (productColors.length > 0) {
      for (Map color in productColors) {
        if (color.values.toList()[0])
          selectedColor = color.toString().substring(11, 17);
      }
    } else {
      selectedColor = ".";
    }

    if (selectedSize == '')
      showInSnackBar('Select size', Colors.red);
    else if (selectedColor == '')
      showInSnackBar('Select color', Colors.red);
    else {
      bool connectionStatus = await _userService.checkInternetConnectivity();

      if (connectionStatus) {
        Map<String, dynamic> args = new Map<String, dynamic>();
        Loader.showLoadingScreen(context, keyLoader);
        String msg = await _shoppingBagService.add(
            widget.itemDetails['productId'], selectedSize, selectedColor, 1);
        print(msg);
        args['price'] = widget.itemDetails['price'];
        args['productId'] = widget.itemDetails['productId'];
        args['quantity'] = productQuantity;
        args['size'] = selectedSize;
        args['color'] = selectedColor;
        Navigator.of(context).pushNamed('/checkout/address', arguments: args);
      } else {
        internetConnectionDialog(context);
      }
    }
  }

  addToShoppingBag() async {
    String selectedSize = '';
    String selectedColor = '';
    if (productSizes.length > 0) {
      for (Map size in productSizes) {
        if (size.values.toList()[0]) selectedSize = size.keys.toList()[0];
      }
    } else {
      selectedSize = "0";
    }

    if (productColors.length > 0) {
      for (Map color in productColors) {
        if (color.values.toList()[0])
          selectedColor = color.toString().substring(11, 17);
      }
    } else {
      selectedColor = ".";
    }

    if (selectedSize == '')
      showInSnackBar('Select size', Colors.red);
    else if (selectedColor == '')
      showInSnackBar('Select color', Colors.red);
    else {
      bool connectionStatus = await _userService.checkInternetConnectivity();

      if (connectionStatus) {
        Loader.showLoadingScreen(context, keyLoader);
        String msg = await _shoppingBagService.add(
            widget.itemDetails['productId'],
            selectedSize,
            selectedColor,
            productQuantity);
        Navigator.of(keyLoader.currentContext, rootNavigator: true).pop();
        showInSnackBar(msg, Colors.black);
      } else {
        internetConnectionDialog(context);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    setItemDetails(widget.itemDetails);
    print(widget.itemDetails);
    print("202 in particular");
  }

  @override
  Widget build(BuildContext buildContext) {
    SizeConfig().init(buildContext);
    setCustomWidth(SizeConfig.screenSize);

    return Scaffold(
      key: _productScaffoldKey,
      appBar: header('Product Details', _productScaffoldKey, true, context),
      drawer: sidebar(context),
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.25, 0.2],
              colors: [Color(0xffff77a9), Colors.white],
            ),
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
                SizeConfig.safeBlockHorizontal * 6.7,
                SizeConfig.topPadding,
                SizeConfig.safeBlockHorizontal * 6.7,
                SizeConfig.topPadding),
            child: SizedBox(
              height: SizeConfig.screenHeight,
              width: SizeConfig.screenWidth,
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(35)),
                color: Colors.red,
                elevation: 10.0,
                margin: EdgeInsets.zero,
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    Container(
                      height: customDimension['productImageHeight'],
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              // image: NetworkImage(widget.itemDetails['image']),
                              // 'assets/mock_images/products'
                              image: AssetImage(
                                  "assets/mock_images/products/${widget.itemDetails['image']}"),
                              fit: BoxFit.fill)),
                    ),
                    Expanded(
                        child: Container(
                            width: SizeConfig.screenWidth,
                            padding: EdgeInsets.symmetric(
                                vertical: 10.0,
                                horizontal: SizeConfig.safeBlockHorizontal * 5),
                            margin: EdgeInsets.zero,
                            decoration: BoxDecoration(
                              color: Color(0xff97144d),
                            ),
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Flexible(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'T-Shirt',
                                          style: TextStyle(
                                              fontFamily: 'Lato-Regular',
                                              fontSize: SizeConfig
                                                      .safeBlockHorizontal *
                                                  4.5,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 1.0),
                                        ),
                                        Text(
                                          "\u{20B9}${widget.itemDetails['price']}.00",
                                          style: TextStyle(
                                              fontSize: SizeConfig
                                                      .safeBlockHorizontal *
                                                  4.8,
                                              fontFamily: 'Lato-Regular',
                                              color: Colors.white70,
                                              fontWeight: FontWeight.bold),
                                        )
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 10.0),
                                  Text(
                                    widget.itemDetails['name'],
                                    style: TextStyle(
                                      fontFamily: 'Lato-Regular',
                                      fontSize:
                                          SizeConfig.safeBlockHorizontal * 3.8,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                  productColors.length > 0
                                      ? Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical:
                                                  SizeConfig.safeBlockVertical *
                                                      1.2),
                                          child: Center(
                                            child: Text(
                                              'Color',
                                              style: TextStyle(
                                                  fontFamily: 'Lato-Regular',
                                                  fontSize: SizeConfig
                                                          .safeBlockHorizontal *
                                                      5,
                                                  letterSpacing: 1.0,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        )
                                      : SizedBox(height: 1),
                                  productColors.length > 0
                                      ? ColorGroupButton(
                                          productColors, selectProductColor)
                                      : SizedBox(height: 1),
                                  productSizes.length > 0
                                      ? Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical:
                                                  SizeConfig.safeBlockVertical *
                                                      1.2),
                                          child: Center(
                                            child: Text(
                                              'Size',
                                              style: TextStyle(
                                                  fontFamily: 'Lato-Regular',
                                                  fontSize: SizeConfig
                                                          .safeBlockHorizontal *
                                                      5,
                                                  letterSpacing: 1.0,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        )
                                      : SizedBox(height: 1),
                                  productSizes.length > 0
                                      ? ProductSize(
                                          productSizes,
                                          customDimension,
                                          setSizeList,
                                          selectProductSize)
                                      : SizedBox(height: 1),
                                  Center(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                          vertical:
                                              SizeConfig.safeBlockVertical *
                                                  1.2),
                                      child: Text(
                                        'Quantity',
                                        style: TextStyle(
                                            fontFamily: 'Lato-Regular',
                                            fontSize:
                                                SizeConfig.safeBlockHorizontal *
                                                    5,
                                            letterSpacing: 1.0,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: <Widget>[
                                      MaterialButton(
                                        onPressed: () {
                                          setProductQuantity('inc');
                                        },
                                        color: Colors.white,
                                        child: Icon(
                                          Icons.add,
                                          size: SizeConfig.safeBlockHorizontal *
                                              7,
                                        ),
                                        padding: EdgeInsets.all(
                                            SizeConfig.safeBlockHorizontal * 3),
                                        shape: CircleBorder(),
                                        elevation: 18.0,
                                      ),
                                      Text(
                                        '$productQuantity',
                                        style: TextStyle(
                                            fontSize:
                                                SizeConfig.safeBlockHorizontal *
                                                    7,
                                            fontWeight: FontWeight.bold,color: Colors.white),
                                      ),
                                      MaterialButton(
                                        onPressed: () {
                                          setProductQuantity('dec');
                                        },
                                        textColor: Colors.white,
                                        color: Colors.black,
                                        child: Icon(
                                          Icons.remove,
                                          size: SizeConfig.safeBlockHorizontal *
                                              7,
                                        ),
                                        padding: EdgeInsets.all(
                                            SizeConfig.safeBlockHorizontal * 3),
                                        shape: CircleBorder(),
                                        elevation: 18.0,
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10.0),
                                  ProductButtons(
                                      addToShoppingBag, checkoutProduct),
                                ])))
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
