//
//  Bodega.m
//  TheBodega
//
//  Created by Mikkel Sindberg Eriksen on 26/04/2016.
//  Copyright © 2016 Mikkel Sindberg Eriksen. All rights reserved.
//

#import "Bodega.h"

NSString * const BodegaErrorDomain = @"Bodega panic!";


@interface Bodega ()

@property (nonatomic, strong, readwrite) NSString           *name;
@property (nonatomic, strong, readwrite) id <BeerFetching>  waitress;
@property (nonatomic, strong, readwrite) id <BeerStoring>   beerStorage;

@end


@implementation Bodega


#pragma mark - Public Interface

- (instancetype)initWithName:(NSString *)name
                 beerStorage:(id<BeerStoring>)storage
                    waitress:(id<BeerFetching>)waitress{

    self = [super init];
    if (!self) {
        return nil;
    }

    self.name = name;
    self.beerStorage = storage;
    self.waitress = waitress;
    
    return self;
}

- (void)orderBeerWithCompletion:(void (^)(Beer *beer, NSError *error))complete{

    if (self.waitress.busy) {
    
        if (complete) {
            complete(nil, [self bodegaErrorWithErrorCode:BodegaErrorCodeStaffBusy]);
        }
    
    } else {
        
        if (complete) {
            [self.waitress fetchBeerFromStorage:self.beerStorage
                                       complete:^(Beer *beer, NSError *error) {
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
