import 'package:app/Model/chats/chat_message.dart';
import 'package:flutter/material.dart';

class CallView extends StatefulWidget {
  const CallView({super.key, required this.chatMessage});
  final ChatMessage chatMessage;

  @override
  State<CallView> createState() => _CallViewState();
}

class _CallViewState extends State<CallView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Call View'),
      ),
      body: const Center(
        child: Text('Call View'),
      ),
    );
  }
}
