import 'package:flutter/material.dart';

class CenterAnimation extends StatelessWidget {
  final double pinOffset;
  const CenterAnimation({super.key, required this.pinOffset});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedContainer(
        duration: Duration(milliseconds: 150),
        transform: Matrix4.translationValues(0, pinOffset, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(3),
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 3),
                color: Colors.amber,
                borderRadius: BorderRadius.circular(9),
              ),
              child: pinOffset < 0
                  ? CircularProgressIndicator(
                      color: Colors.black,
                      strokeWidth: 3,
                    )
                  : Icon(Icons.person, color: Colors.black),
            ),
            Container(
              width: 3,
              height: 25,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(9),
              ),
            ),
            Container(
              width: 2,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(9),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
