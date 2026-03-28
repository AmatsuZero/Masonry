//
//  MASConstraintMaker.m
//  Masonry
//
//  Created by Jonas Budelmann on 20/07/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "MASConstraintMaker.h"
#import "MASViewConstraint.h"
#import "MASCompositeConstraint.h"
#import "MASConstraint+Private.h"
#import "MASViewAttribute.h"
#import "View+MASAdditions.h"

@interface MASConstraintMaker () <MASConstraintDelegate>

@property (nonatomic, weak) MAS_VIEW *view;
@property (nonatomic, strong) NSMutableArray<__kindof MASConstraint *> *constraints;

@end

@implementation MASConstraintMaker

- (instancetype)initWithView:(MAS_VIEW *)view {
    self = [super init];
    if (!self) return nil;
    
    self.view = view;
    self.constraints = [NSMutableArray array];
    
    return self;
}

- (NSArray *)install {
    if (self.removeExisting) {
        NSArray *installedConstraints = [MASViewConstraint installedConstraintsForView:self.view];
        for (MASConstraint *constraint in installedConstraints) {
            [constraint uninstall];
        }
    }
    NSArray *constraints = self.constraints.copy;
    for (MASConstraint *constraint in constraints) {
        constraint.updateExisting = self.updateExisting;
        [constraint install];
    }
    [self.constraints removeAllObjects];
    return constraints;
}

- (NSArray *)prepare {
    NSArray *constraints = self.constraints.copy;
    [self.constraints removeAllObjects];
    return constraints;
}

#pragma mark - MASConstraintDelegate

- (void)constraint:(MASConstraint *)constraint shouldBeReplacedWithConstraint:(MASConstraint *)replacementConstraint {
    NSUInteger index = [self.constraints indexOfObject:constraint];
    NSAssert(index != NSNotFound, @"Could not find constraint %@", constraint);
    [self.constraints replaceObjectAtIndex:index withObject:replacementConstraint];
}

- (MASConstraint *)constraint:(MASConstraint *)constraint addConstraintWithLayoutAttribute:(NSLayoutAttribute)layoutAttribute {
    MASViewAttribute *viewAttribute = [[MASViewAttribute alloc] initWithView:self.view layoutAttribute:layoutAttribute];
    MASViewConstraint *newConstraint = [[MASViewConstraint alloc] initWithFirstViewAttribute:viewAttribute];
    if ([constraint isKindOfClass:MASViewConstraint.class]) {
        //replace with composite constraint
        NSArray *children = @[constraint, newConstraint];
        MASCompositeConstraint *compositeConstraint = [[MASCompositeConstraint alloc] initWithChildren:children];
        compositeConstraint.delegate = self;
        [self constraint:constraint shouldBeReplacedWithConstraint:compositeConstraint];
        return compositeConstraint;
    }
    if (!constraint) {
        newConstraint.delegate = self;
        [self.constraints addObject:newConstraint];
    }
    return newConstraint;
}

#pragma mark - standard Attributes

- (MASConstraint *)addConstraintWithLayoutAttribute:(NSLayoutAttribute)layoutAttribute {
    return [self constraint:nil addConstraintWithLayoutAttribute:layoutAttribute];
}

#pragma mark - attribute mapping helper

- (NSDictionary<NSNumber *, MASConstraint * (^)(void)> *)attributeMapping {
    return @{
        @(MASAttributeLeft): ^{ return self.view.mas_left; },
        @(MASAttributeRight): ^{ return self.view.mas_right; },
        @(MASAttributeTop): ^{ return self.view.mas_top; },
        @(MASAttributeBottom): ^{ return self.view.mas_bottom; },
        @(MASAttributeLeading): ^{ return self.view.mas_leading; },
        @(MASAttributeTrailing): ^{ return self.view.mas_trailing; },
        @(MASAttributeWidth): ^{ return self.view.mas_width; },
        @(MASAttributeHeight): ^{ return self.view.mas_height; },
        @(MASAttributeCenterX): ^{ return self.view.mas_centerX; },
        @(MASAttributeCenterY): ^{ return self.view.mas_centerY; },
        @(MASAttributeBaseline): ^{ return self.view.mas_baseline; },
        @(MASAttributeFirstBaseline): ^{ return self.view.mas_firstBaseline; },
        @(MASAttributeLastBaseline): ^{ return self.view.mas_lastBaseline; },
#if TARGET_OS_IPHONE || TARGET_OS_TV
        @(MASAttributeLeftMargin): ^{ return self.view.mas_leftMargin; },
        @(MASAttributeRightMargin): ^{ return self.view.mas_rightMargin; },
        @(MASAttributeTopMargin): ^{ return self.view.mas_topMargin; },
        @(MASAttributeBottomMargin): ^{ return self.view.mas_bottomMargin; },
        @(MASAttributeLeadingMargin): ^{ return self.view.mas_leadingMargin; },
        @(MASAttributeTrailingMargin): ^{ return self.view.mas_trailingMargin; },
        @(MASAttributeCenterXWithinMargins): ^{ return self.view.mas_centerXWithinMargins; },
        @(MASAttributeCenterYWithinMargins): ^{ return self.view.mas_centerYWithinMargins; },
#endif
    };
}

