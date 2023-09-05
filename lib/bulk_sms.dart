import 'package:flutter/material.dart';
import 'package:sms_advanced/sms_advanced.dart';

class BulkSms extends StatefulWidget {
  const BulkSms({super.key});

  @override
  State<BulkSms> createState() => _BulkSmsState();
}

class _BulkSmsState extends State<BulkSms> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(children: [
        ElevatedButton(
            onPressed: sendGroupSms, child: const Text('Send Group SMS')),
      ]),
    );
  }

  void sendGroupSms() {}
}
