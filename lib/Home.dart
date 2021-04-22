import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:async';
import 'dart:convert';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  List _listaTarefas = [];
  Map<String, dynamic> _ultimoRemovido = Map();
  TextEditingController _controllerTarefa = TextEditingController();

  Future<File> _getFile() async {

    final diretorio = await getApplicationDocumentsDirectory();
    return File( "${diretorio.path}/dados.json");

  }

  _salvarTarefa(){

    String textoDigitado = _controllerTarefa.text;

    //criar dados
    Map<String, dynamic> tarefa = Map();
    tarefa["titulo"] = textoDigitado;
    tarefa["realizada"] = false;

    setState(() {
      _listaTarefas.add( tarefa );
    });

    _salvarArquivo();
    _controllerTarefa.text = "";

  }

  _salvarArquivo() async {

    var arquivo = await _getFile();

    String dados = json.encode( _listaTarefas );
    arquivo.writeAsString( dados );

  }

  _lerArquivo() async {

    try{

      final arquivo = await _getFile();
      arquivo.readAsString();

    }catch(e){

      return null;

    }

  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _lerArquivo().then( (dados){
      setState(() {
        _listaTarefas = json.decode(dados);
      });
    } );

  }

  Widget criarItemLista( context, index ){

    //final item = _listaTarefas[index]["titulo"];

    return Dismissible(
      key: Key( DateTime.now().millisecondsSinceEpoch.toString() ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction){

        //recuperar ultimo item excluido
        _ultimoRemovido = _listaTarefas[index];

        //remove o item da lista
        _listaTarefas.removeAt(index);
        _salvarArquivo();

        //snackBar
        final snackbar = SnackBar(
          //backgroundColor: Colors.green,
          duration: Duration(seconds: 5),
            content: Text("Tarefa removida!!"),
          action: SnackBarAction(
            label: "Desfazer",
            onPressed: (){

              //insere novamente na lista o item removido
              setState(() {
                _listaTarefas.insert(index, _ultimoRemovido);
              });
              _salvarTarefa();

            },
          ),
        );
        
        Scaffold.of(context).showSnackBar(snackbar);

      },
      background: Container(
        color: Colors.red,
        padding: EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Icon(
              Icons.delete,
              color: Colors.white,
            )
          ],
        ),
      ),

      child: CheckboxListTile(
        title: Text ( _listaTarefas[index]['titulo'] ),
        value: _listaTarefas[index]['realizada'],
        onChanged: ( valorAlterado ){

          setState(() {
            _listaTarefas[index]['realizada'] = valorAlterado;
          });

          _salvarArquivo();
        },
      )
    );

  }


  @override
  Widget build(BuildContext context) {

    //_salvarArquivo();
    //print("Itens" + _listaTarefas.toString() );

    return Scaffold(
      appBar: AppBar(
        title: Text("Lista de tarefas"),
        backgroundColor: Colors.purple,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        child: Icon( Icons.add ),
        onPressed: (){

          showDialog(
              context: context,
            builder: (context){

                return AlertDialog(
                  title: Text("Adicionar tarefa"),
                  content: TextField(
                    controller: _controllerTarefa,
                    decoration: InputDecoration(
                      labelText: "Insira sua tarefa"
                    ),
                    onChanged: ( text ){

                    },
                  ),
                  actions: <Widget>[
                    FlatButton(
                      child: Text("Cancelar"),
                      onPressed: () => Navigator.pop(context),
                    ),
                    FlatButton(
                      child: Text("Salvar"),
                      onPressed: (){
                        //salvar
                        _salvarTarefa();

                        Navigator.pop(context);

                      },
                    )
                  ],
                 );

            }
          );

        },
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        elevation: 10,

      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: _listaTarefas.length,
              itemBuilder: criarItemLista
            ),
          )
        ],
      )
    );
  }
}