- (MASConstraint *)addConstraintWithAttributes:(MASAttribute)attrs {
    __unused MASAttribute anyAttribute = (MASAttributeLeft | MASAttributeRight | MASAttributeTop | MASAttributeBottom | MASAttributeLeading
                                          | MASAttributeTrailing | MASAttributeWidth | MASAttributeHeight | MASAttributeCenterX
                                          | MASAttributeCenterY | MASAttributeBaseline
                                          | MASAttributeFirstBaseline | MASAttributeLastBaseline
#if TARGET_OS_IPHONE || TARGET_OS_TV
                                          | MASAttributeLeftMargin | MASAttributeRightMargin | MASAttributeTopMargin | MASAttributeBottomMargin
                                          | MASAttributeLeadingMargin | MASAttributeTrailingMargin | MASAttributeCenterXWithinMargins
                                          | MASAttributeCenterYWithinMargins
#endif
                                          );
    
    NSAssert((attrs & anyAttribute) != 0, @"You didn't pass any attribute to make.attributes(...)");
    
    NSMutableArray *attributes = [NSMutableArray array];
    NSDictionary<NSNumber *, MASConstraint * (^)(void)> *mapping = [self attributeMapping];
    
    // 使用循环处理所有属性，替代大量的if条件判断
    for (NSNumber *attributeKey in mapping) {
        MASAttribute attribute = [attributeKey integerValue];
        if ((attrs & attribute) != 0) {
            MASConstraint * (^attributeBlock)(void) = mapping[attributeKey];
            [attributes addObject:attributeBlock()];
        }
    }
    
    NSMutableArray *children = [NSMutableArray arrayWithCapacity:attributes.count];
    
    for (MASViewAttribute *a in attributes) {
        [children addObject:[[MASViewConstraint alloc] initWithFirstViewAttribute:a]];
    }
    
    MASCompositeConstraint *constraint = [[MASCompositeConstraint alloc] initWithChildren:children];
    constraint.delegate = self;
    [self.constraints addObject:constraint];
    return constraint;
}

- (MASConstraint *)left {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeLeft];
}

- (MASConstraint *)top {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeTop];
}

- (MASConstraint *)right {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeRight];
}

- (MASConstraint *)bottom {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeBottom];
}

- (MASConstraint *)leading {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeLeading];
}

- (MASConstraint *)trailing {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeTrailing];
}

- (MASConstraint *)width {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeWidth];
}

- (MASConstraint *)height {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeHeight];
}

- (MASConstraint *)centerX {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeCenterX];
}

- (MASConstraint *)centerY {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeCenterY];
}

- (MASConstraint *)baseline {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeBaseline];
}

- (MASConstraint *(^)(MASAttribute))attributes {
    return ^(MASAttribute attrs){
        return [self addConstraintWithAttributes:attrs];
    };
}

- (MASConstraint *)firstBaseline {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeFirstBaseline];
}

- (MASConstraint *)lastBaseline {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeLastBaseline];
}

#if TARGET_OS_IPHONE || TARGET_OS_TV

- (MASConstraint *)leftMargin {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeLeftMargin];
}

- (MASConstraint *)rightMargin {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeRightMargin];
}

- (MASConstraint *)topMargin {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeTopMargin];
}

- (MASConstraint *)bottomMargin {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeBottomMargin];
}

- (MASConstraint *)leadingMargin {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeLeadingMargin];
}

- (MASConstraint *)trailingMargin {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeTrailingMargin];
}

- (MASConstraint *)centerXWithinMargins {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeCenterXWithinMargins];
}

- (MASConstraint *)centerYWithinMargins {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeCenterYWithinMargins];
}

#endif


#pragma mark - composite Attributes

- (MASConstraint *)edges {
    return [self addConstraintWithAttributes:MASAttributeTop | MASAttributeLeft | MASAttributeRight | MASAttributeBottom];
}

- (MASConstraint *)size {
    return [self addConstraintWithAttributes:MASAttributeWidth | MASAttributeHeight];
}

- (MASConstraint *)center {
    return [self addConstraintWithAttributes:MASAttributeCenterX | MASAttributeCenterY];
}

#pragma mark - grouping

- (MASConstraint *(^)(dispatch_block_t group))group {
    return ^id(dispatch_block_t group) {
        NSInteger previousCount = self.constraints.count;
        group();

        NSArray *children = [self.constraints subarrayWithRange:NSMakeRange(previousCount, self.constraints.count - previousCount)];
        MASCompositeConstraint *constraint = [[MASCompositeConstraint alloc] initWithChildren:children];
        constraint.delegate = self;
        return constraint;
    };
}

@end
