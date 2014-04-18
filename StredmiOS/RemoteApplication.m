//
//  RemoteApplication.m
//  StredmiOS
//
//  Created by Conner Fromknecht on 4/14/14.
//  Copyright (c) 2014 Stredm. All rights reserved.
//

#import "RemoteApplication.h"
#import "JNAppDelegate.h"

#import <Mixpanel/Mixpanel.h>

@implementation RemoteApplication

- (void)remoteControlReceivedWithEvent:(UIEvent *)receivedEvent {
    if (receivedEvent.type == UIEventTypeRemoteControl) {
        JNAppDelegate* jnad = (JNAppDelegate*) [[UIApplication sharedApplication] delegate];
        
        switch (receivedEvent.subtype) {
            case UIEventSubtypeRemoteControlPause:
                [jnad.playerView pause];
                [jnad.playerView updateLockscreen];
                
                [[Mixpanel sharedInstance] track:@"Lock Screen Pause"];

                break;
                
            case UIEventSubtypeRemoteControlPlay:
                [jnad.playerView play];
                [jnad.playerView updateLockscreen];
                
                [[Mixpanel sharedInstance] track:@"Lock Screen Play"];
                
                break;
                
            case UIEventSubtypeRemoteControlPreviousTrack:
                [jnad.playerView previous];
                [jnad.playerView updateLockscreen];
                
                break;
                
            case UIEventSubtypeRemoteControlNextTrack:
                [jnad.playerView next];
                [jnad.playerView updateLockscreen];
                
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
