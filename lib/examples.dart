import 'package:flutter/material.dart';

// Exemplo de caixa de exibição de texto (Text Widget)
class TextDisplayWidget extends StatelessWidget {
  final String text;

  const TextDisplayWidget({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 18.0), // Estilo de fonte opcional
    );
  }
}

// Exemplo de caixa de entrada de texto (TextField Widget)
class TextInputWidget extends StatefulWidget {
  final TextEditingController controller;

  const TextInputWidget({super.key, required this.controller});

  @override
  TextInputWidgetState createState() => TextInputWidgetState();
}

class TextInputWidgetState extends State<TextInputWidget> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      decoration: const InputDecoration(
        labelText: 'Digite algo',
        border: OutlineInputBorder(),
      ),
    );
  }
}

// Exemplo de como passar um objeto de uma widget para outra
class FirstWidget extends StatelessWidget {
  final MyObject myObject;

  const FirstWidget({super.key, required this.myObject});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SecondWidget(myObject: myObject),
          ),
        );
      },
      child: const Text('Ir para o segundo widget'),
    );
  }
}

class SecondWidget extends StatelessWidget {
  final MyObject myObject;

  const SecondWidget({super.key, required this.myObject});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Segundo Widget'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Nome: ${myObject.name}'),
            Text('Idade: ${myObject.age}'),
            ElevatedButton(
              onPressed: () {
                // Realize alguma operação com myObject, se necessário
              },
              child: const Text('Fazer alguma operação'),
            ),
          ],
        ),
      ),
    );
  }
}

class MyObject {
  final String name;
  final int age;

  MyObject({required this.name, required this.age});
}

// Exemplo de uso
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final myObject = MyObject(name: 'João', age: 30);

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Primeiro Widget'),
        ),
        body: Center(
          child: FirstWidget(myObject: myObject),
        ),
      ),
    );
  }
}
