//
//  ZCSAvatarCaptureController.m
//  ZCSAvatarCaptureDemo
//
//  Created by Zane Shannon on 8/27/14.
//  Copyright (c) 2014 Zane Shannon. All rights reserved.
//

#import "ZCSAvatarCaptureController.h"
#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>

@interface ZCSAvatarCaptureController () {
	CGRect previousFrame;
	BOOL isCapturing;
}

@property (nonatomic, strong) UIImageView *avatarView;
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureStillImageOutput *stillImageOutput;
@property (nonatomic, strong) AVCaptureDevice *captureDevice;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;
@property (nonatomic, assign) BOOL isCapturingImage;
@property (nonatomic, strong) UIImageView *capturedImageView;
@property (nonatomic, strong) UIImagePickerController *picker;
@property (nonatomic, strong) UIView *imageSelectedView;
@property (nonatomic, strong) UIImage *selectedImage;

- (void)startCapture;
- (void)endCapture;

@end

@implementation ZCSAvatarCaptureController

- (void)viewDidLoad {
	[super viewDidLoad];
	isCapturing = NO;
	// self.view.backgroundColor = [UIColor yellowColor];
	self.view.autoresizesSubviews = YES;
	self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(startCapture)];
	[self.view addGestureRecognizer:singleTapGestureRecognizer];
	self.avatarView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
	self.avatarView.image = self.image;
	self.avatarView.contentMode = UIViewContentModeScaleAspectFill;
	self.avatarView.layer.masksToBounds = YES;
	self.avatarView.layer.cornerRadius = CGRectGetWidth(self.view.frame) / 2;
	[self.view addSubview:self.avatarView];
}

- (void)viewWillLayoutSubviews {
	[super viewWillLayoutSubviews];
	self.view.layer.cornerRadius = CGRectGetWidth(self.view.frame) / 2.0;
	self.avatarView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
	self.avatarView.layer.cornerRadius = CGRectGetWidth(self.view.frame) / 2.0;
}

