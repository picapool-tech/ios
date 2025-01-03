import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class NetworkController extends GetxController {
  // Observable variable to track connectivity status
  var isConnected = true.obs;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription _connectivitySubscription;

  @override
  void onInit() {
    super.onInit();
    _startListening();
  }

  @override
  void onClose() {
    _connectivitySubscription.cancel();
    super.onClose();
  }

  // this will handle the connectivity status all the time..
  // if network disconnects, it will handle that also..at any point of time.
  void _startListening() {
    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen((results) async {
      isConnected.value =
          await InternetConnectionChecker.instance.hasConnection;
    });
  }

  // Check initial connectivity status when the app starts
  // this function is not useful at this time..
  Future<void> _checkInitialConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    isConnected.value = (result != ConnectivityResult.none);
  }
}
