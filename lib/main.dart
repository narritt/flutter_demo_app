import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_app/Cat.dart';
import 'package:http/http.dart' as http;


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(title: Text('ListViews')),
        body: MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  final String apiString = 'https://api.thecatapi.com/v1/images/search?limit=10&page=10&order=Desc';
  Animation<double> animation;
  AnimationController animController;

  var catList = new List<Cat>();

  @override
  Widget build(BuildContext context) {

    animController = new AnimationController(vsync: this, duration: new Duration(seconds: 6));

    return Scaffold(
      body: _builtListView(),
      floatingActionButton: FloatingActionButton(
        onPressed: _refresh,
        tooltip: 'Refresh',
        child: Icon(Icons.refresh),
      ),
    );
  }

  Widget _builtListView() {
    if (catList.isEmpty) {
      _refresh();
      //If no cats - return animation!
      if(!animController.isAnimating) {     // TODO: why it is not working? start the second animation
        animController.repeat();
        print("ANIMATION RUN, RUN STATUS: " + animController.isAnimating.toString());
        return new Center(
            child: new RotationTransition(
                turns: animController,
                child: Icon(Icons.refresh,
                    color: Colors.blue,
                    size: 100,)
            )
        );
      }
    }
    //if list full of cats - return list
    return ListView.builder(
      itemCount: catList == null ? 0 : catList.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(catList[index].url),
          ),
          title: Text(catList[index].id),
        );
      },
    );
  }

  void _refresh() {
    catList.clear();
    var catsFuture = fetchCats();
    //When the async done, gets value from 'Future'
    catsFuture.then((_catListResult) {
      catList = _catListResult;
      _builtListView();

      //animation stopping
      animController.stop();
      print("ANIMATION STOP, RUN STATUS: " + animController.isAnimating.toString());

      setState(() {  });      //rebuild the scene
    });
  }

  Future<List<Cat>> fetchCats() async {
    final response = await http.get(apiString);

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response, then parse the JSON.
      List<Cat> catListFetched = new List<Cat>();
      List<dynamic> jsonCatList = json.decode(response.body);
      for (Map<String, dynamic> catJson in jsonCatList){
        catListFetched.add(Cat.fromJson(catJson));
      }
      return catListFetched;
    } else {
      throw Exception('Failed to load cats');
    }
  }
}

