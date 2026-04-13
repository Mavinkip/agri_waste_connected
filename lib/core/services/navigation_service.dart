import 'package:flutter/material.dart';

class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  
  // Primary navigation methods
  static void pushNamed(String routeName, {Object? arguments}) {
    navigatorKey.currentState?.pushNamed(routeName, arguments: arguments);
  }
  
  static void pushReplacementNamed(String routeName, {Object? arguments}) {
    navigatorKey.currentState?.pushReplacementNamed(routeName, arguments: arguments);
  }
  
  static void pop() {
    if (navigatorKey.currentState?.canPop() == true) {
      navigatorKey.currentState?.pop();
    }
  }
  
  // Aliases for convenience (these match what's being called in the code)
  static void push(String routeName) {
    pushNamed(routeName);
  }
  
  static void pushReplacement(String routeName) {
    pushReplacementNamed(routeName);
  }
  
  static void replace(String routeName) {
    pushReplacementNamed(routeName);
  }
  
  static void go(String routeName) {
    pushReplacementNamed(routeName);
  }
  
  static void back() {
    pop();
  }
}
