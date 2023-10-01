// ignore_for_file: constant_identifier_names

import 'package:conditional_builder/conditional_builder.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';
import 'package:todoapp/shared/cubit/cubit.dart';

//Button
Widget defaultButton({
  Color background = Colors.blue,
  double width = double.infinity,
  bool isUpperCase = true,
  @required String? text,
  @required Function? function,
}) =>
    Center(
      child: Container(
        width: width,
        height: 40.0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: background,
        ),
        child: MaterialButton(
          // height: 40.0,
          onPressed: () {
            function!();
          },
          child: Text(
            isUpperCase ? text!.toUpperCase() : text!,
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ),
    );

Widget defaultTextButton({
  @required Function()? function,
  @required String? text,
}) =>
    TextButton(
      onPressed: function,
      child: Text(text!.toUpperCase()),
    );

// Text Form Feiled
Widget defaultFormField({
  @required TextEditingController? controller,
  @required TextInputType? type,
  String? Function(String?)? onSubmitted,
  //@required String? validate,
  @required String? labelText,
  @required IconData? prefixIcon,
  IconData? suffixIcon,
  Function? suffixPress,
  bool onPassword = false,
  Function(String)? onChange,
  @required String? Function(String?)? validate,
}) =>
    TextFormField(
      controller: controller,
      keyboardType: type,
      obscureText: onPassword,
      onChanged: onChange,
      validator: validate,
      onFieldSubmitted: onSubmitted,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(
          prefixIcon,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            suffixIcon,
          ),
          onPressed: () {
            suffixPress!();
          },
        ),
        border: const OutlineInputBorder(),
      ),
    );


Widget buildTaskitem(Map model, context) => Dismissible(
      key: Key(model['id'].toString()),
      onDismissed: (direction) {
        AppCubit.get(context).deleteItem(id: model['id']);
      },
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.teal,
              radius: 40.0,
              child: Text(
                '${model['time']}',
              ),
            ),
            const SizedBox(
              width: 20.0,
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${model['title']}',
                    style: const TextStyle(
                      fontSize: 21.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  Text(
                    '${model['date']}',
                    style: const TextStyle(),
                  ),
                ],
              ),
            ),
            const SizedBox(
              width: 20.0,
            ),
            IconButton(
                onPressed: () {
                  AppCubit.get(context)
                      .updateItem(status: 'done', id: model['id']);
                },
                icon: const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                )),
            const SizedBox(
              width: 20.0,
            ),
            IconButton(
                onPressed: () {
                  AppCubit.get(context)
                      .updateItem(status: 'archive', id: model['id']);
                },
                icon: const Icon(
                  Icons.archive,
                  color: Colors.black38,
                )),
          ],
        ),
      ),
    );

Widget defaultFormField_Date({
  @required TextEditingController? controller,
  @required TextInputType? type,
  Function? onSubmitted,
  Function? onTap,
  @required String? validate,
  @required String? labelText,
  @required IconData? prefixIcon,
  IconData? suffixIcon,
  Function? suffixPress,
  bool onPassword = false,
}) {
  return TextFormField(
      controller: controller,
      keyboardType: type,
      obscureText: onPassword,
      onTap: () {
        onTap!();
      },
      onChanged: (val) {
        if (kDebugMode) {
          print(val);
        }
      },
      validator: (value) {
        if (value!.isEmpty) {
          return validate;
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(
          prefixIcon,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            suffixIcon,
          ),
          onPressed: () {
            suffixPress!();
          },
        ),
        border: const OutlineInputBorder(),
      ),
    );
}

//عرض رسالة بنص الصفحة
Widget tasksBuilder({
  required List<Map> task,
}) {
  return ConditionalBuilder(
    condition: task.isNotEmpty,
    builder: (context) => ListView.separated(
      itemBuilder: (context, index) => buildTaskitem(task[index], context),
      separatorBuilder: (context, index) => myDivider(),
      itemCount: task.length,
    ),
    fallback: (context) => Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(
            Icons.menu,
            size: 100.0,
            color: Colors.grey,
          ),
          Text(
            'No Tasks Yet , Pleas Add Some Tasks',
            style: TextStyle(
                fontSize: 16.0,
                color: Colors.grey,
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
    ),
  );
}


Widget myDivider() => Padding(
      padding: const EdgeInsetsDirectional.only(
        start: 20.0,
      ),
      child: Container(
        width: double.infinity,
        height: 1.0,
        color: Colors.grey[300],
      ),
    );


void navigateTo(context, widget) => Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => widget,
      ),
    );

void navigateAndFinish(context, widget) => Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => widget,
      ),
      //عايز الغي يلي فات او اخلي true
      (Route<dynamic> route) => false,
    );

void showToast({
  required String text,
  required ToastStates state,
}) =>
    Toast.show(
      text,
      duration: Toast.lengthLong,
      gravity: Toast.bottom,
      backgroundColor: chooseToastColor(state),
    );

enum ToastStates { SUCCESS, ERROR, WARNING }

Color chooseToastColor(ToastStates state) {
  Color color;
  switch (state) {
    case ToastStates.SUCCESS:
      color = Colors.green;
      break;

    case ToastStates.ERROR:
      color = Colors.red;
      break;

    case ToastStates.WARNING:
      color = Colors.amber;
      break;
  }
  return color;
}
