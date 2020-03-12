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

class _MyHomePageState extends State<MyHomePage> {
  final String apiString = 'https://api.thecatapi.com/v1/images/search?limit=10&page=10&order=Desc';

  var catList = new List<Cat>();

  void _refresh() {
    var catsFuture = fetchCats();
    //When the async done, gets value from 'Future'
    catsFuture.then((_catListResult) {
      catList = _catListResult;
      _builtListView();
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

  @override
  Widget build(BuildContext context) {
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
    if (catList.isEmpty)
      _refresh();
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

}

