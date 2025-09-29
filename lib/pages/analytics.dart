import 'package:flutter/material.dart';
import '../services/api_client.dart';
import '../components/app_scaffold.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  // Simple in-memory cache to persist between navigations
  static List<_RateRow>? _cachedRows;
  static _Dashboard? _cachedDash;
  static String? _cachedError;

  bool _loadingRates = true;
  bool _loadingDash = true;
  String? _error;

  List<_RateRow> _rows = const [];
  _Dashboard? _dash;

  @override
  void initState() {
    super.initState();
    // hydrate from cache if available
    if (_cachedRows != null) {
      _rows = _cachedRows!;
      _loadingRates = false;
    }
    if (_cachedDash != null) {
      _dash = _cachedDash;
      _loadingDash = false;
    }
    if (_cachedError != null) _error = _cachedError;

    if (_cachedRows == null || _cachedDash == null) {
      _loadAll();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadAll() async {
    await Future.wait([
      _loadRates(),
      _loadDashboard(),
    ]);
  }

  Future<void> _loadRates() async {
    try {
      setState(() {
        _loadingRates = true;
        _error = null;
      });
      final metals = [
        'aluminum',
        'copper',
        'zinc',
        'lead',
        'nickel',
        'tin',
        'steel',
        'stainless-steel',
      ].join(',');
      final resp = await ApiClient().get<Map<String, dynamic>>(
        '/market/rates',
        query: {
          'metals': metals,
          'currency': 'INR',
          'unit': 'kg',
        },
      );
      final data = resp.data ?? {};
      final payload = data['data'] as Map<String, dynamic>?;
      final timestampStr = (payload?['timestamp'] as String?) ?? DateTime.now().toIso8601String();
      final dt = DateTime.tryParse(timestampStr) ?? DateTime.now();
      final datetimeHuman = '${dt.toLocal().toString().split(' ').first} / '
          '${TimeOfDay.fromDateTime(dt).format(context)} IST';
      final List<dynamic> rates = (payload?['rates'] as List?) ?? [];
      final rows = <_RateRow>[];
      for (final r in rates) {
        final m = r as Map<String, dynamic>;
        rows.add(_RateRow(
          item: (m['metal'] ?? '').toString(),
          lme: (num.tryParse((m['price'] ?? '').toString()) ?? (m['price'] is num ? m['price'] as num : 0)).toDouble(),
          usd: 0,
          datetime: datetimeHuman,
        ));
      }
      setState(() {
        _rows = rows;
      });
      _cachedRows = rows;
    } catch (e) {
      setState(() => _error = 'Failed to load market rates');
      _cachedError = _error;
    } finally {
      if (mounted) setState(() => _loadingRates = false);
    }
  }

  Future<void> _loadDashboard() async {
    try {
      setState(() => _loadingDash = true);
      final year = DateTime.now().year;
      final resp = await ApiClient().get<Map<String, dynamic>>(
        '/analytics/dashboard',
        query: {'year': year},
      );
      final data = resp.data ?? {};
      final payload = data['data'] as Map<String, dynamic>?;
      setState(() {
        _dash = _Dashboard.fromJson(payload ?? {});
      });
      _cachedDash = _dash;
    } catch (_) {
      // keep silent to not block UI
    } finally {
      if (mounted) setState(() => _loadingDash = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      isHomeHeader: false,
      currentIndex: 3,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top grid
            LayoutBuilder(builder: (context, constraints) {
              // Responsive: 3 columns wide if enough width
              final isWide = constraints.maxWidth > 900;
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  SizedBox(
                    width: isWide ? (constraints.maxWidth - 32) / 3 : constraints.maxWidth,
                    child: _MonthlyOrdersChart(dash: _dash, loading: _loadingDash),
                  ),
                  SizedBox(
                    width: isWide ? (constraints.maxWidth - 32) / 3 : constraints.maxWidth,
                    child: _StatCard(
                      title: 'Orders',
                      value: (_dash?.summary.totalOrders ?? 0).toString(),
                      icon: Icons.bar_chart,
                    ),
                  ),
                  SizedBox(
                    width: isWide ? (constraints.maxWidth - 32) / 3 : constraints.maxWidth,
                    child: _StatCard(
                      title: 'Tons delivered',
                      value: (_dash?.summary.totalTonsDelivered ?? 0).toStringAsFixed(3),
                      icon: Icons.trending_up,
                    ),
                  ),
                ],
              );
            }),
            const SizedBox(height: 16),
            // Category distribution (pie-like list)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Category Distribution', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    if ((_dash?.categories ?? []).isEmpty && _loadingDash)
                      const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()))
                    else
                      Column(
                        children: (_dash?.categories ?? []).take(6).map((c) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              children: [
                                Container(width: 10, height: 10, decoration: BoxDecoration(color: Colors.teal.shade400, shape: BoxShape.circle)),
                                const SizedBox(width: 8),
                                Expanded(child: Text('${c.category}')),
                                Text('${c.items}')
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Live Market Rates table
            Text('Live Market Rates', textAlign: TextAlign.center, style: TextStyle(color: Colors.teal.shade700, fontWeight: FontWeight.w700, fontSize: 18)),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
                    if (_loadingRates && _rows.isEmpty) const Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()),
                    if (_rows.isNotEmpty) _RatesTable(rows: _rows),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MonthlyOrdersChart extends StatelessWidget {
  final _Dashboard? dash;
  final bool loading;
  const _MonthlyOrdersChart({required this.dash, required this.loading});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Monthly Orders', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            if ((dash?.monthly ?? []).isEmpty && loading)
              const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()))
            else
              SizedBox(
                height: 140,
                child: CustomPaint(
                  painter: _OrdersLinePainter(dash?.monthly ?? const []),
                  child: Container(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _OrdersLinePainter extends CustomPainter {
  final List<_Monthly> data;
  _OrdersLinePainter(this.data);
  @override
  void paint(Canvas canvas, Size size) {
    final paintLine = Paint()
      ..color = const Color(0xFF267E82)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    final paintPoint = Paint()..color = const Color(0xFF267E82);
    if (data.isEmpty) return;
    final maxVal = data.map((e) => e.orders).fold<double>(1, (p, c) => c > p ? c : p);
    final double stepX = data.length > 1 ? size.width / (data.length - 1) : 0.0;
    final toY = (double v) => size.height - (v / maxVal) * (size.height * 0.8);
    final path = Path();
    for (int i = 0; i < data.length; i++) {
      final double x = i * stepX;
      final double y = toY(data[i].orders);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
      canvas.drawCircle(Offset(x, y), 3.0, paintPoint);
    }
    canvas.drawPath(path, paintLine);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  const _StatCard({required this.title, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 28, color: const Color(0xFF6c63ff)),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _RatesTable extends StatelessWidget {
  final List<_RateRow> rows;
  const _RatesTable({required this.rows});
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(columns: const [
        DataColumn(label: Text('S.No.')),
        DataColumn(label: Text('ITEM')),
        DataColumn(label: Text('SPOT (LME)')),
        DataColumn(label: Text('SPOT (USD)')),
        DataColumn(label: Text('DATE/TIME')),
        DataColumn(label: Text('')),
      ], rows: [
        for (int i = 0; i < rows.length; i++)
          DataRow(cells: [
            DataCell(Text('${i + 1}.')),
            DataCell(Text(rows[i].item)),
            DataCell(Text(rows[i].lme.toStringAsFixed(2))),
            DataCell(Text(rows[i].usd.toStringAsFixed(2))),
            DataCell(Text(rows[i].datetime)),
            const DataCell(Icon(Icons.history, color: Colors.blue)),
          ])
      ]),
    );
  }
}

class _RateRow {
  final String item;
  final double lme;
  final double usd;
  final String datetime;
  const _RateRow({required this.item, required this.lme, required this.usd, required this.datetime});
}

class _Dashboard {
  final _Summary summary;
  final List<_Monthly> monthly;
  final List<_Category> categories;
  const _Dashboard({required this.summary, required this.monthly, required this.categories});

  factory _Dashboard.fromJson(Map<String, dynamic> json) {
    final sum = json['summary'] as Map<String, dynamic>?;
    final mon = (json['monthly'] as List?) ?? const [];
    final cat = (json['categories'] as List?) ?? const [];
    return _Dashboard(
      summary: _Summary(
        totalOrders: (sum?['totalOrders'] as num?)?.toInt() ?? 0,
        totalItems: (sum?['totalItems'] as num?)?.toInt() ?? 0,
        totalTonsDelivered: (sum?['totalTonsDelivered'] as num?)?.toDouble() ?? 0,
      ),
      monthly: mon.map((e) => _Monthly.fromJson((e as Map).cast<String, dynamic>())).toList(),
      categories: cat.map((e) => _Category.fromJson((e as Map).cast<String, dynamic>())).toList(),
    );
  }
}

class _Summary {
  final int totalOrders;
  final int totalItems;
  final double totalTonsDelivered;
  const _Summary({required this.totalOrders, required this.totalItems, required this.totalTonsDelivered});
}

class _Monthly {
  final String month;
  final double orders;
  final double items;
  final double tonsDelivered;
  const _Monthly({required this.month, required this.orders, required this.items, required this.tonsDelivered});
  factory _Monthly.fromJson(Map<String, dynamic> json) => _Monthly(
        month: (json['month'] ?? '').toString(),
        orders: (json['orders'] as num?)?.toDouble() ?? 0,
        items: (json['items'] as num?)?.toDouble() ?? 0,
        tonsDelivered: (json['tonsDelivered'] as num?)?.toDouble() ?? 0,
      );
}

class _Category {
  final String category;
  final int items;
  const _Category({required this.category, required this.items});
  factory _Category.fromJson(Map<String, dynamic> json) => _Category(
        category: (json['category'] ?? '').toString(),
        items: (json['items'] as num?)?.toInt() ?? 0,
      );
}


