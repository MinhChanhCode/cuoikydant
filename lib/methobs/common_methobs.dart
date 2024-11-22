import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class CommonMethobs
{
  checkConnectivity(BuildContext context) async
  {
    var connectionResult = await Connectivity().checkConnectivity();

    if (connectionResult != ConnectivityResult.mobile && connectionResult != ConnectivityResult.wifi)
      {
        if(!context.mounted) return;
        displaySnackBar("your Internet is not Available. Check your connection. Try again", context);
      }
  }

  displaySnackBar(String messageText, BuildContext context)
  {
    var snackBar = SnackBar(content: Text(messageText));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}