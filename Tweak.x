#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <Vision/Vision.h>
#import <objc/runtime.h>
#import <roothide.h>
#import <AudioToolbox/AudioToolbox.h>

// --- INTERFACES ---
@interface SBLockScreenManager : NSObject
+ (instancetype)sharedInstance;
- (BOOL)unlockUIFromSource:(int)source withOptions:(id)options;
@end

@interface CSCoverSheetViewController : UIViewController
@end

@interface FaceID2DManager : NSObject <AVCaptureVideoDataOutputSampleBufferDelegate>
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureVideoDataOutput *videoOutput;
@property (nonatomic, strong) dispatch_queue_t cameraQueue;
@property (nonatomic, weak) id currentCoverSheet;
@property (nonatomic, assign) BOOL isProcessingFrame;
+ (instancetype)sharedManager;
- (void)startCameraSession;
- (void)stopCameraSession;
@end

// --- IMPLEMENTATION ---
@implementation FaceID2DManager

+ (instancetype)sharedManager {
    static FaceID2DManager *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[FaceID2DManager alloc] init];
    });
    return shared;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _isProcessingFrame = NO;
        _cameraQueue = dispatch_queue_create("com.faceid2d.cameraQueue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (void)setupCamera {
    if (self.captureSession) return;

    self.captureSession = [[AVCaptureSession alloc] init];
    [self.captureSession beginConfiguration];
    self.captureSession.sessionPreset = AVCaptureSessionPreset640x480;

    AVCaptureDevice *frontCamera = nil;
    AVCaptureDeviceDiscoverySession *discoverySession = [AVCaptureDeviceDiscoverySession 
        discoverySessionWithDeviceTypes:@[AVCaptureDeviceTypeBuiltInWideAngleCamera]
        mediaType:AVMediaTypeVideo
        position:AVCaptureDevicePositionFront];
    NSArray *devices = discoverySession.devices;
    for (AVCaptureDevice *device in devices) {
        if (device.position == AVCaptureDevicePositionFront) {
            frontCamera = device;
            break;
        }
    }

    if (!frontCamera) {
        NSLog(@"[FaceID2D] Front camera not found.");
        [self.captureSession commitConfiguration];
        return;
    }

    NSError *error = nil;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:frontCamera error:&error];
    if (error || !input) {
        NSLog(@"[FaceID2D] Camera input error: %@", error.localizedDescription);
        [self.captureSession commitConfiguration];
        return;
    }

    if ([self.captureSession canAddInput:input]) {
        [self.captureSession addInput:input];
    }

    self.videoOutput = [[AVCaptureVideoDataOutput alloc] init];
    self.videoOutput.alwaysDiscardsLateVideoFrames = YES;
    [self.videoOutput setSampleBufferDelegate:self queue:self.cameraQueue];

    NSDictionary *videoSettings = @{(id)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA)};
    [self.videoOutput setVideoSettings:videoSettings];

    if ([self.captureSession canAddOutput:self.videoOutput]) {
        [self.captureSession addOutput:self.videoOutput];
    }

    [self.captureSession commitConfiguration];
    NSLog(@"[FaceID2D] Camera setup completed successfully.");
}

- (void)startCameraSession {
    dispatch_async(self.cameraQueue, ^{
        [self setupCamera];
        if (self.captureSession && !self.captureSession.isRunning) {
            [self.captureSession startRunning];
            NSLog(@"[FaceID2D] Camera session started.");
        }
    });
}

- (void)stopCameraSession {
    dispatch_async(self.cameraQueue, ^{
        [self stopCameraSessionBlock];
    });
}

- (void)stopCameraSessionBlock {
    if (self.captureSession && self.captureSession.isRunning) {
        [self.captureSession stopRunning];
        NSLog(@"[FaceID2D] Camera session stopped.");
    }
}

- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    if (self.isProcessingFrame) return;
    self.isProcessingFrame = YES;

    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    if (!pixelBuffer) {
        self.isProcessingFrame = NO;
        return;
    }

    VNImageRequestHandler *handler = [[VNImageRequestHandler alloc] initWithCVPixelBuffer:pixelBuffer options:@{}];
    VNDetectFaceRectanglesRequest *request = [[VNDetectFaceRectanglesRequest alloc] initWithCompletionHandler:^(VNRequest *req, NSError *err) {
        if (err) {
            NSLog(@"[FaceID2D] Vision error: %@", err.localizedDescription);
            self.isProcessingFrame = NO;
            return;
        }

        NSArray *results = req.results;
        if (results && results.count > 0) {
            NSLog(@"[FaceID2D] Face detected! Triggering unlock...");
            [self triggerUnlock];
        } else {
            self.isProcessingFrame = NO;
        }
    }];

    [handler performRequests:@[request] error:nil];
}

- (void)triggerUnlock {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self stopCameraSessionBlock];
        SBLockScreenManager *lockManager = [NSClassFromString(@"SBLockScreenManager") sharedInstance];
        if (lockManager && [lockManager respondsToSelector:@selector(unlockUIFromSource:withOptions:)]) {
            [lockManager unlockUIFromSource:0 withOptions:nil];
            NSLog(@"[FaceID2D] Unlocked via SBLockScreenManager successfully!");
        }
        self.isProcessingFrame = NO;
    });
}

@end 

%hook CSCoverSheetViewController

- (void)viewDidAppear:(BOOL)animated {
    %orig;
    AudioServicesPlaySystemSound(1520); 
    NSLog(@"[FaceID2D] Lockscreen appeared.");
    [FaceID2DManager sharedManager].currentCoverSheet = self;
    [[FaceID2DManager sharedManager] startCameraSession];
}

- (void)viewWillDisappear:(BOOL)animated {
    %orig;
    NSLog(@"[FaceID2D] Lockscreen disappeared.");
    [[FaceID2DManager sharedManager] stopCameraSession];
}

%end

%ctor {
    NSLog(@"[FaceID2D] === Tweak loaded into SpringBoard via Roothide! ===");
}