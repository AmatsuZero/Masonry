//
//  MASConstraint.h
//  Masonry
//
//  Created by Jonas Budelmann on 22/07/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "MASUtilities.h"
#import "MASConstraintConvertible.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *	Enables Constraints to be created with chainable syntax
 *  Constraint can represent single NSLayoutConstraint (MASViewConstraint) 
 *  or a group of NSLayoutConstraints (MASComposisteConstraint)
 */
MAS_SWIFT_UI_ACTOR
@interface MASConstraint : NSObject

// Chaining Support

/**
 *	Modifies the NSLayoutConstraint constant,
 *  only affects MASConstraints in which the first item's NSLayoutAttribute is one of the following
 *  NSLayoutAttributeTop, NSLayoutAttributeLeft, NSLayoutAttributeBottom, NSLayoutAttributeRight
 */
- (MASConstraint * (^)(MASEdgeInsets insets))insets;

/**
 *	Modifies the NSLayoutConstraint constant,
 *  only affects MASConstraints in which the first item's NSLayoutAttribute is one of the following
 *  NSLayoutAttributeTop, NSLayoutAttributeLeft, NSLayoutAttributeBottom, NSLayoutAttributeRight
 */
- (MASConstraint * (^)(CGFloat inset))inset;

/**
 *	Modifies the NSLayoutConstraint constant,
 *  only affects MASConstraints in which the first item's NSLayoutAttribute is one of the following
 *  NSLayoutAttributeWidth, NSLayoutAttributeHeight
 */
- (MASConstraint * (^)(CGSize offset))sizeOffset;

/**
 *	Modifies the NSLayoutConstraint constant,
 *  only affects MASConstraints in which the first item's NSLayoutAttribute is one of the following
 *  NSLayoutAttributeCenterX, NSLayoutAttributeCenterY
 */
- (MASConstraint * (^)(CGPoint offset))centerOffset;

/**
 *	Modifies the NSLayoutConstraint constant
 */
- (MASConstraint * (^)(CGFloat offset))offset;

/**
 *  Modifies the NSLayoutConstraint constant based on a value type
 */
- (MASConstraint * (^)(NSValue *value))valueOffset;

/**
 *	Sets the NSLayoutConstraint multiplier property
 */
- (MASConstraint * (^)(CGFloat multiplier))multipliedBy;

/**
 *	Sets the NSLayoutConstraint multiplier to 1.0/dividedBy
 */
- (MASConstraint * (^)(CGFloat divider))dividedBy;

/**
 *	Sets the NSLayoutConstraint priority to a float or MASLayoutPriority
 */
- (MASConstraint * (^)(MASLayoutPriority priority))priority;

/**
 *	Sets the NSLayoutConstraint priority to MASLayoutPriorityLow
 */
- (MASConstraint * (^)(void))priorityLow;

/**
 *	Sets the NSLayoutConstraint priority to MASLayoutPriorityMedium
 */
- (MASConstraint * (^)(void))priorityMedium;

/**
 *	Sets the NSLayoutConstraint priority to MASLayoutPriorityHigh
 */
- (MASConstraint * (^)(void))priorityHigh;

/**
 *	Sets the constraint relation to NSLayoutRelationEqual
 *  returns a block which accepts one of the following:
 *    MASViewAttribute, UIView, NSValue, NSArray
 *  see readme for more details.
 */
- (MASConstraint * (^)(id<MASConstraintConvertible> attr))equalTo;

/**
 *	Sets the constraint relation to NSLayoutRelationGreaterThanOrEqual
 *  returns a block which accepts one of the following:
 *    MASViewAttribute, UIView, NSValue, NSArray
 *  see readme for more details.
 */
- (MASConstraint * (^)(id<MASConstraintConvertible> attr))greaterThanOrEqualTo;

/**
 *	Sets the constraint relation to NSLayoutRelationLessThanOrEqual
 *  returns a block which accepts one of the following:
 *    MASViewAttribute, UIView, NSValue, NSArray
 *  see readme for more details.
 */
