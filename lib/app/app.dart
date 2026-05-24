import 'package:flutter/material.dart';

import 'routing/app_router.dart';
import 'theme.dart';

class PeraXApp extends StatelessWidget {
  const PeraXApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Pera-X',
      debugShowCheckedModeBanner: false,
      theme: PeraXTheme.darkTheme,
      routerConfig: appRouter,
    );
  }
}
