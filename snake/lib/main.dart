import 'dart:ui';
import 'package:flutter/material.dart';
import 'dart:math';//为了提供min和随即数
import 'dart:async';

import 'package:flutter/material.dart' as prefix0;//Timer在内
//=============================事件总线==========================================
//订阅者回调签名
typedef void EventCallback(arg);

//定义一个top-level变量，页面引入该文件后可以直接使用bus
//var bus = new EventBus();

class EventBus {
  //私有构造函数
  EventBus._internal();

  //保存单例
  static EventBus _singleton = new EventBus._internal();

  //工厂构造函数
  factory EventBus()=> _singleton;

  //保存事件订阅者队列，key:事件名(id)，value: 对应事件的订阅者队列
  var _emap = new Map<Object, List<EventCallback>>();

  //添加订阅者
  void on(eventName, EventCallback f) {
    if (eventName == null || f == null) return;
    _emap[eventName] ??= new List<EventCallback>();
    _emap[eventName].add(f);
  }

  //移除订阅者
  void off(eventName, [EventCallback f]) {
    var list = _emap[eventName];
    if (eventName == null || list == null) return;
    if (f == null) {
      _emap[eventName] = null;
    } else {
      list.remove(f);
    }
  }

  //触发事件，事件触发后该事件所有订阅者会被调用
  void emit(eventName, [arg]) {
    var list = _emap[eventName];
    if (list == null) return;
    int len = list.length - 1;
    //反向遍历，防止在订阅者在回调中移除自身带来的下标错位
    for (var i = len; i > -1; --i) {
      list[i](arg);
    }
  }
}
//==============================方向键事件==================================
const timeout_temp = const Duration(milliseconds: 200);
Timer snaketimer = Timer.periodic(timeout_temp, (arg){});//定时器

//==============================================================================
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    var materialapp = new MaterialApp(
      title: 'Snake Demo',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      //注册路由表
      routes: {
        "/": (context) => CanvasTest(), //注册首页路由
      },
    );
    return materialapp;
  }
}
//=============================主体=============================================
class CanvasTest extends StatefulWidget {
  CanvasTest({Key key}) : super(key: key);

  @override
  CanvasTestState createState() => new CanvasTestState();
}

class CanvasTestState extends State<CanvasTest> {

  @override
  var bus = new EventBus();

  @override
  void initState() {
    super.initState();
    // 订阅事件
    bus.on("loop", settest);
  }

  @override
  void dispose() {
    super.dispose();
    //widget关闭时 删除监听
    bus.off("loop");
  }

  void settest(arg){//刷新页面
    setState(() {
    });
  }


  Widget build(BuildContext context) {
    return
      Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.amber, Colors.amber],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            )),
        child: ConstrainedBox(
          constraints: BoxConstraints.expand(),
          child: Stack(
            alignment:Alignment.center , //指定未定位或部分定位widget的对齐方式
            children: <Widget>[
              //===================================控件
              Positioned(//画板
                top: 50,
                child: CustomPaintRoute(),
              ),
              Positioned(//左
                left: 25,
                top:390,
                child: MaterialButton(
                  child: Icon(Icons.arrow_back),
                  color: Colors.grey,
                  minWidth: 60,
                  height: 60,
                  onPressed: () {
                    print("左");
                    bus.emit("ctrl","left");
                    },
                ),
              ),
              Positioned(//右
                left: 145,
                top:390,
                child: MaterialButton(
                  child: Icon(Icons.arrow_forward),
                  color: Colors.grey,
                  minWidth: 60,
                  height: 60,
                  onPressed: () {print("右");bus.emit("ctrl","right");},
                ),
              ),
              Positioned(//上
                left: 85,
                top:330,
                child: MaterialButton(
                  child: Icon(Icons.arrow_upward),
                  color: Colors.grey,
                  minWidth: 60,
                  height: 60,
                  onPressed: () {print("上");bus.emit("ctrl","up");},
                ),
              ),
              Positioned(//下
                left: 85,
                top:450,
                child: MaterialButton(
                  child: Icon(Icons.arrow_downward),
                  color: Colors.grey,
                  minWidth: 60,
                  height: 60,
                  onPressed: () {print("下");bus.emit("ctrl","down");},
                ),
              ),
              Positioned(//开始
                left: 100,
                top:550,
                child: MaterialButton(
                  child: Text("start"),
                  color: Colors.grey,
                  minWidth: 50,
                  height: 30,
                  onPressed: () {print("开始");bus.emit("ctrl","start");},
                ),
              ),
              Positioned(//暂停
                left: 180,
                top:550,
                child: MaterialButton(
                  child: Text("stop"),
                  color: Colors.grey,
                  minWidth: 50,
                  height: 30,
                  onPressed: () {print("暂停");bus.emit("ctrl","stop");},
                ),
              ),
              Positioned(//A
                left: 280,
                top: 350,
                child: MaterialButton(
                  child: Text("A", style: TextStyle(fontSize: 48.0,)),
                  minWidth: 70,
                  height: 70,
                  color: Colors.grey,
                  shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(90.0)),
                  onPressed: () {print("A");bus.emit("ctrl","loop_speed_up");},
                ),
              ),
              Positioned(//B
                left: 240,
                top:430,
                child: MaterialButton(
                  child: Text("B", style: TextStyle(fontSize: 48.0,)),
                  color: Colors.grey,
                  minWidth: 70,
                  height: 70,
                  shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(90.0)),
                  onPressed: () {print("B");bus.emit("ctrl","loop_speed_down");},
                ),
              ),
            ],
          ),
        ),
      );

  }
}
//============================LCD部分===========================================
class CustomPaintRoute extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>
        [
          CustomPaint(
            size: Size(300, 250), //指定画布大小
            painter: MyPainter(),
          ),
        ],
      ),
    );
  }
}

