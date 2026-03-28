//
//  MASConstraintConvertible.h
//  Masonry
//
//  Created on 2026/03/28.
//

#import "MASUtilities.h"
#import "MASViewAttribute.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  Marker protocol indicating that a type can be used as a constraint target
 *  in equalTo / greaterThanOrEqualTo / lessThanOrEqualTo.
 *
 *  Conforming types:
 *    - MASViewAttribute  (view.mas_top, view.mas_left, …)
 *    - MAS_VIEW           (UIView / NSView — convenience, auto-resolves attribute)
 *    - NSValue / NSNumber  (boxed scalars: CGFloat, CGSize, CGPoint, MASEdgeInsets)
 *    - NSArray             (composite constraint targets; elements are validated at runtime)
 */
NS_SWIFT_NAME(ConstraintConvertible)
@protocol MASConstraintConvertible <NSObject>
@end

// MARK: - Protocol Conformance Declarations

@interface MASViewAttribute (MASConstraintConvertible) <MASConstraintConvertible>
@end

@interface MAS_VIEW (MASConstraintConvertible) <MASConstraintConvertible>
@end

@interface NSValue (MASConstraintConvertible) <MASConstraintConvertible>
@end

@interface NSArray (MASConstraintConvertible) <MASConstraintConvertible>
@end

NS_ASSUME_NONNULL_END
