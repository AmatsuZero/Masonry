//
//  UIView+MASAdditions.m
//  Masonry
//
//  Created by Jonas Budelmann on 20/07/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "View+MASAdditions.h"
#import <objc/runtime.h>

@implementation MAS_VIEW (MASAdditions)

- (NSArray *)mas_makeConstraints:(void(NS_NOESCAPE ^)(MASConstraintMaker *))block {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    MASConstraintMaker *constraintMaker = [[MASConstraintMaker alloc] initWithView:self];
    block(constraintMaker);
    return [constraintMaker install];
}

- (NSArray *)mas_updateConstraints:(void(NS_NOESCAPE ^)(MASConstraintMaker *))block {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    MASConstraintMaker *constraintMaker = [[MASConstraintMaker alloc] initWithView:self];
    constraintMaker.updateExisting = YES;
    block(constraintMaker);
    return [constraintMaker install];
}

- (NSArray *)mas_remakeConstraints:(void(NS_NOESCAPE ^)(MASConstraintMaker *make))block {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    MASConstraintMaker *constraintMaker = [[MASConstraintMaker alloc] initWithView:self];
    constraintMaker.removeExisting = YES;
    block(constraintMaker);
    return [constraintMaker install];
}

- (NSArray *)mas_prepareConstraints:(void(NS_NOESCAPE ^)(MASConstraintMaker *make))block {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    MASConstraintMaker *constraintMaker = [[MASConstraintMaker alloc] initWithView:self];
    block(constraintMaker);
    return [constraintMaker prepare];
}

#pragma mark - NSLayoutAttribute properties

