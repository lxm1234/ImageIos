//
//  ViewController.m
//  ImageDemo
//
//  Created by lxm on 2017/12/8.
//  Copyright © 2017年 lxm. All rights reserved.
//

#import "ViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface ViewController ()<UIImagePickerControllerDelegate>{
    UIImageView* imageview;
    UIImageView* imageview1;
    UIImageView* imageview2;
    UIImageView* imageview3;
    UIImageView* imageview4;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    [self loadImage];
//    [self convertTest];
//    [self greyTest];
//    [self reColorTest];
//    [self reColorTest1];
//    [self imageHighLight];
    // Do any additional setup after loading the view, typically from a nib.
    [self configCamera];
}
- (void)configCamera{
    UIImagePickerController *controller = [[UIImagePickerController alloc] init];
    controller.sourceType = UIImagePickerControllerSourceTypeCamera;
    NSString* mediaType = (__bridge NSString*)kUTTypeImage;
    controller.mediaTypes = [[NSArray alloc] initWithObjects:mediaType, nil];
    controller.delegate = self;
    [self.navigationController presentViewController:controller animated:false completion:nil];
}

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    NSString* mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(__bridge NSString*)kUTTypeImage]) {
        UIImage* image = [info objectForKey:UIImagePickerControllerOriginalImage];
        unsigned char* imageData = [self convertImageToByte:image];
        unsigned char* newImageData = [self convertReColorData:imageData width:image.size.width height:image.size.height];
        UIImage* newImage = [self convertDataToImage:newImageData image:image];
        UIImageWriteToSavedPhotosAlbum(newImage, nil, nil, nil);
    }
}
- (void)convertTest {
    UIImage* image = [UIImage imageNamed:@"IMG_0435"];
    unsigned char* imageData = [self convertImageToByte:image];
    UIImage* imageNew = [self convertDataToImage:imageData image:image];
    imageview1.image = imageNew;
}
- (void)greyTest {
    UIImage* image = [UIImage imageNamed:@"IMG_0435"];
    unsigned char* imageData = [self convertImageToByte:image];
    unsigned char* imageNewData = [self convertImageGreyData:imageData width:image.size.width height:image.size.height];
    UIImage* imageNew = [self convertDataToImage:imageNewData image:image];
    imageview2.image = imageNew;
}
- (void)reColorTest {
    UIImage* image = [UIImage imageNamed:@"IMG_0435"];
    unsigned char* imageData = [self convertImageToByte:image];
    unsigned char* imageNewData = [self convertReColorData:imageData width:image.size.width height:image.size.height];
    UIImage* imageNew = [self convertDataToImage:imageNewData image:image];
    imageview3.image = imageNew;
}
- (void)reColorTest1 {
    UIImage* image = [UIImage imageNamed:@"IMG_0435"];
    unsigned char* imageData = [self convertImageToByte:image];
    unsigned char* imageData1 = [self convertImageGreyData:imageData width:image.size.width height:image.size.height];
    unsigned char* imageNewData = [self convertReColorData:imageData1 width:image.size.width height:image.size.height];
    UIImage* imageNew = [self convertDataToImage:imageNewData image:image];
    imageview4.image = imageNew;
}
- (void)imageHighLight {
    UIImage* image = [UIImage imageNamed:@"IMG_0435"];
    unsigned char* imageData = [self convertImageToByte:image];
    unsigned char* imageNewData = [self convertHighLightData:imageData width:image.size.width height:image.size.height];
    UIImage* imageNew = [self convertDataToImage:imageNewData image:image];
    imageview4.image = imageNew;
}
- (unsigned char*)convertImageGreyData:(unsigned char*)imageData width:(float)width height:(float)height {
    unsigned char* result = malloc(width * height * 4 * sizeof(unsigned char));
    memset(result, 0 , width * height * 4 * sizeof(unsigned char));
    for (int w = 0; w < height; ++w) {
        for (int n = 0; n < width; ++n) {
            int bitmapIndex = n + w * width;
            unsigned char red = *(imageData + bitmapIndex*4);
            unsigned char green = *(imageData + bitmapIndex*4 + 1);
            unsigned char blue = *(imageData + bitmapIndex*4 + 2);
            int bitmap = red * 77/255 + green * 151/255 + blue * 88/255;
            bitmap = bitmap > 255 ? 255 : bitmap;
            memset(result + bitmapIndex * 4, bitmap, 1);
            memset(result + bitmapIndex * 4 + 1, bitmap, 1);
            memset(result + bitmapIndex * 4 + 2, bitmap, 1);
        }
    }
    
    return result;
}
- (unsigned char*)convertReColorData:(unsigned char*)imageData width:(float)width height:(float)height {
    unsigned char* result = malloc(width * height * 4 * sizeof(unsigned char));
    memset(result, 0 , width * height * 4 * sizeof(unsigned char));
    for (int w = 0; w < height; ++w) {
        for (int n = 0; n < width; ++n) {
            int bitmapIndex = n + w * width;
            unsigned char red = *(imageData + bitmapIndex*4);
            unsigned char green = *(imageData + bitmapIndex*4 + 1);
            unsigned char blue = *(imageData + bitmapIndex*4 + 2);
            memset(result + bitmapIndex * 4,255 - red, 1);
            memset(result + bitmapIndex * 4 + 1,255 - green, 1);
            memset(result + bitmapIndex * 4 + 2, 255 - blue, 1);
        }
    }
    
    return result;
}
- (unsigned char*)convertHighLightData:(unsigned char*)imageData width:(float)width height:(float)height {
    unsigned char* result = malloc(width * height * 4 * sizeof(unsigned char));
    memset(result, 0 , width * height * 4 * sizeof(unsigned char));
    
    NSArray *array = @[@"55",@"110",@"155",@"185",@"220",@"240",@"250",@"255"];
    int beforNum= 0;
    NSMutableArray *newArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < 8; ++i) {
        NSString* str = [array objectAtIndex:i];
        int num = str.intValue;
        int step = 0;
        if (i == 0) {
            step = num/32.0;
            beforNum = step;
        } else {
            step = (num - beforNum)/32.0;
        }
        for (int j = 0; j < 32; ++j) {
            int newNum = 0;
            if (i == 0) {
                newNum = step * j;
            } else {
                newNum = step * j + beforNum;
            }
            [newArray addObject:[NSString stringWithFormat:@"%d",newNum]];
        }
        beforNum = num;
    }
    for (int w = 0; w < height; ++w) {
        for (int n = 0; n < width; ++n) {
            int bitmapIndex = n + w * width;
            unsigned char red = *(imageData + bitmapIndex*4);
            unsigned char green = *(imageData + bitmapIndex*4 + 1);
            unsigned char blue = *(imageData + bitmapIndex*4 + 2);
            NSString* sRed = [newArray objectAtIndex:red];
            NSString* sgreen = [newArray objectAtIndex:green];
            NSString* sBlue = [newArray objectAtIndex:blue];
            unsigned char newRed = sRed.intValue;
            unsigned char newGreen = sgreen.intValue;
            unsigned char newBlue = sBlue.intValue;
            memset(result + bitmapIndex * 4,newRed, 1);
            memset(result + bitmapIndex * 4 + 1,newGreen, 1);
            memset(result + bitmapIndex * 4 + 2, newBlue, 1);
        }
    }
    
    return result;
}

