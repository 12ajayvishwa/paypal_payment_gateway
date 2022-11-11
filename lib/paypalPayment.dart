import 'dart:core';
import 'package:flutter/material.dart';
import 'package:paypal_payment_gateway/paypal_services.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaypalPayment extends StatefulWidget {
  final Function onFinish;
  const PaypalPayment({Key? key, required this.onFinish}) : super(key: key);

  @override
  State<PaypalPayment> createState() => _PaypalPaymentState();
}

class _PaypalPaymentState extends State<PaypalPayment> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  var checkoutUrl;
  var executeUrl;
  var accessToken;

  PaypalServices services = PaypalServices();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      try {
        accessToken = await services.getAcessToken();
        final transactions = getOrderParams();
        final res =
            await services.createPaypalPayment(transactions, accessToken);
        if (res != null) {
          checkoutUrl = res["approvalUrl"];
          executeUrl = res["executedUrl"];
        }
      } catch (e) {
        print('exception:' + e.toString());
      }
    });
  }

  String returnURL = "return_example.com";
  String cancelURl = "cancel_example.com";

  Map<dynamic, dynamic> defaultCurrency = {
    "symbol": "USD",
    "decimalDigit": 2,
    "symbolBeforeTheNumber": true,
    "currency": "USD"
  };
  bool isEnabledShipping = false;
  bool isEnabledAddress = false;
  String itemName = "iPhone";
  String itemPrice = '1.99';
  int quantity = 1;

  Map<String, dynamic> getOrderParams() {
    List items = [
      {
        "name": itemName,
        "quantity": quantity,
        "price": itemPrice,
        "currency": defaultCurrency['currency'],
      }
    ];

    String totalAmount = '1.99';
    String subTotalAmount = '1.99';
    String shippingCost = '0';
    int shippingDiscountCost = 0;
    String userFirstName = 'Ajay';
    String userLastName = 'Vishwakarma';
    String addressCity = 'Bhopal';
    String addressStreet = 'Chetak bridge';
    String addressZipCode = "470121";
    String addressCountry = "India";
    String addressState = "MP";
    String addressPhoneNumber = "+919340484796";

    Map<String, dynamic> temp = {
      "intent": "sale",
      "payer": {"payment_method": "paypal"},
      "transactions": [
        {
          "amount": {
            "total": totalAmount,
            "currency": defaultCurrency['currency'],
            "details": {
              "subtotal": subTotalAmount,
              "shipping": shippingCost,
              "shipping_discount": ((-1.0) * shippingDiscountCost).toString()
            }
          },
          "description": "The payment transation description.",
          "payment_options": {
            "allowed_payment_method": "INSTANT_FUNDING_SOURCE",
          },
          "items_list": {
            "items": items,
            if (isEnabledShipping && isEnabledAddress)
              "shipping_address": {
                "recipient_name": userFirstName + "" + userLastName,
                "line1": addressStreet,
                "line2": "",
                "city": addressCity,
                "country_code": addressCountry,
                "postal_code": addressZipCode,
                "phone": addressPhoneNumber,
                "state": addressState
              }
          }
        }
      ],
      "note_to_payer": "contact us for any quations on your order.",
      "redirect_urls": {"return_url": returnURL, "Cancel_url": cancelURl}
    };
    return temp;
  }

  @override
  Widget build(BuildContext context) {
    print(checkoutUrl);
    if (checkoutUrl != null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).backgroundColor,
          leading: GestureDetector(
            child: Icon(Icons.arrow_back_ios),
            onTap: () => Navigator.pop(context),
          ),
        ),
        body: WebView(
          initialUrl: checkoutUrl,
          javascriptMode: JavascriptMode.unrestricted,
          navigationDelegate: (NavigationRequest request) {
            if (request.url.contains(returnURL)) {
              final uri = Uri.parse(request.url);
              final payerID = uri.queryParameters['PayerID'];
              if (payerID != null) {
                services
                    .executePayment(executeUrl, payerID, accessToken)
                    .then((id) {
                  widget.onFinish(id);
                  Navigator.pop(context);
                });
              } else {
                Navigator.of(context).pop();
              }
              Navigator.of(context).pop();
            }
            if (request.url.contains(cancelURl)) {
              Navigator.of(context).pop();
            }
            return NavigationDecision.navigate;
          },
        ),
      );
    } else {
      return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: Center(child: Container(child: CircularProgressIndicator(),),),
      );
    }
  }
}
