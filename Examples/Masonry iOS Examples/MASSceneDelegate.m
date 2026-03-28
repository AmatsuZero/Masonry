//
//  MASSceneDelegate.m
//  Masonry
//
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "MASSceneDelegate.h"
#import "MASExampleListViewController.h"

@implementation MASSceneDelegate

- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
    UIWindowScene *windowScene = (UIWindowScene *)scene;
    
    self.window = [[UIWindow alloc] initWithWindowScene:windowScene];
    self.window.backgroundColor = UIColor.whiteColor;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:MASExampleListViewController.new];
    self.window.rootViewController = navigationController;
    [self.window makeKeyAndVisible];
}

@end
