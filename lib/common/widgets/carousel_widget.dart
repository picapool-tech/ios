import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class CarouseldWiget extends StatefulWidget {
  final int count;
  final Widget Function(BuildContext, int, int)? itemBuilder;
  final double height;
  const CarouseldWiget({
    super.key,
    required this.count,
    required this.itemBuilder,
    this.height = 400.0,
  });

  @override
  State<CarouseldWiget> createState() => _CarouseldWigetState();
}

class _CarouseldWigetState extends State<CarouseldWiget> {
  int _current = 0;
  final CarouselControllerImpl _controller = CarouselControllerImpl();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CarouselSlider.builder(
          carouselController: _controller,
          options: CarouselOptions(
            height: widget.height,
            autoPlay: true,
            aspectRatio: 1,
            autoPlayCurve: Curves.fastOutSlowIn,
            enlargeCenterPage: true,
            enableInfiniteScroll: true,
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            viewportFraction: 1,
            onPageChanged: (index, reason) {
              setState(() {
                _current = index;
              });
            },
          ),
          itemCount: widget.count,
          itemBuilder: widget.itemBuilder,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.count, (index) {
            return Container(
              width: 8.0,
              height: 8.0,
              margin:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _current == index ? Colors.blueAccent : Colors.grey,
              ),
            );
          }),
        ),
      ],
    );
  }
}
