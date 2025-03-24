import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: GridScreen(),
    );
  }
}

class GridScreen extends StatelessWidget {
  final List<String> items = List.generate(12, (index) => 'Item $index');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Grid Zoom Animation')),
      body: GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 1,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          return Builder(
            builder: (itemContext) {
              return GestureDetector(
                onTap: () => _openPage(itemContext, index),
                child: Hero(
                  tag: 'item_$index',
                  flightShuttleBuilder: (_, __, ___, ____, toHeroContext) {
                    return Material(
                      type: MaterialType.transparency,
                      child: toHeroContext.widget,
                    );
                  },
                  createRectTween: (begin, end) {
                    return MaterialRectCenterArcTween(begin: begin, end: end);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        items[index],
                        style: const TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _openPage(BuildContext context, int index) {
    // Get position of tapped item
    final box = context.findRenderObject() as RenderBox;
    final position = box.localToGlobal(Offset.zero);

    Navigator.of(context).push(
      PageRouteBuilder(
        fullscreenDialog: true,
        opaque: false,
        transitionDuration: const Duration(milliseconds: 400),
        reverseTransitionDuration: const Duration(milliseconds: 400),
        barrierColor: Colors.transparent,
        pageBuilder: (context, animation, secondaryAnimation) {
          return DetailPage(index: index, position: position);
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }
}

class DetailPage extends StatelessWidget {
  final int index;
  final Offset position;

  const DetailPage({super.key, required this.index, required this.position});

  @override
  Widget build(BuildContext context) {
    // Tính toán khoảng cách để đưa item vào giữa màn hình
    final screenSize = MediaQuery.of(context).size;
    final targetX = (screenSize.width - 300) / 2 - position.dx;
    final targetY = (screenSize.height - 300) / 2 - position.dy;

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Page')),
      body: Center(
        child: Hero(
          tag: 'item_$index',
          createRectTween: (begin, end) {
            return MaterialRectCenterArcTween(begin: begin, end: end);
          },
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              color: Colors.blueAccent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Material(
              color: Colors.transparent,
              child: Center(
                child: Text(
                  'Item $index',
                  style: const TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
