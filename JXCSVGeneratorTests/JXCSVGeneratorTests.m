//
//  JXCSVGeneratorTests.m
//  JXCSVGeneratorTests
//
//  Created by Jan on 26.06.13.
//  Copyright (c) 2013 Jan Weiß. All rights reserved.
//

#import "JXCSVGeneratorTests.h"

#import "JXCSVGenerator.h"


@implementation JXCSVGeneratorTests {
	NSArray *_tableMatrix1;
}

- (void)setUp
{
    [super setUp];
    
	_tableMatrix1 = @[
	@[@"Header 1",				@"Header2",					@"3"],
	@[@"cell\nwith line break",	@"1\"/1' cell with quotes",	@"-3"],
	@[@"second row",			@"a,b;c",					@"3.0"],
	@[@"",						@" ",						@"2012-01-01"]
	];
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testBasic
{
	NSString *expectedString =
	@"Header 1,Header2,3\n"
	"\"cell\nwith line break\",\"1\"\"/1' cell with quotes\",-3\n"
	"second row,\"a,b;c\",3.0\n"
	", ,2012-01-01\n";
	
	JXCSVGenerator *csvGenerator = [JXCSVGenerator csvGeneratorWithCellSeparator:@","
																	  lineEnding:@"\n"];
	
	NSString *resultString = [csvGenerator stringForTableMatrix:_tableMatrix1];
	
	//NSLog(@"%@", resultString);
	
	STAssertEqualObjects(resultString, expectedString, @"Basic test failed");
}

- (void)testQuoteStyles
{
	NSString *expectedStringQSWhitespace =
	@"\"Header 1\",Header2,3\n"
	"\"cell\nwith line break\",\"1\"\"/1' cell with quotes\",-3\n"
	"\"second row\",\"a,b;c\",3.0\n"
	",\" \",2012-01-01\n";
	
	JXCSVGenerator *csvGenerator = [JXCSVGenerator csvGeneratorWithCellSeparator:@","
																	  lineEnding:@"\n"];
	csvGenerator.quoteStyle = JXCSVGeneratorQuoteStyleCellsWithWhitespace;
	
	NSString *resultString = [csvGenerator stringForTableMatrix:_tableMatrix1];
	
	NSLog(@"%@", resultString);
	
	STAssertEqualObjects(resultString, expectedStringQSWhitespace, @"JXCSVGeneratorQuoteStyleCellsWithWhitespace test failed");
	
	
	NSString *expectedStringQSAll =
	@"\"Header 1\",\"Header2\",\"3\"\n"
	"\"cell\nwith line break\",\"1\"\"/1' cell with quotes\",\"-3\"\n"
	"\"second row\",\"a,b;c\",\"3.0\"\n"
	"\"\",\" \",\"2012-01-01\"\n";
	
	csvGenerator.quoteStyle = JXCSVGeneratorQuoteStyleAllCells;
	
	resultString = [csvGenerator stringForTableMatrix:_tableMatrix1];
	
	NSLog(@"%@", resultString);
	
	STAssertEqualObjects(resultString, expectedStringQSAll, @"JXCSVGeneratorQuoteStyleAllCells test failed");

}

@end
