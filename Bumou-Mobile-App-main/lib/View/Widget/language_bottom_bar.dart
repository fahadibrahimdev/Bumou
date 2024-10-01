import 'package:app/Constants/color.dart';
import 'package:app/Controller/app_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LanguageChangeBar extends StatelessWidget {
  const LanguageChangeBar({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppController>(builder: (cntrlr) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(
          2,
          (index) => TextButton(
            onPressed: () async {
              cntrlr.selectedLanguage = index;
              cntrlr.updateLanguage(cntrlr.locale[index]['locale']);
            },
            child: Text(
              cntrlr.locale[index]['name'],
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: cntrlr.selectedLanguage == index
                        ? AppColors.primary
                        : AppColors.black,
                  ),
            ),
          ),
        ),
      );
    });
  }
}
