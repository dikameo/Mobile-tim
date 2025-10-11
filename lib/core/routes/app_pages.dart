import 'package:get/get.dart';
import 'package:mobile_tim/features/coffee_catalog/catalog_withlayoutbuilder.dart';
import '/features/coffee_catalog/catalog_mediaquery.dart'; // Sesuaikan path jika perlu

import 'app_routes.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.catalogWithMediaquery,
      page: () => const CoffeeCatalogWithMediaQuery(),
      transition: Transition.fade,
    ),
    GetPage(
      name: AppRoutes.catalogWithLayoutBuilder,
      page: () => const CoffeeCatalogWithLayoutBuilder(),
      transition: Transition.fade,
    ),
  ];
}
