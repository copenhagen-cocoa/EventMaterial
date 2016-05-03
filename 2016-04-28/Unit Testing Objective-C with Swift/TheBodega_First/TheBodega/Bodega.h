//
//  Bodega.h
//  TheBodega
//
//  Created by Mikkel Sindberg Eriksen on 27/04/2016.
//  Copyright © 2016 Unwire. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Beer.h"

/** The error domain for the bodega */
extern NSString * const BodegaErrorDomain;

typedef NS_ENUM(NSInteger, BodegaErrorCode) {
    /** An unknown error happened in the Bodega */
    BodegaErrorCodeUnknown,
    /** The Bodega staff is busy */
    BodegaErrorCodeStaffBusy,
    /** The Bodega is out of beer */
    BodegaErrorCodeOutOfBeer,
};


/**
 * @brief A class representing a cosy bodega.
 */
@interface Bodega : NSObject

/**
 * @brief The name of the bodega.
 */
@property (nonatomic, strong, readonly) NSString *name;

/**
 * @brief Initialize a bodega with the given name.
 *
 * @param name The name of the bodega.
 *
 * @return A bodega initialized with the given name.
 */
- (instancetype)initWithName:(NSString *)name;

/**
 * @brief A method to order a beer at the bodega.
 *
 * @param complete The completion block, which will be executed when the beer order either succeeds or fails.
 */
- (void)orderBeerWithCompletion:(void(^)(Beer *beer, NSError *error))complete;

@end
