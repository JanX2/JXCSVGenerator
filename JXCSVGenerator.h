//
//  JXCSVGenerator.h
//  CSV Converter
//
//  Created by Jan on 21.11.12.
//
//  Copyright 2012 Jan Weiß. Some rights reserved: <http://opensource.org/licenses/mit-license.php>
//

#import <Foundation/Foundation.h>

@interface JXCSVGenerator : NSObject {
	NSString *_separator;
	NSString *_lineEnding;
}

@property (nonatomic, retain) NSString *separator;
@property (nonatomic, retain) NSString *lineEnding;

- (id)initWithCellSeparator:(NSString *)separator
				 lineEnding:(NSString *)lineEnding;
+ (id)csvGeneratorWithCellSeparator:(NSString *)separator
						 lineEnding:(NSString *)lineEnding;

- (NSString *)stringForCSVArray:(NSArray *)csvArray;


- (NSData *)dataForCSVArray:(NSArray *)csvArray
				   encoding:(NSStringEncoding)encoding;

@end
