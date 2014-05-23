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


NSUInteger supportedQuoteStyles[] = {
	JXCSVGeneratorQuoteStyleDefault,
	JXCSVGeneratorQuoteStyleCellsWithWhitespace,
	JXCSVGeneratorQuoteStyleAllCells
};

NSString *supportedQuoteStyleNames[] = {
	@"Like Apple Numbers",
	@"Like Excel",
	@"Escape All Cells"
};
/* For genstrings:
 NSLocalizedString(@"Like Apple Numbers", @"JXCSVGenerator Quote Style Name")
 NSLocalizedString(@"Like Excel", @"JXCSVGenerator Quote Style Name")
 NSLocalizedString(@"Escape All Cells" @"JXCSVGenerator Quote Style Name")
 */


@implementation JXCSVGenerator

@synthesize separator = _separator;
@synthesize lineEnding = _lineEnding;

@synthesize quoteStyle = _quoteStyle;

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
	if (_quoteStyle == JXCSVGeneratorQuoteStyleRawCells)  return;
	
	if (_quoteStyle == JXCSVGeneratorQuoteStyleTSV) {
		NSRange searchRange = NSMakeRange(0, theString.length);
		[theString replaceOccurrencesOfString:@"\t"
								   withString:@"⇥"
									  options:NSLiteralSearch
										range:searchRange];
		
		return;
	}

	NSUInteger firstQuoteIndex = [theString rangeOfString:@"\""].location;
	BOOL containsQuotes = (firstQuoteIndex != NSNotFound);
	
	BOOL needsQuoting = NO;
	
	if (containsQuotes) {
		NSRange searchRange = NSMakeRange(firstQuoteIndex, (theString.length - firstQuoteIndex));
		[theString replaceOccurrencesOfString:@"\""
								   withString:@"\"\""
									  options:NSLiteralSearch
										range:searchRange];

		needsQuoting = YES;
	}
	else {
		switch (_quoteStyle) {
			case JXCSVGeneratorQuoteStyleDefault:
			{
				BOOL containsSeparator = ([theString rangeOfString:_separator].location != NSNotFound);
				if (containsSeparator) {
					needsQuoting = YES;
					break;
				}
				
				BOOL containsLineBreak = ([theString rangeOfString:_lineEnding].location != NSNotFound);
				if (containsLineBreak) {
					needsQuoting = YES;
					break;
				}
				
				break;
			}
				
			case JXCSVGeneratorQuoteStyleCellsWithWhitespace:
			{
				BOOL containsSeparator = ([theString rangeOfString:_separator].location != NSNotFound);
				if (containsSeparator) {
					needsQuoting = YES;
					break;
				}
				
				NSCharacterSet *whitespaceCharacterSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
				NSRange firstWhitespaceRange = [theString rangeOfCharacterFromSet:whitespaceCharacterSet];
				BOOL containsWhitespace = (firstWhitespaceRange.location != NSNotFound);
				if (containsWhitespace) {
					needsQuoting = YES;
					break;
				}

				break;
			}
				
			case JXCSVGeneratorQuoteStyleAllCells:
			{
				needsQuoting = YES;
				break;
			}
				
			default:
			{
				[NSException raise:NSInvalidArgumentException
							format:@"%ld is not a recognized quote style.", (unsigned long)_quoteStyle];
				return;
				break;
			}
		}
	}
	
	if (needsQuoting) {
		[theString insertString:@"\"" atIndex:0];
		[theString appendString:@"\""];
	}
}


- (NSString *)stringForTableMatrix:(NSArray *)csvArray;
{
	NSMutableArray *csvFirstLine = csvArray[0];
	NSUInteger columnCount = csvFirstLine.count;
	NSMutableString *outString = [[NSMutableString alloc] init];
	NSMutableArray *rowArray = [NSMutableArray arrayWithCapacity:columnCount];
	
	// Escape each cell’s content, assemble rows seperated by _separator and append to outString
	for (NSMutableArray *csvLine in csvArray) {
		if (_quoteStyle != JXCSVGeneratorQuoteStyleTSV &&
			_quoteStyle != JXCSVGeneratorQuoteStyleRawCells &&
			csvLine.count == 1 &&
			((NSString *)csvLine[0]).length == 0) {
			// Add a single quoted empty string to prevent the CSV row from seeming empty,
			// whenever it consists of a single empty cell.
			// We can’t do this for TSV, as it does not support quoting.
			NSMutableString *tmpString  = [NSMutableString stringWithString:@"\"\""];
			
			[rowArray addObject:tmpString];
		}
		else {
			for (NSString *csvCellString in csvLine) {
				NSMutableString *tmpString = [NSMutableString stringWithString:csvCellString];
				
				[self escapeStringForCSV:tmpString];
				
				[rowArray addObject:tmpString];
			}
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
	
	NSData *outData = nil;
	BOOL allowLossyConversion = NO;
	while (outData == nil) {
		outData = [outString dataUsingEncoding:encoding
						  allowLossyConversion:allowLossyConversion];
		
		if (outData == nil && allowLossyConversion == NO) {
			allowLossyConversion = YES;
			if (notifyIfLossy) {
				[[NSNotificationCenter defaultCenter] postNotificationName:JXCSVGeneratorConversionWasLossyNotification object:self];
			}
		}
		else {
			break;
		}
	}
	
	return outData;
}

#pragma mark -
#pragma mark Quote Styles

+ (NSArray *)supportedQuoteStyles;
{
	NSUInteger supportedQuoteStylesCount = sizeof(supportedQuoteStyles)/sizeof(supportedQuoteStyles[0]);
	NSMutableArray *quoteStylesArray = [NSMutableArray arrayWithCapacity:supportedQuoteStylesCount];
	for (NSUInteger i = 0; i < supportedQuoteStylesCount; i++) {
		JXCSVGeneratorQuoteStyle quoteStyle = supportedQuoteStyles[i];
		[quoteStylesArray addObject:@(quoteStyle)];
	}
	
	return quoteStylesArray;
}

+ (NSArray *)supportedQuoteStyleLocalizedNames;
{
	NSUInteger supportedQuoteStyleNamesCount = sizeof(supportedQuoteStyleNames)/sizeof(supportedQuoteStyleNames[0]);
	NSMutableArray *quoteStyleNamesArray = [NSMutableArray arrayWithCapacity:supportedQuoteStyleNamesCount];
	for (NSUInteger i = 0; i < supportedQuoteStyleNamesCount; i++) {
		NSString *quoteStyleName = NSLocalizedString(supportedQuoteStyleNames[i], @"JXCSVGenerator Quote Style Name");
		[quoteStyleNamesArray addObject:quoteStyleName];
	}
	
	return quoteStyleNamesArray;
}

@end
