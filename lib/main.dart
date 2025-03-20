import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(PokemonBattleApp());
}

class PokemonBattleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: PokemonBattleScreen(),
    );
  }
}

class PokemonBattleScreen extends StatefulWidget {
  @override
  _PokemonBattleScreenState createState() => _PokemonBattleScreenState();
}

class _PokemonBattleScreenState extends State<PokemonBattleScreen> {
  TextEditingController searchController1 = TextEditingController();
  TextEditingController searchController2 = TextEditingController();
  Map<String, dynamic>? pokemon1;
  Map<String, dynamic>? pokemon2;
  String? battleResult;

  // Fetch Pokémon details by name
  Future<void> fetchPokemon(String name, int player) async {
    final response = await http.get(
        Uri.parse('https://api.pokemontcg.io/v2/cards?q=name:$name'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['data'].isNotEmpty) {
        setState(() {
          if (player == 1) {
            pokemon1 = data['data'][0];
          } else {
            pokemon2 = data['data'][0];
          }
        });
      } else {
        showError('Pokémon not found!');
      }
    } else {
      showError('Failed to load Pokémon');
    }
  }

  // Battle logic: Compare HP of the two Pokémon
  void battlePokemons() {
    if (pokemon1 == null || pokemon2 == null) {
      showError('Both Pokémon must be selected!');
      return;
    }

    int hp1 = int.tryParse(pokemon1!['hp'] ?? '0') ?? 0;
    int hp2 = int.tryParse(pokemon2!['hp'] ?? '0') ?? 0;

    setState(() {
      if (hp1 > hp2) {
        battleResult = "${pokemon1!['name']} Wins!";
      } else if (hp2 > hp1) {
        battleResult = "${pokemon2!['name']} Wins!";
      } else {
        battleResult = "It's a Tie!";
      }
    });
  }

  // Show error messages
  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pokémon Battle')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Pokémon Search Fields
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController1,
                    decoration: InputDecoration(
                      labelText: 'Enter Pokémon 1',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.search, color: Colors.blue),
                  onPressed: () => fetchPokemon(searchController1.text, 1),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController2,
                    decoration: InputDecoration(
                      labelText: 'Enter Pokémon 2',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.search, color: Colors.blue),
                  onPressed: () => fetchPokemon(searchController2.text, 2),
                ),
              ],
            ),

            SizedBox(height: 20),

            // Display Pokémon Cards
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                pokemon1 != null
                    ? buildPokemonCard(pokemon1!)
                    : Container(width: 150, height: 200),
                pokemon2 != null
                    ? buildPokemonCard(pokemon2!)
                    : Container(width: 150, height: 200),
              ],
            ),

            SizedBox(height: 20),

            // Battle Button
            ElevatedButton(
              onPressed: battlePokemons,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                textStyle: TextStyle(fontSize: 18),
                backgroundColor: Colors.red,
              ),
              child: Text('Battle!'),
            ),

            SizedBox(height: 20),

            // Battle Result
            if (battleResult != null)
              Text(
                battleResult!,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
          ],
        ),
      ),
    );
  }

  // Function to create Pokémon card widget
  Widget buildPokemonCard(Map<String, dynamic> pokemon) {
    return Column(
      children: [
        Image.network(pokemon['images']['small'], height: 150),
        Text(
          pokemon['name'],
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text("HP: ${pokemon['hp']}"),
      ],
    );
  }
}
