import 'package:flutter/material.dart';
import '../components/app_scaffold.dart';
import '../services/api_client.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool _loading = true;
  String? _error;
  bool showUnread = false;
  String? selectedType;
  List<_NotificationItem> _notifications = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await ApiClient().get<List<dynamic>>('/notifications');
      final data = res.data ?? [];
      final list = data
          .whereType<Map<String, dynamic>>()
          .map((e) => _NotificationItem.fromJson(e))
          .toList();
      setState(() {
        _notifications = list;
      });
    } catch (e) {
      setState(() => _error = 'Failed to load notifications');
    } finally {
      setState(() => _loading = false);
    }
  }

  List<String> get _types => _notifications
      .map((n) => n.type ?? '')
      .where((t) => t.isNotEmpty)
      .toSet()
      .toList()
    ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

  List<_NotificationItem> get _filtered => _notifications.where((n) {
        final readFilter = showUnread ? !(n.isRead == true) : true;
        final typeFilter = selectedType != null ? n.type == selectedType : true;
        return readFilter && typeFilter;
      }).toList();

  String _formatTime(String? iso) {
    if (iso == null || iso.isEmpty) return '';
    final dt = DateTime.tryParse(iso);
    if (dt == null) return '';
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes} minute${diff.inMinutes == 1 ? '' : 's'} ago';
    if (diff.inHours < 24) return '${diff.inHours} hour${diff.inHours == 1 ? '' : 's'} ago';
    if (diff.inDays < 7) return '${diff.inDays} day${diff.inDays == 1 ? '' : 's'} ago';
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  String _typeIcon(String? type) {
    switch ((type ?? 'system').toLowerCase()) {
      case 'order':
        return '🛒';
      case 'payment':
        return '💰';
      case 'profile':
        return '👤';
      case 'security':
        return '🔒';
      case 'admin':
        return '👑';
      case 'announcement':
        return '📣';
      default:
        return '🔔';
    }
  }

  Future<void> _markAsRead(int id) async {
    try {
      await ApiClient().post('/notifications/$id/read');
      setState(() {
        final idx = _notifications.indexWhere((n) => n.id == id);
        if (idx != -1) _notifications[idx] = _notifications[idx].copyWith(isRead: true);
      });
    } catch (_) {}
  }

  Future<void> _markAllAsRead() async {
    try {
      await ApiClient().post('/notifications/read-all');
      setState(() {
        _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
      });
    } catch (_) {}
  }

  Future<void> _delete(int id) async {
    try {
      await ApiClient().post('/notifications/$id/delete');
      setState(() {
        _notifications.removeWhere((n) => n.id == id);
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      isHomeHeader: false,
      currentIndex: 2,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Notifications",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isNarrow = constraints.maxWidth < 380;
                  return Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Row(children: [
                        _buildTabButton("All", !showUnread),
                        const SizedBox(width: 12),
                        _buildTabButton("Unread", showUnread),
                      ]),
                      if (_types.isNotEmpty)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ConstrainedBox(
                              constraints: BoxConstraints(maxWidth: isNarrow ? 180 : 240),
                              child: DropdownButton<String>(
                                value: selectedType,
                                hint: const Text('All types'),
                                isExpanded: false,
                                items: [
                                  const DropdownMenuItem<String>(value: null, child: Text('All types')),
                                  ..._types.map((t) => DropdownMenuItem<String>(value: t, child: Text(t))).toList(),
                                ],
                                onChanged: (val) => setState(() => selectedType = val),
                              ),
                            ),
                            const SizedBox(width: 8),
                            OutlinedButton.icon(
                              onPressed: _markAllAsRead,
                              icon: const Icon(Icons.done_all, size: 16),
                              label: const Text('Mark all read'),
                            )
                          ],
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              if (_loading)
                const Expanded(child: Center(child: CircularProgressIndicator()))
              else if (_error != null)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_error!),
                        const SizedBox(height: 8),
                        OutlinedButton(onPressed: _load, child: const Text('Retry')),
                      ],
                    ),
                  ),
                )
              else if (_filtered.isEmpty)
                const Expanded(
                  child: Center(child: Text('No notifications found')),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: _filtered.length,
                    itemBuilder: (context, i) {
                      final n = _filtered[i];
                      final isUnread = n.isRead != true;
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFAFBFA),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isUnread ? const Color(0xFF4b5e5b) : Colors.grey.shade300),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_typeIcon(n.type), style: const TextStyle(fontSize: 20)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(n.title ?? 'Notification', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)),
                                      ),
                                      Text(_formatTime(n.createdAt), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                    ],
                                  ),
                                  if (n.message != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(n.message!, maxLines: 3, overflow: TextOverflow.ellipsis),
                                    ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      if (isUnread)
                                        TextButton.icon(
                                          onPressed: () => _markAsRead(n.id),
                                          icon: const Icon(Icons.check, size: 14, color: Color(0xFF4b5e5b)),
                                          label: const Text('Mark read', style: TextStyle(color: Color(0xFF4b5e5b))),
                                        ),
                                      TextButton.icon(
                                        onPressed: () => _delete(n.id),
                                        icon: const Icon(Icons.delete_outline, size: 14, color: Colors.red),
                                        label: const Text('Delete', style: TextStyle(color: Colors.red)),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton(String text, bool active) {
    return GestureDetector(
      onTap: () {
        setState(() {
          showUnread = text == "Unread";
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: active ? Colors.teal.shade700 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: active ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

}

class _NotificationItem {
  final int id;
  final String? title;
  final String? message;
  final bool? isRead;
  final String? type;
  final String? createdAt;
  const _NotificationItem({
    required this.id,
    this.title,
    this.message,
    this.isRead,
    this.type,
    this.createdAt,
  });

  factory _NotificationItem.fromJson(Map<String, dynamic> json) {
    return _NotificationItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title']?.toString(),
      message: json['message']?.toString(),
      isRead: (json['is_read'] ?? json['read']) as bool?,
      type: json['type']?.toString(),
      createdAt: json['created_at']?.toString() ?? json['createdAt']?.toString(),
    );
  }

  _NotificationItem copyWith({
    String? title,
    String? message,
    bool? isRead,
    String? type,
    String? createdAt,
  }) {
    return _NotificationItem(
      id: id,
      title: title ?? this.title,
      message: message ?? this.message,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
