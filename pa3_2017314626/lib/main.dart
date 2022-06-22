import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pa3_2017314626/pages/page1.dart';
import 'package:pa3_2017314626/pages/page2.dart';
import 'package:pa3_2017314626/pages/page3.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

String id_answer = "skku";
String pw_answer = "1234";

class loginProvider with ChangeNotifier{
  String _lg_plz = 'Login Please...';
  Color txt_clr = Colors.grey;
  get lg_plz => _lg_plz;
  loginProvider(this._lg_plz);
  void change_msg(String id){
    _lg_plz = 'Login Success. Hello '+id;
    txt_clr = Colors.blue;
    notifyListeners();
  }
}

class visibleProvider with ChangeNotifier{
  bool _visible;
  get visible => _visible;
  visibleProvider(this._visible);
  void invisible(bool check){
    _visible = check;
    notifyListeners();
  }
}

class visibleProvider2 with ChangeNotifier{
  bool _visible2;
  get visible => _visible2;
  visibleProvider2(this._visible2);
  void invisible(bool check){
    _visible2 = check;
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context)=>loginProvider("Login Please...")),
        ChangeNotifierProvider(create: (context)=>visibleProvider(true)),
      ],
    child: MaterialApp(
      title: '2017314626 LeeJaeHun',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      onGenerateRoute: (routerSettings){
        switch(routerSettings.name){
          case '/':
            return MaterialPageRoute(builder: (_)=>login());
          case 'page1_navi':
            return MaterialPageRoute(builder: (_)=>page1_navi(routerSettings.arguments));
          default:
            return MaterialPageRoute(builder: (_) => login());
        }
      },
    )
    );
  }
}

class login extends StatelessWidget{
  final textController = TextEditingController();
  final textController2 = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final loginProvider login = Provider.of<loginProvider>(context);
    final visibleProvider vis = Provider.of<visibleProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("2017314626 LeeJaeHun"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'CORONA LIVE',
              style: Theme.of(context).textTheme.headline4,
            ),
            Consumer<loginProvider>(
                builder: (context,login,child)=>Text(
                  login._lg_plz,
                  style:TextStyle( color : login.txt_clr),
                )),
            Consumer<visibleProvider>(
              builder: (context,vis,child)=>Visibility(
                child:  Container(
                    margin: EdgeInsets.all(50),
                    width: 300,
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.all(Radius.circular(10))
                    ),
                    child:Column(children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("ID:"),
                          SizedBox(
                            width : 200,
                            child:
                            TextField(
                              controller: textController,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("PW:"),
                          SizedBox(
                            width : 200,
                            child:
                            TextField(
                              controller: textController2,
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton(onPressed: () {
                        if (textController.text == id_answer && textController2.text == pw_answer){
                          login.change_msg(id_answer);
                          vis.invisible(false);
                        }
                      },
                          child: Text('Login'))
                    ],)
                ),
                visible: vis._visible,
              ),
            ),
            Consumer<visibleProvider>(
                builder: (context,vis,child)=>Visibility(
                  child: Column(children: [
                    SizedBox(
                      width: 300,
                      height: 300,
                      child: Image.asset("assets/images/sponge.jpg"),
                    ),
                    ElevatedButton(child: Text('Start CORONA LIVE'),
                      onPressed: (){
                        Navigator.pushNamed(
                          context,
                          'page1_navi',
                          arguments:{"user-msg1":id_answer,"user-msg2":"Login Page"},);
                      },),
                  ],
                  ),
                  visible: !(vis._visible),
                )
            ),

          ],
        ),
      ),
    );
  }
}