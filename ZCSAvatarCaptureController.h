//
//  ZCSAvatarCaptureController.h
//  ZCSAvatarCaptureDemo
//
//  Created by Zane Shannon on 8/27/14.
//  Copyright (c) 2014 Zane Shannon. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZCSAvatarCaptureController;

@protocol ZCSAvatarCaptureControllerDelegate <NSObject>
- (void)imageSelected:(UIImage *)image;
- (void)imageSelectionCancelled;
@end

@interface ZCSAvatarCaptureController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (weak) id<ZCSAvatarCaptureControllerDelegate> delegate;
@property (strong, nonatomic) UIImage *image;

@end