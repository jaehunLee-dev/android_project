import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pa3_2017314626/main.dart';
import 'package:pa3_2017314626/pages/page1.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';

class tableProvider with ChangeNotifier{
  bool _visible = false;
  bool _visible2 = false;
  get visible => _visible;
  get visible2 => _visible2;
  tableProvider(this._visible,this._visible2);
  void invisible(bool check, bool check2){
    _visible = check;
    _visible2 = check2;
    notifyListeners();
  }
}

class graphProvider with ChangeNotifier{
  int _status;
  get status => _status;
  graphProvider(this._status);
  void cg_graph(int graph){
    _status = graph;
    notifyListeners();
  }
}

Future<Case> fetchAlbum() async{
  final response =
  await http.get(Uri.https("covid.ourworldindata.org", "data/owid-covid-data.json"));
  if (response.statusCode == 200){
    return Case.fromJson(jsonDecode(response.body));
  }else{
    throw Exception('Failed to load case');
  }
}

class Case{
  Map<String, dynamic> case_data = Map <String, dynamic>();
  Case({@required this.case_data});
  factory Case.fromJson(dynamic json){
    return Case(case_data: json);
  }
}

class page2 extends StatelessWidget {
  final Map<String, String> arguments;

  page2(this.arguments);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context)=>tableProvider(false,false)),
        ChangeNotifierProvider(create: (context)=>graphProvider(1)),
      ],
      child: MaterialApp(
        title: 'case/death',
        initialRoute:'/',
        onGenerateRoute: (routerSettings) {
          switch (routerSettings.name) {
            case '/':
              return MaterialPageRoute(builder: (_) => page2_ui(arguments));
              break;
            case 'page1_navi':
              return MaterialPageRoute(
                  builder: (_) => page1_navi(routerSettings.arguments));
              break;
          }
        },
      ),
    );
  }
}

class page2_ui extends StatelessWidget{
  final Map<String, String> arguments;
  page2_ui(this.arguments);

  int total_case =0;
  int total_death =0;
  int new_case =0;
  String recent;
  String recent_year;
  String recent_month;
  String recent_day;
  Future<Case> futureCase;
  dynamic case_data;
  List<dynamic> _list = List<dynamic>();
  List<String> case_country = List<String>();
  List<String> death_country = List<String>();
  int jungbok2= 0;
  DateTime recent_dt;
  List<DateTime> dt_week = List<DateTime>(7);
  List<DateTime> dt_month = List<DateTime>(28);
  List<int> tcase_list = List<int>(28);
  List<int> dcase_list = List<int>(28);

  double min_tcase = 0.0;


  String dateForm(DateTime dt){
    String month, day;
    if (dt.month<10)
      month = '0'+dt.month.toString();
    else
      month = dt.month.toString();
    if (dt.day<10)
      day = '0'+dt.day.toString();
    else
      day = dt.day.toString();
    return dt.year.toString()+'-'+month+'-'+day;
  }

