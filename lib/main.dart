// @dart=2.9
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/cubit/albumart_cubit.dart';
import 'package:music_app/cubit/slider_cubit.dart';
import 'package:music_app/data/collection.dart';
import 'package:music_app/ui/screens/home_page.dart';
import 'package:music_app/ui/screens/splash_screen.dart';

import 'cubit/music_state_cubit.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<MusicStateCubit>(
          create: (context) => MusicStateCubit(),
        ),
        BlocProvider<SliderCubit>(
          create: (context) => SliderCubit(),
        ),
        BlocProvider<AlbumArtCubit>(
          create: (context) => AlbumArtCubit(),
        ),
        BlocProvider<CurrentSongCubit>(
          create: (context) => CurrentSongCubit(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        darkTheme: ThemeData.dark(),
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: FutureBuilder(
          future: Collection.getSongs(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return HomePage();
            } else {
              return SplashScreen();
            }
          },
        ),
      ),
    );
  }
}



//  flutter run --no-sound-null-safety --no-sound-null-safety  --split-per-abi
