import 'package:flutter/material.dart';
import 'package:picapool/widgets/location_bar.dart';


class LocationAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const LocationAppBar({
    super.key,
   required this.hasBackRoute
  });

  @override
  Size get preferredSize {
    return const Size.fromHeight(60.0);
  }
  final bool hasBackRoute;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      centerTitle: false,
      
      title: const LocationBar() ,
      actions: const <Widget>[
           Padding(
             padding: EdgeInsets.all(8.0),
             child: CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.black,
                      child: Icon(
                        Icons.person,
                        color: Colors.white,
                      ),
                    ),
           ),
      ],
    );
  }
}
