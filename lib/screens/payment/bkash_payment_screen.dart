import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../services/api_service.dart';

class BkashPaymentScreen extends StatefulWidget {
  final double amount;
  final String offenseId;
  final String merchantInvoiceNumber;

  const BkashPaymentScreen({
    super.key,
    required this.amount,
    required this.offenseId,
    required this.merchantInvoiceNumber,
  });

  @override
  State<BkashPaymentScreen> createState() => _BkashPaymentScreenState();
}

class _BkashPaymentScreenState extends State<BkashPaymentScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _paymentCompleted = false;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
    _createPayment();
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..addJavaScriptChannel(
        'FlutterChannel', // Changed from ReactNativeWebView
        onMessageReceived: (JavaScriptMessage message) {
          print('📱 Message from WebView: ${message.message}');

          // Skip non-payment messages
          if (message.message == 'Bridge injected successfully' ||
              message.message.contains('injected')) {
            print('⏭️ Skipping bridge message');
            return;
          }

          try {
            final data = jsonDecode(message.message);
            // Check if it's a valid payment result
            if (data.containsKey('status') || data.containsKey('trxID')) {
              _handlePaymentResult(data);
            } else {
              print('⚠️ Not a payment result: $data');
            }
          } catch (e) {
            print('Error parsing message: $e');
            // Check if it's a payment message even without JSON
            if (message.message.contains('success') ||
                message.message.contains('trxID')) {
              _handlePaymentResult({
                'status': message.message.contains('success') ? 'success' : 'failed',
                'trxID': message.message,
                'message': 'Payment completed'
              });
            }
          }
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            print('🌐 Page started: $url');
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            print('✅ Page finished: $url');
            setState(() {
              _isLoading = false;
            });

            // Check if this is the callback page
            if (url.contains('bkash/callback') || url.contains('payment status')) {
              print('🎯 Callback page detected');
              // Try to extract data from URL
              final uri = Uri.parse(url);
              if (uri.queryParameters.isNotEmpty) {
                _handlePaymentResult({
                  'status': uri.queryParameters['status'] ?? 'success',
                  'trxID': uri.queryParameters['trxID'] ?? '',
                  'message': uri.queryParameters['message'] ?? 'Payment completed'
                });
              }
            }

            // Inject JavaScript with a unique channel name
            _controller.runJavaScript('''
              (function() {
                console.log("Setting up payment bridge...");
                
                // Create a unique channel for payment messages only
                window.paymentBridge = {
                  sendPaymentData: function(data) {
                    console.log("Sending payment data:", data);
                    if (window.FlutterChannel) {
                      window.FlutterChannel.postMessage(JSON.stringify(data));
                    }
                  }
                };
                
                // Override only payment-related console logs
                var originalLog = console.log;
                console.log = function() {
                  var args = Array.from(arguments);
                  var message = args.join(' ');
                  
                  // Only intercept messages that look like payment data
                  if (message.includes('Payment') || 
                      message.includes('trxID') || 
                      message.includes('success') ||
                      message.includes('failed')) {
                    
                    if (window.FlutterChannel) {
                      // Try to extract structured data
                      var data = { message: message };
                      if (message.includes('trxID')) {
                        var match = message.match(/trxID[:\s]+([A-Z0-9]+)/i);
                        if (match) data.trxID = match[1];
                      }
                      if (message.includes('success')) data.status = 'success';
                      if (message.includes('failed')) data.status = 'failed';
                      
                      window.FlutterChannel.postMessage(JSON.stringify(data));
                    }
                  }
                  
                  originalLog.apply(console, args);
                };
                
                console.log("Payment bridge ready");
              })();
            ''');
          },
          onNavigationRequest: (NavigationRequest request) {
            print('🚀 Navigation: ${request.url}');

            // Check for callback URLs
            if (request.url.contains('bkash/callback') ||
                request.url.contains('localhost') ||
                request.url.contains('127.0.0.1')) {
              print('🎯 Callback navigation');
            }

            return NavigationDecision.navigate;
          },
        ),
      );
  }

  Future<void> _createPayment() async {
    try {
      setState(() {
        _isLoading = true;
      });

      print('💰 Creating payment for offense: ${widget.offenseId}');

      final response = await ApiService.createBkashPayment(
        amount: widget.amount,
        offenseId: widget.offenseId,
        merchantInvoiceNumber: widget.merchantInvoiceNumber,
      );

      print('📦 Payment response: $response');

      if (response['success'] == true && response['bkashURL'] != null) {
        print('🔗 Loading URL: ${response['bkashURL']}');
        await _controller.loadRequest(Uri.parse(response['bkashURL']));
      } else {
        _showErrorAndPop(response['message'] ?? 'Failed to create payment');
      }
    } catch (e) {
      print('💥 Error: $e');
      _showErrorAndPop('Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _handlePaymentResult(Map<String, dynamic> data) {
    if (_paymentCompleted) return;

    print('🎉 Payment result received: $data');

    // Extract data
    String status = data['status']?.toString().toLowerCase() ?? '';
    String trxID = data['trxID']?.toString() ?? data['transaction_id']?.toString() ?? '';
    String message = data['message']?.toString() ?? '';

    // Determine success
    bool isSuccess = status == 'success' ||
        status == 'Success' ||
        message.toLowerCase().contains('success') ||
        (trxID.isNotEmpty && trxID != 'Bridge injected successfully');

    // Validate trxID - ignore bridge messages
    if (trxID == 'Bridge injected successfully' || trxID.contains('injected')) {
      print('⚠️ Ignoring bridge message as payment result');
      return;
    }

    Map<String, dynamic> result = {
      'success': isSuccess,
      'transaction_id': trxID,
      'message': message.isEmpty ?
      (isSuccess ? 'Payment successful' : 'Payment failed') :
      message,
    };

    print('📤 Returning result: $result');

    _paymentCompleted = true;

    // Small delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        Navigator.pop(context, result);
      }
    });
  }

  void _showErrorAndPop(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
    Navigator.pop(context, {'success': false, 'message': message});
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (!_paymentCompleted) {
          final shouldPop = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Cancel Payment'),
              content: const Text('Are you sure you want to cancel?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('NO'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, true);
                    Navigator.pop(context, {
                      'success': false,
                      'message': 'Payment cancelled',
                    });
                  },
                  child: const Text('YES'),
                ),
              ],
            ),
          );
          return shouldPop ?? false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('bKash Payment'),
          elevation: 0,
          backgroundColor: Colors.pink.shade600,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              if (!_paymentCompleted) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Cancel Payment'),
                    content: const Text('Are you sure you want to cancel?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('NO'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pop(context, {
                            'success': false,
                            'message': 'Payment cancelled',
                          });
                        },
                        child: const Text('YES'),
                      ),
                    ],
                  ),
                );
              } else {
                Navigator.pop(context);
              }
            },
          ),
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_isLoading)
              Container(
                color: Colors.white.withOpacity(0.8),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}