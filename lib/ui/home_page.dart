import 'dart:convert';

import 'package:buscador_de_gifs/ui/gif_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:share/share.dart';
import 'package:transparent_image/transparent_image.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  String? _search;
  int _offset = 0;

  Future<Map> _getGifs() async {
    http.Response response;

    if (_search != null) { //faz a requizição do site
      response = await http.get(Uri.parse(
          "https://api.giphy.com/v1/gifs/trending?api_key=HQEASWKeRAZOxBdn4FZWzMuXO4IWbfP6&limit=20&rating=g"));
    } else {
      response = await http.get(Uri.parse("https://api.giphy.com/v1/gifs/search?api_key=HQEASWKeRAZOxBdn4FZWzMuXO4IWbfP6&q=$_search&limit=19&offset=$_offset&rating=g&lang=pt"));
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
              padding: const EdgeInsets.all(10.0),
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
                    _offset = 0;     //reseta o icone de pesquisa
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

  int _getCount(List data) {     //cria um ultimo widget para pesquisa
    if(_search == null){
      return data.length;     //mantem a lista caso não esteja pesquisando
    } else {
      return data.length + 1;     //carrega a lista caso esteja pesquisando
    }
  }

  Widget _createGifTable(BuildContext context, AsyncSnapshot snapshot) {     //cria uma grade de itens
    return GridView.builder(
        padding:const EdgeInsets.all(10.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,     //quantidade de itens na vertical
            crossAxisSpacing: 10.0,     //espacamento entre os itens
            mainAxisSpacing: 10.0     //espacamento na vertical
        ),
        itemCount: _getCount(snapshot.data["data"]),     //quantidade de itens na horizontal
        itemBuilder: (context, index) {
          if(_search == null || index < snapshot.data["data"].length)
            return GestureDetector(
              /*child: Image.network(snapshot.data["data"][index]["images"]["fixed_height"]["url"],
                height: 300.0,
                fit: BoxFit.cover,
              ),*/
              child: FadeInImage.memoryNetwork(     //cria um carregamento de imagens mais suave
                placeholder: kTransparentImage,     //cria uma imagem transparente
                image: snapshot.data["data"][index]["images"]["fixed_height"]["url"],
                height: 300.0,
                fit: BoxFit.cover,
              ),
              onTap: () {     //transfere para a proxima pagina
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => GifPage(snapshot.data["data"][index]))     //declara uma rota
                );
              },
              onLongPress: () {     //compartilha o arquivo quando for apertado
                Share.share(snapshot.data["data"][index]["images"]["fixed_height"]["url"]);
              },
            );
          else
            return Container(     //cria um icone de pesquisa
              child: GestureDetector(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, color: Colors.white, size: 70.0,),
                    Text("Carregar mais...",
                      style: TextStyle(color: Colors.white, fontSize: 22.0),),
                  ],
                ),
                onTap: () {     //faz com que o icone de pesquisa funcione
                  setState(() {
                    _offset += 19;
                  });
                },
              ),
            );
        }
    );
  }
}