class MyPainter extends CustomPainter {
  var bus2 = new EventBus();
  static double food_x = 50.0;
  static double food_y = 50.0;
  static List body = [
  ];//坐标为左上角坐标
  //运动控制
  static String head_forword = "right";
  static int loop_speed = 200;
  //游戏状态,"before_begin","ing","stop","end"
  static String game_state = "before_begin";

//================================初始化身体
  void InitSnake(){
    body.removeRange(0,body.length);
    body.add([
    100.0+Random().nextInt(10)*10,50.0+Random().nextInt(10)*10,
    ]);
    body.add([
      body[0][0]+10.0,body[0][1]
    ]);
    //game_state = "ing";
  }
  //===================================刷新及判定食物
  void RereshFood(){
    if( (food_x==body[0][0])&&(food_y==body[0][1]) ){
      body.add([
        food_x,food_y
      ]);

      while(1==1) {
        bool gen_ok = false;
        food_x = 10.0 + Random().nextInt(29) * 10;
        food_y = 10.0 + Random().nextInt(24) * 10;
        for(List loc in body){
          if( (food_x==loc[0])&&(food_y==loc[1]) ){
            gen_ok = true;
          }
        }
        if(!gen_ok) { break; }
      }
    }
  }

  //============================速度调节
  void LoopSpeedChange(){
    if(game_state!="before_begin"){}
    snaketimer.cancel();

    switch (loop_speed) {
      case 200:
        const timeout = const Duration(milliseconds: 200);
        snaketimer = Timer.periodic(timeout, CtrlForword);
        break;
      case 150:
        const timeout = const Duration(milliseconds: 150);
        snaketimer = Timer.periodic(timeout, CtrlForword);
        break;
      case 100:
        const timeout = const Duration(milliseconds: 100);
        snaketimer = Timer.periodic(timeout, CtrlForword);
        break;
      case 50:
        const timeout = const Duration(milliseconds: 50);
        snaketimer = Timer.periodic(timeout, CtrlForword);
        break;
    }
  }

