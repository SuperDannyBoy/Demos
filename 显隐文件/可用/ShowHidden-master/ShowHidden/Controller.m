//
//  Controller.m
//  ShowHidden
//
//  Created by Vincenzo Pimpinella on 15/12/13.
//  Copyright (c) 2013 Vincenzo Pimpinella. All rights reserved.
//

#import "Controller.h"

@implementation Controller

- (IBAction)show:(id)sender {
    system([@"defaults write com.apple.finder AppleShowAllFiles 1" UTF8String]);
    NSLog(@"Show -> exec: defaults write com.apple.finder AppleShowAllFiles 1");
    system("killall Finder");
}

- (IBAction)hide:(id)sender {
    system([@"defaults write com.apple.finder AppleShowAllFiles 0" UTF8String]);
    NSLog(@"Hide -> exec: defaults write com.apple.finder AppleShowAllFiles 0");
    system("killall Finder");
}

- (IBAction)openURL:(id)sender {
    NSAlert *alert = [NSAlert alertWithMessageText:@"提示" defaultButton:@"确定" alternateButton:nil otherButton:nil informativeTextWithFormat:@"感谢开源精神！感谢VinP提供的技术基础！"];
    [alert beginSheetModalForWindow:[NSApplication sharedApplication].windows.firstObject completionHandler:^(NSModalResponse returnCode) {
        
    }];
}

@end
