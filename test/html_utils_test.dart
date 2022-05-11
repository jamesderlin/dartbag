// Test with `dart test --platform={chrome,firefox}`

@TestOn('browser')

import 'dart:html' as html;

import 'package:dart_utils/html_utils.dart';
import 'package:test/test.dart';

void main() {
  test('Uses the correct test page', () {
    expect(html.document.title, 'HTML Utils Test');
  });

  group('TemporaryCssRule', () {
    const rgbRed = 'rgb(255, 0, 0)';
    const rgbGreen = 'rgb(0, 255, 0)';
    const rgbMiddleBlue = 'rgb(0, 0, 127)';
    const rgbBlack = 'rgb(0, 0, 0)';
    const rgbWhite = 'rgb(255, 255, 255)';

    late String selector;
    late String textColorRule;
    late String backgroundColorRule;
    late html.Element element;

    void initTest(String id) {
      const selectorBase = '#tempRule-test-';

      selector = '$selectorBase$id';
      textColorRule = '$selector { color: $rgbRed; }';
      backgroundColorRule = '$selector { background-color: $rgbGreen; }';
      element = html.querySelector(selector)!;
    }

    /// Addes the specified CSS rules in order.
    Iterable<TemporaryCssRule?> addRules(List<String> rules) sync* {
      for (var rule in rules) {
        yield TemporaryCssRule.add(rule);
      }
    }

    test('Added rules are applied', () {
      initTest('add');

      var style = element.getComputedStyle();
      expect(style.color, rgbBlack);
      expect(style.backgroundColor, rgbWhite);

      var iterator = addRules([textColorRule, backgroundColorRule]).iterator;

      expect(iterator.moveNext(), true);
      var addedTextColorRule = iterator.current;
      expect(addedTextColorRule, isNotNull);

      style = element.getComputedStyle();
      expect(style.color, rgbRed);
      expect(style.backgroundColor, rgbWhite);

      expect(iterator.moveNext(), true);
      var addedBackgroundColorRule = iterator.current;
      expect(addedBackgroundColorRule, isNotNull);

      style = element.getComputedStyle();
      expect(style.color, rgbRed);
      expect(style.backgroundColor, rgbGreen);
    });

    test('Removing rules in LIFO order works', () {
      initTest('lifo');

      var iterator = addRules([textColorRule, backgroundColorRule]).iterator;
      expect(iterator.moveNext(), true);
      var addedTextColorRule = iterator.current!;

      expect(iterator.moveNext(), true);
      var addedBackgroundColorRule = iterator.current!;

      expect(iterator.moveNext(), false);

      var style = element.getComputedStyle();
      expect(style.color, rgbRed);
      expect(style.backgroundColor, rgbGreen);

      expect(addedBackgroundColorRule.remove(), true);
      style = element.getComputedStyle();
      expect(style.color, rgbRed);
      expect(style.backgroundColor, rgbWhite);

      expect(addedTextColorRule.remove(), true);
      style = element.getComputedStyle();
      expect(style.color, rgbBlack);
      expect(style.backgroundColor, rgbWhite);
    });

    test('Removing rules in FIFO order works', () {
      initTest('fifo');

      var iterator = addRules([textColorRule, backgroundColorRule]).iterator;
      expect(iterator.moveNext(), true);
      var addedTextColorRule = iterator.current!;

      expect(iterator.moveNext(), true);
      var addedBackgroundColorRule = iterator.current!;

      var style = element.getComputedStyle();
      expect(style.color, rgbRed);
      expect(style.backgroundColor, rgbGreen);

      expect(addedTextColorRule.remove(), true);
      style = element.getComputedStyle();
      expect(style.color, rgbBlack);
      expect(style.backgroundColor, rgbGreen);

      expect(addedBackgroundColorRule.remove(), true);
      style = element.getComputedStyle();
      expect(style.color, rgbBlack);
      expect(style.backgroundColor, rgbWhite);
    });

    test('Overlapping rules work', () {
      initTest('overlap');

      var style = element.getComputedStyle();
      expect(style.color, rgbBlack);

      var rule1 = TemporaryCssRule.add('$selector { color: $rgbRed; }')!;
      style = element.getComputedStyle();
      expect(style.color, rgbRed);

      var rule2 = TemporaryCssRule.add('$selector { color: $rgbGreen; }')!;
      style = element.getComputedStyle();
      expect(style.color, rgbGreen);

      var rule3 = TemporaryCssRule.add('$selector { color: $rgbMiddleBlue; }')!;
      style = element.getComputedStyle();
      expect(style.color, rgbMiddleBlue);

      expect(rule3.remove(), true);
      style = element.getComputedStyle();
      expect(style.color, rgbGreen);

      expect(rule1.remove(), true);
      style = element.getComputedStyle();
      expect(style.color, rgbGreen);

      expect(rule2.remove(), true);
      style = element.getComputedStyle();
      expect(style.color, rgbBlack);
    });
  });
}
