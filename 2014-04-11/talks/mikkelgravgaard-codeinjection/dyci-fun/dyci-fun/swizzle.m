//
// Created by Mikkel Gravgaard on 27/02/14.
// Copyright (c) 2014 Betafunk. All rights reserved.
//

#import "swizzle.h"
#import <objc/runtime.h>

@implementation UICollectionView (ExceptionHandling)


-(void)swizzled_layoutSubviews {
   @try{
       [self swizzled_layoutSubviews];
   } @catch (NSException *e){
       NSLog(@"===== YOU FOOL! %@ =====",e);
       [self playAlarm];
   }
}

- (void)playAlarm{
    NSError *error = nil;
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"alarm" withExtension:@"wav"];
    AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    if(error) NSLog(@"%@",error);
    objc_setAssociatedObject(self, @"Player", player, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    player = objc_getAssociatedObject(self, @"Player");
    [player play];

}

+ (void)load {
   Method original, swizzled;

   original = class_getInstanceMethod(self, @selector(layoutSubviews));
   swizzled = class_getInstanceMethod(self, @selector(swizzled_layoutSubviews));
   method_exchangeImplementations(original, swizzled);

}
@end
