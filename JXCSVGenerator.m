//
//  JXCSVGenerator.m
//  CSV Converter
//
//  Created by Jan on 21.11.12.
//
//  Copyright 2012 Jan Weiß. Some rights reserved: <http://opensource.org/licenses/mit-license.php>
//

#import "JXCSVGenerator.h"

NSString * const	JXCSVGeneratorConversionWasLossyNotification		= @"JXCSVGeneratorConversionWasLossyNotification";

@implementation JXCSVGenerator

@synthesize separator = _separator;
@synthesize lineEnding = _lineEnding;

- (instancetype)initWithCellSeparator:(NSString *)separator
				 lineEnding:(NSString *)lineEnding;
{
	self = [super init];
	
	if (self) {
		_separator = JX_RETAIN(separator);
		_lineEnding = JX_RETAIN(lineEnding);
	}
	
	return self;
}


+ (instancetype)csvGeneratorWithCellSeparator:(NSString *)separator
						 lineEnding:(NSString *)lineEnding;
{
	id result = [[[self class] alloc] initWithCellSeparator:separator
												 lineEnding:lineEnding];
	
	return JX_AUTORELEASE(result);
}

#if (JX_HAS_ARC == 0)
- (void)dealloc
{
	self.separator = nil;
	self.lineEnding = nil;
	
	[super dealloc];
}
#endif


- (void)escapeStringForCSV:(NSMutableString *)theString
{
	BOOL containsSeparator = ([theString rangeOfString:_separator].location != NSNotFound);
	BOOL containsQuotes = ([theString rangeOfString:@"\""].location != NSNotFound);
	BOOL containsLineBreak = ([theString rangeOfString:_lineEnding].location != NSNotFound);
	
	if (containsQuotes) {
		[theString replaceOccurrencesOfString:@"\"" withString:@"\"\"" options:NSLiteralSearch range:NSMakeRange(0, [theString length])];
	}
	
	if (containsQuotes || containsSeparator || containsLineBreak) {
		[theString insertString:@"\"" atIndex:0];
		[theString appendString:@"\""];
	}
}


- (NSString *)stringForTableMatrix:(NSArray *)csvArray;
{
    NSUInteger columnCount = [[csvArray objectAtIndex:0] count];
    NSMutableString *outString = [[NSMutableString alloc] init];
	NSMutableArray *rowArray = [NSMutableArray arrayWithCapacity:columnCount];
	
	// Escape each cell’s content, assemble rows seperated by _separator and append to outString
	for (NSMutableArray *csvLine in csvArray) {
		for (NSString *csvCellString in csvLine) {
			NSMutableString *tmpString  = [NSMutableString stringWithString:csvCellString];
			
			[self escapeStringForCSV:tmpString];
			
			[rowArray addObject:tmpString];
		}
		
		[outString appendString:[rowArray componentsJoinedByString:_separator]];
		[outString appendString:_lineEnding];
		[rowArray removeAllObjects];
	}
	
    return JX_AUTORELEASE(outString);
}

- (NSData *)dataForTableMatrix:(NSArray *)csvArray
					  encoding:(NSStringEncoding)encoding;
{
	return [self dataForTableMatrix:csvArray
						   encoding:encoding
					  notifyIfLossy:YES];
}

- (NSData *)dataForTableMatrix:(NSArray *)csvArray
					  encoding:(NSStringEncoding)encoding
				 notifyIfLossy:(BOOL)notifyIfLossy;
{
	NSString *outString = [self stringForTableMatrix:csvArray];
    
	NSData *outData= nil;
	BOOL allowLossyConversion = NO;
	while (outData == nil) {
		outData = [outString dataUsingEncoding:encoding
						  allowLossyConversion:allowLossyConversion];
		
		if (outData == nil && allowLossyConversion == NO) {
			allowLossyConversion = YES;
			if (notifyIfLossy) {
				[[NSNotificationCenter defaultCenter] postNotificationName:JXCSVGeneratorConversionWasLossyNotification object:nil];
			}
		}
		else {
			break;
		}
	}
	
    return outData;
}

@end
