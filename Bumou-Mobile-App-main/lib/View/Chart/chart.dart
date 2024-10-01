import 'package:app/Constants/color.dart';
import 'package:app/Controller/mood_controller.dart';
import 'package:app/Model/mood.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../Constants/assets.dart';

class ChartView extends StatefulWidget {
  const ChartView({super.key});

  @override
  State<ChartView> createState() => _ChartViewState();
}

class _ChartViewState extends State<ChartView> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<MoodController>(builder: (cntrlr) {
      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: RichText(
            text: TextSpan(
                style: Theme.of(context).textTheme.headlineSmall,
                children: [
                  TextSpan(text: 'Your '.tr),
                  TextSpan(
                      text: 'MOODWEEK'.tr,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall!
                          .copyWith(color: AppColors.primary)),
                ]),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(50),
            child: Row(
              children: List.generate(3, (index) {
                return Expanded(
                  child: InkWell(
                    onTap: () {
                      cntrlr.selectedIndex = index;
                      cntrlr.update();
                      cntrlr.onTap(index);
                    },
                    child: Container(
                      height: 50,
                      margin: const EdgeInsets.all(5),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: cntrlr.selectedIndex == index
                            ? AppColors.primary
                            : AppColors.white,
                      ),
                      child: Text(
                        cntrlr.heading[index].tr,
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              fontWeight: FontWeight.w700,
                              color: cntrlr.selectedIndex == index
                                  ? AppColors.white
                                  : AppColors.black,
                            ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(
                    left: MediaQuery.sizeOf(context).width * 0.07),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(AppAssets().mood.length, (index) {
                    String mood = AppAssets().mood[index]['mood'];
                    String image = AppAssets().mood[index]['image'];
                    return Column(
                      children: [
                        SvgPicture.asset(image, width: 50, height: 50),
                        const SizedBox(height: 10),
                        Text(mood.tr,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 10))
                      ],
                    );
                  }),
                ),
              ),
              // const SizedBox(height: 30),
              cntrlr.isLoadingMood
                  ? const Center(child: CircularProgressIndicator())
                  : cntrlr.moodErrorMsg != null
                      ? Center(child: Text(cntrlr.moodErrorMsg!))
                      : cntrlr.mood.isEmpty
                          ? const Center(child: SfCartesianChart())
                          : SfCartesianChart(
                              primaryXAxis: const CategoryAxis(
                                  majorGridLines: MajorGridLines(width: 0)),
                              primaryYAxis: NumericAxis(
                                maximum: 100,
                                axisLine: const AxisLine(width: 0),
                                majorTickLines: const MajorTickLines(size: 0),
                                numberFormat: NumberFormat.decimalPatternDigits(
                                    decimalDigits: 0),
                                labelFormat: '{value} %',
                              ),
                              series: <CartesianSeries>[
                                ColumnSeries<Mood, String>(
                                  dataSource: MoodController.to.mood,
                                  xValueMapper: (Mood mood, _) =>
                                      '${mood.mood}'.tr,
                                  yValueMapper: (Mood mood, _) =>
                                      mood.percentage,
                                  dataLabelSettings: const DataLabelSettings(
                                    labelPosition:
                                        ChartDataLabelPosition.outside,
                                    isVisible: true,
                                    labelAlignment: ChartDataLabelAlignment.top,
                                    textStyle: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  color: AppColors.primary,
                                )
                              ],
                            ),
              const SizedBox(height: 30),
              SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.2,
                child: Center(
                  child: AutoSizeText(
                    "Visible psychological pulsation".tr,
                    maxLines: 1,
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
