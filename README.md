# Masonry [![CI](https://github.com/AmatsuZero/Masonry/actions/workflows/ci.yml/badge.svg)](https://github.com/AmatsuZero/Masonry/actions/workflows/ci.yml) [![codecov](https://codecov.io/gh/AmatsuZero/Masonry/branch/master/graph/badge.svg)](https://codecov.io/gh/AmatsuZero/Masonry) [![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage) ![Pod Version](https://img.shields.io/cocoapods/v/Masonry.svg?style=flat)

Masonry is a light-weight layout framework which wraps AutoLayout with a nicer syntax. Masonry has its own layout DSL which provides a chainable way of describing your NSLayoutConstraints which results in layout code that is more concise and readable.
Masonry supports iOS, Mac OS X and tvOS.

**Swift users:** Masonry now ships a native Swift DSL via the `MasonrySwift` module. See the [Swift Support](#swift-support) section below.

For examples take a look at the **Masonry iOS Examples** project in the Masonry workspace. You will need to run `pod install` after downloading.

## What's wrong with NSLayoutConstraints?

Under the hood Auto Layout is a powerful and flexible way of organising and laying out your views. However creating constraints from code is verbose and not very descriptive.
Imagine a simple example in which you want to have a view fill its superview but inset by 10 pixels on every side
```obj-c
UIView *superview = self.view;

UIView *view1 = [[UIView alloc] init];
view1.translatesAutoresizingMaskIntoConstraints = NO;
view1.backgroundColor = [UIColor greenColor];
[superview addSubview:view1];

UIEdgeInsets padding = UIEdgeInsetsMake(10, 10, 10, 10);

[superview addConstraints:@[

    //view1 constraints
    [NSLayoutConstraint constraintWithItem:view1
                                 attribute:NSLayoutAttributeTop
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:superview
                                 attribute:NSLayoutAttributeTop
                                multiplier:1.0
                                  constant:padding.top],

    [NSLayoutConstraint constraintWithItem:view1
                                 attribute:NSLayoutAttributeLeft
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:superview
                                 attribute:NSLayoutAttributeLeft
                                multiplier:1.0
                                  constant:padding.left],

    [NSLayoutConstraint constraintWithItem:view1
                                 attribute:NSLayoutAttributeBottom
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:superview
                                 attribute:NSLayoutAttributeBottom
                                multiplier:1.0
                                  constant:-padding.bottom],

    [NSLayoutConstraint constraintWithItem:view1
                                 attribute:NSLayoutAttributeRight
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:superview
                                 attribute:NSLayoutAttributeRight
                                multiplier:1
                                  constant:-padding.right],

 ]];
```
Even with such a simple example the code needed is quite verbose and quickly becomes unreadable when you have more than 2 or 3 views.
Another option is to use Visual Format Language (VFL), which is a bit less long winded.
However the ASCII type syntax has its own pitfalls and its also a bit harder to animate as `NSLayoutConstraint constraintsWithVisualFormat:` returns an array.

## Prepare to meet your Maker!

Heres the same constraints created using MASConstraintMaker

```obj-c
UIEdgeInsets padding = UIEdgeInsetsMake(10, 10, 10, 10);

[view1 mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.equalTo(superview.mas_top).with.offset(padding.top); //with is an optional semantic filler
    make.left.equalTo(superview.mas_left).with.offset(padding.left);
    make.bottom.equalTo(superview.mas_bottom).with.offset(-padding.bottom);
    make.right.equalTo(superview.mas_right).with.offset(-padding.right);
}];
```
Or even shorter

```obj-c
[view1 mas_makeConstraints:^(MASConstraintMaker *make) {
    make.edges.equalTo(superview).with.insets(padding);
}];
```

Also note in the first example we had to add the constraints to the superview `[superview addConstraints:...`.
Masonry however will automagically add constraints to the appropriate view.

Masonry will also call `view1.translatesAutoresizingMaskIntoConstraints = NO;` for you.

## Not all things are created equal

> `.equalTo` equivalent to **NSLayoutRelationEqual**

> `.lessThanOrEqualTo` equivalent to **NSLayoutRelationLessThanOrEqual**

> `.greaterThanOrEqualTo` equivalent to **NSLayoutRelationGreaterThanOrEqual**

These three equality constraints accept one argument which can be any of the following:

#### 1. MASViewAttribute

```obj-c
make.centerX.lessThanOrEqualTo(view2.mas_left);
```

MASViewAttribute           |  NSLayoutAttribute
-------------------------  |  --------------------------
view.mas_left              |  NSLayoutAttributeLeft
view.mas_right             |  NSLayoutAttributeRight
view.mas_top               |  NSLayoutAttributeTop
view.mas_bottom            |  NSLayoutAttributeBottom
view.mas_leading           |  NSLayoutAttributeLeading
view.mas_trailing          |  NSLayoutAttributeTrailing
view.mas_width             |  NSLayoutAttributeWidth
view.mas_height            |  NSLayoutAttributeHeight
view.mas_centerX           |  NSLayoutAttributeCenterX
view.mas_centerY           |  NSLayoutAttributeCenterY
view.mas_baseline          |  NSLayoutAttributeBaseline

#### 2. UIView/NSView

if you want view.left to be greater than or equal to label.left :
```obj-c
//these two constraints are exactly the same
make.left.greaterThanOrEqualTo(label);
make.left.greaterThanOrEqualTo(label.mas_left);
```

#### 3. NSNumber

Auto Layout allows width and height to be set to constant values.
if you want to set view to have a minimum and maximum width you could pass a number to the equality blocks:
```obj-c
//width >= 200 && width <= 400
make.width.greaterThanOrEqualTo(@200);
make.width.lessThanOrEqualTo(@400)
```

However Auto Layout does not allow alignment attributes such as left, right, centerY etc to be set to constant values.
So if you pass a NSNumber for these attributes Masonry will turn these into constraints relative to the view&rsquo;s superview ie:
```obj-c
//creates view.left = view.superview.left + 10
make.left.lessThanOrEqualTo(@10)
```

Instead of using NSNumber, you can use primitives and structs to build your constraints, like so:
```obj-c
make.top.mas_equalTo(42);
make.height.mas_equalTo(20);
make.size.mas_equalTo(CGSizeMake(50, 100));
make.edges.mas_equalTo(UIEdgeInsetsMake(10, 0, 10, 0));
make.left.mas_equalTo(view).mas_offset(UIEdgeInsetsMake(10, 0, 10, 0));
```

By default, macros which support [autoboxing](https://en.wikipedia.org/wiki/Autoboxing#Autoboxing) are prefixed with `mas_`. Unprefixed versions are available by defining `MAS_SHORTHAND_GLOBALS` before importing Masonry.

#### 4. NSArray

An array of a mixture of any of the previous types
```obj-c
make.height.equalTo(@[view1.mas_height, view2.mas_height]);
make.height.equalTo(@[view1, view2]);
make.left.equalTo(@[view1, @100, view3.right]);