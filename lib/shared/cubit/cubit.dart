import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todoapp/modules/archived_task.dart';
import 'package:todoapp/modules/done_task.dart';
import 'package:todoapp/modules/new_task.dart';
import 'package:todoapp/shared/cubit/states.dart';
import 'package:todoapp/shared/network/local/cache_helper.dart';

class AppCubit extends Cubit<AppStates> {
  AppCubit() : super(AppInitialState());

  //object AppCubit
  static AppCubit get(context) => BlocProvider.of(context);

  int currentIndex = 0;
  Database? database;

  //Show item Task
  List<Map> newtask = [];
  List<Map> donetask = [];
  List<Map> archivetask = [];

  bool isBottomSheetShow = false;
  IconData fabIcon = Icons.edit;

  List<Widget> screen = [
    NewTask(),
    DoneTask(),
    ArchivedTask(),
  ];

  //title App bar
  List<String> title = [
    'Task App',
    'Done Task ',
    'Archived task',
  ];

  void changeIndex(int index) {
    currentIndex = index;
    emit(AppChangeBottomNavBarState());
  }

  void Create_DB() {
    openDatabase(
      'todo.db',
      version: 1,
      onCreate: (database, version) {
        print('DB create');
        database
            .execute(
                'CREATE TABLE Test (id INTEGER PRIMARY KEY, title TEXT , date TEXT , time TEXT , status TEXT)')
            .then((value) {
          print('table create');
        }).catchError((error) {
          print('error create');
        });
      },
      onOpen: (database) {
        Get_DB(database);
        print('DB opened');
      },
    ).then((value) {
      database = value;
      emit(AppCreateDBState());
    });
  }

  Inser_DB({
    @required String? title,
    @required String? date,
    @required String? time,
  }) async {
    await database!.transaction((txn) async {
      txn
          .rawInsert(
              'INSERT INTO Test (title , date , time ,status) VALUES("${title}","${date}","${time}","new")')
          .then((value) {
        print('$value insert successfully');
        emit(AppInsertDBState());
        Get_DB(database);
      }).catchError((error) {
        print(error.toString());
      });
    });
  }

  void Get_DB(database) async {
    emit(AppGetDBLodingState());
    database!.rawQuery('SELECT * FROM Test').then((value) {
      print(value);
      newtask = [];
      donetask = [];
      archivetask = [];
      // print(value['status']);
      value.forEach((element) {
        if (element['status'] == 'new')
          newtask.add(element);
        else if (element['status'] == 'done')
          donetask.add(element);
        else
          archivetask.add(element);
        // newtask = value;
      });

      emit(AppGetDBState());
    });
  }

  void changeBottomSheetState({
    @required bool? isShow,
    @required IconData? icon,
  }) {
    isBottomSheetShow = isShow!;
    fabIcon = icon!;

    emit(AppChangeBottomSheetState());
  }

  void updateItem({
    @required String? status,
    @required int? id,
  }) async {
    database!.rawUpdate('UPDATE Test SET status = ? WHERE id = ?',
        ['${status}', id]).then((value) {
      Get_DB(database);
      emit(AppUpdateDBState());
    });
  }

  void deleteItem({
    @required int? id,
  }) async {
    database!.rawDelete('DELETE FROM Test WHERE id = ?', [id]).then((value) {
      Get_DB(database);
      emit(AppDeleteDBState());
    });
  }

  bool isDark = false;

  void changeAppMode({bool? fromShared}) {
    if (fromShared != null) {
      isDark = fromShared;
    }
    else
      isDark = !isDark;
    CacheHelper.putbool(key: 'isDark', value: isDark).then((value) {
      emit(AppChangeMode());
    });
  }
}
