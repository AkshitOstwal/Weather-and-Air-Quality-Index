import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flare_flutter/flare.dart';
import 'package:flare_flutter/flare_controls.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'package:nasa_app_challenge/demo.dart';
import 'package:nasa_app_challenge/feedback.dart';

void main() {
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void setState(fn) {
    super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Weather',
      theme: ThemeData.dark(),
      home: HomePage(),
    );
  }
}

class Anim {
  String name;
  double _value = 0, pos = 0, min, max, speed;
  bool endless = false;
  ActorAnimation actor;
  Anim(this.name, this.min, this.max, this.speed, this.endless);
  get value => _value * (max - min) + min;
  set value(double v) => _value = (v - min) / (max - min);
}

class AniControl extends FlareControls {
  List<Anim> items;
  AniControl(this.items);

  @override
  bool advance(FlutterActorArtboard board, double elapsed) {
    super.advance(board, elapsed);
    for (var a in items) {
      if (a.actor == null) continue;
      var d = (a.pos - a._value).abs();
      var m = a.pos > a._value ? -1 : 1;
      if (a.endless && d > 0.5) {
        m = -m;
        d = 1.0 - d;
      }
      var e = elapsed / a.actor.duration * (1 + d * a.speed);
      a.pos = e < d ? (a.pos + e * m) : a._value;
      if (a.endless) a.pos %= 1.0;
      a.actor.apply(a.actor.duration * a.pos, board, 1.0);
    }
    return true;
  }

  @override
  void initialize(FlutterActorArtboard board) {
    super.initialize(board);
    items.forEach((a) => a.actor = board.getAnimation(a.name));
  }

