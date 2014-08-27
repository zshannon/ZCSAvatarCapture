//
//  ViewController.h
//  ZCSAvatarCaptureDemo
//
//  Created by Zane Shannon on 8/27/14.
//  Copyright (c) 2014 Zane Shannon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZCsAvatarCaptureController.h"

@interface ViewController : UIViewController <ZCSAvatarCaptureControllerDelegate>

@property (strong, nonatomic) IBOutlet UIView *avatarView;

@end
