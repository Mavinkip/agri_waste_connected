import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/farmer_bloc.dart';
import '../widgets/farmer_app_menu.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<FarmerBloc>().add(const LoadNotifications());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FarmerBloc, FarmerState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Notifications'),
            actions: const [FarmerAppMenu(currentScreen: 'notifications')],
          ),
          body: state is NotificationsLoaded
              ? state.notifications.isEmpty
                  ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.notifications_none, size: 64, color: Colors.grey),
                      SizedBox(height: 12),
                      Text('No notifications yet', style: TextStyle(color: Colors.grey, fontSize: 16)),
                      SizedBox(height: 4),
                      Text('Updates about your listings will appear here', style: TextStyle(color: Colors.grey, fontSize: 13)),
                    ]))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.notifications.length,
                      itemBuilder: (ctx, i) {
                        final n = state.notifications[i];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: n.isRead ? Colors.grey.shade100 : Colors.green.shade100,
                              child: Icon(n.isRead ? Icons.notifications_outlined : Icons.notifications, color: n.isRead ? Colors.grey : Colors.green),
                            ),
                            title: Text(n.title, style: TextStyle(fontWeight: n.isRead ? FontWeight.normal : FontWeight.bold)),
                            subtitle: Text(n.message, maxLines: 2, overflow: TextOverflow.ellipsis),
                            trailing: Text(_timeAgo(n.createdAt), style: const TextStyle(fontSize: 11, color: Colors.grey)),
                            onTap: () => context.read<FarmerBloc>().add(MarkNotificationRead(n.id)),
                          ),
                        );
                      },
                    )
              : state is FarmerLoading
                  ? const Center(child: CircularProgressIndicator())
                  : const Center(child: Text('Could not load notifications')),
        );
      },
    );
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
