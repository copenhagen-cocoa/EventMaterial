//
//  Bodega.m
//  TheBodega
//
//  Created by Mikkel Sindberg Eriksen on 27/04/2016.
//  Copyright © 2016 Unwire. All rights reserved.
//

#import "Bodega.h"
#import "Waitress.h"

NSString * const BodegaErrorDomain = @"Bodega panic!";


@interface Bodega ()

@property (nonatomic, strong, readwrite) NSString   *name;
@property (nonatomic, strong, readwrite) Waitress   *waitress;

@end


@implementation Bodega


#pragma mark - Public Interface

- (instancetype)initWithName:(NSString *)name{

    self = [super init];
    if (!self) {
        return nil;
    }

    self.name = name;
    self.waitress = [[Waitress alloc] initWithName:@"Cindy"];
    
    return self;
}

- (void)orderBeerWithCompletion:(void (^)(Beer *beer, NSError *error))complete{

    if (self.waitress.busy) {
    
        if (complete) {
            complete(nil, [self bodegaErrorWithErrorCode:BodegaErrorCodeStaffBusy]);
        }
    
    } else {
        
        if (complete) {
            [self.waitress fetchBeerWithCompletion:^(Beer *beer, NSError *error) {
                complete(beer, error);
            }];
        }
        
    }
}


#pragma mark - Internal Helpers

- (NSError *)bodegaErrorWithErrorCode:(BodegaErrorCode)errorCode{

    return [NSError errorWithDomain:BodegaErrorDomain code:errorCode userInfo:nil];
}


@end