- (void)loadImage {
    imageview = [[UIImageView alloc] initWithFrame:CGRectMake(18, 20, 180, 135)];
    imageview.image = [UIImage imageNamed:@"IMG_0435"];
    [self.view addSubview:imageview];
    imageview1 = [[UIImageView alloc] initWithFrame:CGRectMake(218, 20, 180, 135)];
    [self.view addSubview:imageview1];
    imageview2 = [[UIImageView alloc] initWithFrame:CGRectMake(18, 175, 180, 135)];
    [self.view addSubview:imageview2];
    imageview3 = [[UIImageView alloc] initWithFrame:CGRectMake(218, 175, 180, 135)];
    [self.view addSubview:imageview3];
    imageview4 = [[UIImageView alloc] initWithFrame:CGRectMake(18, 335, 180, 135)];
    [self.view addSubview:imageview4];
}

- (unsigned char*) convertImageToByte:(UIImage*) image{
    CGImageRef imageRef = [image CGImage];
    CGSize image_size = [image size];
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    void* data = malloc(image_size.width*image_size.height*4);
    CGContextRef contextRef = CGBitmapContextCreate(data, image_size.width, image_size.height,8 , 4 * image_size.width, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGContextDrawImage(contextRef, CGRectMake(0, 0, image_size.width, image_size.height), imageRef);
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(contextRef);
    return (unsigned char*) data;
}
- (UIImage*) convertDataToImage:(unsigned char*) imageData image:(UIImage*)imageSource{
    float width = imageSource.size.width;
    float height = imageSource.size.height;
    NSInteger dataLength = width * height * 4;
    int bitsPerComponent = 8;
    int bitsPerPixel = 32;
    int bytesPerRow = 4 * width;
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
    CGColorRenderingIntent renderIntent = kCGRenderingIntentDefault;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGDataProviderRef providerRef = CGDataProviderCreateWithData(NULL, imageData, dataLength, NULL);
    CGImageRef imageRef = CGImageCreate(width, height, bitsPerComponent, bitsPerPixel, bytesPerRow, colorSpace, bitmapInfo, providerRef, NULL, NO, renderIntent);
    UIImage*  imageNew = [UIImage imageWithCGImage:imageRef];
    CFRelease(imageRef);
    CGColorSpaceRelease(colorSpace);
    CGDataProviderRelease(providerRef);
    return  imageNew;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