- (MASConstraint * (^)(id<MASConstraintConvertible> attr))lessThanOrEqualTo;

/**
 *  Sets the constraint relation to NSLayoutRelationEqual and records the call-site
 *  file and line number into mas_key for improved debugging.
 *  Used automatically by the mas_equalTo() macro.
 */
- (MASConstraint * (^)(id<MASConstraintConvertible> attr, NSString *file, NSUInteger line))equalToWithLocation;

/**
 *  Sets the constraint relation to NSLayoutRelationGreaterThanOrEqual and records the call-site
 *  file and line number into mas_key for improved debugging.
 *  Used automatically by the mas_greaterThanOrEqualTo() macro.
 */
- (MASConstraint * (^)(id<MASConstraintConvertible> attr, NSString *file, NSUInteger line))greaterThanOrEqualToWithLocation;

/**
 *  Sets the constraint relation to NSLayoutRelationLessThanOrEqual and records the call-site
 *  file and line number into mas_key for improved debugging.
 *  Used automatically by the mas_lessThanOrEqualTo() macro.
 */
- (MASConstraint * (^)(id<MASConstraintConvertible> attr, NSString *file, NSUInteger line))lessThanOrEqualToWithLocation;

/**
 *  Sets the constraint relation to NSLayoutRelationEqual with the corresponding
 *  attribute of the receiver view's superview.
 *  Equivalent to equalTo(superview) or equalTo(superview.mas_<attribute>).
 *  The view must have a superview before this constraint is installed.
 */
- (MASConstraint *)equalToSuperview;

/**
 *  Sets the constraint relation to NSLayoutRelationGreaterThanOrEqual with the corresponding
 *  attribute of the receiver view's superview.
 *  Equivalent to greaterThanOrEqualTo(superview).
 *  The view must have a superview before this constraint is installed.
 */
- (MASConstraint *)greaterThanOrEqualToSuperview;

/**
 *  Sets the constraint relation to NSLayoutRelationLessThanOrEqual with the corresponding
 *  attribute of the receiver view's superview.
 *  Equivalent to lessThanOrEqualTo(superview).
 *  The view must have a superview before this constraint is installed.
 */
- (MASConstraint *)lessThanOrEqualToSuperview;

/**
 *	Optional semantic property which has no effect but improves the readability of constraint
 */
- (MASConstraint *)with;

/**
 *	Optional semantic property which has no effect but improves the readability of constraint
 */
- (MASConstraint *)and;

/**
 *	Creates a new MASCompositeConstraint with the called attribute and reciever
 */
- (MASConstraint *)left;
- (MASConstraint *)top;
- (MASConstraint *)right;
- (MASConstraint *)bottom;
- (MASConstraint *)leading;
- (MASConstraint *)trailing;
- (MASConstraint *)width;
- (MASConstraint *)height;
- (MASConstraint *)centerX;
- (MASConstraint *)centerY;
- (MASConstraint *)baseline;

- (MASConstraint *)firstBaseline;
- (MASConstraint *)lastBaseline;

#if TARGET_OS_IPHONE || TARGET_OS_TV

- (MASConstraint *)leftMargin;
- (MASConstraint *)rightMargin;
- (MASConstraint *)topMargin;
- (MASConstraint *)bottomMargin;
- (MASConstraint *)leadingMargin;
- (MASConstraint *)trailingMargin;
- (MASConstraint *)centerXWithinMargins;
- (MASConstraint *)centerYWithinMargins;

#endif


/**
 *	Sets the constraint debug name
 */
- (MASConstraint * (^)(id _Nullable key))key;

// NSLayoutConstraint constant Setters
// for use outside of mas_updateConstraints/mas_makeConstraints blocks

/**
 *	Modifies the NSLayoutConstraint constant,
 *  only affects MASConstraints in which the first item's NSLayoutAttribute is one of the following
 *  NSLayoutAttributeTop, NSLayoutAttributeLeft, NSLayoutAttributeBottom, NSLayoutAttributeRight
 */
- (void)setInsets:(MASEdgeInsets)insets;

