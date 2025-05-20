import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scoped_model/scoped_model.dart';

import 'state.dart';
import 'pages/all.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(ScopedModel<SambazaState>(
    model: SambazaState(),
    child: Sambaza(),
  ));
}

class Sambaza extends StatelessWidget {
  const Sambaza({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        initialRoute: RootPage.route,
        onUnknownRoute: UnknownPage.create,
        routes: <String, WidgetBuilder>{
          AppPage.route: AppPage.create,
          AssignSerialsPage.route: AssignSerialsPage.create,
          BranchDispatchPage.route: BranchDispatchPage.create,
          BranchInventoryPage.route: BranchInventoryPage.create,
          BranchLPOsPage.route: BranchLPOsPage.create,
          BranchOrdersPage.route: BranchOrdersPage.create,
          BranchStockTransfersPage.route: BranchStockTransfersPage.create,
          CreateOrderPage.route: CreateOrderPage.create,
          CreateSalePage.route: CreateSalePage.create,
          CreateServiceRequestPage.route: CreateServiceRequestPage.create,
          CreateStockTransferPage.route: CreateStockTransferPage.create,
          CreateTransactionPage.route: CreateTransactionPage.create,
          EditOrderPage.route: EditOrderPage.create,
          ForgotPasswordPage.route: ForgotPasswordPage.create,
          LPOItemsPage.route: LPOItemsPage.create,
          LoginPage.route: LoginPage.create,
          RootPage.route: RootPage.create,
          ServiceRequestsPage.route: ServiceRequestsPage.create,
        },
        theme: ThemeData(
          buttonTheme: ButtonThemeData(
            colorScheme: ColorScheme.fromSwatch(
              brightness: Brightness.dark,
              primarySwatch: Colors.cyan,
            ),
            disabledColor: Colors.grey,
          ),
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            foregroundColor: Colors.white,
          ),
          primaryTextTheme: Typography.whiteMountainView,
          scaffoldBackgroundColor: Colors.cyan[50],
          snackBarTheme: SnackBarThemeData(
            actionTextColor: Colors.white,
          ),
          appBarTheme: AppBarTheme(
            iconTheme: IconThemeData(
              color: Colors.white,
            ), systemOverlayStyle: SystemUiOverlayStyle.light,
          ), colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.cyan).copyWith(surface: Colors.cyan[50]),
        ),
        title: 'Sambaza',
      );
}
