//
//  ZYPathMenuAppDelegate.h
//  ZYPathMenu
//
//  Created by wxg on 13-7-17.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZYPathMenuViewController;

@interface ZYPathMenuAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    ZYPathMenuViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet ZYPathMenuViewController *viewController;

@end

