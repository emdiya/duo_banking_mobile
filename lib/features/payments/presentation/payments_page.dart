import '../../../core/widgets/app_page_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PaymentsPage extends StatefulWidget {
  const PaymentsPage({super.key});
  @override
  State<PaymentsPage> createState() => _PaymentsPageState();
}

class _PaymentsPageState extends State<PaymentsPage> {
  bool subscription = false;
  bool favoritesOnly = false;
  bool searching = false;
  String query = '';
  String location = 'Phnom Penh';
  final favorites = <String>{};
  static const categories = [
    (Icons.electrical_services_outlined, 'Utilities'),
    (Icons.account_balance_outlined, 'Government Services'),
    (Icons.domain_outlined, 'Real Estate'),
    (Icons.router_outlined, 'Internet & TV'),
    (Icons.verified_user_outlined, 'Insurance'),
    (Icons.percent_outlined, 'Finance & Investment'),
    (Icons.school_outlined, 'Education'),
    (Icons.local_shipping_outlined, 'Trading & Distribution'),
    (Icons.sports_esports_outlined, 'Entertainment'),
    (Icons.credit_card_outlined, 'Membership & Subscription'),
    (Icons.travel_explore_outlined, 'Travel & Tours'),
    (Icons.volunteer_activism_outlined, 'Charity & Donation'),
  ];

  @override
  Widget build(BuildContext context) {
    final items = categories
        .where(
          (c) =>
              c.$2.toLowerCase().contains(query.toLowerCase()) &&
              (!favoritesOnly || favorites.contains(c.$2)) &&
              (!subscription ||
                  [
                    'Internet & TV',
                    'Entertainment',
                    'Membership & Subscription',
                  ].contains(c.$2)),
        )
        .toList();
    return AppPageScaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'Payments',
          style: TextStyle(fontSize: 19, fontWeight: FontWeight.w500),
        ),
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.chevron_left),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/home'),
        ),
        actions: [
          IconButton(
            tooltip: searching ? 'Close search' : 'Search payments',
            onPressed: () => setState(() {
              searching = !searching;
              query = '';
            }),
            icon: Icon(searching ? Icons.close : Icons.search, size: 27),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(12, 24, 12, 24),
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  for (final tab in ['Payments', 'Subscription']) ...[
                    if (tab == 'Subscription') const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(30),
                        onTap: () => setState(
                          () => subscription = tab == 'Subscription',
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: subscription == (tab == 'Subscription')
                                ? const Color(0xFF6D76FF)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: const Color(0xFFEEEEEE)),
                          ),
                          child: Text(
                            tab,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: subscription == (tab == 'Subscription')
                                  ? Colors.white
                                  : const Color(0xFF666666),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Flexible(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () async {
                      final result = await showModalBottomSheet<String>(
                        context: context,
                        showDragHandle: true,
                        builder: (ctx) => SafeArea(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Padding(
                                padding: EdgeInsets.all(12),
                                child: Text(
                                  'Select location',
                                  style: TextStyle(fontSize: 19),
                                ),
                              ),
                              for (final city in [
                                'Phnom Penh',
                                'Siem Reap',
                                'Battambang',
                                'All locations',
                              ])
                                ListTile(
                                  title: Text(city),
                                  trailing: location == city
                                      ? const Icon(
                                          Icons.check,
                                          color: Color(0xFF6D76FF),
                                        )
                                      : null,
                                  onTap: () => Navigator.pop(ctx, city),
                                ),
                            ],
                          ),
                        ),
                      );
                      if (mounted && result != null) {
                        setState(() => location = result);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.filter_alt_outlined,
                            color: Color(0xFF657793),
                            size: 23,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              location,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF657793),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                _filter(
                  'Favorite',
                  favoritesOnly,
                  () => setState(() => favoritesOnly = true),
                ),
                const SizedBox(width: 14),
                _filter(
                  'All',
                  !favoritesOnly,
                  () => context.push('/payments-all'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (searching)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: TextField(
                  autofocus: true,
                  onChanged: (value) => setState(() => query = value),
                  decoration: const InputDecoration(
                    hintText: 'Search categories',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),
            Text(
              subscription ? 'Subscription' : 'Category',
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 14),
            if (items.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No matching categories. Long press a category to add it to favorites.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54),
                ),
              ),
            LayoutBuilder(
              builder: (context, constraints) => Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (final item in items)
                    SizedBox(
                      width: (constraints.maxWidth - 12) / 2,
                      child: Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(9),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(9),
                          onTap: () => context.push(
                            Uri(
                              path: '/payments-all',
                              queryParameters: {'category': item.$2},
                            ).toString(),
                          ),
                          onLongPress: () => setState(() {
                            if (!favorites.add(item.$2)) {
                              favorites.remove(item.$2);
                            }
                          }),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(minHeight: 68),
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(9),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFF0F5F7),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      item.$1,
                                      size: 23,
                                      color: const Color(0xFF657793),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      item.$2,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF333333),
                                      ),
                                    ),
                                  ),
                                  if (favorites.contains(item.$2))
                                    const Icon(
                                      Icons.star,
                                      size: 12,
                                      color: Color(0xFFFF9510),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filter(String label, bool selected, VoidCallback onTap) => Semantics(
    selected: selected,
    button: true,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(3),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 4),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: selected
                ? const [Color(0xFFFF6510), Color(0xFFFFAA13)]
                : const [Color(0xFFFF8215), Color(0xFFFFAE20)],
          ),
          borderRadius: BorderRadius.circular(3),
        ),
        child: Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
      ),
    ),
  );
}
