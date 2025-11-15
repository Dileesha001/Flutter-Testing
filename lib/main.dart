import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }
  var favorites = <WordPair>[];

  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }
  void removeFavorite(WordPair pair) {
    favorites.remove(pair);
    notifyListeners();
  }
}


 // ...

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    Widget page;
switch (selectedIndex) {
  case 0:
    page = GeneratorPage();
    break;
  case 1:
    page = FavoritesPage();
    break;
  default:
    throw UnimplementedError('no widget for $selectedIndex');
}
    return Scaffold(
      body: Row(
        children: [
          SafeArea(
            child: NavigationRail(
              extended: false,
              destinations: [
                NavigationRailDestination(
                  icon: Icon(Icons.home),
                  label: Text('Home'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.favorite),
                  label: Text('Favorites'),
                ),
              ],
              selectedIndex: selectedIndex,
              onDestinationSelected: (value) {
                setState(() {
                  selectedIndex = value;
                });
              },
            ),
          ),
          Expanded(
            child: Container(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: page,
            ),
          ),
        ],
      ),
    );
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BigCard(pair: pair),
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavorite();
                },
                icon: Icon(icon),
                label: Text('Like'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  appState.getNext();
                },
                child: Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ...

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );
    return Card(
      color : theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(50.0),
        child: Semantics(
          label: pair.asPascalCase, // Keep for accessibility
          child: RichText(
            text: TextSpan(
              style: style, // This is the default "normal" style
              children: [
                TextSpan(
                  // Capitalize the first word (e.g., "first" -> "First")
                  text: pair.first[0].toUpperCase() + pair.first.substring(1),
                  style: style.copyWith(
                    fontWeight: FontWeight.w100
                  )
                  // This word will use the default 'style'
                ),
                TextSpan(
                  // Capitalize the second word
                  text: pair.second[0].toUpperCase() + pair.second.substring(1),
                  
                  // Take the default 'style' and ONLY change the weight
                  style: style.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ...

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    if (appState.favorites.isEmpty) {
      return Center(
        child: Text('No favorites yet.'),
      );
    }

    // Use LayoutBuilder to check the screen size
    return LayoutBuilder(
      builder: (context, constraints) {
        
        // On a narrow screen (phone), use the original ListView
        if (constraints.maxWidth < 600) {
          return ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text('You have '
                    '${appState.favorites.length} favorites:'),
              ),
              for (var pair in appState.favorites)
                ListTile(
                  leading: Icon(Icons.favorite),
                  title: Text(pair.asLowerCase),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      appState.removeFavorite(pair);
                    },
                  ),
                ),
            ],
          );
        }

        // On a wide screen (tablet/desktop), use a GridView
        else {
          return GridView.count(
            crossAxisCount: 2, // Show 2 columns. Try 3 or 4!
            
            // Adjust this ratio to change the height of grid items
            childAspectRatio: 7.0, 
            
            children: [
              // We put the header as the first item in the grid
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text('You have '
                    '${appState.favorites.length} favorites:'),
              ),
              
              // Then add all the favorites
              for (var pair in appState.favorites)
                ListTile(
                  leading: Icon(Icons.favorite),
                  title: Text(pair.asLowerCase),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      appState.removeFavorite(pair);
                    },
                  ),
                ),
            ],
          );
        }
      },
    );
  }
}