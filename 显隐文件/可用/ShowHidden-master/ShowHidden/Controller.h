//
//  Controller.h
//  ShowHidden
//
//  Created by Vincenzo Pimpinella on 15/12/13.
//  Copyright (c) 2013 Vincenzo Pimpinella. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Controller : NSObject {
    IBOutlet NSButton* show_button;
    IBOutlet NSButton* hide_button;
}

- (IBAction)show:(id)sender;
- (IBAction)hide:(id)sender;
- (IBAction)openURL:(id)sender;
@end
