//
//  Waitress.h
//  TheBodega
//
//  Created by Mikkel Sindberg Eriksen on 27/04/2016.
//  Copyright © 2016 Unwire. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Beer.h"

/**
 * @brief Class representing a waitress for fetching beer!
 */
@interface Waitress : NSObject

/**
 * @brief The name of the waitress.
 */
@property (nonatomic, strong, readonly) NSString *name;

/**
 * @brief A property indicating if BeerFetching is busy.
 */
@property (nonatomic, assign, readonly) BOOL busy;

/**
 * @brief Initializes a waitress with the given name.
 *
 * @param name The name to give the waitress.
 *
 * @return A waitress initialized with the given name.
 */
- (instancetype)initWithName:(NSString *)name;

/**
 * @brief Fetch a beer from the given storage and execute complete when done.
 *
 * @param complete The completion block to execute when done fetching.
 */
- (void)fetchBeerWithCompletion:(void(^)(Beer *beer, NSError *error))complete;

@end


