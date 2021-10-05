import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:english_words/english_words.dart';

void main() =>
    runApp(MyApp());


var suggestions = <WordPair>[];
final _saved = <WordPair>{};
final _biggerFont = const TextStyle(fontSize: 18.0);


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Startup Name Generator',
      theme: ThemeData(
        primaryColor: Colors.white,
      ),
      home: HomePage(),
    );
  }
}



class HomePage extends StatefulWidget {
    static const routeName = '/';
    @override
    _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Startup Name Generator'),
          actions: [
            IconButton(icon: Icon(Icons.list), onPressed: _pushSaved),
          ],
        ),
        body: RandomWords()
    );
  }

    void _pushSaved() {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (BuildContext context) {
            final tiles = _saved.map(
                  (WordPair pair) {
                return ListTile(
                  title: Text(
                    pair.asPascalCase,
                    style: _biggerFont,
                  ),
                );
              },
            );
            final divided = tiles.isNotEmpty
                ? ListTile.divideTiles(context: context, tiles: tiles).toList()
                : <Widget>[];

            return Scaffold(
              appBar: AppBar(
                title: Text('Saved Suggestions'),
              ),
              body: ListView(children: divided),
            );
          },
        ),
      );
    }
  }


class RandomWords extends StatefulWidget {

  @override
  _RandomWordsState createState() => _RandomWordsState();
}

class _RandomWordsState extends State<RandomWords> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, int i) {
          if (i.isOdd) {
            return Divider();
          }
          int index = i ~/ 2;
          if (index >= suggestions.length) {
            suggestions.addAll(generateWordPairs().take(10));
          }
          return _toDelete(context, suggestions[index], index);
        }
    );
  }


  Widget _toDelete(BuildContext context, WordPair pair, int index) {
    final item = pair.asPascalCase;
    return Dismissible(
        key: Key(item),
        direction: DismissDirection.startToEnd,
        onDismissed: (direction) {
          setState(() {
            var removidos = suggestions.removeAt(index);
            _saved.remove(removidos);
          });
        },
        background: Container(color: Colors.red,),
        child: _buildRow(context, item, pair, index)
    );
  }

  Widget _buildRow(context, item, pair, int index){
    final alreadySaved = _saved.contains(pair);
    return ListTile(
      title: Text(item, style: _biggerFont),
      trailing: IconButton(
        icon: alreadySaved ? Icon(Icons.favorite) : Icon(
            Icons.favorite_border),
        color: alreadySaved ? Colors.red : null,
        onPressed: () {
          setState(() {
            if (alreadySaved) {
              Icon(Icons.favorite_border, color: null,);
              _saved.remove(pair);
            } else {
              Icon(Icons.favorite, color: Colors.red,);
              _saved.add(pair);
            }
          });
        },
      ),
      onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
              builder: (BuildContext context) => EditPage(),
            settings: RouteSettings(arguments: {'index': index, 'pair': pair})
          )
      )
    );
  }

}
class EditPage extends StatefulWidget {

  @override
  _EditPageState createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  String? first ='';
  String? second = '';
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(context) {
    Map arguments = ModalRoute.of(context)!.settings.arguments as Map;
    var index = arguments['index'];
    var pair = arguments['pair'];
    first = pair.first;
    second = pair.second;
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit item'),),
      body: Container(
          color: Colors.white,
          child: _buildForm(context, pair, index)),
    );
  }

  _buildForm(context, pair, index) {
    return Form(
      key: _formKey,
      child: Wrap(
        alignment: WrapAlignment.center,
        runSpacing: 16.0,
        children: <Widget>[
          TextFormField(
            initialValue: first,
            keyboardType: TextInputType.text,
            decoration: const InputDecoration(labelText: 'Primeira'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter some text';
              }
              return null;
            },
            onSaved: (newValue) {
              first = newValue;
            },
          ),
          TextFormField(
            initialValue: second,
            keyboardType: TextInputType.text,
            decoration: const InputDecoration(labelText: 'Segunda'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter some text';
              }
              return null;
            },
            onSaved: (value) {
              second = value;
            },
          ),
          SizedBox(
            width: double.infinity,
          ),
          ElevatedButton(
            onPressed: () => _save(context, index),
            child: Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _save(BuildContext context, index) {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Processing Data')),
      );
      _formKey.currentState!.save();
      print(suggestions);
      setState(() {
        var pair = WordPair(first!, second!);
        suggestions[index] = pair;
      });
      print(suggestions);
      Navigator.of(context).push(
          MaterialPageRoute(
              builder: (BuildContext context) => HomePage()
          )
      );
    }
    else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ERROR')),
      );
    }

  }
}