/**
 *	Modifies the NSLayoutConstraint constant,
 *  only affects MASConstraints in which the first item's NSLayoutAttribute is one of the following
 *  NSLayoutAttributeTop, NSLayoutAttributeLeft, NSLayoutAttributeBottom, NSLayoutAttributeRight
 */
- (void)setInset:(CGFloat)inset;

/**
 *	Modifies the NSLayoutConstraint constant,
 *  only affects MASConstraints in which the first item's NSLayoutAttribute is one of the following
 *  NSLayoutAttributeWidth, NSLayoutAttributeHeight
 */
- (void)setSizeOffset:(CGSize)sizeOffset;

/**
 *	Modifies the NSLayoutConstraint constant,
 *  only affects MASConstraints in which the first item's NSLayoutAttribute is one of the following
 *  NSLayoutAttributeCenterX, NSLayoutAttributeCenterY
 */
- (void)setCenterOffset:(CGPoint)centerOffset;

/**
 *	Modifies the NSLayoutConstraint constant
 */
- (void)setOffset:(CGFloat)offset;


// NSLayoutConstraint Installation support

#if TARGET_OS_MAC && !(TARGET_OS_IPHONE || TARGET_OS_TV)
/**
 *  Whether or not to go through the animator proxy when modifying the constraint
 */
@property (nonatomic, copy, readonly) MASConstraint *animator;
#endif

/**
 *  Activates an NSLayoutConstraint if it's supported by an OS. 
 *  Invokes install otherwise.
 */
- (void)activate;

/**
 *  Deactivates previously installed/activated NSLayoutConstraint.
 */
- (void)deactivate;

/**
 *	Creates a NSLayoutConstraint and adds it to the appropriate view.
 */
- (void)install;

/**
 *	Removes previously installed NSLayoutConstraint
 */
- (void)uninstall;

@end

/**
 *  Convenience auto-boxing macros for MASConstraint methods.
 *
 *  Defining MAS_SHORTHAND_GLOBALS will turn on auto-boxing for default syntax.
 *  A potential drawback of this is that the unprefixed macros will appear in global scope.
 */
#define mas_equalTo(...)                 equalToWithLocation(MASBoxValue((__VA_ARGS__)), @(__FILE__), __LINE__)
#define mas_greaterThanOrEqualTo(...)    greaterThanOrEqualToWithLocation(MASBoxValue((__VA_ARGS__)), @(__FILE__), __LINE__)
#define mas_lessThanOrEqualTo(...)       lessThanOrEqualToWithLocation(MASBoxValue((__VA_ARGS__)), @(__FILE__), __LINE__)

#define mas_offset(...)                  valueOffset(MASBoxValue((__VA_ARGS__)))

#define mas_equalToSuperview             equalToSuperview


#ifdef MAS_SHORTHAND_GLOBALS

#define equalTo(...)                     equalToWithLocation(MASBoxValue((__VA_ARGS__)), @(__FILE__), __LINE__)
#define greaterThanOrEqualTo(...)        greaterThanOrEqualToWithLocation(MASBoxValue((__VA_ARGS__)), @(__FILE__), __LINE__)
#define lessThanOrEqualTo(...)           lessThanOrEqualToWithLocation(MASBoxValue((__VA_ARGS__)), @(__FILE__), __LINE__)

#define offset(...)                      mas_offset(__VA_ARGS__)

#endif


@interface MASConstraint (AutoboxingSupport)

/**
 *  Aliases to corresponding relation methods (for shorthand macros)
 *  Also needed to aid autocompletion
 */
- (MASConstraint * (^)(id<MASConstraintConvertible> attr))mas_equalTo;
- (MASConstraint * (^)(id<MASConstraintConvertible> attr))mas_greaterThanOrEqualTo;
- (MASConstraint * (^)(id<MASConstraintConvertible> attr))mas_lessThanOrEqualTo;

/**
 *  A dummy method to aid autocompletion
 */
- (MASConstraint * (^)(id<MASConstraintConvertible> offset))mas_offset;

@end

NS_ASSUME_NONNULL_END
