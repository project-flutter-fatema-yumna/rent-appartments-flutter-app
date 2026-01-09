import 'dart:convert';

import 'package:flats_app/MyColors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../Services/chats_services/get_chat_sevice.dart';
import '../../Services/chats_services/post_chat_service.dart';

class chatSecondScreen extends StatefulWidget {
   final String reverbHost = '10.0.2.2';
   final  int reverbPort = 8080;
   final String reverbAppKey = 'fwpve9f5bloektacezr1';
   final String laravelAppHost = '10.0.2.2:8000';


  static String id = 'chatSecondScreen';

  final String phone;
  final String title;
  final int myId;
  final int otherUserId;
  final String token;

   chatSecondScreen({
    super.key,
    required this.phone,
    required this.title,
    required this.myId,
    required this.otherUserId,
    required this.token,
  });

  @override
  State<chatSecondScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<chatSecondScreen> {
  WebSocketChannel? _ws;
  String? _socketId;

  final _controller = TextEditingController();
  final _scroll = ScrollController();
  bool _loading = false;


  final List<Map<String, dynamic>> _messages = [];

  final getChatSevices _getService = getChatSevices();
  final postChatSevices _postService = postChatSevices();
  @override
  void initState() {
    super.initState();
    _loadMessages();
    _connectToReverb();
  }
  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 50), () {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent + 140,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }
  Future<void> _loadMessages() async {
   // final prefs = await SharedPreferences.getInstance();
    //token = prefs.getString('token');
    //myId = prefs.getInt('user_id');

    setState(() => _loading = true);
    try {
      final response = await _getService.getMessage(
        token: widget.token,
        srcId: widget.otherUserId,
      );
      _messages.clear();
      if (response is List) {
        for (final item in response.reversed) {
          final map = item as Map<String, dynamic>;

          final int srcId = map['src_id'] as int;
          final String text = map['content']?.toString() ?? '';

          final bool isMe = srcId == widget.myId;

          _messages.add({
            "me": isMe,
            "text": text,
          });
        }
      }
      setState(() {});
      _scrollToBottom();

    } catch (e) {
      print('Error loading messages: $e');
    } finally {
      setState(() => _loading = false);
    }
  }
  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({"me": true, "text": text});
    });
    _controller.clear();
    _scrollToBottom();

    try {
      final response = await _postService.postMessage(
        token: widget.token,
        desId: widget.otherUserId,
        content: text,
      );
     // print('sendMessage response: $response');
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  Future<void> _connectToReverb() async {
    final wsUrl =
        'ws://${widget.reverbHost}:${widget.reverbPort}/app/${widget.reverbAppKey}';

    try {
      //print('Connecting to Reverb WS: $wsUrl');

      _ws = WebSocketChannel.connect(Uri.parse(wsUrl));
      _ws!.stream.listen(
            (rawMessage) async {
          //print('WS message: $rawMessage');

          final data = jsonDecode(rawMessage as String);
          final String? event = data['event'];
          if (event == 'pusher:connection_established') {
            final connData = jsonDecode(data['data']);
            _socketId = connData['socket_id'] as String;
            print('socket_id = $_socketId');

            await _subscribeToPrivateChat();
          }
          else if (event == 'message.sent') {
            final payload = jsonDecode(data['data']);
            final msg = (payload['message'] ?? payload) as Map<String, dynamic>;

            final int srcId = msg['src_id'] as int;
            final int destId = msg['dest_id'] as int;
            final String text = msg['content']?.toString() ?? '';

            final bool belongsToThisChat =
                (srcId == widget.myId && destId == widget.otherUserId) ||
                    (srcId == widget.otherUserId && destId == widget.myId);

            if (!belongsToThisChat) return;
            if (srcId == widget.myId) {
              return;
            }

            setState(() {
              _messages.add({
                "me": false,
                "text": text,
              });
            });
            _scrollToBottom();
          }

            },
        onDone: () {
          print('WS connection closed');
        },
        onError: (error) {
          print('WS error: $error');
        },
      );
    } catch (e) {
      print('Error connecting to Reverb: $e');
    }
  }
  Future<void> _subscribeToPrivateChat() async {
    if (_ws == null || _socketId == null) return;
    final channelName = 'private-chat.${widget.myId}';
    print('SUBSCRIBE CHANNEL = $channelName');

    final authToken = await _broadcastAuthentication(channelName);
    if (authToken == null) {
      print('Auth token is null, cannot subscribe');
      return;
    }

    final subscriptionMessage = {
      'event': 'pusher:subscribe',
      'data': {
        'auth': authToken,
        'channel': channelName,
      }
    };

    _ws!.sink.add(jsonEncode(subscriptionMessage));
    //print('Subscription message sent to $channelName');
  }
  Future<String?> _broadcastAuthentication(String channelName) async {
    final url = Uri.parse('http://${widget.laravelAppHost}/broadcasting/auth');
   // print('Auth request to: $url');

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
        },
        body: {
          'socket_id': _socketId!,
          'channel_name': channelName,
        },
      );

      print('Auth status: ${response.statusCode}');
      print('Auth body: ${response.body}');

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return body['auth'] as String?;
      } else {
        return null;
      }
    } catch (e) {
      print('Auth error: $e');
      return null;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    try {
      _ws?.sink.close();
    } catch (_) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: myColors.colorWhite,
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        leading: IconButton(
            onPressed: (){Navigator.pop(context);}, icon: Icon(Icons.arrow_back_ios)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.shade100,
                    blurRadius: 1,
                    spreadRadius: 1,
                    offset: Offset(1, 1),
                  ),
                ],
              ),
              child: IconButton(
                onPressed: () async {
                  final Uri phoneUri = Uri(
                    scheme: 'tel',
                    path: widget.phone,
                  );

                  if (await canLaunchUrl(phoneUri)) {
                    await launchUrl(phoneUri);
                  } else {
                    print('Could not launch phone call');
                  }
                },
                icon: Icon(
                  Icons.phone,
                  color: Colors.green,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_loading)  Center(child: SpinKitThreeBounce(color: Colors.blue,size: 20,),),
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (_, index) {
                final msg = _messages[index];
                final isMe = msg["me"] as bool;

                return Align(
                  alignment:
                  isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    decoration: BoxDecoration(
                      color: isMe ? const Color(0xff1E88E5) : Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(isMe ? 16 : 4),
                        bottomRight: Radius.circular(isMe ? 4 : 16),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Text(
                      msg["text"] as String,
                      style: TextStyle(
                        color: isMe ? Colors.white : Colors.black87,
                        fontSize: 14,
                        height: 1.25,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      minLines: 1,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: "write message",
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(999),
                          borderSide:
                          BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(999),
                          borderSide: const BorderSide(
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  InkWell(
                    onTap: _send,
                    borderRadius: BorderRadius.circular(999),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.send, color: Colors.white),
                    ),
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
