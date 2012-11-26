//
//  JXCSVGenerator.h
//  CSV Converter
//
//  Created by Jan on 21.11.12.
//
//  Copyright 2012 Jan Weiß. Some rights reserved: <http://opensource.org/licenses/mit-license.php>
//

#import <Foundation/Foundation.h>

#import "JXArcCompatibilityMacros.h"

@interface JXCSVGenerator : NSObject {
	NSString *_separator;
	NSString *_lineEnding;
}

@property (nonatomic, JX_STRONG) NSString *separator;
@property (nonatomic, JX_STRONG) NSString *lineEnding;

- (instancetype)initWithCellSeparator:(NSString *)separator
				 lineEnding:(NSString *)lineEnding;
+ (instancetype)csvGeneratorWithCellSeparator:(NSString *)separator
						 lineEnding:(NSString *)lineEnding;

// A TableMatrix is an array of arrays.
// Each subarray contains cell objects.
// All subarrays need to contain a single object type:
// NSString.
// Each entry in this topmost array represents a row.
// Each of the strings in a row represent a column of the row.
#if 0
	// Here is an example of such an array:
    NSArray *sampleTableMatrix = @[
	@[@"Header 1", @"Header 2"],
	@[@"cell 1", @"cell 2"],
	@[@"second row", @"second row 2"]
	];
#endif

- (NSString *)stringForTableMatrix:(NSArray *)csvArray;


- (NSData *)dataForTableMatrix:(NSArray *)csvArray
					  encoding:(NSStringEncoding)encoding;

@end
