import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/html.dart';

void main() {
  runApp(ChatApp());
}

class ChatApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final WebSocketChannel channel = HtmlWebSocketChannel.connect('ws://localhost:8080/ws');
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isTyping = false;

  @override
  void dispose() {
    _controller.dispose();
    channel.sink.close();
    super.dispose();
  }

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      channel.sink.add(_controller.text);
      setState(() {
        _messages.add({'type': 'sent', 'message': _controller.text});
      });
      _controller.clear();
    }
  }

  void _showTyping() {
    if (!_isTyping) {
      _isTyping = true;
      channel.sink.add('is typing...');
      Future.delayed(Duration(seconds: 3), () {
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
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            Expanded(
              child: StreamBuilder(
                stream: channel.stream,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final data = snapshot.data.toString().split(': ');
                    final sender = data[0];
                    final message = data.sublist(1).join(': ');

                    if (message == 'is typing...') {
                      return Text(
                        '$sender is typing...',
                        style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
                      );
                    } else {
                      _messages.add({'type': 'received', 'message': '$sender: $message'});
                    }
                  }

                  return ListView.builder(
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      return Align(
                        alignment: message['type'] == 'sent' ? Alignment.centerRight : Alignment.centerLeft,
                        child: ListTile(
                          title: Text(message['message']!),
                          tileColor: message['type'] == 'sent' ? Colors.green[100] : Colors.blue[100],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      onChanged: (text) => _showTyping(),
                      decoration: InputDecoration(hintText: 'Type a message...'),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
