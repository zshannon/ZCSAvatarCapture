ZCSAvatarCapture
=================

## Add to your Podfile

`pod 'ZCSAvatarCapture', '~> 0.0.1'`

## Use in your project
```obj-c
#import "ZCSAvatarCaptureController.h"

ZCSAvatarCaptureController *avatarCaptureController = [[ZCSAvatarCaptureController alloc] init];
avatarCaptureController.delegate = self;
avatarCaptureController.image = [UIImage imageNamed:@"model-001.jpg"];
avatarCaptureController.view.frame = self.avatarView.frame;
[self.view addSubview:avatarCaptureController.view];
```

