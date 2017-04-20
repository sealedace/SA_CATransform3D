//
//  ViewController.m
//  CATransform3D
//
//  Created by sealedace on 20/4/2017.
//  Copyright © 2017 sealedace. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () {
}

@property (strong, nonatomic) CATransformLayer *baseLayer;
@property (strong, nonatomic) CALayer *greenLayer;
@property (strong, nonatomic) CALayer *magentaLayer;
@property (strong, nonatomic) CALayer *blueLayer;
@property (strong, nonatomic) CALayer *yellowLayer;
@property (strong, nonatomic) CALayer *purpleLayer;

@property (nonatomic) BOOL isThreeDee;

@end

@implementation ViewController

- (CATransformLayer *)baseLayer {
    if (!_baseLayer) {
        _baseLayer = [CATransformLayer layer];
        _baseLayer.anchorPoint = CGPointZero;
        _baseLayer.bounds = self.view.bounds;
        _baseLayer.position = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
    }
    return _baseLayer;
}

- (CALayer *)blueLayer {
    if (!_blueLayer) {
        _blueLayer = [CALayer layer];
        _blueLayer.backgroundColor = [UIColor blueColor].CGColor;
        _blueLayer.bounds = CGRectMake(0, 0, 100, 100);
        _blueLayer.anchorPoint = CGPointMake(1, 0.5); // right
        _blueLayer.position = CGPointMake(-50,0);
    }
    return _blueLayer;
}

- (CALayer *)yellowLayer {
    if (!_yellowLayer) {
        _yellowLayer = [CALayer layer];
        _yellowLayer.backgroundColor = [UIColor purpleColor].CGColor;
        _yellowLayer.bounds = CGRectMake(0, 0, 100, 100);
        _yellowLayer.anchorPoint = CGPointMake(0.5, 1); // bottom
        _yellowLayer.position = CGPointMake(0,-50);
    }
    return _yellowLayer;
}

- (CALayer *)purpleLayer {
    if (!_purpleLayer) {
        _purpleLayer = [CALayer layer];
        _purpleLayer.backgroundColor = [UIColor yellowColor].CGColor;
        _purpleLayer.bounds = CGRectMake(0, 0, 100, 100);
        _purpleLayer.anchorPoint = CGPointMake(0.5, 0); // top
        _purpleLayer.position = CGPointMake(0,50);
    }
    return _purpleLayer;
}

- (CALayer *)greenLayer {
    if (!_greenLayer) {
        _greenLayer = [CATransformLayer layer];
        _greenLayer.bounds = CGRectMake(0, 0, 100, 100);
        _greenLayer.anchorPoint = CGPointMake(0, 0.5); // left
        _greenLayer.position = CGPointMake(50,0);
    }
    return _greenLayer;
}

- (CALayer *)magentaLayer {
    if (!_magentaLayer) {
        _magentaLayer = [CALayer layer];
        _magentaLayer.backgroundColor = [UIColor magentaColor].CGColor;
        _magentaLayer.bounds = CGRectMake(0, 0, 100, 100);
        _magentaLayer.anchorPoint = CGPointMake(0, 0.5); // left
        _magentaLayer.position = CGPointMake(100,50);
        _magentaLayer.doubleSided = YES;
    }
    return _magentaLayer;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [self.view addGestureRecognizer:pan];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [self.view addGestureRecognizer:tap];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    [self.view.layer addSublayer:self.baseLayer];
    
    CALayer *redLayer = [CALayer layer];
    redLayer.backgroundColor = [UIColor redColor].CGColor;
    redLayer.frame = CGRectMake(0, 0, 100, 100);
    redLayer.position = CGPointMake(0,0);
    [self.baseLayer addSublayer:redLayer];
    
    [self.baseLayer addSublayer:self.blueLayer];
    
    [self.baseLayer addSublayer:self.yellowLayer];
    
    [self.baseLayer addSublayer:self.purpleLayer];
    
    // need a transform layer for green to mount magenta on
    
    [self.baseLayer addSublayer:self.greenLayer];
    
    CALayer *greenSolidLayer = [CALayer layer];
    greenSolidLayer.backgroundColor = [UIColor greenColor].CGColor;
    greenSolidLayer.bounds = CGRectMake(0, 0, 100, 100);
    greenSolidLayer.anchorPoint = CGPointMake(0, 0); // top left
    greenSolidLayer.position = CGPointMake(0,0);
    [self.greenLayer addSublayer:greenSolidLayer];
    
    // the "lid"
    
    [self.greenLayer addSublayer:self.magentaLayer];
    
    CATransform3D initialTransform = self.baseLayer.sublayerTransform;
    initialTransform.m34 = 1.0 / -300;
    self.baseLayer.sublayerTransform = initialTransform;
}

- (void)pan:(UIPanGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateChanged)
    {
        CGPoint displacement = [gesture translationInView:self.view];
        CATransform3D currentTransform = self.baseLayer.sublayerTransform;
        
        if (displacement.x==0 && displacement.y==0)
        {
            // no rotation, nothing to do
            return;
        }
        
        CGFloat totalRotation = sqrt(displacement.x * displacement.x + displacement.y * displacement.y) * M_PI / 180.0;
        CGFloat xRotationFactor = displacement.x/totalRotation;
        CGFloat yRotationFactor = displacement.y/totalRotation;
        
        if (self.isThreeDee)
        {
            currentTransform = CATransform3DTranslate(currentTransform, 0, 0, 50);
        }
        
        CATransform3D rotationalTransform = CATransform3DRotate(currentTransform, totalRotation,
                                                                (xRotationFactor * currentTransform.m12 - yRotationFactor * currentTransform.m11),
                                                                (xRotationFactor * currentTransform.m22 - yRotationFactor * currentTransform.m21),
                                                                (xRotationFactor * currentTransform.m32 - yRotationFactor * currentTransform.m31));
        
        if (self.isThreeDee)
        {
            rotationalTransform = CATransform3DTranslate(rotationalTransform, 0, 0, -50);
        }
        
        [CATransaction setAnimationDuration:0];
        
        self.baseLayer.sublayerTransform = rotationalTransform;
        
        [gesture setTranslation:CGPointZero inView:self.view];
    }
}

- (void)tap:(UITapGestureRecognizer *)gesture
{
    self.isThreeDee = !self.isThreeDee;
    
    if (self.isThreeDee)
    {
        self.greenLayer.transform = CATransform3DMakeRotation(-M_PI_2, 0, 1, 0);
        self.blueLayer.transform = CATransform3DMakeRotation(M_PI_2, 0, 1, 0);
        self.yellowLayer.transform = CATransform3DMakeRotation(-M_PI_2, 1, 0, 0);
        self.purpleLayer.transform = CATransform3DMakeRotation(M_PI_2, 1, 0, 0);
        self.magentaLayer.transform = CATransform3DMakeRotation(0.8*-M_PI_2, 0, 1, 0);
    }
    else
    {
        self.greenLayer.transform = CATransform3DIdentity;
        self.blueLayer.transform = CATransform3DIdentity;
        self.yellowLayer.transform = CATransform3DIdentity;
        self.purpleLayer.transform = CATransform3DIdentity;
        self.magentaLayer.transform = CATransform3DIdentity;
    }
}


@end