- (MASViewAttribute *)mas_left {
    return [[MASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeLeft];
}

- (MASViewAttribute *)mas_top {
    return [[MASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeTop];
}

- (MASViewAttribute *)mas_right {
    return [[MASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeRight];
}

- (MASViewAttribute *)mas_bottom {
    return [[MASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeBottom];
}

- (MASViewAttribute *)mas_leading {
    return [[MASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeLeading];
}

- (MASViewAttribute *)mas_trailing {
    return [[MASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeTrailing];
}

- (MASViewAttribute *)mas_width {
    return [[MASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeWidth];
}

- (MASViewAttribute *)mas_height {
    return [[MASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeHeight];
}

- (MASViewAttribute *)mas_centerX {
    return [[MASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeCenterX];
}

- (MASViewAttribute *)mas_centerY {
    return [[MASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeCenterY];
}

- (MASViewAttribute *)mas_baseline {
    return [[MASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeBaseline];
}

- (MASViewAttribute *(^)(NSLayoutAttribute))mas_attribute
{
    return ^(NSLayoutAttribute attr) {
        return [[MASViewAttribute alloc] initWithView:self layoutAttribute:attr];
    };
}

- (MASViewAttribute *)mas_firstBaseline {
    return [[MASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeFirstBaseline];
}
- (MASViewAttribute *)mas_lastBaseline {
    return [[MASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeLastBaseline];
}

#if TARGET_OS_IPHONE || TARGET_OS_TV

- (MASViewAttribute *)mas_leftMargin {
    return [[MASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeLeftMargin];
}

- (MASViewAttribute *)mas_rightMargin {
    return [[MASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeRightMargin];
}

- (MASViewAttribute *)mas_topMargin {
    return [[MASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeTopMargin];
}

- (MASViewAttribute *)mas_bottomMargin {
    return [[MASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeBottomMargin];
}

- (MASViewAttribute *)mas_leadingMargin {
    return [[MASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeLeadingMargin];
}

- (MASViewAttribute *)mas_trailingMargin {
    return [[MASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeTrailingMargin];
}

- (MASViewAttribute *)mas_centerXWithinMargins {
    return [[MASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeCenterXWithinMargins];
}

- (MASViewAttribute *)mas_centerYWithinMargins {
    return [[MASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeCenterYWithinMargins];
}

- (MASViewAttribute *)mas_safeAreaLayoutGuide {
    return [[MASViewAttribute alloc] initWithView:self item:self.safeAreaLayoutGuide layoutAttribute:NSLayoutAttributeNotAnAttribute];
}

- (MASViewAttribute *)mas_safeAreaLayoutGuideLeading {
    return [[MASViewAttribute alloc] initWithView:self item:self.safeAreaLayoutGuide layoutAttribute:NSLayoutAttributeLeading];
}

- (MASViewAttribute *)mas_safeAreaLayoutGuideTrailing {
    return [[MASViewAttribute alloc] initWithView:self item:self.safeAreaLayoutGuide layoutAttribute:NSLayoutAttributeTrailing];
}

- (MASViewAttribute *)mas_safeAreaLayoutGuideLeft {
    return [[MASViewAttribute alloc] initWithView:self item:self.safeAreaLayoutGuide layoutAttribute:NSLayoutAttributeLeft];
}

- (MASViewAttribute *)mas_safeAreaLayoutGuideRight {
    return [[MASViewAttribute alloc] initWithView:self item:self.safeAreaLayoutGuide layoutAttribute:NSLayoutAttributeRight];
}

- (MASViewAttribute *)mas_safeAreaLayoutGuideTop {
    return [[MASViewAttribute alloc] initWithView:self item:self.safeAreaLayoutGuide layoutAttribute:NSLayoutAttributeTop];
}

- (MASViewAttribute *)mas_safeAreaLayoutGuideBottom {
    return [[MASViewAttribute alloc] initWithView:self item:self.safeAreaLayoutGuide layoutAttribute:NSLayoutAttributeBottom];
}

- (MASViewAttribute *)mas_safeAreaLayoutGuideWidth {
    return [[MASViewAttribute alloc] initWithView:self item:self.safeAreaLayoutGuide layoutAttribute:NSLayoutAttributeWidth];
}

- (MASViewAttribute *)mas_safeAreaLayoutGuideHeight {
    return [[MASViewAttribute alloc] initWithView:self item:self.safeAreaLayoutGuide layoutAttribute:NSLayoutAttributeHeight];
}

- (MASViewAttribute *)mas_safeAreaLayoutGuideCenterX {
    return [[MASViewAttribute alloc] initWithView:self item:self.safeAreaLayoutGuide layoutAttribute:NSLayoutAttributeCenterX];
}

- (MASViewAttribute *)mas_safeAreaLayoutGuideCenterY {
    return [[MASViewAttribute alloc] initWithView:self item:self.safeAreaLayoutGuide layoutAttribute:NSLayoutAttributeCenterY];
}

#endif

#pragma mark - associated properties

- (id)mas_key {
    return objc_getAssociatedObject(self, @selector(mas_key));
}

- (void)setMas_key:(id)key {
    objc_setAssociatedObject(self, @selector(mas_key), key, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - heirachy

- (instancetype)mas_closestCommonSuperview:(MAS_VIEW *)view {
    // Degenerate case: same view (e.g. make.width.equalTo(view.mas_width))
    if (self == view) return self;
    // Fast path O(1): siblings sharing a direct parent (most common in UI layout)
    if (self.superview && self.superview == view.superview) {
        return self.superview;
    }
    // Fast path O(1): direct parent-child relationship
    if (self.superview == view) return view;
    if (view.superview == self) return self;

    // General case: two-pointer O(n), inspired by linked-list intersection.
    // Each pointer traverses its own chain then restarts at the other view's
    // origin; they meet at the LCA after (depth_A + depth_B) steps.
    // Both reach nil simultaneously when there is no common ancestor.
    MAS_VIEW *a = self;
    MAS_VIEW *b = view;
    while (a != b) {
        a = (a == nil) ? view : a.superview;
        b = (b == nil) ? self : b.superview;
    }
    return a;
}

@end
