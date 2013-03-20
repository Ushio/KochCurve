
#import "ViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <GLKit/GLKMath.h>

@implementation ViewController
{
    IBOutlet UIImageView *canvas;
    int iterationCount;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    canvas.layer.borderWidth = 1.0;
    canvas.layer.borderColor = [UIColor redColor].CGColor;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)drawKochCurve:(CGContextRef)context iteration:(int)iteration beg:(GLKVector2)beg end:(GLKVector2)end
{
    if(iteration <= 0)
    {
        CGPoint line[] = {{beg.x, beg.y}, {end.x, end.y}};
        CGContextStrokeLineSegments(context, line, 2);
    }
    else
    {
        GLKVector2 p0 = beg;
        GLKVector2 p4 = end;
        
        GLKVector2 vector = GLKVector2Subtract(end, beg);
        GLKVector2 nvector = GLKVector2Normalize(vector);
        GLKVector2 p1 = GLKVector2Lerp(beg, end, 1.0 / 3.0);
        GLKVector2 p3 = GLKVector2Lerp(beg, end, 2.0 / 3.0);
        
        GLKMatrix3 rotate = GLKMatrix3MakeRotation(GLKMathDegreesToRadians(90.0f), 0, 0, 1);
        GLKVector3 rotated3 = GLKMatrix3MultiplyVector3(rotate, GLKVector3Make(nvector.x, nvector.y, 0.0f));
        GLKVector2 rotated = {rotated3.x, rotated3.y};
        
        GLKVector2 center = GLKVector2DivideScalar(GLKVector2Add(beg, end), 2.0f);
        float length = GLKVector2Distance(beg, end) / 3.0 * 0.5f * tanf(GLKMathDegreesToRadians(45.0f));
        GLKVector2 p2 = GLKVector2Add(center, GLKVector2MultiplyScalar(rotated, length));
        
        GLKVector2 lines[] = {p0, p1, p2, p3, p4};
        for(int i = 0 ; i < sizeof(lines) / sizeof(lines[0]) - 1 ; ++i)
        {
            [self drawKochCurve:context iteration:iteration - 1 beg:lines[i] end:lines[i + 1]];
        }
    }

}

- (IBAction)generate:(id)sender
{
    const int size = 320 * [UIScreen mainScreen].scale;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL,
                                                 size, size,
                                                 8, 4 * size,
                                                 colorSpace,
                                                 kCGImageAlphaPremultipliedLast);
    CGColorSpaceRelease(colorSpace);
    colorSpace = NULL;
    
    /**
     drawing
     */
    [self drawKochCurve:context iteration:iterationCount beg:GLKVector2Make(0, size / 2) end:GLKVector2Make(size, size / 2)];
    ++iterationCount;
    
    /**
     *create image
     */
    CGImageRef imageFromContext = CGBitmapContextCreateImage(context);
    UIImage *image = [UIImage imageWithCGImage:imageFromContext scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
    CGImageRelease(imageFromContext);
    imageFromContext = NULL;
    
    CGContextRelease(context);
    
    canvas.image = image;
}

@end
