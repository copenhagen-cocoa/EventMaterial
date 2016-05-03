//
//  BeerFridge.h
//  TheBodega
//
//  Created by Mikkel Sindberg Eriksen on 27/04/2016.
//  Copyright © 2016 Unwire. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Beer.h"

/**
 * @brief A protocol defining an interface for storing beer.
 */
@protocol BeerStoring <NSObject>

/**
 * @brief A method to grab a beer from the storage.
 *
 * @return A beer from the storage
 */
- (Beer *)grabBeer;

/**
 * @brief A method to put a beer into the storage.
 *
 * @param beer The beer to put in tht storage.
 */
- (void)storeBeer:(Beer *)beer;

@end


/**
 * @brief BeerFridge is a simple default implementation of BeerStorage.
 */
@interface BeerFridge : NSObject <BeerStoring>

@end
