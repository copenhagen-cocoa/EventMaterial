//
//  Waitress.h
//  TheBodega
//
//  Created by Mikkel Sindberg Eriksen on 26/04/2016.
//  Copyright © 2016 Mikkel Sindberg Eriksen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BeerFridge.h"

/**
 * @brief A protocol defining an interface for fetching beer.
 */
@protocol BeerFetching <NSObject>

/**
 * @brief A property indicating if BeerFetching is busy.
 */
@property (nonatomic, assign, readonly) BOOL busy;

/**
 * @brief Fetch a beer from the given storage and execute complete when done.
 * 
 * @param beerStorage The storage that the beer should be fetched from.
 * @param complete The completion block to execute when done fetching.
 */
- (void)fetchBeerFromStorage:(id <BeerStoring>)beerStorage
                    complete:(void(^)(Beer *beer, NSError *error))complete;

@end


/**
 * @brief Class representing a waitress for fetching beer!
 */
@interface Waitress : NSObject <BeerFetching>

/**
 * @brief The name of the waitress.
 */
@property (nonatomic, strong, readonly) NSString *name;

/**
 * @brief Initializes a waitress with the given name.
 *
 * @param name The name to give the waitress.
 *
 * @return A waitress initialized with the given name.
 */
- (instancetype)initWithName:(NSString *)name;

@end
