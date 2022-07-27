import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:razorpay_intergration/model/razorpay_response_model.dart';
import 'package:http/http.dart' as http;

import 'constant.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({Key? key}) : super(key: key);

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  Razorpay? _razorpay;
  TextEditingController amount = TextEditingController();

  @override
  void initState() {
    _razorpay = Razorpay();
    _razorpay?.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay?.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay?.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    super.initState();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    Fluttertoast.showToast(msg: " Payment Successfully");
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    Fluttertoast.showToast(msg: "Payment failed");
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    Fluttertoast.showToast(msg: "Payment Successfully");
  }

  Future<dynamic> createOrder() async {
    var mapHeader = <String, String>{};
    mapHeader['Authorization'] =
        "Basic cnpwX3Rlc3RfU2RHQmFoV3RsS1dNd2I6Mlh2WElOSDlMcG9xTHdyU3F5cDFzam5y";
    mapHeader['Accept'] = "application/json";
    mapHeader['Content-Type'] = "application/x-www-form-urlencoded";
    var map = <String, String>{};
    setState(() {
      map['amount'] = "${(num.parse(amount.text) * 100)}";
    });
    map['currency'] = "INR";
    map['receipt'] = "receipt1";
    print("map $map");
    var response = await http.post(Uri.https("api.razorpay.com", "/v1/orders"),
        headers: mapHeader, body: map);
    print("...." + response.body);
    if (response.statusCode == 200) {
      RazorpayOrderResponse data =
          RazorpayOrderResponse.fromJson(json.decode(response.body));
      openCheckout(data);
    } else {
      Fluttertoast.showToast(msg: "Something went wrong!");
    }
  }

  void openCheckout(RazorpayOrderResponse data) async {
    var options = {
      'key': RazorpayApiKey,
      'amount': "${(num.parse(amount.text) * 100)}",
      'name': 'Razorpay Test',
      'description': '',
      'order_id': '${data.id}',
    };

    try {
      _razorpay?.open(options);
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Razorpay integration"),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: amount,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                  focusedBorder: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(),
                  hintText: "Amount"),
            ),
          ),
          ElevatedButton.icon(
              onPressed: () => createOrder(),
              icon: Icon(Icons.arrow_forward_sharp),
              label: Text("PAY"))
        ],
      ),
    );
  }
}
