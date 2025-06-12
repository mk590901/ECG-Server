// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gui_model/main.dart';
import 'package:gui_model/mock/service_mock.dart';

void main() {

  ServiceAdapter.initInstance();

  String? one = '';
  String? two = '';

  test('Service mock creation', () {
    expect(0, ServiceAdapter.instance()?.size());
  });

  test('Service mock add', () {
    one = ServiceAdapter.instance()?.add();
    expect(1, ServiceAdapter.instance()?.size());

  });

  test('Service mock add', () {
    two = ServiceAdapter.instance()?.add();
    expect(2, ServiceAdapter.instance()?.size());
  });

  test('Service mock remove', () {
    ServiceAdapter.instance()?.remove(one);
    expect(1, ServiceAdapter.instance()?.size());
    ServiceAdapter.instance()?.remove(two);
    expect(0, ServiceAdapter.instance()?.size());
  });

}


