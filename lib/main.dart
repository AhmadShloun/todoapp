import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todoapp/layout/todo_layout.dart';
import 'package:todoapp/shared/bloc_observer.dart';
import 'package:todoapp/shared/cubit/cubit.dart';
import 'package:todoapp/shared/cubit/states.dart';
import 'package:todoapp/shared/network/local/cache_helper.dart';
import 'package:todoapp/shared/styles/themes.dart';

//ليتحركو كلون مع Single scroll
// shrinkWrap: true,
// physics: NeverScrollableScrollPhysics(),

void main() {
  // bool sys = true;

  BlocOverrides.runZoned(
    () async {
      //
      WidgetsFlutterBinding.ensureInitialized();

      bool isDark =  false;

      Widget widget;
      widget = HomeLayout();
      HttpOverrides.global = MyHttpOverrides();
      runApp(MyApp(
        isDark: isDark,
        startWidget: widget,
      ));
    },
    blocObserver: MyBlocObserver(),
  );
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class MyApp extends StatelessWidget {
  final bool isDark;
  final Widget startWidget;

  MyApp({
    required this.isDark,
    required this.startWidget,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AppCubit()
            ..changeAppMode(
              fromShared: isDark,
            ),
        ),
      ],
      child: BlocConsumer<AppCubit, AppStates>(
        listener: (context, state) {},
        builder: (context, state) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: AppCubit.get(context).isDark
                ? ThemeMode.light
                : ThemeMode.light,
            home: startWidget,
          );
        },
      ),
    );
  }
}
