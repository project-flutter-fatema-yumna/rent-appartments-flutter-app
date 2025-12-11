import 'package:flutter/material.dart';

class WaitingForAcception extends StatelessWidget {
  static String id = 'WaitingForAcceptionScreen';
  const WaitingForAcception({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      body: Center(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.blue[50],
            border: Border.all(
              color: Colors.black,
            )
          ),
          child: Column(
            children: [
              Text('Your account is pending admin approval', style: TextStyle(fontSize: 40),),
            ],
          ),
        ),
      ),
    );
  }
}