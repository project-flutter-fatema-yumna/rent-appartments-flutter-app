import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../MyColors.dart';
import '../../Services/Lessor_Services/get_current_chats.dart';
import '../../models/model_current_chat.dart';
import 'chatSecondScreen.dart';

class Chat_Screen extends StatefulWidget {
  const Chat_Screen({super.key});

  @override
  State<Chat_Screen> createState() => _Chat_ScreenState();
}

class _Chat_ScreenState extends State<Chat_Screen> {
   String? token =
      '1|EZIEoy5aLnCdi5XP2jxeaGtnNT60yqCeYyfoaP0W9a2b30e6';
    int? myId
   = 1;

  bool loading = true;
  List<ModelCurrentChat> chats = [];


  @override
  void initState() {
    super.initState();
   // _loadUserData();

    fetchChats();
  }
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString('token');
      myId = prefs.getInt('userId');
    });

    //print("token from prefs => $token");
    //print("myId from prefs => $myId");

     await fetchChats();
  }

  Future<void> fetchChats() async {
    try {
      final data =
      await GetCurrentChatsService().getCurrentChats(token: token!);
      print('TOKEN USED FOR Lessor WEBSOCKET BROADCAST = ${token}');
      print('MY ID = ${myId}');

      setState(() {
        chats = data;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      print("ERROR: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: SpinKitThreeBounce(color: Colors.blue,size: 20,)),
      );
    }

    return Scaffold(
      backgroundColor: myColors.colorWhite,
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: chats.isEmpty
            ? const Center(child: Text("No chats yet"))
            : ListView.separated(
          itemCount: chats.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final chat = chats[index];

            final name =
            "${chat.firstName} ${chat.lastName}".trim();

            return ChatCardStatic(
              modelCurrentChat: chat,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => chatSecondScreen(
                      phone: chat.phone,
                      title: name,
                      myId: myId!,
                      otherUserId: chat.otherUserId,
                      token: token!,
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class ChatCardStatic extends StatelessWidget {
  final ModelCurrentChat modelCurrentChat;
  final VoidCallback onTap;

  const ChatCardStatic({
    super.key,
    required this.modelCurrentChat,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final name =
    "${modelCurrentChat.firstName} ${modelCurrentChat.lastName}".trim();
    
    final lastMessage = "Last message ...";

    final time = modelCurrentChat.lastMessageAt;

    const int unreadCount = 0;
    
    final initials = name.isEmpty
        ? "?"
        : name
        .split(" ")
        .where((e) => e.isNotEmpty)
        .take(2)
        .map((e) => e[0])
        .join()
        .toUpperCase();

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black12.withOpacity(0.06)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: const Color(0xffE3F2FD),
                child: Text(
                  initials,
                  style: const TextStyle(
                    color: Color(0xff1E88E5),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    time,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (unreadCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xff1E88E5),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        "$unreadCount",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    )
                  else
                    const SizedBox(height: 22),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

