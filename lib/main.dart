import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zenipay/firebase_options.dart';
import 'package:zenipay/services/auth_repository.dart';
import 'package:zenipay/services/notification_services.dart';
import 'package:zenipay/views/pages/login/bloc/phone_auth_bloc.dart';
import 'package:zenipay/views/pages/onboarding/onboarding_page.dart';

Future<void> main() async {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
    systemNavigationBarColor: Colors.black,
    statusBarColor: Colors.black
  ));
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  NotificationServices.initialize();
  runApp(ProviderScope(
      child: MultiRepositoryProvider(
    providers: [
      RepositoryProvider(create: (context) => AuthRepository()),
    ],
    child: MultiBlocProvider(providers: [
      BlocProvider(
          create: (context) =>
              PhoneAuthBloc(authRepository: context.read<AuthRepository>()))
    ], child: const Zenipay()),
  )));
}

class Zenipay extends ConsumerStatefulWidget {
  const Zenipay({super.key});
  @override
  ConsumerState<Zenipay> createState() => _ZenipayState();
}

class _ZenipayState extends ConsumerState<Zenipay> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zenipay',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true),
      home: const OnBoardingPage(),
    );
  }
}
