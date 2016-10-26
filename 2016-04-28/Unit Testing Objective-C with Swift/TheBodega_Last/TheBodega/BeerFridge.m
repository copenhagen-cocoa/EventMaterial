//
//  BeerFridge.m
//  TheBodega
//
//  Created by Mikkel Sindberg Eriksen on 27/04/2016.
//  Copyright © 2016 Unwire. All rights reserved.
//

#import "BeerFridge.h"

static NSString * const FridgeShelfKey = @"FridgeShelf";


@implementation BeerFridge


#pragma mark - BeerStoring Protocol Implementation

- (Beer *)grabBeer{

    return [[NSUserDefaults standardUserDefaults] objectForKey:FridgeShelfKey];
}

- (void)storeBeer:(Beer *)beer{

    [[NSUserDefaults standardUserDefaults] setObject:beer forKey:FridgeShelfKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
