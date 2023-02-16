import 'package:flutter/material.dart';
import 'package:zenipay/models/subscription.dart';
import 'package:zenipay/services/notification_services.dart';

class BuySubscriptionPage extends StatefulWidget {
  final int id;
  const BuySubscriptionPage({super.key, required this.subscription, required this.id});
  final Subscription subscription;
  @override
  State<BuySubscriptionPage> createState() => _BuySubscriptionPageState();
}

class _BuySubscriptionPageState extends State<BuySubscriptionPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.subscription.name),
      ),
      body: Column(
        children: [
          ListView.builder(
            shrinkWrap: true,
            itemCount: widget.subscription.plans.length,
            itemBuilder: ((context, index) => ListTile(
              trailing: Text('₹ ${widget.subscription.plans[index]['pricing']}'),
              title: Text(widget.subscription.plans[index]['plan']),
              subtitle: Row(
                children: [
                  ElevatedButton(onPressed: () {
                    NotificationServices.showScheduledNotification(
                  // ignore: prefer_interpolation_to_compose_strings
                  id: widget.id, title: '${widget.subscription.name} ' +
                   widget.subscription.plans[index]['plan'], body: 'Your subscription started!');
                  }, child: const Text('Start')),
                  ElevatedButton(onPressed: () {
                    NotificationServices.stopScheduledNotification(
                  // ignore: prefer_interpolation_to_compose_strings
                  id: widget.id, title: '${widget.subscription.name} ' +
                   widget.subscription.plans[index]['plan'], body: 'Your subscription started!');
                  }, child: const Text('Stop'))
                ],
              ),
            )
          ))
        ],
      ),
    );
  }
}
