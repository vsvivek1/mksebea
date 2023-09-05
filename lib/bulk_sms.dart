import 'package:flutter/material.dart';
import 'package:sms_advanced/sms_advanced.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

class BulkSms extends StatefulWidget {
  const BulkSms({super.key});

  @override
  State<BulkSms> createState() => _BulkSmsState();
}

class _BulkSmsState extends State<BulkSms> {
  var jsonData;
  Set<String> units = Set<String>();
  final TextEditingController _textEditingController = TextEditingController();
  int maxCharacters = 75;

  List<String> selectedUnits = [];
  late List<Map<dynamic, dynamic>> numberOfMemebrsOfUnits = [];

  int totalSelectedMembersCount = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _textEditingController.addListener(_updateCharacterCount);
    loadJsonData();
  }

  void getTotalSelectedMembersCount(List<String> selectedUnitNames,
      List<Map<dynamic, dynamic>> numberOfMembersOfUnits) {
    totalSelectedMembersCount = 0;

    for (var unitName in selectedUnitNames) {
      // Find the unit map in numberOfMembersOfUnits based on unitName
      var unitMap = numberOfMembersOfUnits
          .firstWhere((map) => map['unit'] == unitName, orElse: () => {});

      if (unitMap != null && unitMap['count'] != null) {
        // Add the count to the total count

        int uc = unitMap['count'] as int;
        totalSelectedMembersCount += uc;
      }
    }

    // return totalSelectedMembersCount;
  }

  void _updateCharacterCount() {
    setState(() {
      maxCharacters = 75 - _textEditingController.text.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(children: [
        TextField(
          controller: _textEditingController,
          maxLength: 75,
          maxLines: null, // Allows multiple lines
          decoration: InputDecoration(
            labelText: 'Enter text (max 75 characters)',
            counterText: '$maxCharacters characters left',
          ),
        ),
        SizedBox(
          width: MediaQuery.sizeOf(context).width * .9,
          height: MediaQuery.sizeOf(context).height * .4,
          child: ListView(
            children: numberOfMemebrsOfUnits
                .map((unit) => CheckboxListTile(
                      title: Text(unit['unit'] +
                          ' ' +
                          unit['count'].toString() +
                          ' Members'),
                      value: selectedUnits.contains(unit["unit"]),
                      onChanged: (value) {
                        setState(() {
                          if (value == true) {
                            selectedUnits.add(unit["unit"]);
                          } else {
                            selectedUnits.remove(unit["unit"]);
                          }
                        });

                        getTotalSelectedMembersCount(
                            selectedUnits, numberOfMemebrsOfUnits);
                      },
                    ))
                .toList(),
          ),
        ),
        Text(totalSelectedMembersCount.toString() + ' Is selected for sms'),
        Text(selectedUnits.toString() + ' Units Selected'),
        ElevatedButton(
            onPressed: selectedUnits.isNotEmpty ? sendGroupSms : null,
            child: const Text('Send Group SMS')),
      ]),
    );
  }

  Future<void> loadJsonData() async {
    final String jsonText = await rootBundle.loadString('assets/vconfex.json');
    setState(() {
      jsonData = json.decode(jsonText);
    });

    for (var item in jsonData) {
      units.add(item['unit'].toString());
      if (item['mobile'].toString().length == 10) {
        item['mobile'] = "+91" + item['mobile'].toString();
      } else {
        item['mobile'] = "+" + item['mobile'].toString();
      }
      // print('Name: ${item['name']}');
      // print('Unit: ${item['unit']}');
      // print('Mobile: ${item['mobile']}');
    }

    for (var unit in units.toList()) {
      Map<dynamic, dynamic> unitMap = {
        "unit": unit,
        "count": 0,
      };
      numberOfMemebrsOfUnits.add(unitMap);
    }

    // Calculate counts based on members
    for (var member in jsonData) {
      String unit =
          member['unit']; // Assuming 'unit' is the key in your JSON data
      // Find the corresponding unit map in numberOfMembersOfUnits
      var unitMap = numberOfMemebrsOfUnits
          .firstWhere((map) => map['unit'] == unit, orElse: () => {});

      if (unitMap != null) {
        // Increment the count for the unit
        unitMap['count']++;
      }
    }
    // After loading and parsing the JSON, you can execute a function here
  }

  void sendGroupSms() {
    SmsSender sender = SmsSender();

    for (var item in jsonData) {
      // Check if item['unit'] is in selected units
      if (selectedUnits.contains(item['unit'])) {
        // Run the function for the matching unit

        String address = item['mobile'];

        var msg =
            "Dear Er ${item['name']} Kozhikode Unit cordially invites you to the 70th AGB. Kindly register, participate, and help make it a great success. \n Secrty EA KZD";

        // sender.sendSms(SmsMessage(address, 'Hello flutter world!'));
        // print(" $address ${msg.length} $msg");
        // runFunctionForUnit(item['unit']);
      }
    }
  }
}
