import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pa3_2017314626/main.dart';
import 'package:pa3_2017314626/pages/page1.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';

class tableProvider2 with ChangeNotifier{
  bool _visible = false;
  bool _visible2 = false;
  get visible => _visible;
  get visible2 => _visible2;
  tableProvider2(this._visible,this._visible2);
  void invisible(bool check, bool check2){
    _visible = check;
    _visible2 = check2;
    notifyListeners();
  }
}

class graphProvider2 with ChangeNotifier{
  int _status;
  get status => _status;
  graphProvider2(this._status);
  void cg_graph(int graph){
    _status = graph;
    notifyListeners();
  }
}

Future<vaccine> fetchVac() async{
  final response =
  await http.get(Uri.https("raw.githubusercontent.com","owid/covid-19-data/master/public/data/vaccinations/vaccinations.json"));
  if (response.statusCode == 200){
    return vaccine.fromJson(jsonDecode(response.body));
  }else{
    throw Exception('Failed to load vaccine');
  }
}

class vaccine {
  List<dynamic> v_data = List<dynamic>();

  vaccine({@required this.v_data});
  factory vaccine.fromJson(dynamic json){
    return vaccine(v_data: json);
  }
}

class page3 extends StatelessWidget {
  final Map<String, String> arguments;

  page3(this.arguments);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context)=>tableProvider2(false,false)),
        ChangeNotifierProvider(create: (context)=>graphProvider2(1)),
      ],
      child: MaterialApp(
        title: 'vaccine',
        initialRoute:'/',
        onGenerateRoute: (routerSettings) {
          switch (routerSettings.name) {
            case '/':
              return MaterialPageRoute(builder: (_) => page3_ui(arguments));
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


class page3_ui extends StatelessWidget{
  final Map<String, String> arguments;
  page3_ui(this.arguments);

  int total_vac =0;
  int total_fvac =0;
  int daily_vac =0;
  String recent;
  String recent_year;
  String recent_month;
  String recent_day;
  int jungbok = 0;
  int kor_idx = 0;
  Future<vaccine> futureVac;

  DateTime recent_dt;
  List<DateTime> dt_week = List<DateTime>(7);
  List<DateTime> dt_month = List<DateTime>(28);
  List<int> tvac_list = List<int>(28);
  List<int> dvac_list = List<int>(28);

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
    final tableProvider2 table = Provider.of<tableProvider2>(context);
    final graphProvider2 graph = Provider.of<graphProvider2>(context);
    return Scaffold(
      body: Center(
        child: FutureBuilder<vaccine>(
          future:fetchVac(),
          builder: (context,snapshot){
            if (snapshot.hasData) {
              String nonull(String input){
                if (input != null)
                  return input;
                else
                  return 'null';
              }
              if (jungbok == 0) {
                total_vac = 0;
                total_fvac = 0;
                daily_vac = 0;
                for (int k=0; k<28; k++){
                  tvac_list[k] = 0;
                  dvac_list[k] = 0;
                }
                for (int i = 0; i < snapshot.data.v_data.length; i++) {
                  if (snapshot.data.v_data[i]['country'] == 'South Korea'){
                    kor_idx = i;
                    break;
                  }
                }
                recent = snapshot.data.v_data[kor_idx]['data'].last['date'];
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

                for (int i=0; i<snapshot.data.v_data.length; i++){
                  if ((snapshot.data.v_data[i]["data"].last["date"] == recent)
                      && snapshot.data.v_data[i]["data"].last["people_fully_vaccinated"] != null) {
                    total_fvac += snapshot.data.v_data[i]["data"].last["people_fully_vaccinated"].toInt(); //정상적인 경우
                  }
                  else if (snapshot.data.v_data[i]["data"].last["date"] !=
                      recent) {
                    if (snapshot.data.v_data[i]["data"].last["people_fully_vaccinated"] != null) {
                      total_fvac += snapshot.data.v_data[i]["data"].last["people_fully_vaccinated"].toInt();
                    }
                  }
                  else if (snapshot.data.v_data[i]["data"].last["date"] == recent
                      && snapshot.data.v_data[i]["data"].last["people_fully_vaccinated"] == null) {
                    int idx = (snapshot.data.v_data[i]["data"].length) - 2;
                    if (snapshot.data.v_data[i]["data"][idx]["people_fully_vaccinated"] != null) {
                      total_fvac += snapshot.data.v_data[i]["data"][idx]["people_fully_vaccinated"].toInt();
                    }
                  }

                  if ((snapshot.data.v_data[i]["data"].last["date"] == recent)
                      && snapshot.data.v_data[i]["data"].last["daily_vaccinations"] != null) {
                    daily_vac += snapshot.data.v_data[i]["data"].last["daily_vaccinations"].toInt(); //정상적인 경우
                  }
                  else if (snapshot.data.v_data[i]["data"].last["date"] != recent) {
                    if (snapshot.data.v_data[i]["data"].last["daily_vaccinations"] != null) {
                      daily_vac += snapshot.data.v_data[i]["data"].last["daily_vaccinations"].toInt();
                    }
                  }
                  else if (snapshot.data.v_data[i]["data"].last["date"] == recent
                      && snapshot.data.v_data[i]["data"].last["daily_vaccinations"] == null) {
                    int idx = (snapshot.data.v_data[i]["data"].length) - 2;
                    if (snapshot.data.v_data[i]["data"][idx]["daily_vaccinations"] != null) {
                      daily_vac += snapshot.data.v_data[i]["data"][idx]["daily_vaccinations"].toInt();
                    }
                  }

                  if (snapshot.data.v_data[i]["data"].last["date"] == recent) {
                    if (snapshot.data.v_data[i]["data"]
                        .last["total_vaccinations"] != null) {
                      total_vac += snapshot.data.v_data[i]["data"]
                          .last["total_vaccinations"].toInt(); //정상적인 경우
                    }
                    else if (snapshot.data.v_data[i]["data"].last["people_vaccinated"]!= null)
                      total_vac += snapshot.data.v_data[i]["data"]
                          .last["people_vaccinated"].toInt();
                    else if (snapshot.data.v_data[i]["data"].last["people_fully_vaccinated"]!=null)
                      total_vac += snapshot.data.v_data[i]["data"]
                          .last["people_fully_vaccinated"].toInt();
                  }
                  else if (snapshot.data.v_data[i]["data"].last["date"] != recent) {
                    if (snapshot.data.v_data[i]["data"].last["total_vaccinations"] != null) {
                      total_vac += snapshot.data.v_data[i]["data"].last["total_vaccinations"].toInt();
                    }
                    else if (snapshot.data.v_data[i]["data"].last['people_vaccinated']!=null)
                      total_vac += snapshot.data.v_data[i]["data"]
                          .last["people_vaccinated"].toInt();
                    else if (snapshot.data.v_data[i]["data"].last["people_fully_vaccinated"]!=null)
                      total_vac += snapshot.data.v_data[i]["data"]
                          .last["people_fully_vaccinated"].toInt();
                  }

                  bool nalja = false;
                  int previous_idx = snapshot.data.v_data[i]["data"].length-1;
                  for (int k =0; k<28; k++) {
                    nalja = false;
                    for (int j=snapshot.data.v_data[i]["data"].length-1; j>=0; j--){
                      if (snapshot.data.v_data[i]["data"][j]["date"] == dateForm(dt_month[k])){
                        nalja = true;
                        if (snapshot.data.v_data[i]["data"][j]["daily_vaccinations"] != null){     //날짜 있고 total death있을때
                          dvac_list[k] += snapshot.data.v_data[i]["data"][j]["daily_vaccinations"].toInt();
                          previous_idx = j;
                          break;
                        }
                        else if (j>1 && snapshot.data.v_data[i]["data"][j-1]["daily_vaccinations"]!=null ){ //날짜 있고 total death없고
                          dvac_list[k] += snapshot.data.v_data[i]["data"][j-1]["daily_vaccinations"].toInt();//전날 있을 때
                          break;
                        }
                      }
                    }
                    if (nalja == false) {//날짜 없을 때 => 가장 최근 날짜의 new case 있을 때
                      if (previous_idx!=0&&snapshot.data.v_data[i]["data"][previous_idx-1]["daily_vaccinations"]!=null)
                        dvac_list[k] += snapshot.data.v_data[i]["data"][previous_idx-1]["daily_vaccinations"].toInt();
                    }
                  }

                  nalja = false;
                  previous_idx = snapshot.data.v_data[i]["data"].length-1;
                  for (int k =0; k<28; k++) {
                    nalja = false;
                    for (int j=snapshot.data.v_data[i]["data"].length-1; j>=0; j--){
                      if (snapshot.data.v_data[i]["data"][j]["date"] == dateForm(dt_month[k])){
                        nalja = true;
                        if (snapshot.data.v_data[i]["data"][j]["total_vaccinations"] != null){     //날짜 있고 total death있을때
                          tvac_list[k] += snapshot.data.v_data[i]["data"][j]["total_vaccinations"].toInt();
                          previous_idx = j;
                          break;
                        }
                        else if (snapshot.data.v_data[i]["data"][j]["people_vaccinated"] != null){ //날짜 있고 total death없고
                          tvac_list[k] += snapshot.data.v_data[i]["data"][j]["people_vaccinated"].toInt();//전날 있을 때
                          previous_idx = j;
                          break;
                        }
                        else if (snapshot.data.v_data[i]["data"][j]["people_fully_vaccinated"] != null){ //날짜 있고 total death없고
                          tvac_list[k] += snapshot.data.v_data[i]["data"][j]["people_fully_vaccinated"].toInt();//전날 있을 때
                          previous_idx = j;
                          break;
                        }
                      }
                    }
                    if (nalja == false) {//날짜 없을 때 => 가장 최근 날짜의 new case 있을 때
                      if (previous_idx!=0){
                        if (snapshot.data.v_data[i]["data"][previous_idx-1]["total_vaccinations"]!=null)
                          dvac_list[k] += snapshot.data.v_data[i]["data"][previous_idx-1]["total_vaccinations"].toInt();
                        else if (snapshot.data.v_data[i]["data"][previous_idx-1]["people_vaccinated"]!=null)
                          dvac_list[k] += snapshot.data.v_data[i]["data"][previous_idx-1]["people_vaccinated"].toInt();
                        else if (snapshot.data.v_data[i]["data"][previous_idx-1]["people_fully_vaccinated"]!=null)
                          dvac_list[k] += snapshot.data.v_data[i]["data"][previous_idx-1]["people_fully_vaccinated"].toInt();
                      }
                    }
                  }
                }
                jungbok+=1;
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
                                    Text(
                                        "Total Vacc.\n" +
                                            total_vac.toString()+' people')
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
                                          Text("Total fully Vacc\n" +
                                              total_fvac.toString() +
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
                                          Text("Daily Vacc.\n" +
                                              daily_vac.toString()+' people'),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ]
                          ),
                        ],
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
                          Consumer<graphProvider2>(
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
                                                        case 70:
                                                          return '70억';
                                                        case 80:
                                                          return '80억';
                                                        case 90:
                                                          return '90억';
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
                                                maxY: 90,
                                                minY: 70,
                                                lineBarsData:[
                                                  LineChartBarData(
                                                    spots: [
                                                      FlSpot(1, tvac_list[21]/100000000),
                                                      FlSpot(3, tvac_list[22]/100000000),
                                                      FlSpot(5, tvac_list[23]/100000000),
                                                      FlSpot(7, tvac_list[24]/100000000),
                                                      FlSpot(9, tvac_list[25]/100000000),
                                                      FlSpot(11,tvac_list[26]/100000000),
                                                      FlSpot(13,total_vac/100000000),
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
                          Consumer<graphProvider2>(
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
                                                            return '1억';
                                                          case 20:
                                                            return '2억';
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
                                                  maxY: 25,
                                                  minY: 5,
                                                  lineBarsData:[
                                                    LineChartBarData(
                                                      spots: [
                                                        FlSpot(1, dvac_list[21]/10000000),
                                                        FlSpot(3, dvac_list[22]/10000000),
                                                        FlSpot(5, dvac_list[23]/10000000),
                                                        FlSpot(7, dvac_list[24]/10000000),
                                                        FlSpot(9, dvac_list[25]/10000000),
                                                        FlSpot(11,dvac_list[26]/10000000),
                                                        FlSpot(13,daily_vac/10000000),
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
                          Consumer<graphProvider2>(
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
                                                          case 50:
                                                            return '50억';
                                                          case 60:
                                                            return '60억';
                                                          case 70:
                                                            return '70억';
                                                          case 80:
                                                            return '80억';
                                                          case 90:
                                                            return '90억';
                                                          case 100:
                                                            return '100억';
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
                                                  maxY: 100,
                                                  minY: 50,
                                                  lineBarsData:[
                                                    LineChartBarData(
                                                      spots: [
                                                        FlSpot(2, tvac_list[0]/100000000),FlSpot(4,tvac_list[1]/100000000),
                                                        FlSpot(6, tvac_list[2]/100000000),FlSpot(8,tvac_list[3]/100000000),
                                                        FlSpot(10, tvac_list[4]/100000000),FlSpot(12,tvac_list[5]/100000000),
                                                        FlSpot(14,tvac_list[6]/100000000),FlSpot(16,tvac_list[7]/100000000),
                                                        FlSpot(18,tvac_list[8]/100000000),FlSpot(20,tvac_list[9]/100000000),
                                                        FlSpot(22,tvac_list[10]/100000000),FlSpot(24,tvac_list[11]/100000000),
                                                        FlSpot(26,tvac_list[12]/100000000),FlSpot(28,tvac_list[13]/100000000),
                                                        FlSpot(30,tvac_list[14]/100000000),FlSpot(32,tvac_list[15]/100000000),
                                                        FlSpot(34,tvac_list[16]/100000000),FlSpot(36,tvac_list[17]/100000000),
                                                        FlSpot(38,tvac_list[18]/100000000),FlSpot(40,tvac_list[19]/100000000),
                                                        FlSpot(42,tvac_list[20]/100000000),FlSpot(44,tvac_list[21]/100000000),
                                                        FlSpot(46,tvac_list[22]/100000000),FlSpot(48,tvac_list[23]/100000000),
                                                        FlSpot(50,tvac_list[24]/100000000),FlSpot(52,tvac_list[25]/100000000),
                                                        FlSpot(54,tvac_list[26]/100000000),FlSpot(56,total_vac/100000000),
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
                          Consumer<graphProvider2>(
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
                                                          case 10:
                                                            return '1억';
                                                          case 20:
                                                            return '2억';
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
                                                  maxY: 20,
                                                  minY: 5,
                                                  lineBarsData:[
                                                    LineChartBarData(
                                                      spots: [
                                                        FlSpot(2, dvac_list[0]/10000000),FlSpot(4,dvac_list[1]/10000000),
                                                        FlSpot(6, dvac_list[2]/10000000),FlSpot(8,dvac_list[3]/10000000),
                                                        FlSpot(10, dvac_list[4]/10000000),FlSpot(12,dvac_list[5]/10000000),
                                                        FlSpot(14,dvac_list[6]/10000000),FlSpot(16,dvac_list[7]/10000000),
                                                        FlSpot(18,dvac_list[8]/10000000),FlSpot(20,dvac_list[9]/10000000),
                                                        FlSpot(22,dvac_list[10]/10000000),FlSpot(24,dvac_list[11]/10000000),
                                                        FlSpot(26,dvac_list[12]/10000000),FlSpot(28,dvac_list[13]/10000000),
                                                        FlSpot(30,dvac_list[14]/10000000),FlSpot(32,dvac_list[15]/10000000),
                                                        FlSpot(34,dvac_list[16]/10000000),FlSpot(36,dvac_list[17]/10000000),
                                                        FlSpot(38,dvac_list[18]/10000000),FlSpot(40,dvac_list[19]/10000000),
                                                        FlSpot(42,dvac_list[20]/10000000),FlSpot(44,dvac_list[21]/10000000),
                                                        FlSpot(46,dvac_list[22]/10000000),FlSpot(48,dvac_list[23]/10000000),
                                                        FlSpot(50,dvac_list[24]/10000000),FlSpot(52,dvac_list[25]/10000000),
                                                        FlSpot(54,dvac_list[26]/10000000),FlSpot(56,daily_vac/10000000),
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
                          }, child: Text('Country_name')),
                          TextButton(onPressed: () {
                            table.invisible(false, true);
                          }, child: Text('Total_vacc')),
                        ],
                      ),
                      Divider(
                        height: 10.0,
                        color: Colors.grey,
                        thickness: 1,
                      ),
                          Consumer<tableProvider2>(
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
                                                        .v_data[i-1]['country']:'Country',
                                                      style: TextStyle(
                                                          fontSize: 12),),
                                                  ),
                                                  SizedBox(
                                                    width: 65,
                                                    height: 47,
                                                    child: Text((i>0)?
                                                    nonull(snapshot.data
                                                        .v_data[i-1]["data"].last
                                                        ["total_vaccinations"].toString()):'total',
                                                      style: TextStyle(
                                                          fontSize: 13),),
                                                  ),
                                                  SizedBox(
                                                    width: 65,
                                                    height: 47,
                                                    child: Text((i>0)?
                                                    nonull(snapshot.data
                                                        .v_data[i-1]["data"].last
                                                    ["people_fully_vaccinated"].toString()):'fully',
                                                      style: TextStyle(
                                                          fontSize: 13),),
                                                  ),
                                                  SizedBox(
                                                    width: 65,
                                                    height: 47,
                                                    child: Text((i>0)?
                                                    nonull(snapshot.data
                                                        .v_data[i-1]["data"].last
                                                    ["daily_vaccinations"].toString()):'daily',
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
                    ]),
            )
            ]
              );
            }
            return CircularProgressIndicator();
          },

        )
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.list),
        onPressed: (){
          Navigator.pushNamed(
            context,'page1_navi',
            arguments:{"user-msg1":arguments["user-msg1"],"user-msg2":"Vaccine Page"},);
        },
      ),
    );
  }
}