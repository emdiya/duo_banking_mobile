import '../../../core/widgets/app_page_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MiniAppsPage extends StatefulWidget {
  const MiniAppsPage({super.key});
  @override
  State<MiniAppsPage> createState() => _MiniAppsPageState();
}

class _MiniAppsPageState extends State<MiniAppsPage> {
  String query = '';
  String location = 'All Locations';
  String category = 'Professional Service';
  bool editing = false;
  final expanded = <String>{};
  final favorites = <String>{
    'Legend Cinema',
    'Brown Coffee',
    'Smart Axiata',
    'CBC Check',
  };
  final recent = <String>[];
  final keys = <String, GlobalKey>{};
  static const apps = <String, List<String>>{
    'Professional Service': ['ARC Check'],
    'Finance': ['Manulife'],
    'Vehicle': ['CBC Check'],
    'Mobile, Internet & TV': ['Smart Axiata', 'Cellcard', 'Metfone'],
    'Insurance': ['Manulife'],
    'Technology': ['CBC Check'],
    'Healthcare': ['CBC Check'],
    'Transportation': [],
    'Travel & Tours': [],
    'Education': [],
    'Housing': [],
    'Beauty & Wellness': [],
    'Courier Services': [],
    'Sport & Fitness': [],
    'Entertainment & Art': ['Legend Cinema'],
    'Exhibitions & Galleries': ['Sosoro Museum'],
    'Food & Drink': ['Starbucks', 'Brown Coffee', 'KOI Thé', 'Mixue'],
    'Government Service': [
      'PPSHV Expressway',
      'Prefilling Tax',
      'Property Tax',
      'Road Tax',
    ],
    'Shopping': [],
  };
  List<String> entries(String name) {
    final known = apps[name]!;
    final count =
        [
          'Travel & Tours',
          'Education',
          'Housing',
          'Government Service',
          'Shopping',
        ].contains(name)
        ? 8
        : 4;
    return [
      ...known,
      for (var i = known.length; i < count; i++) 'Demo $name ${i + 1}',
    ];
  }

