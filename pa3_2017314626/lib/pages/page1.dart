import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pa3_2017314626/pages/page2.dart';
import 'package:pa3_2017314626/pages/page3.dart';

class page1_navi extends StatelessWidget{
  final Map<String,String> arguments;
  page1_navi(this.arguments);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Menu',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute:'/',
      onGenerateRoute: (routerSettings) {
        switch (routerSettings.name) {
          case '/':
            return MaterialPageRoute(builder: (_) => page1(arguments));
            break;
          case 'page2':
            return MaterialPageRoute(builder: (_) => page2(routerSettings.arguments));
            break;
          case 'page3':
            return MaterialPageRoute(builder: (_) => page3(routerSettings.arguments));
            break;
        }
      },
    );

  }
}

class page1 extends StatelessWidget{
  final Map<String,String> arguments;

  page1(this.arguments);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title:'Menu',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home:Scaffold(
        appBar: AppBar(
          title: Text("Menu"),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                child:Column(children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children:[TextButton.icon(
                        style: (TextButton.styleFrom(
                          primary: Colors.grey,
                        )),
                        onPressed: (){
                          Navigator.pushNamed(
                            context,
                            'page2',
                            arguments:{"user-msg1":arguments["user-msg1"],"user-msg2":arguments["user-msg2"]},);
                        },
                        icon: Icon(Icons.coronavirus_outlined),
                        label: Text('Cases/Deaths'),
                      ),]
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children:[TextButton.icon(
                        style: (TextButton.styleFrom(
                          primary: Colors.grey,
                        )),
                        onPressed: (){
                          Navigator.pushNamed(
                            context,
                            'page3',
                            arguments:{"user-msg1":arguments["user-msg1"],"user-msg2":arguments["user-msg2"]},);
                        },
                        icon: Icon(Icons.local_hospital),
                        label: Text('Vaccine'),
                      ),]
                  ),
                ],)
              ),
              SizedBox(height:350),
              Text(
                'Welcome! '+arguments["user-msg1"],
                style: TextStyle(color: Colors.grey,fontSize: 20),
              ),
              Text(
                'Previous: ' +arguments["user-msg2"],
                style: TextStyle(color: Colors.indigo,fontSize: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}