  operator [](String name) {
    for (var a in items) if (a.name == name) return a;
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController controller = TextEditingController();
  int mode = 0, map = 0;
  AniControl compass;
  AniControl earth;
  double lat, lon;
  String city = '',
      weather = '',
      weathertext = '',
      uvindextext = '',
      obstructionsToVisibility = '';
  int humidity = 0, uvindex = 0;
  double temp = 0, windspeed = 0, visibility = 0, pressure = 0;
  var icon;

  void getWeather() async {
    // '7c5c03c8acacd8dea3abd517ae22af34'
    var key = '0oOn3ubAApnplgnRxhs7R5plAShcAzwo';
    //'http://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$key'
    var url =
        'http://dataservice.accuweather.com/locations/v1/cities/geoposition/search?apikey=$key&q=$lat%2C$lon&language=en-us&details=true&toplevel=true';
    var resp = await http.Client().get(url);
    var data = json.decode(resp.body);
    print(data);
    var locationkey = data['Key'];
    print('    location key : $locationkey');
    city = data['SupplementalAdminAreas'][0]['EnglishName'];
    print('hey there we are here at $city');
    var url2 =
        'http://dataservice.accuweather.com/currentconditions/v1/$locationkey?apikey=$key&language=en-us&details=true';
    var resp2 = await http.Client().get(url2);
    var data2 = json.decode(resp2.body);
    print(data2);
    data2 = data2[0];
    weathertext = data2['WeatherText'];
    icon = data2['WeatherIcon'];
    temp = data2['Temperature']['Metric']['Value'];
    windspeed = data2['Wind']['Speed']['Metric']['Value'];
    uvindex = (data2['UVIndex']);
    uvindextext = data2['UVIdexText'];
    visibility = data2['Visibility']['Metric']['Value'];
    obstructionsToVisibility = data2['ObstructionsToVisibility'];
    pressure = data2['Pressure']['Metric']['Value'];
    humidity = data2['RelativeHumidity'];
    if (icon < 10) {
      icon = '0' + icon.toString();
    }
    icon = icon.toString();

    // var m = data['weather'][0];
    // weather = m['main'];
    // icon = m['icon'];
    // m = data['main'];
    // temp = m['temp'] - 273.15;
    // humidity = m['humidity'] + 0.0;
    setState(() {});
  }

  void setLocation(double lati, double long, [bool weather = true]) {
    earth['lat'].value = lat = lati;
    earth['lon'].value = lon = long;
    if (weather) getWeather();
    setState(() {});
  }

  void locate() => Location()
      .getLocation()
      .then((p) => setLocation(p.latitude, p.longitude));

  @override
  void initState() {
    super.initState();

    earth = AniControl([
      Anim('dir', 0, 360, 20, true),
      Anim('lat', -90, 90, 1, false),
      Anim('lon', -180, 180, 1, true),
    ]);

    setLocation(0, 0);
    locate();
  }

  Widget _earth() {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            city,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text('lat:${lat.toStringAsFixed(2)}  lon:${lon.toStringAsFixed(2)}'),
          Container(
            height: 400,
            child: GestureDetector(
              onTap: () => setState(() => earth.play('mode${++map % 2}')),
              onDoubleTap: locate,
              onPanUpdate: (pan) => setLocation(
                  (lat - pan.delta.dy).clamp(-90.0, 90.0),
                  (lon - pan.delta.dx + 180) % 360 - 180,
                  false),
              onPanEnd: (_) => getWeather(),
              child: FlareActor("assets/earth.flr",
                  animation: 'pulse', controller: earth),
            ),
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
              width: 148,
              height: 148,
              child: Image(
                  image: NetworkImage(
                      'https://developer.accuweather.com/sites/default/files/$icon-s.png',
                      scale: 0.1)),
            ), //FlareActor('assets/weather.flr', animation: icon)),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${temp.toInt()}°', style: TextStyle(fontSize: 50)),
              Text(weathertext),
              Text('Humidity: ${humidity.toInt()}'),
            ]),
          ]),
        ]);
  }

  Widget _details() {
    return Column(
      children: <Widget>[
        Container(
          margin: EdgeInsets.symmetric(horizontal: 8),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(45.0),
            ),
            color: Colors.blueGrey,
            elevation: 10,
            child: ListTile(
              leading: Image.asset('assets/sun.png'),
              title: Text('UV Index'),
              subtitle:
                  Text('$uvindex ${uvindextext == null ? '' : uvindextext}'),
              trailing: Text('know more'),
              onTap: () {
                _uvindexDetails();
              },
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 8),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(45.0),
            ),
            color: Colors.blueGrey,
            elevation: 10,
            child: ListTile(
              leading: Image.asset('assets/pressure.png'),
              title: Text('Temperature'),
              subtitle: Text('$temp° C'),
              trailing: Text('know more'),
              onTap: () {
                _tempDetails();
              },
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 8),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(45.0),
            ),
            color: Colors.blueGrey,
            elevation: 10,
            child: ListTile(
              leading: Image.asset('assets/visibility.png'),
              title: Text('Visibility'),
              subtitle: Text(
                  '$visibility ${obstructionsToVisibility == null ? '' : obstructionsToVisibility} km'),
              trailing: Text('know more'),
              onTap: () {
                _visibilityDetails();
              },
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 8),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(45.0),
            ),
            color: Colors.blueGrey,
            elevation: 10,
            child: ListTile(
              leading: Image.asset('assets/wind.png'),
              title: Text('Humidity'),
              subtitle: Text('$humidity'),
              trailing: Text('know more'),
              onTap: () {
                _humidityDetails();
              },
            ),
          ),
        ),
      ],
    );
  }

  void _uvindexDetails() {
    // flutter defined function
    showDialog(
        context: context,
        builder: (BuildContext context) {
          // return object of type Dialog
          return AlertDialog(
            title: Text('UV Index : $uvindex'),
            content: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  GestureDetector(
                    child: Container(
                      decoration: (uvindex < 2.9)
                          ? BoxDecoration(
                              border: Border.all(color: Colors.white, width: 5))
                          : BoxDecoration(),
                      child: Container(
                        color: Colors.green,
                        height: 80,
                        width: 80,
                        child: Center(
                            child: Text(
                          ' Low \n0-2.9',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )),
                      ),
                    ),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("Recommended protection"),
                            content: Text(
                                "A UV index reading of 0 to 2 means low danger from the Sun's UV rays for the average person.Wear sunglasses on bright days. If you burn easily, cover up and use broad spectrum SPF 30+ sunscreen. Bright surfaces, such as sand, water, and snow, will increase UV exposure."),
                            actions: <Widget>[
                              FlatButton(
                                child: Text("Close"),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                  SizedBox(
                    height: 2,
                  ),
                  GestureDetector(
                    child: Container(
                      decoration: ((uvindex > 3.0) & (uvindex < 5.9))
                          ? BoxDecoration(
                              border: Border.all(color: Colors.white, width: 5))
                          : BoxDecoration(),
                      child: Container(
                        color: Colors.yellow,
                        height: 80,
                        width: 80,
                        child: Center(
                            child: Text(
                          'Moderate \n 3.0-5.9',
                          style: TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold),
                        )),
                      ),
                    ),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("Recommended protection"),
                            content: Text(
                                "A UV index reading of 3 to 5 means moderate risk of harm from unprotected Sun exposure.Stay in shade near midday when the Sun is strongest. If outdoors, wear Sun protective clothing, a wide-brimmed hat, and UV-blocking sunglasses. Generously apply broad spectrum SPF 30+ sunscreen every 2 hours, even on cloudy days, and after swimming or sweating. Bright surfaces, such as sand, water, and snow, will increase UV exposure."),
                            actions: <Widget>[
                              FlatButton(
                                child: Text("Close"),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                  SizedBox(
                    height: 2,
                  ),
                  GestureDetector(
                    child: Container(
                      decoration: ((uvindex > 6) && (uvindex < 7.9))
                          ? BoxDecoration(
                              border: Border.all(color: Colors.white, width: 5))
                          : BoxDecoration(),
                      child: Container(
                        color: Colors.orange,
                        height: 80,
                        width: 80,
                        child: Center(
                            child: Text(
                          ' High \n6.0-7.9',
                          style: TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold),
                        )),
                      ),
                    ),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("Recommended protection"),
                            content: Text(
                                'A UV index reading of 6 to 7 means high risk of harm from unprotected Sun exposure. Protection against skin and eye damage is needed.Reduce time in the Sun between 10 a.m. and 4 p.m. If outdoors, seek shade and wear Sun protective clothing, a wide-brimmed hat, and UV-blocking sunglasses. Generously apply broad spectrum SPF 30+ sunscreen every 2 hours, even on cloudy days, and after swimming or sweating. Bright surfaces, such as sand, water, and snow, will increase UV exposure.'),
                            actions: <Widget>[
                              FlatButton(
                                child: Text("Close"),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                  SizedBox(
                    height: 2,
                  ),
                  GestureDetector(
                    child: Container(
                      decoration: ((uvindex > 8) && (uvindex < 10.9))
                          ? BoxDecoration(
                              border: Border.all(color: Colors.white, width: 5))
                          : BoxDecoration(),
                      child: Container(
                        color: Colors.red,
                        height: 80,
                        width: 80,
                        child: Center(
                            child: Text(
                          'Very high \n 8.0-10.9',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )),
                      ),
                    ),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("Recommended protection"),
                            content: Text(
                                'A UV index reading of 8 to 10 means very high risk of harm from unprotected Sun exposure. Take extra precautions because unprotected skin and eyes will be damaged and can burn quickly.Minimize Sun exposure between 10 a.m. and 4 p.m. If outdoors, seek shade and wear Sun protective clothing, a wide-brimmed hat, and UV-blocking sunglasses. Generously apply broad spectrum SPF 30+ sunscreen every 2 hours, even on cloudy days, and after swimming or sweating. Bright surfaces, such as sand, water, and snow, will increase UV exposure.'),
                            actions: <Widget>[
                              FlatButton(
                                child: Text("Close"),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                  SizedBox(
                    height: 2,
                  ),
                  GestureDetector(
                    child: Container(
                      decoration: ((uvindex > 11))
                          ? BoxDecoration(
                              border: Border.all(color: Colors.white, width: 5))
                          : BoxDecoration(),
                      child: Container(
                        color: Colors.purpleAccent,
                        height: 80,
                        width: 80,
                        child: Center(
                            child: Text(
                          'Extreme \n 11.0+',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )),
                      ),
                    ),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("Recommended protection"),
                            content: Text(
                                'A UV index reading of 11 or more means extreme risk of harm from unprotected Sun exposure. Take all precautions because unprotected skin and eyes can burn in minutes.Try to avoid Sun exposure between 10 a.m. and 4 p.m. If outdoors, seek shade and wear Sun protective clothing, a wide-brimmed hat, and UV-blocking sunglasses. Generously apply broad spectrum SPF 30+ sunscreen every 2 hours, even on cloudy days, and after swimming or sweating. Bright surfaces, such as sand, water, and snow, will increase UV exposure.'),
                            actions: <Widget>[
                              FlatButton(
                                child: Text("Close"),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text('Try tapping the colored boxes for more info!!'),
                ],
              ),
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

  void _tempDetails() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          String str = '';
          if ((temp > 22) && (temp < 36)) {
            str = 'Normal: No Risk';
          } else {
            str =
                'Risk:\n1.Drink lot of water.\n2.stay in the house.\n3.Cover body parts if going outside.';
          }
          // return object of type Dialog
          return AlertDialog(
            title: Text('Temperature : $temp° C'),
            content: SingleChildScrollView(
              child: Container(
                child: Text(str),
              ),
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

  void _humidityDetails() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          String str = '';
          if (humidity > 60) {
            str =
                'High:\n1.Dehydration.\n2.Fatigue.\n3.Muscle Cramp\n4.Heat exhaustion.\n5.Heat Stroke.';
          } else if (humidity < 35) {
            str = 'Low:\n1.Survival of viruses.\n2.Drying of ice.\n3.Dry Skin.';
          } else {
            str = 'Normal : No Harm';
          }
          // return object of type Dialog
          return AlertDialog(
            title: Text('Humidity : $humidity'),
            content: SingleChildScrollView(
              child: Container(
                child: Text(str),
              ),
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

  void _visibilityDetails() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          String str = '';
          if (visibility < .5) {
            str =
                'Low:\n1.Drive Safely.\n2.Turn ON the Headlights.\n3.Wear Mask to protect yourself form Smog';
          } else {
            str = 'Normal : No Harm';
          }
          // return object of type Dialog
          return AlertDialog(
            title: Text('Visibility : $visibility Km'),
            content: SingleChildScrollView(
              child: Container(
                child: Text(str),
              ),
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
    return Scaffold(
      body: Container(
        height: 700,
        margin: EdgeInsets.only(top: 40),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(hintText: 'Search City'),
                ),
                margin: EdgeInsets.all(15),
              ),
              RaisedButton(
                color: Colors.teal,
                child: Text('Search'),
                onPressed: () {},
              ),
              SizedBox(
                height: 10,
              ),
              _earth(),
              Container(
                color: Colors.white30,
                height: 4,
                width: 200,
              ),
              SizedBox(
                height: 10,
              ),
              _details(),
              SizedBox(
                height: 10,
              ),
              RaisedButton(
                child: Text('Get AQI'),
                onPressed: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) {
                    return DataPage(lat, lon,city);
                  }));
                },
              ),
              SizedBox(
                height: 15,
              )
            ],
          ),
        ),
      ),
      floatingActionButton: Container(
        margin: EdgeInsets.only(top: 150),
        child: FloatingActionButton(
          backgroundColor: Colors.teal,
          elevation: 10,
          child: Icon(
            Icons.mode_comment,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return FeedbackPage();
            }));
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
    );
  }
}

// WlryPetf7Cu0zcPbYtxG6FRNaZ0ADSRp
// sw07Epgou2LRosds4BJvlLuxStu25LEX
// 0oOn3ubAApnplgnRxhs7R5plAShcAzwo
// XMjCT4gQfIAcp0tnZEWmalUTq31nHMeR
// VSd4HG1WTDxZsLwG3DuA6N2JjGhG64qF
