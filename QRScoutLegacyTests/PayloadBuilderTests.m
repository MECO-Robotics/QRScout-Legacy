#import <XCTest/XCTest.h>
#import "PayloadBuilder.h"

@interface PayloadBuilderTests : XCTestCase
@end

@implementation PayloadBuilderTests

- (void)testColumnsPreserveSpreadsheetContract {
    NSArray *expectedColumns = @[
        @"Scouter Initials", @"Match Number", @"Team Number", @"Starting Position", @"No Show",
        @"Fuel Scored", @"Where collected Fuel", @"Other Auto actions",
        @"Robot Stuck or a Stop in Auto", @"Climbed", @"Fuel Scored", @"Bump Trench",
        @"Deffended by Opponent", @"Fuel Fed", @"Opposing Zone Actions", @"Climbed",
        @"Mechanical Issue", @"Died", @"Triped/Fell Over", @"Scoring Efectiveness",
        @"Scored How?", @"Scoring Location", @"Feeding/Passing Skill", @"Passed How?",
        @"Defense Skill", @"Yello/Red Card", @"First Pick", @"Second Pick", @"Comments"
    ];
    XCTAssertEqual([PayloadBuilder columnNames].count, (NSUInteger)29);
    XCTAssertEqualObjects([PayloadBuilder columnNames], expectedColumns);
    XCTAssertEqualObjects([PayloadBuilder delimiter], @"\t");
}

- (void)testSanitizerProtectsTabSeparatedColumns {
    XCTAssertEqualObjects([PayloadBuilder sanitizeValue:@"  drive,\t\nwell\r  "], @"drive,  well");
    XCTAssertEqualObjects([PayloadBuilder sanitizeValue:nil], @"");
}

- (void)testPayloadJoinsAllValuesWithoutChangingTheirOrder {
    NSArray *values = @[
        @"AJ", @"12", @"8324", @"Outpost Trench", @"false", @"500", @"Outpost,Neutral Zone", @"Passed,Bump", @"true", @"C",
        @"450", @"Bump,Trench", @"true", @"300", @"Collecting,Defense", @"L3", @"true", @"false", @"true",
        @"5", @"both", @"Outpost Trench,Hub", @"4", @"stationary", @"5", @"Yellow", @"Yes", @"May", @"solid"
    ];
    XCTAssertEqualObjects([PayloadBuilder payloadFromValues:values],
        @"AJ\t12\t8324\tOutpost Trench\tfalse\t500\tOutpost,Neutral Zone\tPassed,Bump\ttrue\tC\t450\tBump,Trench\ttrue\t300\tCollecting,Defense\tL3\ttrue\tfalse\ttrue\t5\tboth\tOutpost Trench,Hub\t4\tstationary\t5\tYellow\tYes\tMay\tsolid");
    XCTAssertEqualObjects([PayloadBuilder payloadFromValues:@[@"too", @"short"]], @"");
}

- (void)testScannerPayloadIsKeyboardSafeAndRoundTripsUnicode {
    NSMutableArray *values = [NSMutableArray arrayWithCapacity:29];
    for (NSUInteger index = 0; index < 29; index++) {
        [values addObject:[NSString stringWithFormat:@"field %lu — value", (unsigned long)index]];
    }
    NSString *payload = [PayloadBuilder scannerPayloadFromValues:values];
    XCTAssertTrue([payload hasPrefix:@"QRSCOUT1-"]);
    XCTAssertEqual([payload rangeOfCharacterFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].location, NSNotFound);

    NSString *base64URL = [payload substringFromIndex:@"QRSCOUT1-".length];
    NSString *base64 = [base64URL stringByReplacingOccurrencesOfString:@"-" withString:@"+"];
    base64 = [base64 stringByReplacingOccurrencesOfString:@"_" withString:@"/"];
    while (base64.length % 4 != 0) {
        base64 = [base64 stringByAppendingString:@"="];
    }
    NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:base64 options:0];
    NSString *decoded = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
    XCTAssertEqualObjects(decoded, [PayloadBuilder payloadFromValues:values]);
}

@end
