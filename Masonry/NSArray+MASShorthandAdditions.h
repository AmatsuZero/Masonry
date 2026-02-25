//
//  NSArray+MASShorthandAdditions.h
//  Masonry
//
//  Created by Jonas Budelmann on 22/07/13.
//  Copyright (c) 2013 Jonas Budelmann. All rights reserved.
//

#import "NSArray+MASAdditions.h"

#ifdef MAS_SHORTHAND

/**
 *	Shorthand array additions without the 'mas_' prefixes,
 *  only enabled if MAS_SHORTHAND is defined
 */
@interface NSArray (MASShorthandAdditions)

- (NSArray<__kindof MASConstraint *> *)makeConstraints:(void(NS_NOESCAPE ^)(MASConstraintMaker *make))block;
- (NSArray<__kindof MASConstraint *> *)updateConstraints:(void(NS_NOESCAPE ^)(MASConstraintMaker *make))block;
- (NSArray<__kindof MASConstraint *> *)remakeConstraints:(void(NS_NOESCAPE ^)(MASConstraintMaker *make))block;

@end

@implementation NSArray (MASShorthandAdditions)

- (NSArray<__kindof MASConstraint *> *)makeConstraints:(void(NS_NOESCAPE ^)(MASConstraintMaker *))block {
    return [self mas_makeConstraints:block];
}

- (NSArray<__kindof MASConstraint *> *)updateConstraints:(void(NS_NOESCAPE ^)(MASConstraintMaker *))block {
    return [self mas_updateConstraints:block];
}

- (NSArray<__kindof MASConstraint *> *)remakeConstraints:(void(NS_NOESCAPE ^)(MASConstraintMaker *))block {
    return [self mas_remakeConstraints:block];
}

@end

#endif
