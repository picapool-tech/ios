import 'package:flutter/material.dart';

class ComingSoon extends StatelessWidget {
  final String title;
  const ComingSoon({super.key, this.title = "Food"});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: false,
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0),
              const Color(0xFFFF8D41),
              Colors.white,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Image.asset(
              "assets/images/coming_soon.png",
              fit: BoxFit.fitWidth,
              width: MediaQuery.of(context).size.width * 0.8,
            ),
            Text(
              "Preparing something special for you!\nStay tuned for the best offers",
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
    );
  }
}
