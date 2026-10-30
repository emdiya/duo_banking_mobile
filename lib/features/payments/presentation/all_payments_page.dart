import '../../../core/widgets/app_page_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AllPaymentsPage extends StatefulWidget {
  const AllPaymentsPage({super.key, this.category});
  final String? category;
  @override
  State<AllPaymentsPage> createState() => _AllPaymentsPageState();
}

class _AllPaymentsPageState extends State<AllPaymentsPage> {
  bool searching = false;
  bool expandedRecent = false;
  bool editing = false;
  String query = '';
  String location = 'Phnom Penh';
  final recent = <String>[];
  static const groups = <String, List<String>>{
    'Utilities': [
      'Cintri Cambodia',
      'Electricite Du Cambodge – EDC',
      'Enterprise for Managing Municipal Waste',
      'Kampot Water Utility',
      'Krong Stueng Saen Water Utility',
      'Lvea Rumchek Water Supply',
      'Medical Waste Management',
      'Pharorth Vattanak Water',
      'Demo Water Supply',
      'Demo Electricity',
      'Demo Sanitation',
      'Demo Waste Services',
    ],
    'Government Services': [
      'PPSHV Expressway',
      'Prefilling Tax',
      'Property Tax',
      'Road Tax',
      'General Department of Taxation',
      'Demo Public Services',
      'Demo Registration',
      'Demo License',
      'Demo Permit',
      'Demo Administration',
      'Demo Transport',
      'Demo Municipal Services',
    ],
  };

  List<String> billers(String category) =>
      groups[category] ??
      ['Demo $category Provider', 'Demo $category Services'];
  void openBiller(String name) {
    if (editing) {
      setState(() => recent.remove(name));
      return;
    }
    setState(() {
      recent.remove(name);
      recent.insert(0, name);
    });
    context.push('/bill-payment', extra: name);
  }

  Widget avatar(String name, int index, {double size = 46}) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: name.startsWith('Demo')
          ? const Color(0xFFF1F6F8)
          : [
              const Color(0xFFE7F5E9),
              const Color(0xFFEEF0FC),
              const Color(0xFFE1F3ED),
              const Color(0xFFF1F6F8),
            ][index % 4],
      border: Border.all(color: const Color(0xFFE8ECEE), width: 1.5),
    ),
    child: Icon(
      name.contains('Tax')
          ? Icons.account_balance_outlined
          : name.contains('Water')
          ? Icons.water_drop_outlined
          : name.contains('Electric')
          ? Icons.bolt_outlined
          : name.contains('Expressway')
          ? Icons.add_road
          : Icons.business_outlined,
      size: size * .53,
      color: name.startsWith('Demo')
          ? const Color(0xFFB6C4CD)
          : [
              const Color(0xFF009B31),
              const Color(0xFF6779BC),
              const Color(0xFF009E86),
              const Color(0xFF718393),
            ][index % 4],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final sections = widget.category == null
        ? groups.keys.toList()
        : [widget.category!];
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
              context.canPop() ? context.pop() : context.go('/bills'),
        ),
        actions: [
          IconButton(
            tooltip: searching ? 'Close search' : 'Search billers',
            icon: Icon(searching ? Icons.close : Icons.search, size: 27),
            onPressed: () => setState(() {
              searching = !searching;
              query = '';
            }),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(6, 12, 6, 20),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 0, 6, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.category ?? 'All Payments',
                      style: const TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () async {
                      final result = await showModalBottomSheet<String>(
                        context: context,
                        showDragHandle: true,
                        builder: (ctx) => SafeArea(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              for (final city in [
                                'Phnom Penh',
                                'Siem Reap',
                                'Battambang',
                                'All locations',
                              ])
                                ListTile(
                                  title: Text(city),
                                  trailing: city == location
                                      ? const Icon(Icons.check)
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
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.filter_alt_outlined,
                            size: 23,
                            color: Color(0xFF657793),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            location,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF657793),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (searching)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TextField(
                  autofocus: true,
                  onChanged: (value) => setState(() => query = value),
                  decoration: const InputDecoration(
                    hintText: 'Search billers',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Text(
                        'Recent',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 24,
                          child: Stack(
                            children: [
                              for (
                                var i = 0;
                                i <
                                    (recent.isEmpty
                                        ? 5
                                        : recent.take(5).length);
                                i++
                              )
                                Positioned(
                                  left: i * 16,
                                  child: Container(
                                    width: 24,
                                    height: 24,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Color(0xFFD5E7EC),
                                          Color(0xFF92AFBA),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: expandedRecent
                            ? 'Collapse recent'
                            : 'Expand recent',
                        onPressed: () =>
                            setState(() => expandedRecent = !expandedRecent),
                        icon: Icon(
                          expandedRecent
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          size: 20,
                        ),
                        visualDensity: VisualDensity.compact,
                      ),
                      const Spacer(),
                      Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF6412), Color(0xFFFFAC12)],
                          ),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: InkWell(
                          onTap: () => setState(() {
                            editing = !editing;
                            expandedRecent = true;
                          }),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 5,
                            ),
                            child: Text(
                              editing ? 'Done' : 'Edit',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (expandedRecent) ...[
                    if (recent.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(14),
                        child: Text(
                          'Your recently opened billers will appear here.',
                          style: TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                      ),
                    for (final name in recent)
                      ListTile(
                        dense: true,
                        title: Text(name),
                        trailing: Icon(
                          editing
                              ? Icons.remove_circle_outline
                              : Icons.chevron_right,
                          color: editing ? Colors.red : Colors.grey,
                        ),
                        onTap: () => openBiller(name),
                      ),
                  ],
                ],
              ),
            ),
            for (final section in sections)
              if (billers(
                section,
              ).any((name) => name.toLowerCase().contains(query.toLowerCase())))
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  padding: const EdgeInsets.fromLTRB(6, 12, 6, 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 6, bottom: 12),
                        child: Text(
                          section,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      LayoutBuilder(
                        builder: (context, constraints) => Wrap(
                          spacing: 4,
                          runSpacing: 20,
                          children: [
                            for (final entry in billers(
                              section,
                            ).asMap().entries)
                              if (entry.value.toLowerCase().contains(
                                query.toLowerCase(),
                              ))
                                SizedBox(
                                  width: (constraints.maxWidth - 12) / 4,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(8),
                                    onTap: () => openBiller(entry.value),
                                    child: Column(
                                      children: [
                                        avatar(entry.value, entry.key),
                                        const SizedBox(height: 5),
                                        SizedBox(
                                          height: 34,
                                          child: Text(
                                            entry.value,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              height: 1.35,
                                              color: Color(0xFF333333),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            if (!sections.any(
              (s) => billers(
                s,
              ).any((name) => name.toLowerCase().contains(query.toLowerCase())),
            ))
              const Padding(
                padding: EdgeInsets.all(24),
                child: Text('No matching billers', textAlign: TextAlign.center),
              ),
          ],
        ),
      ),
    );
  }
}
