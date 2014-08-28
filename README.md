ZCSAvatarCapture
=================

## Add to your Podfile

`pod 'ZCSAvatarCapture', '~> 0.0.1'`

## Use in your project
```obj-c
#import "ZCSAvatarCaptureController.h"

ZCSAvatarCaptureController *avatarCaptureController = [[ZCSAvatarCaptureController alloc] init];
avatarCaptureController.delegate = self;
avatarCaptureController.image = [UIImage imageNamed:@"model-001.jpg"]; // Use your current avatar image here
avatarCaptureController.view.frame = CGRectMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2, 100, 100); // Set to whatever size you'd like
[self.view addSubview:avatarCaptureController.view];
```

