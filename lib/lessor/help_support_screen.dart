import 'package:flutter/material.dart';

class HelpSupportScreen extends StatelessWidget {
  static const String id = 'HelpSupportScreen';

  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support',style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.blue,
        leading: IconButton(onPressed: (){Navigator.pop(context);}, icon: Icon(Icons.arrow_back_ios_rounded,color: Colors.white,),),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Welcome to Help & Support!\n\n'
                'If you need assistance using the app or have any questions, '
                'you\'re in the right place.\n\n'
                'Here you can find answers to common questions and ways to contact our support team.',
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 24),

          const Text(
            'Frequently Asked Questions',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          // FAQ 1
          const ExpansionTile(
            title: Text('How do I book an apartment?'),
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  'Browse available apartments, open any listing, select your start '
                      'and end dates, then tap the “Reserve” button. Once the owner '
                      'reviews your request, you will receive a notification with the result.',
                ),
              ),
            ],
          ),

          // FAQ 2
          const ExpansionTile(
            title: Text('Why is my reservation still "Pending"?'),
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  'Pending means the apartment owner hasn\'t approved or rejected '
                      'your request yet. You will get notified once they take action.',
                ),
              ),
            ],
          ),

          // FAQ 3
          const ExpansionTile(
            title: Text('What happens when my booking is accepted or rejected?'),
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  'Accepted: Your booking is confirmed and the agreed amount is deducted '
                      'from your wallet.\n\n'
                      'Rejected: The booking is denied and no money is withdrawn.',
                ),
              ),
            ],
          ),

          // FAQ 4
          const ExpansionTile(
            title: Text('How do I add balance to my wallet?'),
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  'Go to “My Wallet” and choose Add Balance. Follow the steps to '
                      'complete your payment. Your wallet will update once the request is approved.',
                ),
              ),
            ],
          ),

          // FAQ 5
          const ExpansionTile(
            title: Text('I’m not receiving notifications. What should I do?'),
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  'Make sure notifications are enabled in your device settings. '
                      'If the issue continues, try logging out and back in, or contact support.',
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          const Text(
            'Contact Us',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Need more help? We’re here for you!',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 12),
                  Text('📧 Email Support: support@flatsapp.com'),
                  SizedBox(height: 4),
                  Text('📱 WhatsApp / Phone: +963 988 892 049'),
                  SizedBox(height: 4),
                  Text('⏰ Support Hours: 9:00 AM – 8:00 PM'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                // TODO: open report form / WhatsApp
              },
              child: const Text('Report a Problem'),
            ),
          ),
        ],
      ),
    );
  }
}
