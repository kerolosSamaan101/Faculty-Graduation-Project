import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../../core/utils/colors_manager.dart';
import '../../../../../core/utils/images_manager.dart';

class MaterialItemWidget extends StatelessWidget {
  MaterialItemWidget({super.key, required this.courseName});
  String courseName;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      width: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: ColorsManager.darkGrey,
      ),
      child: Column(
        children: [
          Expanded(
            child: Center( // Center the image inside the container
              child: Container(
                height: 80, // Adjust as needed
                width: 80,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(ImagesManager.booksImg),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom:20,left: 5,right: 5),
            child: Text(
              courseName,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold,color: ColorsManager.backGroundColor),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
