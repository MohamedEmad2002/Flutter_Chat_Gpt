import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_gpt/constants/const.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _openAI = OpenAI.instance.build(
    token: openaIkey,
    baseOption: HttpSetup(
      receiveTimeout: const Duration(seconds: 5),
    ),
    enableLog: true,
  );

  final ChatUser _currentUser =
      ChatUser(id: "1", firstName: "Mohamed", lastName: "Emad");
  final ChatUser _gptChatUser =
      ChatUser(id: "2", firstName: "GPT", lastName: "Bot");

  final List<ChatMessage> _messages = [];
  final List<ChatUser> _typingUsers =[];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text('Chat'),
        centerTitle: true,
      ),
      body: DashChat(
          messageOptions: const MessageOptions(
            currentUserContainerColor: Colors.teal,
            containerColor: Colors.white,
          ),
          currentUser: _currentUser,
          typingUsers: _typingUsers,
          onSend: (ChatMessage m) {
            getChatResponse(m);
          },
          messages: _messages),
    );
  }

  Future<void> getChatResponse(ChatMessage m) async {
    setState(() {
      _messages.insert(0, m);
      _typingUsers.add(_gptChatUser);
    });
    List<Messages> messagesHistory = _messages.map((m) {
      if (m.user == _currentUser) {
        return Messages(role: Role.user, content: m.text);
      } else {
        return Messages(role: Role.assistant, content: m.text);
      }
    }).toList();

    final request = ChatCompleteText(
        model: GptTurbo0301ChatModel(),
        messages: messagesHistory,
        maxToken: 200);

    final response = await _openAI.onChatCompletion(request: request);
    for (var element in response!.choices) {
      setState(() {
        _messages.insert(
            0,
            ChatMessage(
                text: element.message!.content,
                user: _gptChatUser,
                createdAt: DateTime.now()));
      });
    }
    setState(() {
      _typingUsers.remove(_gptChatUser);
    });
  }
}
