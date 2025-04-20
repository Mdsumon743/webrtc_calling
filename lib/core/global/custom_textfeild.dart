import 'package:flutter/material.dart';

class CustomTextfeild extends StatelessWidget {
  final TextEditingController controller;
  final String lebel;
  const CustomTextfeild({
    super.key,
    required this.controller,
    required this.lebel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12,vertical: 5),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextFormField(
        controller: controller,
        cursorColor: Colors.green,
        decoration: InputDecoration(
          hintText: lebel,
          hintStyle: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: Colors.black,
          ),
          contentPadding: EdgeInsets.all(0),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
      ),
    );
  }
}
