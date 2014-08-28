ZCSAvatarCapture
=================

You've got user avatars in your app. You probably don't have user avatar editing as nice as this.

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

## Screenshots ##

![Example App with Avatar](/../screenshots/one.png?raw=true "Example App with Avatar")
![Example with Camera](/../screenshots/two.png?raw=true "Example with Camera")
![Example with Photo](/../screenshots/three.png?raw=true "Example with Photo")
![Example App after Avatar](/../screenshots/four.png?raw=true "Example App after Avatar")

## Contributing ##

Send me Pull Requests here, please.