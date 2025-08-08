import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../core/theme/color_data.dart';
import '../bloc/notification_bloc.dart';
import '../bloc/notification_event.dart';
import '../bloc/notification_state.dart';
import '../model/notification_model.dart';

class NotificationListScreen extends StatefulWidget {
  const NotificationListScreen({Key? key}) : super(key: key);

  @override
  State<NotificationListScreen> createState() => _NotificationListScreenState();
}

class _NotificationListScreenState extends State<NotificationListScreen>
    with TickerProviderStateMixin {
  late AnimationController _refreshIconController;
  int? expandedIndex; // <-- ADD THIS HERE

  @override
  void initState() {
    super.initState();
    _refreshIconController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    // Fetch notifications when screen opens
    context.read<NotificationBloc>().add(FetchNotificationList());
  }

  @override
  void dispose() {
    _refreshIconController.dispose();
    super.dispose();
  }

  Future<void> _refreshNotifications() async {
    _refreshIconController.repeat();
    context.read<NotificationBloc>().add(FetchNotificationList());
    await Future.delayed(const Duration(seconds: 1));
    _refreshIconController.stop();
    _refreshIconController.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(
            Icons.arrow_back_ios,
            color: primaryColor,
          ), // or your custom `icon`
        ),
        title: Text(
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        actions: [
          RotationTransition(
            turns: Tween(begin: 0.0, end: 1.0).animate(_refreshIconController),
            child: IconButton(
              icon: Icon(Icons.refresh, color: primaryColor),
              onPressed: _refreshNotifications,
            ),
          ),
        ],
      ),
      body: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {
          if (state is NotificationInitial) {
            context.read<NotificationBloc>().add(FetchNotificationList());
            return const Center(child: CircularProgressIndicator());
          } else if (state is NotificationLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is NotificationLoaded) {
            return _buildNotificationsList(state.notifications);
          } else if (state is NotificationError) {
            return _buildErrorView(state.message);
          }
          return const Center(child: Text('Unknown state'));
        },
      ),
    );
  }

  Widget _buildNotificationsList(List<NotificationModel> notifications) {
    if (notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_off_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No notifications yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Pull down to refresh',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshNotifications,
      color: primaryColor,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 12),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          // return _buildNotificationCard(notification);
          return _buildNotificationCard(notification, index);
        },
      ),
    );
  }

  // Widget _buildNotificationCard(NotificationModel notification) {
  //   return Container(
  //     margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(12),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.grey.withOpacity(0.1),
  //           spreadRadius: 1,
  //           blurRadius: 5,
  //           offset: const Offset(0, 2),
  //         ),
  //       ],
  //     ),
  //     child: ClipRRect(
  //       borderRadius: BorderRadius.circular(12),
  //       child: Material(
  //         color: Colors.transparent,
  //         child: InkWell(
  //           onTap: null,
  //           child: Padding(
  //             padding: const EdgeInsets.all(16),
  //             child: Row(
  //               crossAxisAlignment: CrossAxisAlignment.center,
  //               children: [
  //                 Container(
  //                   width: 50,
  //                   height: 50,
  //                   decoration: BoxDecoration(
  //                     color: primaryColor.withOpacity(0.1),
  //                     borderRadius: BorderRadius.circular(12),
  //                   ),
  //                   child: Icon(
  //                     Icons.notifications_active,
  //                     color: primaryColor,
  //                     size: 24,
  //                   ),
  //                 ),
  //                 const SizedBox(width: 16),
  //                 Expanded(
  //                   child: Column(
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     children: [
  //                       Row(
  //                         children: [
  //                           Expanded(
  //                             child: Text(
  //                               notification.title,
  //                               style: TextStyle(
  //                                 fontWeight: FontWeight.bold,
  //                                 fontSize: 16,
  //                               ),
  //                               maxLines: 1,
  //                               overflow: TextOverflow.ellipsis,
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                       const SizedBox(height: 2),
  //                       Text(
  //                         notification.body,
  //                         style: TextStyle(
  //                           color: Colors.grey[700],
  //                           fontSize: 14,
  //                         ),
  //                         maxLines: 2,
  //                         overflow: TextOverflow.ellipsis,
  //                       ),
  //                       if (notification.sentTime != null) ...[
  //                         const SizedBox(height: 8),
  //                         Text(
  //                           timeago.format(notification.sentTime!),
  //                           style: TextStyle(
  //                             fontSize: 12,
  //                             color: Colors.grey[500],
  //                           ),
  //                         ),
  //                       ]
  //                     ],
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget _buildNotificationCard(NotificationModel notification, int index) {
    final isExpanded = expandedIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          expandedIndex = isExpanded ? null : index;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Top Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.notifications_active,
                      color: primaryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notification.title,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          notification.body,
                          style:
                              TextStyle(color: Colors.grey[700], fontSize: 14),
                        ),
                        if (notification.data != null &&
                            notification.data!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Data: ${notification.data}',
                            style: TextStyle(
                                color: Colors.grey[500], fontSize: 13),
                          ),
                        ],
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            if (notification.sentTime != null)
                              Text(
                                'Sent: ${timeago.format(notification.sentTime!)}',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey[500]),
                              ),
                            if (notification.createdAt != null) ...[
                              const SizedBox(width: 8),
                              Text(
                                'Created: ${timeago.format(notification.createdAt!)}',
                                style: TextStyle(
                                    fontSize: 10, color: Colors.grey[400]),
                              ),
                            ]
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              /// Expanded image below
              if (isExpanded &&
                  notification.image != null &&
                  notification.image!.isNotEmpty) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    notification.image!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 180,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorView(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 60,
            color: Colors.red[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Oops! Something went wrong',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _refreshNotifications,
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
