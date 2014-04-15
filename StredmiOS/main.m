//
//  main.m
//  StredmiOS
//
//  Created by Jesus Najera on 2/25/14.
//  Copyright (c) 2014 Stredm. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "JNAppDelegate.h"
#import "RemoteApplication.h"

int main(int argc, char * argv[])
{
    @autoreleasepool {
        return UIApplicationMain(argc, argv, NSStringFromClass([RemoteApplication class]), NSStringFromClass([JNAppDelegate class]));
    }
}
