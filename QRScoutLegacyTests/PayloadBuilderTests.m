#import <XCTest/XCTest.h>
#import "PayloadBuilder.h"

@interface PayloadBuilderTests : XCTestCase
@end

@implementation PayloadBuilderTests

- (void)testColumnsPreserveSpreadsheetContract {
    NSString *columns = [[PayloadBuilder columnNames] componentsJoinedByString:@","];
    XCTAssertEqualObjects(columns,
        @"scout,match,team,alliance,station,robotNotes,autoMobility,autoFuel,autoAmp,"
         "teleopSpeaker,teleopAmp,teleopFeed,fouls,defenseRating,endgame,comments");
}

- (void)testSanitizerMatchesLegacyCSVBehavior {
    XCTAssertEqualObjects([PayloadBuilder sanitizeValue:@"  drive,\nwell  "], @"drive  well");
    XCTAssertEqualObjects([PayloadBuilder sanitizeValue:nil], @"");
}

- (void)testPayloadJoinsAllValuesWithoutChangingTheirOrder {
    NSArray *values = @[
        @"Alex", @"12", @"365", @"Red", @"2", @"fast",
        @"1", @"2", @"3", @"4", @"5", @"6", @"0", @"4", @"Climb", @"solid"
    ];
    XCTAssertEqualObjects([PayloadBuilder payloadFromValues:values],
        @"Alex,12,365,Red,2,fast,1,2,3,4,5,6,0,4,Climb,solid");
}

@end
