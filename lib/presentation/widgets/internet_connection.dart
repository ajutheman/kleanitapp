import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:kleanit/core/theme/color_data.dart';
import 'package:kleanit/core/theme/resizer/fetch_pixels.dart';
import 'package:kleanit/core/theme/widget_utils.dart';

import '../../core/utils/hepler.dart';

class CheckInternetConnection extends StatefulWidget {
  final Widget child;
  final Function? onReload;

  const CheckInternetConnection({
    super.key,
    required this.child,
    this.onReload,
  });

  @override
  State<CheckInternetConnection> createState() =>
      _CheckInternetConnectionState();
}

class _CheckInternetConnectionState extends State<CheckInternetConnection> {
  bool _isConnected = true;
  bool _isLoading = false;

  Future<void> _checkConnectivity() async {
    setState(() {
      _isLoading = true;
    });

    bool connected = await isConnected();

    setState(() {
      _isConnected = connected;
      _isLoading = false;
    });
  }

  void _reloadScreen() async {
    setState(() {
      _isLoading = true;
    });

    bool connected = await isConnected();

    if (connected) {
      setState(() {
        _isConnected = true;
        _isLoading = false;
      });

      // Call the onReload callback if provided
      if (widget.onReload != null) {
        widget.onReload!();
      }
    } else {
      setState(() {
        _isConnected = false;
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
  }

  @override
  Widget build(BuildContext context) {
    FetchPixels(context);

    if (_isLoading) {
      return Scaffold(
        body: Center(child: SpinKitCircle(color: primaryColor)),
      );
    }

    if (!_isConnected) {
      return _buildNoInternetScreen();
    }

    return widget.child;
  }

  Scaffold _buildNoInternetScreen() {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(FetchPixels.getPixelWidth(20)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              getSvgImage('no_internet.svg', height: 120, width: 120),
              getVerSpace(FetchPixels.getPixelHeight(20)),
              getCustomFont(
                "No Internet Connection",
                20,
                Colors.black,
                1,
                fontWeight: FontWeight.bold,
                textAlign: TextAlign.center,
              ),
              getVerSpace(FetchPixels.getPixelHeight(12)),
              getCustomFont(
                "Please check your internet connection and try again.",
                16,
                Colors.black54,
                2,
                textAlign: TextAlign.center,
              ),
              getVerSpace(FetchPixels.getPixelHeight(30)),
              ElevatedButton(
                onPressed: _isLoading ? null : _reloadScreen,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isLoading ? Colors.grey : primaryColor,
                  padding: EdgeInsets.symmetric(
                    horizontal: FetchPixels.getPixelWidth(24),
                    vertical: FetchPixels.getPixelHeight(12),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.refresh, color: Colors.white),
                    getHorSpace(FetchPixels.getPixelWidth(8)),
                    getCustomFont(
                      _isLoading ? "Loading..." : "Try Again",
                      16,
                      Colors.white,
                      1,
                      fontWeight: FontWeight.w600,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
