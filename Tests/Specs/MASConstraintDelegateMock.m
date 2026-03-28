//
//  MASConstraintDelegate.m
//  Masonry
//
//  Created by Jonas Budelmann on 28/07/13.
//  Copyright (c) 2013 Jonas Budelmann. All rights reserved.
//

#import "MASConstraintDelegateMock.h"
#import "MASViewConstraint.h"

@implementation MASConstraintDelegateMock

- (id)init {
    self = [super init];
    if (!self) return nil;

    self.constraints = NSMutableArray.new;
    self.chainedConstraints = NSMutableArray.new;

    return self;
}

- (void)constraint:(MASConstraint *)constraint shouldBeReplacedWithConstraint:(MASConstraint *)replacementConstraint {
    [self.constraints replaceObjectAtIndex:[self.constraints indexOfObject:constraint] withObject:replacementConstraint];
}

- (id)constraint:(nullable MASConstraint *)constraint addConstraintWithLayoutAttribute:(NSLayoutAttribute)layoutAttribute {
    [self.chainedConstraints addObject:constraint];

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
    MASViewConstraint *viewConstraint = [[MASViewConstraint alloc] initWithFirstViewAttribute:[[MASViewAttribute alloc] initWithView:nil item:nil layoutAttribute:layoutAttribute]];
#pragma clang diagnostic pop
    return viewConstraint;
}

@end
