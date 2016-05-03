//
//  Beer.m
//  TheBodega
//
//  Created by Mikkel Sindberg Eriksen on 26/04/2016.
//  Copyright © 2016 Mikkel Sindberg Eriksen. All rights reserved.
//

#import "Beer.h"

@interface Beer ()

@property (nonatomic, strong, readwrite) NSString *name;
@property (nonatomic, strong, readwrite) NSNumber *percentage;
@property (nonatomic, strong, readwrite) NSNumber *centiliters;

@end


@implementation Beer


#pragma mark - Public Interface

- (instancetype)initWithName:(NSString *)name
           alcoholPercentage:(NSNumber *)percentage
                 centiliters:(NSNumber *)centiliters{

    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.name = name;
    self.percentage = percentage;
    self.centiliters = centiliters;
    
    return self;
}

@end
