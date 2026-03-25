//
//  MASTestExpectation.m
//  Masonry
//
//  Lightweight Expecta-compatible shim for SPM test support.
//

#import "MASTestExpectation.h"
#import <math.h>

@interface MASTestExpectation ()

@property (nonatomic, strong) id actualValue;
@property (nonatomic, assign) BOOL negated;
@property (nonatomic, assign) const char *filePath;
@property (nonatomic, assign) NSUInteger lineNumber;
@property (nonatomic, weak) XCTestCase *testCase;

@end

@implementation MASTestExpectation

+ (instancetype)expectationWithValue:(id)value
                            testCase:(XCTestCase *)testCase
                                file:(const char *)file
                                line:(NSUInteger)line {
    MASTestExpectation *exp = [MASTestExpectation new];
    exp.actualValue = value;
    exp.testCase = testCase;
    exp.filePath = file;
    exp.lineNumber = line;
    return exp;
}

#pragma mark - Chaining

- (MASTestExpectation *)to {
    return self;
}

- (MASTestExpectation *)notTo {
    self.negated = YES;
    return self;
}

- (MASTestExpectation *)toNot {
    self.negated = YES;
    return self;
}

#pragma mark - Matchers

- (MASTestExpectation *(^)(id))equal {
    __weak typeof(self) weakSelf = self;
    return ^MASTestExpectation *(id expected) {
        __strong typeof(weakSelf) self = weakSelf;
        BOOL result;
        if (self.actualValue == nil && expected == nil) {
            result = YES;
        } else {
            result = [self.actualValue isEqual:expected];
        }
        if (self.negated) result = !result;

        if (!result) {
            NSString *msg = self.negated
                ? [NSString stringWithFormat:@"expected %@ to not equal %@", self.actualValue, expected]
                : [NSString stringWithFormat:@"expected %@ to equal %@", self.actualValue, expected];
            [self recordFailure:msg];
        }
        return self;
    };
}

- (MASTestExpectation *(^)(id))beIdenticalTo {
    __weak typeof(self) weakSelf = self;
    return ^MASTestExpectation *(id expected) {
        __strong typeof(weakSelf) self = weakSelf;
        BOOL result = (self.actualValue == expected);
        if (self.negated) result = !result;

        if (!result) {
            NSString *msg = self.negated
                ? [NSString stringWithFormat:@"expected %@ to not be identical to %@", self.actualValue, expected]
                : [NSString stringWithFormat:@"expected %@ to be identical to %@", self.actualValue, expected];
            [self recordFailure:msg];
        }
        return self;
    };
}

- (MASTestExpectation *(^)(NSUInteger))haveCountOf {
    __weak typeof(self) weakSelf = self;
    return ^MASTestExpectation *(NSUInteger count) {
        __strong typeof(weakSelf) self = weakSelf;
        NSUInteger actualCount = 0;
        if ([self.actualValue respondsToSelector:@selector(count)]) {
            actualCount = [(id)self.actualValue count];
        }
        BOOL result = (actualCount == count);
        if (self.negated) result = !result;

        if (!result) {
            NSString *msg = self.negated
                ? [NSString stringWithFormat:@"expected %@ to not have count of %lu", self.actualValue, (unsigned long)count]
                : [NSString stringWithFormat:@"expected %@ to have count of %lu, got %lu", self.actualValue, (unsigned long)count, (unsigned long)actualCount];
            [self recordFailure:msg];
        }
        return self;
    };
}

- (void (^)(void))beNil {
    __weak typeof(self) weakSelf = self;
    return ^{
        __strong typeof(weakSelf) self = weakSelf;
        BOOL result = (self.actualValue == nil);
        if (self.negated) result = !result;

        if (!result) {
            NSString *msg = self.negated
                ? @"expected value to not be nil"
                : [NSString stringWithFormat:@"expected nil, got %@", self.actualValue];
            [self recordFailure:msg];
        }
    };
}

- (void (^)(void))beFalsy {
    __weak typeof(self) weakSelf = self;
    return ^{
        __strong typeof(weakSelf) self = weakSelf;
        BOOL result;
        if (self.actualValue == nil) {
            result = YES;
        } else if ([self.actualValue isKindOfClass:[NSNumber class]]) {
            result = ![self.actualValue boolValue];
        } else {
            result = NO;
        }
        if (self.negated) result = !result;

        if (!result) {
            NSString *msg = self.negated
                ? [NSString stringWithFormat:@"expected %@ to not be falsy", self.actualValue]
                : [NSString stringWithFormat:@"expected %@ to be falsy", self.actualValue];
            [self recordFailure:msg];
        }
    };
}