  @override
  Widget build(BuildContext context) {
    final tableProvider table = Provider.of<tableProvider>(context);
    final graphProvider graph = Provider.of<graphProvider>(context);
    return Scaffold(
      body: Center(
          child: FutureBuilder<Case>(
            future: fetchAlbum(),
            builder: (context,snapshot){
              if (snapshot.hasData) {
                double notnull(double input, String key, String information){
                  if (input == null)
                    return snapshot.data.case_data[key]["data"][snapshot.data.case_data[key]["data"].length-2][information];
                  else
                    return input;
                }
                if (jungbok2 == 0) {
                  total_case = 0;
                  total_death = 0;
                  new_case = 0;
                  for (int k=0; k<28; k++){
                    tcase_list[k] = 0;
                    dcase_list[k] = 0;
                  }

                  recent = snapshot.data.case_data["KOR"]["data"].last["date"];
                  recent_year = recent.substring(0,4);
                  recent_month = recent.substring(5,7);
                  recent_day = recent.substring(8);
                  recent_dt = new DateTime(int.parse(recent_year),int.parse(recent_month),int.parse(recent_day)); //datetime 생성
                  dt_week[6] = recent_dt;
                  dt_month[27] = recent_dt;

                  for (int i=5; i>=0; i--){
                    dt_week[i] = recent_dt.subtract(Duration(days:6-i));
                  }
                  for (int i=26; i>=0; i--){
                    dt_month[i] = recent_dt.subtract(Duration(days:27-i));
                  }
                  for (String key in snapshot.data.case_data.keys) {
                    if ((snapshot.data.case_data[key]["data"].last["date"] == recent)
                        && snapshot.data.case_data[key]["data"].last["total_cases"] != null) {
                      total_case += snapshot.data.case_data[key]["data"].last["total_cases"].toInt(); //정상적인 경우
                      case_country.add(key);
                    }
                    else if (snapshot.data.case_data[key]["data"].last["date"] !=
                        recent) {
                      if (snapshot.data.case_data[key]["data"].last["total_cases"] != null) {
                        total_case += snapshot.data.case_data[key]["data"].last["total_cases"].toInt();
                        case_country.add(key);
                      }
                    }
                    else if (snapshot.data.case_data[key]["data"].last["date"] == recent
                        && snapshot.data.case_data[key]["data"].last["total_cases"] == null) {
                      int idx = (snapshot.data.case_data[key]["data"].length) - 2;
                      if (snapshot.data.case_data[key]["data"][idx]["total_cases"] != null) {
                        total_case += snapshot.data.case_data[key]["data"][idx]["total_cases"].toInt();
                        case_country.add(key);
                      }
                    }


                    // 28일 데이터 구하기
                    bool nalja = false;
                    int previous_idx = snapshot.data.case_data[key]["data"].length-1;
                    for (int k =0; k<28; k++) {
                      nalja = false;
                      for (int i=snapshot.data.case_data[key]["data"].length-1; i>=0; i--){
                        if (snapshot.data.case_data[key]["data"][i]["date"] == dateForm(dt_month[k])){
                          nalja = true;
                          if (snapshot.data.case_data[key]["data"][i]["new_cases"] != null){     //날짜 있고 total death있을때
                            dcase_list[k] += snapshot.data.case_data[key]["data"][i]["new_cases"].toInt();
                            previous_idx = i;
                            break;
                            }
                          else if (i>1 && snapshot.data.case_data[key]["data"][i-1]["new_cases"]!=null ){ //날짜 있고 total death없고
                            dcase_list[k] += snapshot.data.case_data[key]["data"][i-1]["new_cases"].toInt();//전날 있을 때
                            break;
                          }
                        }
                        }
                      if (nalja == false) {//날짜 없을 때 => 가장 최근 날짜의 new case 있을 때
                        if (previous_idx!=0&&snapshot.data.case_data[key]["data"][previous_idx-1]["new_cases"]!=null)
                          dcase_list[k] += snapshot.data.case_data[key]["data"][previous_idx-1]["new_cases"].toInt();
                      }
                    }

                    nalja = false;
                    previous_idx = snapshot.data.case_data[key]["data"].length-1;
                    for (int k =0; k<28; k++) {
                      nalja = false;
                      for (int i=snapshot.data.case_data[key]["data"].length-1; i>=0; i--){
                        if (snapshot.data.case_data[key]["data"][i]["date"] == dateForm(dt_month[k])){
                          nalja = true;
                          if (snapshot.data.case_data[key]["data"][i]["total_cases"] != null){     //날짜 있고 total death있을때
                            tcase_list[k] += snapshot.data.case_data[key]["data"][i]["total_cases"].toInt();
                            previous_idx = i;
                            break;
                          }
                          else if (i>1 && snapshot.data.case_data[key]["data"][i-1]["total_cases"]!=null ){ //날짜 있고 total death없고
                            tcase_list[k] += snapshot.data.case_data[key]["data"][i-1]["total_cases"].toInt();//전날 있을 때
                            break;
                          }
                        }
                      }
                      if (nalja == false) {//날짜 없을 때 => 가장 최근 날짜의 total death 있을 때
                        if (previous_idx!=0&&snapshot.data.case_data[key]["data"][previous_idx-1]["total_cases"]!=null)
                          tcase_list[k] += snapshot.data.case_data[key]["data"][previous_idx-1]["total_cases"].toInt();
                      }
                    }
                    //끝끝끝끝

                    if ((snapshot.data.case_data[key]["data"].last["date"] == recent)
                        && snapshot.data.case_data[key]["data"].last["new_cases"] != null) {
                      new_case += snapshot.data.case_data[key]["data"].last["new_cases"].toInt();
                    }
                    else if (snapshot.data.case_data[key]["data"].last["date"] != recent) {
                      if (snapshot.data.case_data[key]["data"].last["new_cases"] != null)
                        new_case += snapshot.data.case_data[key]["data"].last["new_cases"].toInt();
                    }
                    else
                    if (snapshot.data.case_data[key]["data"].last["date"] ==
                        recent && snapshot.data.case_data[key]["data"].last["new_cases"] == null) {
                      int idx = snapshot.data.case_data[key]["data"].length - 2;
                      if (snapshot.data.case_data[key]["data"][idx]["new_cases"] != null)
                        new_case += snapshot.data.case_data[key]["data"][idx]["new_cases"].toInt();
                    }

                    if ((snapshot.data.case_data[key]["data"].last["date"] == recent)
                        && snapshot.data.case_data[key]["data"].last["total_deaths"] != null) {
                      total_death += snapshot.data.case_data[key]["data"].last["total_deaths"].toInt(); //정상적인 경우
                      death_country.add(key);
                    }
                    else if (snapshot.data.case_data[key]["data"].last["date"] !=
                        recent) {
                      if (snapshot.data.case_data[key]["data"].last["total_deaths"] != null) {
                        total_death += snapshot.data.case_data[key]["data"].last["total_deaths"].toInt();
                        death_country.add(key);
                      }
                    }
                    else if (snapshot.data.case_data[key]["data"].last["date"] == recent
                        && snapshot.data.case_data[key]["data"].last["total_deaths"] == null) {
                      int idx = (snapshot.data.case_data[key]["data"].length) - 2;
                      if (snapshot.data.case_data[key]["data"][idx]["total_deaths"] != null) {
                        total_death += snapshot.data.case_data[key]["data"][idx]["total_deaths"].toInt();
                        death_country.add(key);
                      }
                    }
                  }

                  case_country.sort((a, b) =>
                      notnull(snapshot.data.case_data[b]["data"].last["total_cases"],b,"total_cases").compareTo
                        (notnull(snapshot.data.case_data[a]["data"].last["total_cases"],a,"total_cases")));

                  death_country.sort((a, b) =>
                      notnull(snapshot.data.case_data[b]["data"].last["total_deaths"],b,"total_deaths").compareTo
                        (notnull(snapshot.data.case_data[a]["data"].last["total_deaths"],a,"total_deaths")));

                  jungbok2+=1;
                }
                return Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Container(
                          margin: EdgeInsets.all(30),
                          width: 300,
                          height: 130,
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.all(Radius
                                  .circular(
                                  10))
                          ),
                          child: Column(
                              children: [
                                Row(
                                    mainAxisAlignment: MainAxisAlignment
                                        .center,
                                    children: [
                                      SizedBox(
                                        width: 140,
                                        height: 60,
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment
                                                  .center,
                                              children: [
                                                Text("Total cases\n" +
                                                    total_case.toString() +
                                                    " people"),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        width: 140,
                                        height: 60,
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment
                                                  .center,
                                              children: [
                                                Text(
                                                    "Parsed latest date\n" +
                                                        recent)
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ]
                                ),
                                Row(
                                    mainAxisAlignment: MainAxisAlignment
                                        .center,
                                    children: [
                                      SizedBox(
                                        width: 140,
                                        height: 60,
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment
                                                  .center,
                                              children: [
                                                Text("Total Deaths\n" +
                                                    total_death.toString() +
                                                    " people"),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        width: 140,
                                        height: 60,
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment
                                                  .center,
                                              children: [
                                                Text("Daily Cases\n" +
                                                    new_case.toString()),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ]
                                )
                              ]
                          )
                      ),
                      Container(
                        margin: EdgeInsets.all(1),
                        width: 300,
                        height: 250,
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.all(Radius.circular(
                                10))
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextButton(onPressed: () {
                                  graph.cg_graph(1);
                                }, child: Text('Graph1')),
                                TextButton(onPressed: () {
                                  graph.cg_graph(2);
                                }, child: Text('Graph2')),
                                TextButton(onPressed: () {
                                  graph.cg_graph(3);
                                }, child: Text('Graph3')),
                                TextButton(onPressed: () {
                                  graph.cg_graph(4);
                                }, child: Text('Graph4'))
                              ],
                            ),
                            Divider(
                              height: 10.0,
                              color: Colors.grey,
                              thickness: 1,

                            ),
                            Consumer<graphProvider>(
                                builder: (context, vis, child) =>
                                    Visibility(
                                      visible: (graph._status == 1),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children:[
                                          SizedBox(
                                            width : 270,
                                            height :180,
                                            child: LineChart(
                                              LineChartData(
                                                  titlesData: FlTitlesData(
                                                    bottomTitles: SideTitles(
                                                      showTitles: true,
                                                      reservedSize: 22,
                                                      getTextStyles: (value) => const TextStyle(
                                                        color: Color(0xff72719b),
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 10,
                                                      ),
                                                      margin: 10,
                                                      getTitles: (value) {
                                                        switch (value.toInt()) {
                                                          case 1:
                                                            return dt_week[0].month.toString() + '-' +dt_week[0].day.toString();
                                                          case 3:
                                                            return dt_week[1].month.toString() + '-' +dt_week[1].day.toString();
                                                          case 5:
                                                            return dt_week[2].month.toString() + '-' +dt_week[2].day.toString();
                                                          case 7:
                                                            return dt_week[3].month.toString() + '-' +dt_week[3].day.toString();
                                                          case 9:
                                                            return dt_week[4].month.toString() + '-' +dt_week[4].day.toString();
                                                          case 11:
                                                            return dt_week[5].month.toString() + '-' +dt_week[5].day.toString();
                                                          case 13:
                                                            return dt_week[6].month.toString() + '-' +dt_week[6].day.toString();
                                                        }
                                                        return '';
                                                      },
                                                    ),
                                                    leftTitles: SideTitles(
                                                      showTitles: true,
                                                      getTextStyles: (value) => const TextStyle(
                                                        color: Color(0xff75729e),
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 14,
                                                      ),
                                                      getTitles: (value) {
                                                        switch (value.toInt()) {
                                                          case 50:
                                                            return '5억';
                                                          case 52:
                                                            return '5.2억';
                                                          case 54:
                                                            return '5.4억';
                                                          case 56:
                                                            return '5.6억';
                                                          case 58:
                                                            return '5.8억';
                                                          case 60:
                                                            return '6억';
                                                        }
                                                        return '';
                                                      },
                                                      margin: 8,
                                                      reservedSize: 30,
                                                    ),
                                                  ),
                                                  borderData: FlBorderData(
                                                      show: true,
                                                      border: const Border(
                                                        bottom: BorderSide(
                                                          color: Color(0xff4e4965),
                                                          width: 4,
                                                        ),
                                                        left: BorderSide(
                                                          color: Colors.transparent,
                                                        ),
                                                        right: BorderSide(
                                                          color: Colors.transparent,
                                                        ),
                                                        top: BorderSide(
                                                          color: Colors.transparent,
                                                        ),
                                                      )),
                                                  minX: 0,
                                                  maxX: 15,
                                                  maxY: 60,
                                                  minY: 50,
                                                  lineBarsData:[
                                                    LineChartBarData(
                                                      spots: [
                                                        FlSpot(1, tcase_list[21]/10000000),
                                                        FlSpot(3, tcase_list[22]/10000000),
                                                        FlSpot(5, tcase_list[23]/10000000),
                                                        FlSpot(7, tcase_list[24]/10000000),
                                                        FlSpot(9, tcase_list[25]/10000000),
                                                        FlSpot(11,tcase_list[26]/10000000),
                                                        FlSpot(13,tcase_list[27]/10000000),
                                                      ],
                                                      isCurved: false,
                                                      dotData: FlDotData(
                                                        show:true,
                                                      ),
                                                      curveSmoothness: 0,
                                                      colors: const [
                                                        Color(0xf29a4af6),
                                                      ],
                                                      barWidth: 4,
                                                      isStrokeCapRound: true,
                                                      belowBarData: BarAreaData(
                                                        show: false,
                                                      ),
                                                    ),
                                                  ]
                                              ),
                                            ),
                                          ),
                                        ]
                                    ),
                                      ),
                                    ),
                            Consumer<graphProvider>(
                                builder: (context, vis, child) =>
                                    Visibility(
                                      visible: (graph._status == 2),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children:[
                                        SizedBox(
                                        width : 270,
                                        height :180,
                                        child: LineChart(
                                          LineChartData(
                                            titlesData: FlTitlesData(
                                              bottomTitles: SideTitles(
                                                showTitles: true,
                                                reservedSize: 22,
                                                getTextStyles: (value) => const TextStyle(
                                                  color: Color(0xff72719b),
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 10,
                                                ),
                                                margin: 10,
                                                getTitles: (value) {
                                                  switch (value.toInt()) {
                                                    case 1:
                                                      return dt_week[0].month.toString() + '-' +dt_week[0].day.toString();
                                                    case 3:
                                                      return dt_week[1].month.toString() + '-' +dt_week[1].day.toString();
                                                    case 5:
                                                      return dt_week[2].month.toString() + '-' +dt_week[2].day.toString();
                                                    case 7:
                                                      return dt_week[3].month.toString() + '-' +dt_week[3].day.toString();
                                                    case 9:
                                                      return dt_week[4].month.toString() + '-' +dt_week[4].day.toString();
                                                    case 11:
                                                      return dt_week[5].month.toString() + '-' +dt_week[5].day.toString();
                                                    case 13:
                                                      return dt_week[6].month.toString() + '-' +dt_week[6].day.toString();
                                                  }
                                                  return '';
                                                },
                                              ),
                                              leftTitles: SideTitles(
                                                showTitles: true,
                                                getTextStyles: (value) => const TextStyle(
                                                  color: Color(0xff75729e),
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                                getTitles: (value) {
                                                  switch (value.toInt()) {
                                                    case 10:
                                                      return '100만';
                                                    case 12:
                                                      return '120만';
                                                    case 14:
                                                      return '140만';
                                                    case 16:
                                                      return '160만';
                                                    case 18:
                                                      return '180만';
                                                    case 20:
                                                      return '200만';
                                                  }
                                                  return '';
                                                },
                                                margin: 8,
                                                reservedSize: 30,
                                              ),
                                            ),
                                            borderData: FlBorderData(
                                                show: true,
                                                border: const Border(
                                                  bottom: BorderSide(
                                                    color: Color(0xff4e4965),
                                                    width: 4,
                                                  ),
                                                  left: BorderSide(
                                                    color: Colors.transparent,
                                                  ),
                                                  right: BorderSide(
                                                    color: Colors.transparent,
                                                  ),
                                                  top: BorderSide(
                                                    color: Colors.transparent,
                                                  ),
                                                )),
                                            minX: 0,
                                            maxX: 15,
                                            maxY: 20,
                                            minY: 10,
                                            lineBarsData:[
                                              LineChartBarData(
                                                spots: [
                                                  FlSpot(1, dcase_list[21]/100000),
                                                  FlSpot(3, dcase_list[22]/100000),
                                                  FlSpot(5, dcase_list[23]/100000),
                                                  FlSpot(7, dcase_list[24]/100000),
                                                  FlSpot(9, dcase_list[25]/100000),
                                                  FlSpot(11,dcase_list[26]/100000),
                                                  FlSpot(13,dcase_list[27]/100000),
                                                ],
                                                isCurved: false,
                                                dotData: FlDotData(
                                                  show:true,
                                                ),
                                                curveSmoothness: 0,
                                                colors: const [
                                                  Color(0xf29a4af6),
                                                ],
                                                barWidth: 4,
                                                isStrokeCapRound: true,
                                                belowBarData: BarAreaData(
                                                  show: false,
                                                ),
                                              ),
                                            ]
                                          ),
                                        ),
                                      ),
                                      ]
                                      ),
                                    )
                            ),
                            Consumer<graphProvider>(
                                builder: (context, vis, child) =>
                                    Visibility(
                                      visible: (graph._status == 3),
                                      child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children:[
                                            SizedBox(
                                              width : 270,
                                              height :180,
                                              child: LineChart(
                                                LineChartData(
                                                    titlesData: FlTitlesData(
                                                      bottomTitles: SideTitles(
                                                        showTitles: true,
                                                        //reservedSize: 50,
                                                        getTextStyles: (value) => const TextStyle(
                                                          color: Color(0xff72719b),
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 10,
                                                        ),

                                                        //margin: 10,
                                                        getTitles: (value) {
                                                          switch (value.toInt()) {
                                                            case 2:
                                                            return dt_month[0].month.toString() + '-' +dt_month[0].day.toString();
                                                            case 12:
                                                              return dt_month[5].month.toString() + '-' +dt_month[5].day.toString();
                                                            case 22:
                                                              return dt_month[10].month.toString() + '-' +dt_month[10].day.toString();
                                                            case 32:
                                                              return dt_month[15].month.toString() + '-' +dt_month[15].day.toString();
                                                            case 42:
                                                              return dt_month[20].month.toString() + '-' +dt_month[20].day.toString();
                                                            case 52:
                                                              return dt_month[25].month.toString() + '-' +dt_month[25].day.toString();
                                                          }
                                                          //return '1';
                                                        },
                                                      ),
                                                      leftTitles: SideTitles(
                                                        showTitles: true,
                                                        getTextStyles: (value) => const TextStyle(
                                                          color: Color(0xff75729e),
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 14,
                                                        ),
                                                        getTitles: (value) {
                                                          switch (value.toInt()) {
                                                            case 44:
                                                              return '4.4억';
                                                            case 46:
                                                              return '4.6억';
                                                            case 48:
                                                              return '4.8억';
                                                            case 50:
                                                              return '5억';
                                                            case 52:
                                                              return '5.2억';
                                                            case 54:
                                                              return '5.4억';
                                                            case 56:
                                                              return '5.6억';
                                                            case 58:
                                                              return '5.8억';
                                                            case 60:
                                                              return '6억';
                                                          }
                                                          return '';
                                                        },
                                                        margin: 8,
                                                        reservedSize: 30,
                                                      ),
                                                    ),
                                                    borderData: FlBorderData(
                                                        show: true,
                                                        border: const Border(
                                                          bottom: BorderSide(
                                                            color: Color(0xff4e4965),
                                                            width: 4,
                                                          ),
                                                          left: BorderSide(
                                                            color: Colors.transparent,
                                                          ),
                                                          right: BorderSide(
                                                            color: Colors.transparent,
                                                          ),
                                                          top: BorderSide(
                                                            color: Colors.transparent,
                                                          ),
                                                        )),
                                                    minX: 0,
                                                    maxX: 57,
                                                    maxY: 60,
                                                    minY: 44,
                                                    lineBarsData:[
                                                      LineChartBarData(
                                                        spots: [
                                                          FlSpot(2, tcase_list[0]/10000000),FlSpot(4,tcase_list[1]/10000000),
                                                          FlSpot(6, tcase_list[2]/10000000),FlSpot(8,tcase_list[3]/10000000),
                                                          FlSpot(10, tcase_list[4]/10000000),FlSpot(12,tcase_list[5]/10000000),
                                                          FlSpot(14,tcase_list[6]/10000000),FlSpot(16,tcase_list[7]/10000000),
                                                          FlSpot(18,tcase_list[8]/10000000),FlSpot(20,tcase_list[9]/10000000),
                                                          FlSpot(22,tcase_list[10]/10000000),FlSpot(24,tcase_list[11]/10000000),
                                                          FlSpot(26,tcase_list[12]/10000000),FlSpot(28,tcase_list[13]/10000000),
                                                          FlSpot(30,tcase_list[14]/10000000),FlSpot(32,tcase_list[15]/10000000),
                                                          FlSpot(34,tcase_list[16]/10000000),FlSpot(36,tcase_list[17]/10000000),
                                                          FlSpot(38,tcase_list[18]/10000000),FlSpot(40,tcase_list[19]/10000000),
                                                          FlSpot(42,tcase_list[20]/10000000),FlSpot(44,tcase_list[21]/10000000),
                                                          FlSpot(46,tcase_list[22]/10000000),FlSpot(48,tcase_list[23]/10000000),
                                                          FlSpot(50,tcase_list[24]/10000000),FlSpot(52,tcase_list[25]/10000000),
                                                          FlSpot(54,tcase_list[26]/10000000),FlSpot(56,tcase_list[27]/10000000),
                                                        ],
                                                        isCurved: false,
                                                        dotData: FlDotData(
                                                          show:true,
                                                        ),
                                                        curveSmoothness: 0,
                                                        colors: const [
                                                          Color(0xf29a4af6),
                                                        ],
                                                        barWidth: 4,
                                                        isStrokeCapRound: true,
                                                        belowBarData: BarAreaData(
                                                          show: false,
                                                        ),
                                                      ),
                                                    ]
                                                ),
                                              ),
                                            ),
                                          ]
                                      ),
                                    )
                            ),
                            Consumer<graphProvider>(
                                builder: (context, vis, child) =>
                                    Visibility(
                                      visible: (graph._status == 4),
                                      child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children:[
                                            SizedBox(
                                              width : 270,
                                              height :180,
                                              child: LineChart(
                                                LineChartData(
                                                    titlesData: FlTitlesData(
                                                      bottomTitles: SideTitles(
                                                        showTitles: true,
                                                        reservedSize: 22,
                                                        getTextStyles: (value) => const TextStyle(
                                                          color: Color(0xff72719b),
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 10,
                                                        ),
                                                        margin: 10,
                                                        getTitles: (value) {
                                                          switch (value.toInt()) {
                                                            case 2:
                                                              return dt_month[0].month.toString() + '-' +dt_month[0].day.toString();
                                                            case 12:
                                                              return dt_month[5].month.toString() + '-' +dt_month[5].day.toString();
                                                            case 22:
                                                              return dt_month[10].month.toString() + '-' +dt_month[10].day.toString();
                                                            case 32:
                                                              return dt_month[15].month.toString() + '-' +dt_month[15].day.toString();
                                                            case 42:
                                                              return dt_month[20].month.toString() + '-' +dt_month[20].day.toString();
                                                            case 52:
                                                              return dt_month[25].month.toString() + '-' +dt_month[25].day.toString();
                                                          }
                                                          return '';
                                                        },
                                                      ),
                                                      leftTitles: SideTitles(
                                                        showTitles: true,
                                                        getTextStyles: (value) => const TextStyle(
                                                          color: Color(0xff75729e),
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 14,
                                                        ),
                                                        getTitles: (value) {
                                                          switch (value.toInt()) {
                                                            case 12:
                                                              return '120만';
                                                            case 16:
                                                              return '160만';
                                                            case 20:
                                                              return '200만';
                                                            case 24:
                                                              return '240만';
                                                            case 28:
                                                              return '280만';
                                                          }
                                                          return '';
                                                        },
                                                        margin: 8,
                                                        reservedSize: 30,
                                                      ),
                                                    ),
                                                    borderData: FlBorderData(
                                                        show: true,
                                                        border: const Border(
                                                          bottom: BorderSide(
                                                            color: Color(0xff4e4965),
                                                            width: 4,
                                                          ),
                                                          left: BorderSide(
                                                            color: Colors.transparent,
                                                          ),
                                                          right: BorderSide(
                                                            color: Colors.transparent,
                                                          ),
                                                          top: BorderSide(
                                                            color: Colors.transparent,
                                                          ),
                                                        )),
                                                    minX: 0,
                                                    maxX: 57,
                                                    maxY: 30,
                                                    minY: 10,
                                                    lineBarsData:[
                                                      LineChartBarData(
                                                        spots: [
                                                          FlSpot(2, dcase_list[0]/100000),FlSpot(4,dcase_list[1]/100000),
                                                          FlSpot(6, dcase_list[2]/100000),FlSpot(8,dcase_list[3]/100000),
                                                          FlSpot(10, dcase_list[4]/100000),FlSpot(12,dcase_list[5]/100000),
                                                          FlSpot(14,dcase_list[6]/100000),FlSpot(16,dcase_list[7]/100000),
                                                          FlSpot(18,dcase_list[8]/100000),FlSpot(20,dcase_list[9]/100000),
                                                          FlSpot(22,dcase_list[10]/100000),FlSpot(24,dcase_list[11]/100000),
                                                          FlSpot(26,dcase_list[12]/100000),FlSpot(28,dcase_list[13]/100000),
                                                          FlSpot(30,dcase_list[14]/100000),FlSpot(32,dcase_list[15]/100000),
                                                          FlSpot(34,dcase_list[16]/100000),FlSpot(36,dcase_list[17]/100000),
                                                          FlSpot(38,dcase_list[18]/100000),FlSpot(40,dcase_list[19]/100000),
                                                          FlSpot(42,dcase_list[20]/100000),FlSpot(44,dcase_list[21]/100000),
                                                          FlSpot(46,dcase_list[22]/100000),FlSpot(48,dcase_list[23]/100000),
                                                          FlSpot(50,dcase_list[24]/100000),FlSpot(52,dcase_list[25]/100000),
                                                          FlSpot(54,dcase_list[26]/100000),FlSpot(56,dcase_list[27]/100000),
                                                        ],
                                                        isCurved: false,
                                                        dotData: FlDotData(
                                                          show:true,
                                                        ),
                                                        curveSmoothness: 0,
                                                        colors: const [
                                                          Color(0xf29a4af6),
                                                        ],
                                                        barWidth: 4,
                                                        isStrokeCapRound: true,
                                                        belowBarData: BarAreaData(
                                                          show: false,
                                                        ),
                                                      ),
                                                    ]
                                                ),
                                              ),
                                            ),
                                          ]
                                      ),
                                    )
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.all(20),
                        width: 300,
                        height: 250,
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.all(Radius.circular(
                                10))
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment
                                  .spaceAround,
                              children: [
                                TextButton(onPressed: () {
                                  table.invisible(true, false);
                                }, child: Text('Total Cases')),
                                TextButton(onPressed: () {
                                  table.invisible(false, true);
                                }, child: Text('Total Deaths')),
                              ],
                            ),
                            Divider(
                              height: 10.0,
                              color: Colors.grey,
                              thickness: 1,
                            ),
                            Consumer<tableProvider>(
                                builder: (context, vis, child) =>
                                    Visibility(
                                      visible: table._visible,
                                      child: SizedBox(
                                        height: 180,
                                        child: ListView.builder(
                                            scrollDirection: Axis.vertical,
                                            shrinkWrap: true,
                                            itemCount: 8,
                                            itemExtent: 40,
                                            itemBuilder: (BuildContext _ctx,
                                                int i) {
                                              return ListTile(
                                                title: Row(
                                                  mainAxisAlignment: MainAxisAlignment
                                                      .spaceBetween,
                                                  children: [
                                                    SizedBox(
                                                      width: 65,
                                                      height: 47,
                                                      child: Text((i>0)?
                                                        snapshot.data
                                                            .case_data[case_country[i-1]]["location"]:'country',
                                                        style: TextStyle(
                                                            fontSize: 12),),
                                                    ),
                                                    SizedBox(
                                                      width: 65,
                                                      height: 47,
                                                      child: Text((i>0)?
                                                        notnull(snapshot.data
                                                            .case_data[case_country[i-1]]["data"]
                                                            .last["total_cases"],case_country[i-1],"total_cases").toInt()
                                                            .toString():'total_cases',
                                                        style: TextStyle(
                                                            fontSize: 13),),
                                                    ),
                                                    SizedBox(
                                                      width: 65,
                                                      height: 47,
                                                      child: Text((i>0)?
                                                        notnull(snapshot.data
                                                            .case_data[case_country[i-1]]["data"]
                                                            .last["new_cases"],case_country[i-1],"new_cases").toInt()
                                                            .toString():'new_cases',
                                                        style: TextStyle(
                                                            fontSize: 13),),
                                                    ),
                                                    SizedBox(
                                                      width: 65,
                                                      height: 47,
                                                      child: Text((i>0)?
                                                        notnull(snapshot.data
                                                            .case_data[case_country[i-1]]["data"]
                                                            .last["total_deaths"],case_country[i-1],"total_deaths").toInt()
                                                            .toString():'total_deaths',
                                                        style: TextStyle(
                                                            fontSize: 12),),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }
                                        ),
                                      ),
                                    )
                            ),
                            Consumer<tableProvider>(
                                builder: (context, vis, child) =>
                                    Visibility(
                                      visible: table._visible2,
                                      child: SizedBox(
                                        height: 180,
                                        child: ListView.builder(
                                            scrollDirection: Axis.vertical,
                                            shrinkWrap: true,
                                            itemCount: 8,
                                            itemExtent: 40,
                                            itemBuilder: (BuildContext _ctx,
                                                int i) {
                                              return ListTile(
                                                title: Row(
                                                  mainAxisAlignment: MainAxisAlignment
                                                      .spaceBetween,
                                                  children: [
                                                    SizedBox(
                                                      width: 65,
                                                      height: 47,
                                                      child: Text((i>0)?
                                                        snapshot.data
                                                            .case_data[death_country[i-1]]["location"]:'country',
                                                        style: TextStyle(
                                                            fontSize: 12),),
                                                    ),
                                                    SizedBox(
                                                      width: 65,
                                                      height: 47,
                                                      child: Text((i>0)?
                                                        notnull(snapshot.data
                                                            .case_data[death_country[i-1]]["data"]
                                                            .last["total_cases"],death_country[i-1],"total_cases").toInt()
                                                            .toString():'total_cases',
                                                        style: TextStyle(
                                                            fontSize: 13),),
                                                    ),
                                                    SizedBox(
                                                      width: 65,
                                                      height: 47,
                                                      child: Text((i>0)?
                                                        notnull(snapshot.data
                                                            .case_data[death_country[i-1]]["data"]
                                                            .last["new_cases"],death_country[i-1],"new_cases").toInt()
                                                            .toString():'new_cases',
                                                        style: TextStyle(
                                                            fontSize: 13),),
                                                    ),
                                                    SizedBox(
                                                      width: 65,
                                                      height: 47,
                                                      child: Text((i>0)?
                                                        notnull(snapshot.data
                                                            .case_data[death_country[i-1]]["data"]
                                                            .last["total_deaths"],death_country[i-1],"total_deaths").toInt()
                                                            .toString():'total_deaths',
                                                        style: TextStyle(
                                                            fontSize: 12),),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }
                                        ),
                                      ),
                                    )
                            ),
                          ],
                        ),
                      ),
                    ]
                );
              }/*else if (snapshot.hasError) {
                return Text('snapshot error');
              }*/
              return CircularProgressIndicator();
            },
          )
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.list),
        onPressed: (){
          Navigator.pushNamed(
            context,'page1_navi',
            arguments:{"user-msg1":arguments["user-msg1"],"user-msg2":"Cases/Deaths Page"},);
        },
      ),
    );
  }
}