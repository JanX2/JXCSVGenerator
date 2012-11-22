//
//  JXCSVGenerator.m
//  CSV Converter
//
//  Created by Jan on 21.11.12.
//
//  Copyright 2012 Jan Weiß. Some rights reserved: <http://opensource.org/licenses/mit-license.php>
//

#import "JXCSVGenerator.h"

@implementation JXCSVGenerator

- (void)escapeStringForCSV:(NSMutableString *)theString
			 withSeparator:(NSString *)csvSeparator
					andEOL:(NSString *)csvEOL
{
	
	BOOL containsSeparator = ([theString rangeOfString:csvSeparator].location != NSNotFound);
	BOOL containsQuotes = ([theString rangeOfString:@"\""].location != NSNotFound);
	BOOL containsLineBreak = ([theString rangeOfString:csvEOL].location != NSNotFound);
	
	if (containsQuotes) {
		[theString replaceOccurrencesOfString:@"\"" withString:@"\"\"" options:NSLiteralSearch range:NSMakeRange(0, [theString length])];
	}
	
	if (containsQuotes || containsSeparator || containsLineBreak) {
		[theString insertString:@"\"" atIndex:0];
		[theString appendString:@"\""];
	}
}


- (NSString *)stringForCSVArray:(NSArray *)csvArray
				  cellSeparator:(NSString *)csvSeparator
					 lineEnding:(NSString *)csvEOL;
{
    NSUInteger columnCount = [[csvArray objectAtIndex:0] count];
    
	// Escape all cell’s content and append to outString
    NSMutableString *outString = [[NSMutableString alloc] init];
	NSMutableArray *rowArray = [NSMutableArray arrayWithCapacity:columnCount];
	
	for (NSMutableArray *csvLine in csvArray) {
		for (NSString *csvCellString in csvLine) {
			NSMutableString *tmpString  = [NSMutableString stringWithString:csvCellString];
			
			[self escapeStringForCSV:tmpString
					   withSeparator:csvSeparator
							  andEOL:csvEOL];
			
			[rowArray addObject:tmpString];
		}
		
		[outString appendString:[rowArray componentsJoinedByString:csvSeparator]];
		[outString appendString:csvEOL];
		[rowArray removeAllObjects];
	}
    return outString;
}

- (NSData *)dataForCSVArray:(NSArray *)csvArray
			  cellSeparator:(NSString *)csvSeparator
				 lineEnding:(NSString *)csvEOL
				   encoding:(NSStringEncoding)encoding;
{
	NSString *outString = [self stringForCSVArray:csvArray
									cellSeparator:csvSeparator
									   lineEnding:csvEOL];
    
	NSData *outData = [outString dataUsingEncoding:encoding];
	
	[outString release];
    return outData;
}

@end