- (void (^)(void))beTruthy {
    __weak typeof(self) weakSelf = self;
    return ^{
        __strong typeof(weakSelf) self = weakSelf;
        BOOL result;
        if (self.actualValue == nil) {
            result = NO;
        } else if ([self.actualValue isKindOfClass:[NSNumber class]]) {
            result = [self.actualValue boolValue];
        } else {
            result = YES;
        }
        if (self.negated) result = !result;

        if (!result) {
            NSString *msg = self.negated
                ? [NSString stringWithFormat:@"expected %@ to not be truthy", self.actualValue]
                : [NSString stringWithFormat:@"expected %@ to be truthy", self.actualValue];
            [self recordFailure:msg];
        }
    };
}

- (void (^)(Class))beKindOf {
    __weak typeof(self) weakSelf = self;
    return ^(Class cls) {
        __strong typeof(weakSelf) self = weakSelf;
        BOOL result = [self.actualValue isKindOfClass:cls];
        if (self.negated) result = !result;

        if (!result) {
            NSString *msg = self.negated
                ? [NSString stringWithFormat:@"expected %@ to not be kind of %@", self.actualValue, cls]
                : [NSString stringWithFormat:@"expected %@ to be kind of %@", self.actualValue, cls];
            [self recordFailure:msg];
        }
    };
}

- (MASTestExpectation *(^)(id))beCloseTo {
    __weak typeof(self) weakSelf = self;
    return ^MASTestExpectation *(id expected) {
        __strong typeof(weakSelf) self = weakSelf;
        double actualDouble = [self.actualValue doubleValue];
        double expectedDouble = [expected doubleValue];
        BOOL result = fabs(actualDouble - expectedDouble) < 0.01;
        if (self.negated) result = !result;

        if (!result) {
            NSString *msg = self.negated
                ? [NSString stringWithFormat:@"expected %f to not be close to %f", actualDouble, expectedDouble]
                : [NSString stringWithFormat:@"expected %f to be close to %f", actualDouble, expectedDouble];
            [self recordFailure:msg];
        }
        return self;
    };
}

- (void (^)(NSString *))raise {
    __weak typeof(self) weakSelf = self;
    return ^(NSString *exceptionName) {
        __strong typeof(weakSelf) self = weakSelf;
        BOOL raised = NO;
        NSString *actualName = nil;
        @try {
            void (^block)(void) = self.actualValue;
            block();
        } @catch (NSException *exception) {
            raised = YES;
            actualName = exception.name;
        }

        BOOL result = raised && [actualName isEqualToString:exceptionName];
        if (self.negated) result = !result;

        if (!result) {
            NSString *msg = self.negated
                ? [NSString stringWithFormat:@"expected block to not raise %@", exceptionName]
                : [NSString stringWithFormat:@"expected block to raise %@, got %@", exceptionName, actualName ?: @"no exception"];
            [self recordFailure:msg];
        }
    };
}

- (void (^)(void))raiseAny {
    __weak typeof(self) weakSelf = self;
    return ^{
        __strong typeof(weakSelf) self = weakSelf;
        BOOL raised = NO;
        @try {
            void (^block)(void) = self.actualValue;
            block();
        } @catch (NSException *exception) {
            raised = YES;
        }

        BOOL result = raised;
        if (self.negated) result = !result;

        if (!result) {
            NSString *msg = self.negated
                ? @"expected block to not raise any exception"
                : @"expected block to raise an exception, but none was raised";
            [self recordFailure:msg];
        }
    };
}

#pragma mark - Helper

- (void)recordFailure:(NSString *)message {
    XCTSourceCodeLocation *location = [[XCTSourceCodeLocation alloc]
        initWithFilePath:[NSString stringWithUTF8String:self.filePath]
              lineNumber:self.lineNumber];
    XCTSourceCodeContext *context = [[XCTSourceCodeContext alloc] initWithLocation:location];
    XCTIssue *issue = [[XCTIssue alloc] initWithType:XCTIssueTypeAssertionFailure
                                  compactDescription:message
                                 detailedDescription:nil
                                   sourceCodeContext:context
                                     associatedError:nil
                                         attachments:@[]];
    [self.testCase recordIssue:issue];
}

@end
