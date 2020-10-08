// demo src file for ref
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:charts_common/src/common/color.dart' as chartColor;

class DataPage extends StatefulWidget {
  DataPage(this.lat, this.lon, this.city);
  final double lat, lon;

  final String city;
  @override
  _DataPageState createState() => _DataPageState();
}

class _DataPageState extends State<DataPage> {
  var url1 =
      'https://tiles.breezometer.com/v1/air-quality/breezometer-aqi/current-conditions/2/2/1.png?key=648a22beb2544741b87a58bb24c4683b';
  var url2 =
      'https://tiles.waqi.info/tiles/usepa-aqi/2/2/1.png?token=60452fcf62ce0361c8f4cdddda0c9e9f37f6a04d';
  String aqi,
      color = '',
      cat,
      domPol,
      co,
      no2,
      o3,
      pm10,
      pm25,
      so2,
      general,
      elderly,
      lungDiseases,
      heartDiseases,
      pregnant,
      children;

  Widget _imageStack() {
    // var img1 = await http.Client().get(url1);
    // var img2 = await http.Client().get(url2);
    return Stack(
      children: <Widget>[
        Image.network(
          url1,
          scale: 0.8,
          filterQuality: FilterQuality.high,
        ),
        Image.network(
          url2,
          scale: 0.8,
          filterQuality: FilterQuality.high,
        ),
      ],
    );
  }

  Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  Widget _getAQITag() {
    return GestureDetector(
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            // border color
            color: fromHex(color),
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(
          width: 20,
        ),
        //FlareActor('assets/weather.flr', animation: icon)),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('A.Q.I'),
          Text(aqi, style: TextStyle(fontSize: 50)),
          Text(widget.city),
          Text(cat),
        ]),
      ]),
      onTap: () {
        _visulaRep();
      },
    );
  }

  void _visulaRep() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          List<charts.Series<LinearSales, int>> _createSampleData() {
            final chartData = [
              LinearSales(1, 'CO', double.parse(co)),
              LinearSales(2, 'NO2', double.parse(no2)),
              LinearSales(3, 'O3', double.parse(o3)),
              LinearSales(4, 'PM10', double.parse(pm10)),
              LinearSales(5, 'PM25', double.parse(pm25)),
              LinearSales(6, 'SO2', double.parse(so2)),
            ];

            return [
              charts.Series<LinearSales, int>(
                id: 'Sales',
                domainFn: (LinearSales sales, _) => sales.num,
                measureFn: (LinearSales sales, _) => sales.val,
                labelAccessorFn: (LinearSales row, _) =>
                    '${row.name}: ${row.val}',
                data: chartData,
              )
            ];
          }

          // return object of type Dialog
          return Container(
            padding: EdgeInsets.only(top: 60),
            child: Column(
              children: <Widget>[
                Container(
                  height: 200,
                  child: charts.PieChart(
                    _createSampleData(),
                    animate: true,
                    defaultRenderer: charts.ArcRendererConfig(
                      arcWidth: 50,
                      arcRendererDecorators: [
                        charts.ArcLabelDecorator(
                            insideLabelStyleSpec:
                                charts.TextStyleSpec(fontSize: 10),
                            outsideLabelStyleSpec: charts.TextStyleSpec(
                                fontSize: 15,
                                color: chartColor.Color.white,
                                fontWeight: 'bold'),
                            labelPosition: charts.ArcLabelPosition.outside)
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          Text(
                            'CO',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(co)
                        ],
                      ),
                      Column(
                        children: <Widget>[
                          Text(
                            'NO2',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(no2)
                        ],
                      ),
                      Column(
                        children: <Widget>[
                          Text(
                            'O3',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(o3)
                        ],
                      ),
                      Column(
                        children: <Widget>[
                          Text(
                            'PM10',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(pm10)
                        ],
                      ),
                      Column(
                        children: <Widget>[
                          Text(
                            'PM2.5',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(pm25)
                        ],
                      ),
                      Column(
                        children: <Widget>[
                          Text(
                            'SO2',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(so2)
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
        });
  }

  void _getData() async {
    var url3 =
        'https://api.breezometer.com/air-quality/v2/current-conditions?lat=${widget.lat}&lon=${widget.lon}&key=648a22beb2544741b87a58bb24c4683b&features=pollutants_concentrations,local_aqi,health_recommendations';
    print(url3);
    var resp = await http.Client().get(url3);
    var data = json.decode(resp.body);
    print(data);
    setState(() {
      aqi = data['data']['indexes']['ind_cpcb']['aqi_display'];
      color = data['data']['indexes']['ind_cpcb']['color'];
      cat = data['data']['indexes']['ind_cpcb']['category'];
      domPol = data['data']['indexes']['ind_cpcb']['dominant_pollutant'];
      co =
          data['data']['pollutants']['co']['concentration']['value'].toString();
      no2 = data['data']['pollutants']['no2']['concentration']['value']
          .toString();
      o3 =
          data['data']['pollutants']['o3']['concentration']['value'].toString();
      pm10 = data['data']['pollutants']['pm10']['concentration']['value']
          .toString();
      pm25 = data['data']['pollutants']['pm25']['concentration']['value']
          .toString();
      so2 = data['data']['pollutants']['so2']['concentration']['value']
          .toString();
      general = data['data']['health_recommendations']['general_population'];
      elderly = data['data']['health_recommendations']['elderly'];
      lungDiseases = data['data']['health_recommendations']['lung_diseases'];
      heartDiseases = data['data']['health_recommendations']['heart_diseases'];
      pregnant = data['data']['health_recommendations']['pregnant_women'];
      children = data['data']['health_recommendations']['children'];
    });

    //print(data);
    print('aqi = $aqi ,color : $color,cat = $cat,domPol = $domPol ');
  }

  void _infoData() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          // return object of type Dialog
          return AlertDialog(
            title: Text('Recommendations:',style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25,color: Colors.white), ),
            content: SingleChildScrollView(
              child: Container(
                  child: Column(
                children: <Widget>[
                  Text(
                    "General ",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20,color: Colors.tealAccent),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text("$general"),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    " For Elderly ",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20,color: Colors.tealAccent),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text("$elderly"),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    "Lungs Diseases",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20,color: Colors.tealAccent),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text("$lungDiseases"),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    "Heart Diseases",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20,color: Colors.tealAccent),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text("$heartDiseases"),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    "Pregnant womens",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20,color: Colors.tealAccent),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text("$pregnant"),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    "Childrens",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20,color: Colors.tealAccent),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text("$children"),
                  SizedBox(
                    height: 20,
                  ),
                ],
              )),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('Close'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    _getData();
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.info_outline,
              size: 30,
            ),
            onPressed: () {
              _infoData();
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Center(
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 30,
                ),
                Container(
                  child: _imageStack(),
                ),
                SizedBox(
                  height: 30,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Text('Good'),
                    Container(
                      width: 250,
                      height: 25,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.topRight,
                          stops: [0.16, 0.32, 0.48, 0.64, 0.80, 0.96],
                          colors: [
                            Colors.green,
                            Colors.yellow,
                            Colors.orange,
                            Colors.red,
                            Colors.purple,
                            Colors.deepPurple
                          ],
                        ),
                      ),
                    ),
                    Text('Hazardous')
                  ],
                ),
                SizedBox(
                  height: 30,
                ),
                Container(
                  child: color == '' ? Container() : _getAQITag(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LinearSales {
  final String name;
  final double val;
  final int num;

  LinearSales(this.num, this.name, this.val);
}
//
// 648a22beb2544741b87a58bb24c4683b
// d887b7df81f642eaad385044ecf76fc9
// 1f3dadee7d044df6ba0b8ae299ae22ed
// 146566e211ed444185aad3330c0fb6e4
