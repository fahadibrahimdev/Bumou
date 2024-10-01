import 'package:app/Constants/color.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData lightTheme(BuildContext context) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          backgroundColor: AppColors.primary,
          textStyle: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.all(AppColors.primary),
        checkColor: MaterialStateProperty.all(AppColors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
      ),
      listTileTheme: ListTileThemeData(
        tileColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          textStyle: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.grey, width: 1),
          foregroundColor: AppColors.black,
          textStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: GoogleFonts.barlow().fontFamily,
          ),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          backgroundColor: AppColors.transparent,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(fontWeight: FontWeight.bold),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
      ),
      textTheme: GoogleFonts.barlowTextTheme().copyWith(
        displayLarge: Theme.of(context).textTheme.displayLarge!.copyWith(
              fontWeight: FontWeight.bold,
              fontFamily: GoogleFonts.barlow().fontFamily,
              color: AppColors.black,
            ),
        displayMedium: Theme.of(context).textTheme.displayMedium!.copyWith(
              fontWeight: FontWeight.bold,
              fontFamily: GoogleFonts.barlow().fontFamily,
              color: AppColors.black,
            ),
        displaySmall: Theme.of(context).textTheme.displaySmall!.copyWith(
              fontWeight: FontWeight.bold,
              fontFamily: GoogleFonts.barlow().fontFamily,
              color: AppColors.black,
            ),
        titleLarge: Theme.of(context).textTheme.titleLarge!.copyWith(
              fontWeight: FontWeight.w700,
              fontFamily: GoogleFonts.barlow().fontFamily,
              fontSize: 16,
              color: AppColors.black,
            ),
        titleMedium: Theme.of(context).textTheme.titleMedium!.copyWith(
              fontWeight: FontWeight.w600,
              fontFamily: GoogleFonts.barlow().fontFamily,
              color: AppColors.black,
            ),
        titleSmall: Theme.of(context).textTheme.titleSmall!.copyWith(
              fontWeight: FontWeight.w600,
              fontFamily: GoogleFonts.barlow().fontFamily,
              color: AppColors.black,
            ),
        headlineLarge: Theme.of(context).textTheme.headlineLarge!.copyWith(
              fontWeight: FontWeight.w600,
              fontFamily: GoogleFonts.barlow().fontFamily,
              color: AppColors.black,
            ),
        headlineMedium: Theme.of(context).textTheme.headlineMedium!.copyWith(
              fontWeight: FontWeight.w600,
              fontFamily: GoogleFonts.barlow().fontFamily,
              color: AppColors.black,
            ),
        headlineSmall: Theme.of(context).textTheme.headlineSmall!.copyWith(
              fontWeight: FontWeight.w900,
              fontFamily: GoogleFonts.poppins().fontFamily,
              color: AppColors.black,
            ),
        bodyLarge: Theme.of(context).textTheme.bodyLarge!.copyWith(
              fontFamily: GoogleFonts.barlow().fontFamily,
              fontSize: 16,
              color: AppColors.black,
            ),
        bodyMedium: Theme.of(context).textTheme.bodyMedium!.copyWith(
              fontFamily: GoogleFonts.barlow().fontFamily,
              color: AppColors.black,
            ),
        bodySmall: Theme.of(context).textTheme.bodySmall!.copyWith(
              color: AppColors.grey,
              fontFamily: GoogleFonts.barlow().fontFamily,
            ),
        labelLarge: Theme.of(context).textTheme.labelLarge!.copyWith(
              fontWeight: FontWeight.w600,
              fontFamily: GoogleFonts.barlow().fontFamily,
              color: AppColors.black,
            ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        floatingLabelBehavior: FloatingLabelBehavior.never,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.grey, width: 1),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        hintStyle: Theme.of(context)
            .textTheme
            .bodyMedium!
            .copyWith(color: AppColors.grey40),
      ),
    );
  }
}
