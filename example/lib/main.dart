import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:zarro_components/zarro_components.dart';

void main() {
  runApp(const ZarroExample());
}

class ZarroExample extends StatelessWidget {
  const ZarroExample({super.key});

  @override
  Widget build(BuildContext context) {
    return WidgetsApp(
      debugShowCheckedModeBanner: false,
      builder: (BuildContext context, Widget? navigator) => const HomeScreen(),
      color: const Color(0xFF00BCD4),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // return  Center(
    //   child: Material(
    //     child: ColoredBox(
    //       color: const Color(0xFF7c2727).withOpacity(0.2),
    //       child: SizedBox.square(dimension: 400,
    //         child: Center(
    //           child: InkWell(
    //             onTap: (){},
    //             child: SizedBox.square(
    //               dimension: 200,
    //               child: ColoredBox(
    //                 color: Color(0xFF3D9052).withOpacity(0.2),
    //                 child: Center(
    //                   child: Text('Click Here!'),
    //                 ),
    //               ),
    //             ),
    //           ),
    //         ),),
    //     ),
    //   ),
    // );
    return Center(
      child: Zarro(
        child: ColoredBox(
          color: const Color(0xFF7c2727).withOpacity(0.2),
          child: SizedBox.square(dimension: 400,
          child: Center(
            child: StainResponse(
              child: SizedBox.square(
                dimension: 200,
                child: ColoredBox(
                  color: Color(0xFF3D9052).withOpacity(0.2),
                  child: Center(
                    child: Text('Click Here!'),
                  ),
                ),
              ),
            ),
          ),),
        ),
      ),
    );
  }
}
