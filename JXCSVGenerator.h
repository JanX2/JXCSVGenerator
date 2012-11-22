//
//  JXCSVGenerator.h
//  CSV Converter
//
//  Created by Jan on 21.11.12.
//
//  Copyright 2012 Jan Weiß. Some rights reserved: <http://opensource.org/licenses/mit-license.php>
//

#import <Foundation/Foundation.h>

@interface JXCSVGenerator : NSObject

- (NSString *)stringForCSVArray:(NSArray *)csvArray
				  cellSeparator:(NSString *)csvSeparator
					 lineEnding:(NSString *)csvEOL;


- (NSData *)dataForCSVArray:(NSArray *)csvArray
			  cellSeparator:(NSString *)csvSeparator
				 lineEnding:(NSString *)csvEOL
				   encoding:(NSStringEncoding)encoding;

@end
