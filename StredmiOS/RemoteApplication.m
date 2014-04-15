//
//  RemoteApplication.m
//  StredmiOS
//
//  Created by Conner Fromknecht on 4/14/14.
//  Copyright (c) 2014 Stredm. All rights reserved.
//

#import "RemoteApplication.h"
#import "JNAppDelegate.h"

@implementation RemoteApplication

- (void)remoteControlReceivedWithEvent:(UIEvent *)receivedEvent {
    if (receivedEvent.type == UIEventTypeRemoteControl) {
        JNAppDelegate* jnad = (JNAppDelegate*) [[UIApplication sharedApplication] delegate];
        
        switch (receivedEvent.subtype) {
            case UIEventSubtypeRemoteControlPause:
                [jnad.playerView pause];
                break;
                
            case UIEventSubtypeRemoteControlPlay:
                [jnad.playerView play];
                break;
                
            case UIEventSubtypeRemoteControlPreviousTrack:
                break;
                
            case UIEventSubtypeRemoteControlNextTrack:
                break;
                
            default:
                break;
        }
    }
}

-(BOOL)canBecomeFirstResponder {
    return YES;
}

@end
