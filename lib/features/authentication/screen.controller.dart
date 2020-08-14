import 'package:app/core/apis/general.api.dart';
import 'package:app/core/controllers/base.controller.dart';
import 'package:app/core/utils/logger.dart';
import 'package:app/core/managers/hive.manager.dart';
import 'package:app/features/general/custom_dialog.widget.dart';
import 'package:app/features/main/screen.controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

final logger = initLogger("AuthScreenController");

class AuthScreenController extends BaseController {
  // CONSTRUCTOR

  // VARIABLES
  final editingController = TextEditingController();

  // PROPERTIES
  final ready = false.obs;

  // GETTERS

  // INIT

  // FUNCTIONS

  void validate() async {
    this.busyState();
    final token = editingController.text;
    final valid = await GeneralAPI.to.isTokenValid(token);
    this.idleState();

    if (valid) {
      await HiveManager.setClientToken(token);
      MainScreenController.to.refresh();
      Get.back(result: true);

      Get.generalDialog(
        transitionDuration: const Duration(milliseconds: 200),
        pageBuilder: (_, __, ___) => CustomDialog(
          'Welcome',
          "You're now logged in! Enjoy!",
          image: Image.asset('assets/images/revenuecat.png', height: 100),
        ),
      );
    }
  }
}
