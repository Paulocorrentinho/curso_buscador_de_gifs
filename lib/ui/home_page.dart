import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  String? search;
  int offset = 0;

  Future<Map> _getGifs() async {
    http.Response response;

    if(search == null)     //faz a requizição do site
      response = await http.get(Uri.parse("https://api.giphy.com/v1/gifs/trending?api_key=HQEASWKeRAZOxBdn4FZWzMuXO4IWbfP6&limit=20&rating=g"));
    else
      response = await http.get(Uri.parse("https://api.giphy.com/v1/gifs/search?api_key=HQEASWKeRAZOxBdn4FZWzMuXO4IWbfP6&q=$search&limit=20&offset=$offset&rating=g&lang=pt"));
    return json.decode(response.body);     //retorna um arquivo json
  }

  @override
  void initState() {
    super.initState();
    _getGifs().then((map){
      print(map);
    });
  }
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
