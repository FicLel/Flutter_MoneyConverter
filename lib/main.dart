import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:http/http.dart' as http;
Future<Post> fetchPost() async {
  final response =
  await http.get('https://free.currencyconverterapi.com/api/v6/convert?q=EUR_USD&compact=y');

  if (response.statusCode == 200) {
    // If the call to the server was successful, parse the JSON
    return Post.fromJson(json.decode(response.body));
  } else {
    // If that call was not successful, throw an error.
    throw Exception('Failed to load post');
  }
}

class Post {
  final double val;

  Post({this.val});

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      val: json['EUR_USD']['val'],

    );
  }
}
class ChangeMoney extends StatefulWidget{
  @override
  _ChangeMoney createState() =>  _ChangeMoney();
}

class _ChangeMoney extends State<ChangeMoney>{
  double i = 0;
  TextEditingController moneyController = TextEditingController();
  void converter(){
    setState(() {
      i = double.parse(moneyController.text);
    });
  }
  @override
  void dispose(){
    //En su momento limpia la ventana
    moneyController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context){
    moneyController.text = "1";
    return Column(
      children:[
        Container(
          padding: const EdgeInsets.all(8),
          child: Text(
            'EUR'
          )
        ),
        TextField(
            style: new TextStyle(
              fontSize: 40,
              height: 2,
              color: Colors.black
            ),
            decoration: new InputDecoration.collapsed(
                hintText: '1',
                border: OutlineInputBorder(),
                fillColor: Colors.black12
            ),

            controller: moneyController
        ),
        Container(
          padding: const EdgeInsets.only(top: 10.0),
          child: Text(
            'US',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
            child: FutureBuilder<Post>(
              future: fetchPost(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  double rate = snapshot.data.val;
                  String finaltext = (rate*i).toString();
                  return Text(finaltext);
                } else if (snapshot.hasError) {
                  return Text("${snapshot.error}");
                }
                // By default, show a loading spinner
                return CircularProgressIndicator();
              },
            )
        ),
        RaisedButton(
          onPressed: converter,
          child: new Text(
            "Convert",
          ),
        ),
      ],
    );
  }
}

void main() => runApp(MyApp(post: fetchPost()));

class MyApp extends StatelessWidget {
  final Future<Post> post;

  MyApp({Key key, this.post}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Euro-Dollar',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: Scaffold(
        floatingActionButton: FloatingActionButton(child: Icon(Icons.refresh), onPressed: (){
          ChangeMoney();
        },),
        appBar: AppBar(
          title: Text('Money change'),
        ),
        body: ChangeMoney()
      ),
    );
  }
}
