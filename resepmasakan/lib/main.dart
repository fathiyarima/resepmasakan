import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Resep Masakan',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        textTheme: TextTheme(
          headlineLarge: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.orange,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          ),
        ),
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'images/background.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Aplikasi Resep Masakan',
                    style: Theme.of(context).textTheme.headlineLarge,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Temukan berbagai resep masakan yang mudah diikuti.',
                    style: TextStyle(fontSize: 16, color: Colors.orangeAccent),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RecipeListPage()),
                      );
                    },
                    child: Text('Lihat Daftar Resep'),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RecipeInputPage()),
                      );
                    },
                    child: Text('Tambahkan Resep'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RecipeListPage extends StatefulWidget {
  @override
  _RecipeListPageState createState() => _RecipeListPageState();
}

class _RecipeListPageState extends State<RecipeListPage> {
  List<Map<String, dynamic>> recipes = [];

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  // Memuat resep yang sudah ada dari SharedPreferences
  Future<void> _loadRecipes() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('recipes');
    if (data != null) {
      setState(() {
        recipes = List<Map<String, dynamic>>.from(json.decode(data));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Resep'),
        backgroundColor: Colors.orange,
      ),
      body: ListView.builder(
        itemCount: recipes.length,
        itemBuilder: (context, index) {
          final recipe = recipes[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RecipeDetailPage(
                    title: recipe['title']!,
                    ingredients: recipe['ingredients']!,
                    steps: recipe['steps']!,
                  ),
                ),
              );
            },
            child: Card(
              margin: EdgeInsets.all(10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      recipe['title']!,
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class RecipeDetailPage extends StatelessWidget {
  final String title;
  final String ingredients;
  final String steps;

  RecipeDetailPage({required this.title, required this.ingredients, required this.steps});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Bahan-Bahan:', style: Theme.of(context).textTheme.headlineLarge),
              SizedBox(height: 8),
              Text(ingredients, style: Theme.of(context).textTheme.bodyLarge),
              SizedBox(height: 20),
              Text('Langkah-Langkah:', style: Theme.of(context).textTheme.headlineLarge),
              SizedBox(height: 8),
              Text(steps, style: Theme.of(context).textTheme.bodyLarge),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Kembali'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RecipeInputPage extends StatefulWidget {
  @override
  _RecipeInputPageState createState() => _RecipeInputPageState();
}

class _RecipeInputPageState extends State<RecipeInputPage> {
  List<Map<String, dynamic>> recipes = [];
  final _titleController = TextEditingController();
  final _ingredientsController = TextEditingController();
  final _stepsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  // Memuat resep yang sudah ada dari SharedPreferences
  Future<void> _loadRecipes() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('recipes');
    if (data != null) {
      setState(() {
        recipes = List<Map<String, dynamic>>.from(json.decode(data));
      });
    }
  }

  // Menyimpan daftar resep yang diperbarui ke SharedPreferences
  Future<void> _saveRecipes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('recipes', json.encode(recipes));
  }

  // Menambahkan resep baru
  void _addRecipe() async {
    if (_titleController.text.trim().isEmpty ||
        _ingredientsController.text.trim().isEmpty ||
        _stepsController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Harap lengkapi semua field!')),
      );
      return;
    }

    final newRecipe = {
      'title': _titleController.text,
      'ingredients': _ingredientsController.text,
      'steps': _stepsController.text,
    };

    setState(() {
      recipes.add(newRecipe);  // Menambahkan resep baru ke daftar
    });

    // Simpan daftar resep yang sudah diperbarui ke SharedPreferences
    _saveRecipes();

    // Kosongkan kolom input setelah menambahkan resep
    _titleController.clear();
    _ingredientsController.clear();
    _stepsController.clear();
  }

  // Menghapus resep
  void _deleteRecipe(int index) {
    setState(() {
      recipes.removeAt(index);
    });
    _saveRecipes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Input Resep'),
        backgroundColor: Colors.orange,
      ),
      body: Column(
        children: [
          TextField(
            controller: _titleController,
            decoration: InputDecoration(labelText: 'Judul Resep'),
          ),
          TextField(
            controller: _ingredientsController,
            decoration: InputDecoration(labelText: 'Bahan-Bahan'),
          ),
          TextField(
            controller: _stepsController,
            decoration: InputDecoration(labelText: 'Langkah-Langkah'),
          ),
          SizedBox(height: 10),
          ElevatedButton(onPressed: _addRecipe, child: Text('Tambahkan Resep')),
          Expanded(
            child: ListView.builder(
              itemCount: recipes.length,
              itemBuilder: (context, index) {
                final recipe = recipes[index];
                return ListTile(
                  title: Text(recipe['title']),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => _deleteRecipe(index),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
