import 'dart:html';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WebSocket Chat',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyChatPage(),
    );
  }
}

class MyChatPage extends StatefulWidget {
  @override
  _MyChatPageState createState() => _MyChatPageState();
}

class _MyChatPageState extends State<MyChatPage> {
  final TextEditingController _controller = TextEditingController();
  late WebSocket _webSocket;
  bool _isConnected = false;
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _connectToWebSocket();
  }

  void _connectToWebSocket() {
    _webSocket = WebSocket('ws://echo.websocket.org');
    _webSocket.onOpen.listen((event) {
      setState(() {
        _isConnected = true;
      });
    });

    _webSocket.onMessage.listen((event) {
      final message = event.data as String;
      _handleMessage(message);
    });

    _webSocket.onClose.listen((event) {
      setState(() {
        _isConnected = false;
      });
    });
  }

  void _handleMessage(String message) {
    if (message == 'is typing...') {
      setState(() {
        _isTyping = true;
      });
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _isTyping = false;
          });
        }
      });
    } else {
      // Handle regular messages here
    }
  }

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      _webSocket.send(_controller.text);
      _controller.clear();
      setState(() {
        _isTyping = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('WebSocket Chat'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[

                Expanded(
                  child: Column(
                    children: <Widget>[
                      Expanded(
                        child: ListView(
                          children: <Widget>[
                            ListTile(
                              title: Text('Welcome to WebSocket Chat'),
                            ),
                            // Add message list widgets here
                          ],
                        ),
                      ),
                      if (_isTyping)
                        Text(
                          'Someone is typing...',
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: Colors.grey,
                          ),
                        ),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              onChanged: (value) {
                                if (value.isNotEmpty) {
                                  _webSocket.send('is typing...');
                                }
                              },
                              decoration: InputDecoration(
                                hintText: 'Type a message...',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          SizedBox(width: 10.0),
                          ElevatedButton(
                            onPressed: _sendMessage,
                            child: Text('Send'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
