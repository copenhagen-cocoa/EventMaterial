//
//  Waitress.m
//  TheBodega
//
//  Created by Mikkel Sindberg Eriksen on 27/04/2016.
//  Copyright © 2016 Unwire. All rights reserved.
//

#import "Waitress.h"

@interface Waitress ()

@property (nonatomic, strong, readwrite) NSString *name;
@property (nonatomic, assign, readwrite) BOOL busy;

@end


@implementation Waitress


#pragma mark - Public Interface

- (instancetype)initWithName:(NSString *)name{

    self = [super init];
    if (!self) {
        return nil;
    }

    self.name = name;
    
    return self;
}

- (void)fetchBeerWithCompletion:(void (^)(Beer *, NSError *))complete{

    self.busy = YES;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
    
        Beer *beer = [[NSUserDefaults standardUserDefaults] objectForKey:@"BeerFridge"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            self.busy = NO;
            
            if (complete) {
                complete(beer, nil);
            }
            
        });
        
    });
}


@end
