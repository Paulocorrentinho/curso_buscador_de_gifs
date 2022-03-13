import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  String? _search;
  int offset = 0;

  Future<Map> _getGifs() async {
    http.Response response;

    if (_search == null) { //faz a requizição do site
      response = await http.get(Uri.parse(
          "https://api.giphy.com/v1/gifs/trending?api_key=HQEASWKeRAZOxBdn4FZWzMuXO4IWbfP6&limit=20&rating=g"));
    } else {
      response = await http.get(Uri.parse(
          "https://api.giphy.com/v1/gifs/search?api_key=HQEASWKeRAZOxBdn4FZWzMuXO4IWbfP6&q=$_search&limit=20&offset=$offset&rating=g&lang=pt"));
    }
      return json.decode(response.body); //retorna um arquivo json
  }

  @override
  void initState() {
    // TODO: implement initState
    setState(() {
      print(_getGifs());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Image.network(
            "https://developers.giphy.com/static/img/dev-logo-lg.gif"),
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(10.0),
              child: TextField(
                decoration: const InputDecoration(
                  labelText: "Pesquise Aqui!!!",
                  labelStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder(),
                ),
                style: const TextStyle(color: Colors.white, fontSize: 18.0),
                textAlign: TextAlign.center,
                onSubmitted: (text) {
                  setState(() {
                    _search = text;
                  });
                },
              ),
            ),
            Expanded(
              child: FutureBuilder(
                  future: _getGifs(),
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                      case ConnectionState.none:
                        return Container(
                          width: 200.0,
                          height: 200.0,
                          alignment: Alignment.center,
                          child: const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white),
                            strokeWidth: 5.0,
                          ),
                        );
                      default:
                        if (snapshot.hasError)
                          return Container();
                        else {
                          return _createGifTable(context, snapshot);
                        }
                    }
                  }
              ),
            ),
          ]
      ),
    );
  }

  Widget _createGifTable(BuildContext context, AsyncSnapshot snapshot) {     //cria uma grade de itens
    return GridView.builder(
        padding:const EdgeInsets.all(10.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,     //quantidade de itens na vertical
            crossAxisSpacing: 10.0,     //espacamento entre os itens
            mainAxisSpacing: 10.0     //espacamento na vertical
        ),
        itemCount: snapshot.data["data"].length,     //quantidade de itens na horizontal
        itemBuilder: (context, index) {
          return GestureDetector(
            child: Image.network(snapshot.data["data"][index]["images"]["fixed_height"]["url"],
              height: 300.0,
              fit: BoxFit.cover,
            ),
          );
        }
    );
  }
}