  void openApp(String name) {
    if (editing) {
      setState(() {
        if (!favorites.add(name)) {
          favorites.remove(name);
        }
      });
      return;
    }
    setState(() {
      recent.remove(name);
      recent.insert(0, name);
    });
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _logo(name),
              const SizedBox(height: 16),
              Text(
                name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Mini-app demo preview',
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    if (!favorites.add(name)) {
                      favorites.remove(name);
                    }
                  });
                  Navigator.pop(ctx);
                },
                icon: Icon(
                  favorites.contains(name) ? Icons.star : Icons.star_border,
                ),
                label: Text(
                  favorites.contains(name)
                      ? 'Remove from favorites'
                      : 'Add to favorites',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _logo(String name, {double size = 44}) {
    final demo = name.startsWith('Demo');
    final color = name.contains('Cinema')
        ? const Color(0xFF252534)
        : name.contains('Coffee')
        ? const Color(0xFFBF8C38)
        : name.contains('Mixue') || name.contains('Metfone')
        ? const Color(0xFFD51C2C)
        : const Color(0xFF00A66C);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: demo ? const Color(0xFFF0F5F7) : color.withValues(alpha: .1),
        border: Border.all(color: const Color(0xFFE8ECEE)),
      ),
      child: Icon(
        demo
            ? Icons.apps_outlined
            : name.contains('Coffee') ||
                  name.contains('Starbucks') ||
                  name.contains('Thé')
            ? Icons.local_cafe_outlined
            : name.contains('Cinema')
            ? Icons.movie_outlined
            : name.contains('Tax')
            ? Icons.account_balance_outlined
            : name.contains('Smart') ||
                  name.contains('Cellcard') ||
                  name.contains('Metfone')
            ? Icons.cell_tower_outlined
            : Icons.business_outlined,
        size: size * .55,
        color: demo ? const Color(0xFFB9C6CF) : color,
      ),
    );
  }

  Widget grid(List<String> names) => LayoutBuilder(
    builder: (context, constraints) => Wrap(
      spacing: 8,
      runSpacing: 16,
      children: [
        for (final name in names)
          SizedBox(
            width: (constraints.maxWidth - 24) / 4,
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => openApp(name),
              onLongPress: () => setState(() {
                if (!favorites.add(name)) {
                  favorites.remove(name);
                }
              }),
              child: Column(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      _logo(name),
                      if (editing)
                        Positioned(
                          right: -3,
                          top: -3,
                          child: Icon(
                            favorites.contains(name)
                                ? Icons.remove_circle
                                : Icons.add_circle,
                            color: favorites.contains(name)
                                ? Colors.red
                                : Colors.orange,
                            size: 18,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 10,
                      height: 1.3,
                      color: Color(0xFF555555),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    ),
  );

  Widget panel(String title, List<String> names, {bool favorite = false}) =>
      Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (favorite) ...[
                  const Icon(Icons.star_border, size: 20),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (favorite)
                  InkWell(
                    onTap: () => setState(() => editing = !editing),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF8812),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        editing ? 'Done' : 'Edit',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (names.isEmpty)
              const Text(
                'Long press an app to add it to favorites.',
                style: TextStyle(fontSize: 12, color: Colors.black54),
              )
            else
              grid(names),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final sections = apps.keys
        .where(
          (name) =>
              query.isEmpty ||
              name.toLowerCase().contains(query.toLowerCase()) ||
              entries(
                name,
              ).any((app) => app.toLowerCase().contains(query.toLowerCase())),
        )
        .toList();
    return AppPageScaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.chevron_left),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/home'),
        ),
        title: const Text(
          'My Mini-apps',
          style: TextStyle(fontSize: 19, fontWeight: FontWeight.w500),
        ),
        actions: [
          IconButton(
            tooltip: 'Edit favorites',
            onPressed: () => setState(() => editing = !editing),
            icon: const Icon(Icons.grid_view_outlined, size: 23),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 38,
                      child: TextField(
                        onChanged: (value) => setState(() => query = value),
                        style: const TextStyle(fontSize: 12),
                        decoration: InputDecoration(
                          hintText: 'Search',
                          prefixIcon: const Icon(Icons.search, size: 20),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.zero,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(7),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 38,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: location,
                          isExpanded: true,
                          icon: const Icon(
                            Icons.expand_circle_down_outlined,
                            size: 19,
                            color: Color(0xFF8795A3),
                          ),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF657793),
                          ),
                          items: [
                            for (final city in [
                              'All Locations',
                              'Phnom Penh',
                              'Siem Reap',
                            ])
                              DropdownMenuItem(value: city, child: Text(city)),
                          ],
                          onChanged: (value) =>
                              setState(() => location = value!),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Text(
                'Discover',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Material(
                borderRadius: BorderRadius.circular(10),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => openApp('Legend Cinema'),
                  child: Ink(
                    height: 135,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF102B32),
                          Color(0xFF71523C),
                          Color(0xFF9C2533),
                        ],
                      ),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(18),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Cinema Ticket',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 25,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  'Book & Watch',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(height: 14),
                                Text(
                                  'Discover your next movie',
                                  style: TextStyle(
                                    color: Color(0xFFFFD7A0),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.local_movies_outlined,
                            color: Color(0xFFFFD7A0),
                            size: 62,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              for (final label in [
                'Recently Used',
                'Newly Added',
                'Popular in Area',
              ])
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      InkWell(
                        onTap: () => setState(() {
                          if (!expanded.add(label)) {
                            expanded.remove(label);
                          }
                        }),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  label,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              for (final name in [
                                'Smart Axiata',
                                'Brown Coffee',
                                'CBC Check',
                              ])
                                Padding(
                                  padding: const EdgeInsets.only(left: 2),
                                  child: _logo(name, size: 21),
                                ),
                              Icon(
                                expanded.contains(label)
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down,
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (expanded.contains(label))
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: label == 'Recently Used' && recent.isEmpty
                              ? const Text(
                                  'Your recently opened apps will appear here.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black54,
                                  ),
                                )
                              : grid(
                                  label == 'Recently Used'
                                      ? recent
                                      : [
                                          'Smart Axiata',
                                          'Brown Coffee',
                                          'CBC Check',
                                          'Legend Cinema',
                                        ],
                                ),
                        ),
                    ],
                  ),
                ),
              panel('My Favorites', favorites.toList(), favorite: true),
              SizedBox(
                height: 48,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    for (final name in apps.keys)
                      TextButton(
                        onPressed: () {
                          setState(() => category = name);
                          final target = keys[name]?.currentContext;
                          if (target != null) {
                            Scrollable.ensureVisible(
                              target,
                              duration: const Duration(milliseconds: 300),
                              alignment: .05,
                            );
                          }
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: category == name
                              ? const Color(0xFFFF8B14)
                              : const Color(0xFF444444),
                          shape: const RoundedRectangleBorder(),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(name, style: const TextStyle(fontSize: 12)),
                            const SizedBox(height: 7),
                            Container(
                              height: 2,
                              width: 50,
                              color: category == name
                                  ? const Color(0xFFFF8B14)
                                  : Colors.transparent,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              for (final section in sections)
                Container(
                  key: keys.putIfAbsent(section, GlobalKey.new),
                  child: panel(
                    section,
                    entries(section)
                        .where(
                          (name) =>
                              query.isEmpty ||
                              section.toLowerCase().contains(
                                query.toLowerCase(),
                              ) ||
                              name.toLowerCase().contains(query.toLowerCase()),
                        )
                        .toList(),
                  ),
                ),
              if (sections.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'No matching mini-apps',
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
