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

  ServiceMock.initInstance();

  String? one = '';
  String? two = '';

  test('Service mock creation', () {
    expect(0, ServiceMock.instance()?.size());
  });

  test('Service mock add', () {
    one = ServiceMock.instance()?.add();
    expect(1, ServiceMock.instance()?.size());

  });

  test('Service mock add', () {
    two = ServiceMock.instance()?.add();
    expect(2, ServiceMock.instance()?.size());
  });

  test('Service mock remove', () {
    ServiceMock.instance()?.remove(one);
    expect(1, ServiceMock.instance()?.size());
    ServiceMock.instance()?.remove(two);
    expect(0, ServiceMock.instance()?.size());
  });

}