- (void)startCapture {
	if (isCapturing) return;
	isCapturing = YES;
	for (UIView *subview in [self.view.subviews copy]) {
		[subview removeFromSuperview];
	}
	previousFrame = self.view.frame;
	self.view.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
	self.view.layer.cornerRadius = 0.0f;
	UIView *shadeView = [[UIView alloc] initWithFrame:self.view.frame];
	shadeView.alpha = 0.85f;
	shadeView.backgroundColor = [UIColor blackColor];
	[self.view insertSubview:shadeView atIndex:0];
	// Do any additional setup after loading the view.
	self.captureSession = [[AVCaptureSession alloc] init];
	self.captureSession.sessionPreset = AVCaptureSessionPresetPhoto;

	self.capturedImageView = [[UIImageView alloc] init];
	self.capturedImageView.frame = previousFrame;
	self.capturedImageView.layer.cornerRadius = CGRectGetWidth(self.capturedImageView.frame) / 2;
	self.capturedImageView.layer.masksToBounds = YES;
	self.capturedImageView.backgroundColor = [UIColor clearColor];
	self.capturedImageView.userInteractionEnabled = YES;
	self.capturedImageView.contentMode = UIViewContentModeScaleAspectFill;

	self.captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
	self.captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
	self.captureVideoPreviewLayer.frame = previousFrame; // self.view.frame;
	self.captureVideoPreviewLayer.cornerRadius = CGRectGetWidth(self.captureVideoPreviewLayer.frame) / 2;
	[self.view.layer addSublayer:self.captureVideoPreviewLayer];

	NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
	if (devices.count > 0) {
		self.captureDevice = devices[0];
		for (AVCaptureDevice *device in devices) {
			if (device.position == AVCaptureDevicePositionFront) {
				self.captureDevice = device;
				break;
			}
		}

		NSError *error = nil;
		AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:self.captureDevice error:&error];

		[self.captureSession addInput:input];

		self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
		NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG, AVVideoCodecKey, nil];
		[self.stillImageOutput setOutputSettings:outputSettings];
		[self.captureSession addOutput:self.stillImageOutput];

		if (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft) {
			_captureVideoPreviewLayer.connection.videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
		} else if (self.interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
			_captureVideoPreviewLayer.connection.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
		}

		UIButton *shutterButton =
			[[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.bounds) / 2 - 50,
								   previousFrame.origin.y + previousFrame.size.height + 10, 100, 100)];
		[shutterButton setImage:[UIImage imageNamed:@"PKImageBundle.bundle/take-snap"] forState:UIControlStateNormal];
		[shutterButton addTarget:self action:@selector(capturePhoto:) forControlEvents:UIControlEventTouchUpInside];
		[shutterButton setTintColor:[UIColor blueColor]];
		[shutterButton.layer setCornerRadius:20.0];
		[self.view addSubview:shutterButton];

		UIButton *swapCamerasButton =
			[[UIButton alloc] initWithFrame:CGRectMake(previousFrame.origin.x, previousFrame.origin.y - 35, 47, 25)];
		[swapCamerasButton setImage:[UIImage imageNamed:@"PKImageBundle.bundle/front-camera"] forState:UIControlStateNormal];
		[swapCamerasButton addTarget:self action:@selector(swapCameras:) forControlEvents:UIControlEventTouchUpInside];
		[self.view addSubview:swapCamerasButton];
	}

	UIButton *showImagePickerButton = [[UIButton alloc]
		initWithFrame:CGRectMake(previousFrame.origin.x + previousFrame.size.width - 27, previousFrame.origin.y - 35, 27, 27)];
	[showImagePickerButton setImage:[UIImage imageNamed:@"PKImageBundle.bundle/library"] forState:UIControlStateNormal];
	[showImagePickerButton addTarget:self action:@selector(showImagePicker:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:showImagePickerButton];

	UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.bounds) / 2 - 16,
									    previousFrame.origin.y + previousFrame.size.height + 120, 32, 32)];
	[cancelButton setImage:[UIImage imageNamed:@"PKImageBundle.bundle/cancel"] forState:UIControlStateNormal];
	[cancelButton addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:cancelButton];

	self.imageSelectedView = [[UIView alloc] initWithFrame:self.view.frame];
	[self.imageSelectedView setBackgroundColor:[UIColor clearColor]];
	[self.imageSelectedView addSubview:self.capturedImageView];

	UIView *overlayView = [[UIView alloc]
		initWithFrame:CGRectMake(0, previousFrame.origin.y + CGRectGetHeight(previousFrame), CGRectGetWidth(self.view.frame), 60)];
	[self.imageSelectedView addSubview:overlayView];
	UIButton *selectPhotoButton = [[UIButton alloc] initWithFrame:CGRectMake(previousFrame.origin.x, 0, 32, 32)];
	[selectPhotoButton setImage:[UIImage imageNamed:@"PKImageBundle.bundle/selected"] forState:UIControlStateNormal];
	[selectPhotoButton addTarget:self action:@selector(photoSelected:) forControlEvents:UIControlEventTouchUpInside];
	[overlayView addSubview:selectPhotoButton];

	UIButton *cancelSelectPhotoButton =
		[[UIButton alloc] initWithFrame:CGRectMake(previousFrame.origin.x + previousFrame.size.width - 32, 0, 32, 32)];
	[cancelSelectPhotoButton setImage:[UIImage imageNamed:@"PKImageBundle.bundle/cancel"] forState:UIControlStateNormal];
	[cancelSelectPhotoButton addTarget:self action:@selector(cancelSelectedPhoto:) forControlEvents:UIControlEventTouchUpInside];
	[overlayView addSubview:cancelSelectPhotoButton];

	[self.captureSession startRunning];
	[[UIApplication sharedApplication] setStatusBarHidden:YES];
}

- (void)endCapture {
	[self.captureSession stopRunning];
	[[UIApplication sharedApplication] setStatusBarHidden:NO];
	[self.captureVideoPreviewLayer removeFromSuperlayer];
	for (UIView *subview in [self.view.subviews copy]) {
		[subview removeFromSuperview];
	}
	self.view.frame = previousFrame;
	self.avatarView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(previousFrame), CGRectGetHeight(previousFrame))];
	self.avatarView.image = self.image;
	self.avatarView.contentMode = UIViewContentModeScaleAspectFill;
	self.avatarView.layer.masksToBounds = YES;
	self.avatarView.layer.cornerRadius = self.avatarView.frame.size.width / 2;
	[self.view addSubview:self.avatarView];
	self.view.layer.cornerRadius = self.view.frame.size.width / 2;
	isCapturing = NO;
}

