import 'package:flutter/material.dart';
import 'package:picapool/utils/theme.dart';

class CustomCard extends StatelessWidget {
  final String msg;
  final String additionalInfo;

  const CustomCard({super.key, required this.msg, this.additionalInfo = ""});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: customBlue.shade500,
      child: Stack(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: RichText(
              text: TextSpan(
                children: <TextSpan>[
                  //real message
                  TextSpan(
                    text: "$msg    ",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                        ),
                  ),

                  //fake additionalInfo as placeholder
                  TextSpan(
                    text: additionalInfo,
                    style: const TextStyle(
                      color: Colors.transparent,
                    ),
                  ),
                ],
              ),
            ),
          ),

          //real additionalInfo
          Positioned(
            right: 8.0,
            bottom: 4.0,
            child: Text(
              additionalInfo,
              style: const TextStyle(
                fontSize: 12.0,
                color: Colors.white60,
              ),
            ),
          )
        ],
      ),
    );
  }
}
