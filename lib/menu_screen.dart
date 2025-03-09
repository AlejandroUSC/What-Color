import 'package:flutter/material.dart';

class MenuScreen extends StatelessWidget {
  final TextEditingController usernameController = TextEditingController();

  MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 50),
                  child:Column(
                    children: [
                      Text('Spot the Different',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text('Color!',
                        style: TextStyle(
                          fontSize: 50,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 225.0,
                  child: TextField(
                    controller: usernameController,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 20.0,
                        horizontal: 18.0,
                      ),
                      enabledBorder: OutlineInputBorder( // Normal appearance
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder( // When focused
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(
                          color: Color.fromARGB(56, 0, 0, 0),
                          width: 3.0,
                        ),
                      ),
                      fillColor: Colors.white,
                      filled: true,
                      hintText: 'Choose your username!',
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                SizedBox(
                  width: 200.0,
                  child: ElevatedButton(
                    onPressed: () {
                      if(usernameController.text.trim().isEmpty){
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Please enter a username!'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      } else {
                        Navigator.pushNamed(context, '/game',
                            arguments: usernameController.text);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      side: BorderSide(
                        color:Colors.black,
                        width: 1.5,
                      )
                    ),
                    child: Text('Play'),
                  ),
                ),

                SizedBox(height: 20),
                SizedBox(
                  width: 200.0,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/leaderboard', arguments: usernameController.text);
                    },
                    style: ElevatedButton.styleFrom(
                        side: BorderSide(
                          color:Colors.black,
                          width: 1.5,
                        )
                    ),
                    child: Text('Leaderboard'),
                  ),
                )
              ],
            ),
          ),
        ),
    );
  }
}
