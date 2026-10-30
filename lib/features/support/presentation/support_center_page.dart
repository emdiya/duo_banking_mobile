import '../../../core/widgets/app_page_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class SupportCenterPage extends StatelessWidget {
  const SupportCenterPage({super.key});
  static const _items = [
    (
      Icons.map_outlined,
      'Location',
      'Our branches, outlets & ATMs location in map',
    ),
    (
      Icons.currency_exchange,
      'Exchange Rate',
      'Calculate your exchange amount',
    ),
    (Icons.forum_outlined, 'AI Chat', 'Chat with our virtual assistant'),
    (
      Icons.copy_all_outlined,
      'Friend Referral',
      'Share App with your friends and family',
    ),
    (
      Icons.assignment_outlined,
      'Announcement & Notice',
      'View important information and updates',
    ),
    (
      Icons.business_outlined,
      'Bank’s Partner',
      'Check our corporate partners & their services',
    ),
  ];

  Future<void> _preview(BuildContext context, String title, String message) =>
      showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        builder: (ctx) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: Color(0xFF666666),
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Close'),
                ),
              ],
            ),
          ),
        ),
      );

  void _open(BuildContext context, String title) {
    switch (title) {
      case 'Exchange Rate':
        context.push('/exchange-rate');
      case 'Announcement & Notice':
        context.push('/notifications');
      case 'Bank’s Partner':
        context.push('/mini-apps');
      case 'Location':
        _preview(
          context,
          'Location',
          'Branch, outlet and ATM map preview. Live location data is not connected in this demo.',
        );
      case 'AI Chat':
        _preview(
          context,
          'AI Chat',
          'How can we help?\n\n• Find your accounts from Home → Accounts.\n• Receive money from Home → Receive.\n• Manage your preferences from Profile → Settings.\n\nThis is a demo assistant preview.',
        );
      case 'Friend Referral':
        _referral(context);
    }
  }

  Future<void> _referral(BuildContext context) => showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.people_outline,
              size: 44,
              color: Color(0xFF657793),
            ),
            const SizedBox(height: 12),
            const Text(
              'Friend Referral',
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            const Text(
              'Invite friends to explore the Khmer Bank demo.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const SelectableText(
              'DEMO0001',
              style: TextStyle(fontSize: 24, letterSpacing: 2),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              icon: const Icon(Icons.copy_outlined),
              label: const Text('Copy demo referral code'),
              onPressed: () async {
                await Clipboard.setData(const ClipboardData(text: 'DEMO0001'));
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(content: Text('Demo referral code copied')),
                  );
                }
              },
            ),
          ],
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) => AppPageScaffold(
    backgroundColor: const Color(0xFFF2F2F2),
    appBar: AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      centerTitle: true,
      title: const Text(
        'Support Center',
        style: TextStyle(fontSize: 19, fontWeight: FontWeight.w500),
      ),
      leading: IconButton(
        tooltip: 'Back',
        icon: const Icon(Icons.chevron_left),
        onPressed: () => context.canPop() ? context.pop() : context.go('/home'),
      ),
      actions: [
        PopupMenuButton<String>(
          tooltip: 'More support options',
          icon: const Icon(Icons.more_vert),
          onSelected: (value) {
            if (value == 'settings') {
              context.push('/settings');
            } else {
              _preview(
                context,
                'About Khmer Bank',
                'Khmer Bank\nVersion 1.0.0\n\nA fictional banking UI laboratory.',
              );
            }
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'settings', child: Text('Settings')),
            PopupMenuItem(value: 'about', child: Text('About')),
          ],
        ),
      ],
    ),
    body: SafeArea(
      top: false,
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(9),
            clipBehavior: Clip.antiAlias,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
              child: Column(
                children: [
                  for (var i = 0; i < _items.length; i++) ...[
                    InkWell(
                      onTap: () => _open(context, _items[i].$2),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(
                                color: Color(0xFFF0F5F7),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _items[i].$1,
                                color: const Color(0xFF657793),
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _items[i].$2,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF333333),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _items[i].$3,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      height: 1.4,
                                      color: Color(0xFF777777),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (i < _items.length - 1)
                      const Padding(
                        padding: EdgeInsets.only(left: 48, right: 3),
                        child: Divider(height: 1, color: Color(0xFFE1E1E1)),
                      ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'For more assistance, contact us via:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 8),
                _contact(
                  Icons.send,
                  'Bank Telegram Chat',
                  () => _preview(
                    context,
                    'Bank Telegram Chat',
                    'Telegram support is a demo preview. No live chat account is connected.',
                  ),
                ),
                _contact(
                  Icons.phone_outlined,
                  '+855 12 123 123',
                  () => _preview(
                    context,
                    'Phone support',
                    '+855 12 123 123\n\nSample contact number from the design reference. Calling is not connected in this demo.',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  Widget _contact(IconData icon, String label, VoidCallback onTap) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(6),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF7474FF), size: 18),
          const SizedBox(width: 20),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 14, color: Color(0xFF7474FF)),
            ),
          ),
        ],
      ),
    ),
  );
}
