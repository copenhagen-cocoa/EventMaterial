//
//  Beer.h
//  TheBodega
//
//  Created by Mikkel Sindberg Eriksen on 26/04/2016.
//  Copyright © 2016 Mikkel Sindberg Eriksen. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * @Brief A class representing a nice cold (hopefully) beer.
 */
@interface Beer : NSObject

/**
 * @brief The name of the beer.
 */
@property (nonatomic, strong, readonly) NSString *name;

/**
 * @brief The alcohol percentage of the beer.
 */
@property (nonatomic, strong, readonly) NSNumber *percentage;

/**
 * @brief The size of the beer in centiliters.
 */
@property (nonatomic, strong, readonly) NSNumber *centiliters;

/**
 * @brief Initializes a beer with the given name, alcohol percentage and centiliters.
 *
 * @param name          The name of the beer.
 * @param percentage    The alcohol percentage of the beer.
 * @param centiliters   The size of the beer in centiliters.
 *
 * @return An initialized beer with the given values.
 */
- (instancetype)initWithName:(NSString *)name
           alcoholPercentage:(NSNumber *)percentage
                 centiliters:(NSNumber *)centiliters;

@end