  //============================全局事件总线回调
  void CtrlCallback(com) {
    //print("回调事件：" + com.toString());
    if (com == "left") {
      if (head_forword == "right") {
        head_forword = head_forword;
      }
      else {
        head_forword = com;
      }
    }
    else if (com == "right") {
      if (head_forword == "left") {
        head_forword = head_forword;
      }
      else {
        head_forword = com;
      }
    }
    else if (com == "up") {
      if (head_forword == "down") {
        head_forword = head_forword;
      }
      else {
        head_forword = com;
      }
    }
    else if (com == "down") {
      if (head_forword == "up") {
        head_forword = head_forword;
      }
      else {
        head_forword = com;
      }
    }
    else if (com == "start") {
      if ((game_state == "before_begin") || (game_state == "end")) { //开始或重启
        InitSnake(); //初始化蛇身体
        LoopSpeedChange();
        game_state = "ing";
      }
      else if (game_state == "ing") {} //游戏进行中，按钮无效
      else if (game_state == "stop") {
        LoopSpeedChange();
        game_state = "ing";
      }
    }
    else if (com == "stop") {
      snaketimer.cancel();
      if (game_state == "end") {
        game_state = game_state;
      }
      else {
        game_state = "stop";
      }
    }
    else if (com == "loop_speed_up") {
      loop_speed += 50;
      if (loop_speed > 200) {
        loop_speed = 200;
      }
      else{ LoopSpeedChange(); print(loop_speed);}

    }
    else if (com == "loop_speed_down") {
      loop_speed -= 50;
      if (loop_speed < 50) {
        loop_speed = 50;
      }
      else{ LoopSpeedChange(); print(loop_speed);}
    }
  }
//========================================运动控制
  void CtrlForword(timer){
    //print('定时触发='+DateTime.now().toString());

    //位置控制
    for(int i=body.length-1;i > 0;i--){
      body[i][0] = body[i-1][0];
      body[i][1] = body[i-1][1];
    };

    if(head_forword=='left'){
      body[0][0]-=10;
    }
    else if(head_forword=='right'){
      body[0][0]+=10;
    }
    else if(head_forword=='up'){
      body[0][1]-=10;
    }
    else if(head_forword=='down'){
      body[0][1]+=10;
    }
    //=========================================游戏失败判定
    for(int i=body.length-1;i > 0;i--){//自身碰撞判定
      if((body[i][0]==body[0][0])&&(body[i][1]==body[0][1])){
        game_state = "end";
        snaketimer.cancel();
        break;
      }
    }
    if ( (body[0][0]<0)||(body[0][0]>295)||(body[0][1]<5)||(body[0][1]>245) )
      {
        game_state = "end";
        snaketimer.cancel();
      }

    //==============================吃东西判定
    RereshFood();
    bus2.emit("loop",1);
  }

//paint======================================================
  @override
  void paint(Canvas canvas, Size size) {
    double eWidth = size.width / 15;
    double eHeight = size.height / 15;

    bus2.off("ctrl");

    //画棋盘背景
    var paint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.fill //填充
      ..color = Colors.lightGreen; //背景为纸黄色
    canvas.drawRect(Offset.zero & size, paint);
    //画边框
    paint
      ..style = PaintingStyle.stroke //线
      ..color = Colors.black
      ..strokeWidth = 5;
    canvas.drawLine( Offset(0,2.5),Offset(300, 2.5), paint);
    canvas.drawLine( Offset(0,247.5),Offset(300, 247.5), paint);

    if ( (game_state!="end")&&(game_state!="before_begin") ) {
      //绘制食物
      paint
        ..style = PaintingStyle.stroke //线
        ..color = Colors.black
        ..strokeWidth = 10.0;

      for (int i = 0; i <= 15; ++i) {
        //横着画线， 从(0，dy)画到（300，dy）
        canvas.drawLine(
            Offset(food_x, food_y),
            Offset(food_x + 10, food_y),
            paint);
      };

      //遍历绘制蛇身体
      paint
        ..style = PaintingStyle.stroke //线
        ..color = Colors.black
        ..strokeWidth = 10.0;

      for (List loc in body) {
        //横着画线， 从(0，dy)画到（300，dy）
        canvas.drawLine(
            Offset(loc[0], loc[1]),
            Offset(loc[0] + 10, loc[1]),
            paint);
      };
    }
    else if(game_state=="end"){//绘制失败文字
      ParagraphBuilder pb = ParagraphBuilder(ParagraphStyle(
        textAlign: TextAlign.center,
        fontWeight: FontWeight.w900,
        fontStyle: FontStyle.normal,
        fontSize: 60.0,
      ));
      pb.addText('YOU\nLOSE\n'+body.length.toString()+'&'+loop_speed.toString());
      // 设置文本的宽度约束
      ParagraphConstraints pc = ParagraphConstraints(width: 300);
      // 这里需要先layout,将宽度约束填入，否则无法绘制
      Paragraph paragraph = pb.build()..layout(pc);
      // 文字左上角起始点
      Offset offset = Offset(0, 20);
      canvas.drawParagraph(paragraph, offset);
    }
    else if(game_state=="before_begin"){//绘制开始文字
      ParagraphBuilder pb = ParagraphBuilder(ParagraphStyle(
        textAlign: TextAlign.center,
        fontWeight: FontWeight.w900,
        fontStyle: FontStyle.normal,
        fontSize: 60.0,
      ));
      pb.addText('PRESS\nSTART\n');
      // 设置文本的宽度约束
      ParagraphConstraints pc = ParagraphConstraints(width: 300);
      // 这里需要先layout,将宽度约束填入，否则无法绘制
      Paragraph paragraph = pb.build()..layout(pc);
      // 文字左上角起始点
      Offset offset = Offset(0, 50);
      canvas.drawParagraph(paragraph, offset);
    }
    bus2.on("ctrl", CtrlCallback);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
