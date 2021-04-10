import 'package:flutter/material.dart';
import 'dart:ui' as ui;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Widget> dottedCircles = new List<int>
      .generate(6, (i) => i + 1)
      .map((i) => DottedCircleWidget(position: i))
      .toList();
  @override
  Widget build(BuildContext context) {
    int key = 0;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Container(
          child: Stack(
            children:
            [
              ...dottedCircles,
              StreamBuilder<int>(
                  stream: breathStream(),
                  builder: (_, snapshot) {
                    key++;
                    return AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: snapshot.hasData
                            ? BreathWidget(key: ValueKey(key), step: snapshot.data)
                            : Container(color: Colors.white)
                    );
                  }
              ),
            ],
            alignment: Alignment.center,
          ),
        ),
      ),
    );
  }
}

class DottedCircleWidget extends StatelessWidget {
  DottedCircleWidget({Key key, this.position});
  final int position;
  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: DottedCirclePainter(position));
  }
}

class DottedCirclePainter extends CustomPainter {
  DottedCirclePainter(this.position);
  final int position;
  final int initialRadius = 30;
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(
        Offset.zero,
        (initialRadius * position).toDouble(),
        paint
    );
  }
  @override
  bool shouldRepaint(DottedCirclePainter oldDelegate) {
    return position != oldDelegate.position;
  }
}

class BreathWidget extends StatefulWidget {
  BreathWidget({Key key, @required this.step}) : super(key: key);
  final int step;
  @override
  _BreathWidgetState createState() => _BreathWidgetState();
}

class _BreathWidgetState extends State<BreathWidget>
    with SingleTickerProviderStateMixin {

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
        curve: Curves.easeInOutCirc,
        vsync: this,
        duration: const Duration(milliseconds: 300),
        child: CustomPaint(
          painter: GradientCirclePainter(
              radius: widget.step,
              width: widget.step.toDouble()
          ),
        )
    );
  }

}

class GradientCirclePainter extends CustomPainter {
  GradientCirclePainter({this.width, this.radius});
  final double width;
  final int radius;
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..shader = ui.Gradient.linear(
        Offset.zero,
        Offset(size.width, size.height),
        [
          Colors.blue,
          Colors.red,
        ],
      );
    canvas.drawCircle(
        Offset.zero,
        radius.toDouble(),
        paint
    );
  }
  @override
  bool shouldRepaint(GradientCirclePainter old) {
    return radius != old.radius || width != old.width;
  }
}

Stream<int> breathStream() {
  final flow = [1,10,15,20,22,28,40,43,45,57,60,63,69,82,88,90,92,95,100];
  return Stream.periodic(Duration(milliseconds: 400), (i) => flow[i])
      .take(flow.length);
}
