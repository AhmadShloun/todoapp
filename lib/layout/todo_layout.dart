// ignore_for_file: must_be_immutable, non_constant_identifier_names

import 'package:conditional_builder/conditional_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:todoapp/shared/components/components.dart';
import 'package:todoapp/shared/cubit/cubit.dart';
import 'package:todoapp/shared/cubit/states.dart';

class HomeLayout extends StatelessWidget {
  HomeLayout({super.key});

  var KeyScaffold = GlobalKey<ScaffoldState>();
  var keyform = GlobalKey<FormState>();

  var titleController = TextEditingController();
  var timeController = TextEditingController();
  var dateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => AppCubit()..Create_DB(),
      child: BlocConsumer<AppCubit, AppStates>(
        listener: (BuildContext context, AppStates state) {
          if (state is AppInsertDBState) {
            Navigator.pop(context);
          }
        },
        builder: (BuildContext context, AppStates state) {
          AppCubit cubit = AppCubit.get(context);
          return Scaffold(
            key: KeyScaffold,
            appBar: AppBar(
              backgroundColor: Colors.teal,
              title: Text(
                cubit.title[cubit.currentIndex],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            body: ConditionalBuilder(
              //state حاجة تانية غية loding
              condition: state is! AppGetDBLodingState,
              builder: (context) => cubit.screen[cubit.currentIndex],
              fallback: (context) =>
                  const Center(child: CircularProgressIndicator()),
            ),
            floatingActionButton: FloatingActionButton(
              backgroundColor: Colors.teal,
              onPressed: () {
                if (cubit.isBottomSheetShow) {
                  if (keyform.currentState!.validate()) {
                    cubit.Inser_DB(
                        title: titleController.text,
                        date: dateController.text,
                        time: timeController.text);
                  }
                } else {
                  KeyScaffold.currentState!
                      .showBottomSheet(
                        (context) => Container(
                          color: Colors.white,
                          padding: const EdgeInsets.all(
                            20.0,
                          ),
                          child: Form(
                            key: keyform,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                defaultFormField(
                                  controller: titleController,
                                  type: TextInputType.text,
                                  validate: (value) {
                                    if (value!.isEmpty) {
                                      return 'title is Empty ..!';
                                    }
                                    return null;
                                  },
                                  labelText: 'Title Text',
                                  prefixIcon: Icons.title,
                                ),
                                const SizedBox(
                                  height: 15.0,
                                ),
                                defaultFormField_Date(
                                  controller: timeController,
                                  type: TextInputType.datetime,
                                  validate: 'time is Empty ..!',
                                  labelText: 'Time Text',
                                  prefixIcon: Icons.access_time,
                                  onTap: () {
                                    showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay.now(),
                                    ).then((value) {
                                      timeController.text =
                                          value!.format(context);
                                    });
                                  },
                                ),
                                const SizedBox(
                                  height: 15.0,
                                ),
                                defaultFormField_Date(
                                  controller: dateController,
                                  type: TextInputType.datetime,
                                  validate: 'Date is Empty ..!',
                                  labelText: 'Date Text',
                                  onTap: () {
                                    showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime.now(),
                                      lastDate: DateTime.parse('2050-12-31'),
                                    ).then((value) {
                                      dateController.text =
                                          DateFormat.yMMMd().format(value!);
                                    });
                                  },
                                  prefixIcon: Icons.calendar_today,
                                ),
                              ],
                            ),
                          ),
                        ),
                        elevation: 20.0,
                      )
                      .closed
                      .then((value) {
                    cubit.changeBottomSheetState(
                        isShow: false, icon: Icons.edit);
                  });
                  cubit.changeBottomSheetState(isShow: true, icon: Icons.add);
                }
              },
              child: Icon(
                cubit.fabIcon,
              ),
            ),
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              selectedItemColor: Colors.teal,
              // backgroundColor: Colors.pink,
              currentIndex: cubit.currentIndex,
              onTap: (index) {
                cubit.changeIndex(index);
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.menu,
                  ),

                  label: 'Task',

                  //backgroundColor: Colors.pink,
                ),
                BottomNavigationBarItem(
                    icon: Icon(
                      Icons.check_circle_outline,
                    ),
                    label: 'Done'),
                BottomNavigationBarItem(
                  //backgroundColor: Colors.red,
                  icon: Icon(
                    Icons.archive_outlined,
                  ),
                  label: 'archived',
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
