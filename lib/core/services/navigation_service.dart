import 'package:flutter/material.dart';

abstract class NavigationService {
  GlobalKey<NavigatorState> get navigatorKey;

  Future<dynamic> pushNamed(String routeName, {Object? arguments});
  Future<dynamic> pushNamedAndRemoveUntil(
      String routeName, RoutePredicate predicate,
      {Object? arguments});
}

class NavigationServiceImpl extends NavigationService {
  final GlobalKey<NavigatorState> _navigationKey;

  NavigationServiceImpl() : _navigationKey = GlobalKey<NavigatorState>();

  @override
  GlobalKey<NavigatorState> get navigatorKey => _navigationKey;

  @override
  Future<dynamic> pushNamed(String routeName, {Object? arguments}) {
    final currentContext = _navigationKey.currentContext;
    if (currentContext != null) {
      final currentRoute = ModalRoute.of(currentContext)?.settings.name;
      if (routeName == currentRoute) {
        // Đẩy thay thế màn hình hiện tại để reload và không bị nested với cùng 1 màn hình.
        return navigatorKey.currentState!
            .pushReplacementNamed(routeName, arguments: arguments);
      }
    }
    return navigatorKey.currentState!
        .pushNamed(routeName, arguments: arguments);
  }

  @override
  Future pushNamedAndRemoveUntil(String routeName, RoutePredicate predicate,
      {Object? arguments}) {
    return navigatorKey.currentState!.pushNamedAndRemoveUntil(
      routeName,
      predicate,
      arguments: arguments,
    );
  }
}
