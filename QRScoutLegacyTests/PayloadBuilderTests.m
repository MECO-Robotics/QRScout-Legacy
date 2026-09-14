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
        @"AJ", @"12", @"8324", @"OT", @"false", @"500", @"1,3", @"1,2", @"true", @"C",
        @"450", @"1,2", @"true", @"300", @"1,2", @"L3", @"true", @"false", @"true",
        @"5", @"both", @"1,3", @"4", @"stationary", @"5", @"Yellow", @"Yes", @"May", @"solid"
    ];
    XCTAssertEqualObjects([PayloadBuilder payloadFromValues:values],
        @"AJ\t12\t8324\tOT\tfalse\t500\t1,3\t1,2\ttrue\tC\t450\t1,2\ttrue\t300\t1,2\tL3\ttrue\tfalse\ttrue\t5\tboth\t1,3\t4\tstationary\t5\tYellow\tYes\tMay\tsolid");
    XCTAssertEqualObjects([PayloadBuilder payloadFromValues:@[@"too", @"short"]], @"");
}

@end
