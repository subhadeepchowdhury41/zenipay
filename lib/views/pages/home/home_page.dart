import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zenipay/models/subscription.dart';
import 'package:zenipay/models/transaction.dart';
import 'package:zenipay/views/pages/payment/input_payments.dart';
import 'package:zenipay/views/pages/subscriptions/buy_subscription_page.dart';
import 'package:zenipay/views/pages/transactions/transaction_details.dart';
import 'package:zenipay/views/pages/transactions/transaction_user_page.dart';
import '../../../services/firestore_services.dart';
import '../../../utils/app_contants.dart';
import '../register/display_user_details.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  DateTime getDateTime(String date) {
    return DateTime.parse(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.send),
          onPressed: () {
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SendPayment()));
          },
        ),
        appBar: AppBar(
          title: const Text(
            'Dashboard',
            style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const UserDeatilsViewPage()));
                },
                icon: const Icon(Icons.person))
          ],
        ),
        body: Column(
          children: [
            StreamBuilder(
                stream: FirestoreServices.getUserDataLive(
                    FirebaseAuth.instance.currentUser!.uid),
                builder:
                    (context, AsyncSnapshot<Map<String, dynamic>?> snapshot) {
                  if (snapshot.hasData) {
                    return Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                          color: Colors.white12,
                          borderRadius: BorderRadius.circular(13)),
                      margin: const EdgeInsets.all(13),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(13),
                                child: Row(
                                  children: const [
                                    Icon(Icons.wallet),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      'My Balance',
                                      style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold),
                                    )
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(13),
                                child: Text(
                                  (snapshot.data?['balance'] ?? 0).toString(),
                                  style: const TextStyle(
                                      fontSize: 23,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return const Text('Some error occured');
                  } else {
                    return const CircularProgressIndicator();
                  }
                }),
            Container(
              margin: const EdgeInsets.only(left: 19, bottom: 13, top: 20),
              alignment: Alignment.centerLeft,
              child: Row(
                children: const [
                  Icon(Icons.monetization_on),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    'Subscriptions',
                    style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 13),
                decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(13)),
                child: StreamBuilder(
                  stream: FirestoreServices.getSubscriptions(),
                  builder: (context, sublist) {
                    if (!sublist.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: sublist.data!.length,
                        itemBuilder: (ctx, index) {
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 19),
                            child: InkWell(
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (_) => BuySubscriptionPage(
                                    id: int.parse(sublist.data?[index]['id']),
                                  subscription: Subscription.fromJson(
                                    name: sublist.data?[index]['name'] ?? '',
                                    desc: sublist.data?[index]['desc'] ?? '',
                                    plans: sublist.data?[index]['plans'] ?? []
                                  )
                                )));
                              },
                              child: GridTile(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircleAvatar(
                                      child: Image.network(
                                        sublist.data?[index]['iconUrl'],
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 8,
                                    ),
                                    Text(
                                      sublist.data?[index]['name'],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        });
                  },
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(left: 19, bottom: 13, top: 20),
              alignment: Alignment.centerLeft,
              child: Row(
                children: const [
                  Icon(Icons.people_alt),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    'People',
                    style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 13),
                decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(13)),
                child: StreamBuilder(
                    stream: FirestoreServices.getUsersByName(
                        FirebaseAuth.instance.currentUser!.phoneNumber!),
                    builder: (context, userList) {
                      if (!userList.hasData) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: userList.data!.length,
                          itemBuilder: (ctx, index) {
                            return Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 19),
                              child: InkWell(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (ctx) {
                                        return TransactionWithUser(
                                            recipentId: userList.data![index]
                                                ['id']);
                                      },
                                    ),
                                  );
                                },
                                child: GridTile(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CircleAvatar(
                                        child: Text((userList.data![index]
                                                ['name'])
                                            .toString()
                                            .substring(0, 1)),
                                      ),
                                      const SizedBox(
                                        height: 8,
                                      ),
                                      Text(
                                        '${userList.data![index]['name'].toString().substring(0, 10)}..',
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },);
                    },),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(left: 19, bottom: 13, top: 27),
              alignment: Alignment.centerLeft,
              child: Row(
                children: const [
                  Icon(Icons.payments),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    'Transactions',
                    style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 4,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: StreamBuilder(
                  stream: FirestoreServices.getTranscationsOfUser(
                      FirebaseAuth.instance.currentUser!.uid),
                  builder: (context,
                      AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                    if (snapshot.hasData) {
                      snapshot.data!.sort((a, b) {
                        DateTime first = DateTime.parse(a['data']['dateTime']);
                        DateTime second = DateTime.parse(b['data']['dateTime']);
                        return second.compareTo(first);
                      });
                      return ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: snapshot.data?.length,
                        itemBuilder: (context, index) {
                          DateTime dateTime = getDateTime(
                              snapshot.data?[index]['data']['dateTime']);

                          return Container(
                            padding: const EdgeInsets.symmetric(vertical: 7),
                            margin: const EdgeInsets.all(13),
                            decoration: BoxDecoration(
                                color: Colors.white12,
                                borderRadius: BorderRadius.circular(13)),
                            child: ListTile(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (ctx) {
                                      return TransactonDetailsScreen(
                                        transactionId: snapshot.data?[index]
                                            ['txId'],
                                        transactionType: snapshot.data?[index]
                                            ['data']['type'],
                                      );
                                    },
                                  ),
                                );
                              },
                              title: Text('${snapshot.data?[index]['txId']}'),
                              // leading: Text(snapshot.data?[index]['data']['type']),
                              subtitle: Text(snapshot.data?[index]['data']
                                  ['recipentName']),
                              trailing: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Text(
                                    '${snapshot.data?[index]['data']['type'] == TransactionType.outgoing.toString() ? '-' : ''}${(snapshot.data?[index]['data']['amount'] as double)}',
                                    style: TextStyle(
                                      color: snapshot.data?[index]['data']
                                                  ['type'] ==
                                              TransactionType.outgoing
                                                  .toString()
                                          ? Colors.red
                                          : Colors.green,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    '${dateTime.day}/${dateTime.month}/${dateTime.year}',
                                    style: TextStyle(
                                      color: text400,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    } else if (snapshot.hasData && snapshot.data!.isEmpty) {
                      return const Text('No transactions yet!');
                    } else {
                      return const CircularProgressIndicator();
                    }
                  },
                ),
              ),
            )
          ],
        ));
  }
}