- (IBAction)capturePhoto:(id)sender {
	self.isCapturingImage = YES;
	AVCaptureConnection *videoConnection = nil;
	for (AVCaptureConnection *connection in _stillImageOutput.connections) {
		for (AVCaptureInputPort *port in [connection inputPorts]) {
			if ([[port mediaType] isEqual:AVMediaTypeVideo]) {
				videoConnection = connection;
				break;
			}
		}
		if (videoConnection) {
			break;
		}
	}

	[self.stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection
							   completionHandler:^(CMSampleBufferRef imageSampleBuffer, NSError *error) {

								   if (imageSampleBuffer != NULL) {

									   NSData *imageData = [AVCaptureStillImageOutput
										   jpegStillImageNSDataRepresentation:imageSampleBuffer];
									   UIImage *capturedImage = [[UIImage alloc] initWithData:imageData scale:1];
									   self.isCapturingImage = NO;
									   self.capturedImageView.image = capturedImage;
									   for (UIView *view in self.view.subviews) {
										   if ([view class] == [UIButton class]) view.hidden = YES;
									   }
									   [self.view addSubview:self.imageSelectedView];
									   self.selectedImage = capturedImage;
									   imageData = nil;
								   }
							   }];
}

- (IBAction)swapCameras:(id)sender {
	if (self.isCapturingImage != YES) {
		if (self.captureDevice == [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo][0]) {
			// rear active, switch to front
			self.captureDevice = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo][1];

			[self.captureSession beginConfiguration];
			AVCaptureDeviceInput *newInput = [AVCaptureDeviceInput deviceInputWithDevice:self.captureDevice error:nil];
			for (AVCaptureInput *oldInput in self.captureSession.inputs) {
				[self.captureSession removeInput:oldInput];
			}
			[self.captureSession addInput:newInput];
			[self.captureSession commitConfiguration];
		} else if (self.captureDevice == [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo][1]) {
			// front active, switch to rear
			self.captureDevice = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo][0];
			[self.captureSession beginConfiguration];
			AVCaptureDeviceInput *newInput = [AVCaptureDeviceInput deviceInputWithDevice:self.captureDevice error:nil];
			for (AVCaptureInput *oldInput in self.captureSession.inputs) {
				[self.captureSession removeInput:oldInput];
			}
			[self.captureSession addInput:newInput];
			[self.captureSession commitConfiguration];
		}

		// Need to reset flash btn
	}
}

- (IBAction)showImagePicker:(id)sender {
	self.picker = [[UIImagePickerController alloc] init];
	self.picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
	self.picker.delegate = self;
	[self presentViewController:self.picker animated:YES completion:nil];
}

- (IBAction)photoSelected:(id)sender {
	self.image = self.selectedImage;
	[self endCapture];
	if ([self.delegate respondsToSelector:@selector(imageSelected:)]) {
		[self.delegate imageSelected:self.image];
	}
}

- (IBAction)cancelSelectedPhoto:(id)sender {
	[self.imageSelectedView removeFromSuperview];
	for (UIView *view in self.view.subviews) {
		if ([view class] == [UIButton class]) view.hidden = NO;
	}
}

- (IBAction)cancel:(id)sender {
	[self endCapture];
	if ([self.delegate respondsToSelector:@selector(imageSelectionCancelled)]) {
		[self.delegate imageSelectionCancelled];
	}
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	self.selectedImage = [info objectForKey:UIImagePickerControllerOriginalImage];

	[self dismissViewControllerAnimated:YES
				   completion:^{
					   self.capturedImageView.image = self.selectedImage;
					   for (UIView *view in self.view.subviews) {
						   if ([view class] == [UIButton class]) view.hidden = YES;
					   }
					   [self.view addSubview:self.imageSelectedView];
				   }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	[self dismissViewControllerAnimated:YES completion:nil];
}

@end
