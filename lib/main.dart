import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Cep {
  final String cep;
  final String city;
  final String state;

  Cep({required this.cep, required this.city, required this.state});
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _cepController = TextEditingController();
  List<Cep> _ceps = [];

  Future<void> _fetchCep(String cep) async {
    final viaCepUrl = 'https://viacep.com.br/ws/$cep/json/';
    http.Response? response; // Initialize response as nullable
    try {
      response = await http.get(Uri.parse(viaCepUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final cep = Cep(
          cep: data['cep'],
          city: data['localidade'],
          state: data['uf'],
        );
        // Substitua 'YOUR_BACK4APP_API_URL', 'YOUR_APP_ID' e 'YOUR_REST_API_KEY' com suas informações reais do Back4App.
        final back4appUrl = 'YOUR_BACK4APP_API_URL/classes/CEP';
        response = await http.post(
          Uri.parse(back4appUrl),
          headers: {
            'Content-Type': 'application/json',
            'X-Parse-Application-Id': 'YOUR_APP_ID',
            'X-Parse-REST-API-Key': 'YOUR_REST_API_KEY',
          },
          body: json.encode({
            'cep': cep.cep,
            'city': cep.city,
            'state': cep.state,
          }),
        );
        if (response.statusCode == 201) {
          setState(() {
            _ceps.add(cep);
          });
        }
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Consulta de CEP'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _cepController,
              decoration: InputDecoration(labelText: 'Digite um CEP'),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              await _fetchCep(_cepController.text);
            },
            child: Text('Consultar CEP'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _ceps.length,
              itemBuilder: (context, index) {
                final cep = _ceps[index];
                return ListTile(
                  title: Text(cep.cep),
                  subtitle: Text('${cep.city}, ${cep.state}'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
