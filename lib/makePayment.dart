import 'package:flutter/material.dart';
import 'package:paypal_payment_gateway/paypalPayment.dart';


class MakePayment extends StatefulWidget {
  const MakePayment({Key? key}) : super(key: key);
 
  @override
  State<MakePayment> createState() => _MakePaymentState();
}

class _MakePaymentState extends State<MakePayment> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SizedBox(
        height: size.height,
        width: size.width,
        child: Center(
            child: ElevatedButton(
                onPressed: () {    
                  Navigator.push(context, MaterialPageRoute(builder: (_) => PaypalPayment(onFinish: (){},)));
                },
                child: const Text("Make Payment With Paypal"))),
      ),
    );
  }
}
