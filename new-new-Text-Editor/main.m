//
//  main.m
//  new-new-Text-Editor
//
//  Created by E&Z Pierson on 9/26/12.
//  Copyright (c) 2012 E&Z Pierson. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "IDTAppDelegate.h"
CFAbsoluteTime startTime;
int main(int argc, char *argv[])
{
    startTime = CFAbsoluteTimeGetCurrent();
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([IDTAppDelegate class]));
    }
}
