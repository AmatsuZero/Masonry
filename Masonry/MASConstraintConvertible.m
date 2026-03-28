//
//  MASConstraintConvertible.m
//  Masonry
//
//  Created on 2026/03/28.
//

#import "MASConstraintConvertible.h"
#import "MASViewAttribute.h"

// Empty implementations are required to register protocol conformance
// with the ObjC runtime. Without these, Swift's `as!` dynamic cast
// cannot find the conformance for class cluster members (e.g., NSConcreteValue).

@implementation MASViewAttribute (MASConstraintConvertible)
@end

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"

@implementation MAS_VIEW (MASConstraintConvertible)
@end

#pragma clang diagnostic pop

@implementation NSValue (MASConstraintConvertible)
@end

@implementation NSArray (MASConstraintConvertible)
@end
