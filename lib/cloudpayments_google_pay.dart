import 'dart:io';

import 'package:cloudpayments_upgraded/google_pay_response.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Google Pay Environment. In order to make test payments you still have to obtain access to production environment.
/// See <https://developers.google.com/pay/api/android/guides/test-and-deploy/request-prod-access>
enum GooglePayEnvironment { test, production }

/// Contains helper methods that allow you to interact with Google Pay.
class cloudpayments_upgradedGooglePay {
  static const MethodChannel _channel = const MethodChannel('cloudpayments_upgraded');

  cloudpayments_upgradedGooglePay(GooglePayEnvironment environment) {
    _initGooglePay(describeEnum(environment));
  }

  void _initGooglePay(String environment) async {
    await _channel.invokeMethod('createPaymentsClient', {
      'environment': environment,
    });
  }

  /// Checks whether a Google Pay is available on this device and can process payment requests using
  /// cloudpayments_upgraded payment network brands (Visa and Mastercard).
  Future<bool> isGooglePayAvailable() async {
    if (Platform.isAndroid) {
      try {
        final available = await _channel.invokeMethod('isGooglePayAvailable');
        return available;
      } on PlatformException catch (_) {
        return false;
      }
    }
    return false;
  }

  /// Requests Apple Pay payment.
  ///
  /// [price] - Total purchase price. The price must use '.' decimal separator, not ','. Fro example '199.99'
  ///
  /// [currencyCode] - Currency code. For example 'RUB'.
  ///
  /// [countryCode] - Country code. For example 'RU'.
  ///
  /// [merchantName] - Your merchant name.  Merchant name is rendered in the payment sheet.
  /// In TEST environment, or if a merchant isn't recognized, a “Pay Unverified Merchant”
  /// message is displayed in the payment sheet.
  ///
  /// [publicId] - Your cloudpayments_upgraded public id. You can obtain it in your [cloudpayments_upgraded account](https://merchant.cloudpayments_upgraded.ru/)
  ///
  /// Returns [GooglePayResponse]. You have to check whether response is success and if so, you can obtain
  /// payment token by [response.token]
  ///
  /// ```dart
  /// if (response.isSuccess) {
  ///   final token = response.token;
  ///   // use token for payment by a cryptogram
  /// } else if (response.isError) {
  ///   // show error
  ///} else if (response.isCanceled) {
  ///   // google pay was canceled
  ///}
  /// ```
  Future<GooglePayResponse> requestGooglePayPayment({
    required String price,
    required String currencyCode,
    required String countryCode,
    required String merchantName,
    required String publicId,
  }) async {
    if (Platform.isAndroid) {
      try {
        final dynamic result =
            await _channel.invokeMethod<dynamic>('requestGooglePayPayment', {
          'price': price,
          'currencyCode': currencyCode,
          'countryCode': countryCode,
          'merchantName': merchantName,
          'publicId': publicId,
        });
        return GooglePayResponse.fromMap(result);
      } on PlatformException catch (e) {
        return GooglePayResponse.fromPlatformException(e);
      } catch (e) {
        return GooglePayResponse.fromException();
      }
    } else {
      throw Exception("Google Pay is allowed only on Android");
    }
  }
}
