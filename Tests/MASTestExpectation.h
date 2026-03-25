//
//  MASTestExpectation.h
//  Masonry
//
//  Lightweight Expecta-compatible shim for SPM test support.
//  Provides the same expect().to.equal() chain syntax backed by XCTest assertions.
//

#import <XCTest/XCTest.h>
#import <Foundation/Foundation.h>

@interface MASTestExpectation : NSObject

+ (instancetype)expectationWithValue:(id)value
                            testCase:(XCTestCase *)testCase
                                file:(const char *)file
                                line:(NSUInteger)line;

// Chaining
@property (nonatomic, readonly) MASTestExpectation *to;
@property (nonatomic, readonly) MASTestExpectation *notTo;
@property (nonatomic, readonly) MASTestExpectation *toNot;

// Matchers
@property (nonatomic, readonly) MASTestExpectation *(^equal)(id expected);
@property (nonatomic, readonly) MASTestExpectation *(^beIdenticalTo)(id expected);
@property (nonatomic, readonly) MASTestExpectation *(^haveCountOf)(NSUInteger count);
@property (nonatomic, readonly) void (^beNil)(void);
@property (nonatomic, readonly) void (^beFalsy)(void);
@property (nonatomic, readonly) void (^beTruthy)(void);
@property (nonatomic, readonly) void (^beKindOf)(Class cls);
@property (nonatomic, readonly) MASTestExpectation *(^beCloseTo)(id expected);
@property (nonatomic, readonly) void (^raise)(NSString *exceptionName);
@property (nonatomic, readonly) void (^raiseAny)(void);

@end

// Boxing function: extends _MASBoxValue to also handle block types (type[0] == '@' covers both @ and @?)
static inline id _Nullable _MASExpectBoxValue(const char *type, ...) {
    va_list v;
    va_start(v, type);
    id obj = nil;
    if (type[0] == '@') {
        // Handles objects (@) and blocks (@?)
        obj = va_arg(v, id);
    } else if (strcmp(type, @encode(double)) == 0) {
        obj = [NSNumber numberWithDouble:va_arg(v, double)];
    } else if (strcmp(type, @encode(float)) == 0) {
        obj = [NSNumber numberWithFloat:(float)va_arg(v, double)];
    } else if (strcmp(type, @encode(int)) == 0) {
        obj = [NSNumber numberWithInt:va_arg(v, int)];
    } else if (strcmp(type, @encode(long)) == 0) {
        obj = [NSNumber numberWithLong:va_arg(v, long)];
    } else if (strcmp(type, @encode(long long)) == 0) {
        obj = [NSNumber numberWithLongLong:va_arg(v, long long)];
    } else if (strcmp(type, @encode(short)) == 0) {
        obj = [NSNumber numberWithShort:(short)va_arg(v, int)];
    } else if (strcmp(type, @encode(char)) == 0) {
        obj = [NSNumber numberWithChar:(char)va_arg(v, int)];
    } else if (strcmp(type, @encode(bool)) == 0) {
        obj = [NSNumber numberWithBool:(bool)va_arg(v, int)];
    } else if (strcmp(type, @encode(unsigned char)) == 0) {
        obj = [NSNumber numberWithUnsignedChar:(unsigned char)va_arg(v, unsigned int)];
    } else if (strcmp(type, @encode(unsigned int)) == 0) {
        obj = [NSNumber numberWithUnsignedInt:va_arg(v, unsigned int)];
    } else if (strcmp(type, @encode(unsigned long)) == 0) {
        obj = [NSNumber numberWithUnsignedLong:va_arg(v, unsigned long)];
    } else if (strcmp(type, @encode(unsigned long long)) == 0) {
        obj = [NSNumber numberWithUnsignedLongLong:va_arg(v, unsigned long long)];
    } else if (strcmp(type, @encode(unsigned short)) == 0) {
        obj = [NSNumber numberWithUnsignedShort:(unsigned short)va_arg(v, unsigned int)];
    }
    va_end(v);
    return obj;
}

#define MASExpectBoxValue(value) _MASExpectBoxValue(@encode(__typeof__((value))), (value))

// Main expect macro — captures self (XCTestCase), file, and line
#define expect(actual) \
    [MASTestExpectation expectationWithValue:MASExpectBoxValue(actual) \
                                   testCase:self \
                                       file:__FILE__ \
                                       line:__LINE__]

// Autoboxing macros for matchers that may receive scalar arguments.
// The C preprocessor anti-recursion rule prevents infinite expansion:
// equal(42) -> equal(MASExpectBoxValue(42)) and the inner 'equal' is NOT re-expanded.
#define equal(...) equal(MASExpectBoxValue(__VA_ARGS__))
#define beCloseTo(...) beCloseTo(MASExpectBoxValue(__VA_ARGS__))
#define beIdenticalTo(...) beIdenticalTo(MASExpectBoxValue(__VA_ARGS__))
