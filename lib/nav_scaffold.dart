import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class NavScaffold extends StatefulWidget {
  const NavScaffold({required this.child, Key? key}) : super(key: key);
  final Widget child;

  @override
  State<NavScaffold> createState() => _NavScaffoldState();
}

class _NavScaffoldState extends State<NavScaffold> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            if (index == 0) {
              context.go('/');
            } else {
              context.go('/simular');
            }
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(MdiIcons.compass),
            label: 'Explorar',
          ),
          BottomNavigationBarItem(
            icon: Icon(MdiIcons.calculator),
            label: 'Simular',
          ),
        ],
      ),
    );
  }
}
