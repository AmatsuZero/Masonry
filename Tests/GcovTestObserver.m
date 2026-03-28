//
//  GcovTestObserver.m
//  ClassyTests
//
//  Created by Jonas Budelmann on 19/11/13.
//  Copyright (c) 2013 Jonas Budelmann. All rights reserved.
//

#import <XCTest/XCTestObserver.h>

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
@interface GcovTestObserver : XCTestObserver
@end

@implementation GcovTestObserver

- (void)stopObserving {
    [super stopObserving];
#if TARGET_OS_IPHONE
    UIApplication* application = [UIApplication sharedApplication];
    [application.delegate applicationWillTerminate:application];
#endif
}

@end
#pragma clang diagnostic pop