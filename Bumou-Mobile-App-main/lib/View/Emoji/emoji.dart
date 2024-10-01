import 'package:app/Constants/assets.dart';
import 'package:app/Constants/color.dart';
import 'package:app/View/Widget/emoji_dailouge.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class EmojiView extends StatefulWidget {
  const EmojiView({super.key});

  @override
  State<EmojiView> createState() => _EmojiViewState();
}

class _EmojiViewState extends State<EmojiView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('How do you feel?'.tr)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Center(
            child: SizedBox(
              width: MediaQuery.sizeOf(context).width * 0.85,
              height: MediaQuery.sizeOf(context).width,
              child: PieChart(
                PieChartData(
                  startDegreeOffset: -18,
                  sections: List.generate(AppAssets().mood.length, (index) {
                    String mood = AppAssets().mood[index]['mood'];
                    String image = AppAssets().mood[index]['image'];
                    return PieChartSectionData(
                      color: AppColors.transparent,
                      badgeWidget: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          InkWell(
                            onTap: () {
                              Emoji.showEmojiDailouge(
                                context,
                                index: index,
                                mood: AppAssets().mood[index],
                              );
                            },
                            child: SvgPicture.asset(image),
                          ),
                          const SizedBox(height: 10),
                          Text(mood.tr,
                              style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 10),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
