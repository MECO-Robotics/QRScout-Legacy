#import <Foundation/Foundation.h>
#import "PayloadBuilder.h"

static void AssertEqual(NSString *actual, NSString *expected, NSString *message) {
    if (![actual isEqualToString:expected]) {
        NSLog(@"FAIL: %@\nExpected: %@\nActual: %@", message, expected, actual);
        exit(1);
    }
}

int main(void) {
    @autoreleasepool {
        NSString *columns = [[PayloadBuilder columnNames] componentsJoinedByString:[PayloadBuilder delimiter]];
        AssertEqual(columns,
            @"Scouter Initials\tMatch Number\tTeam Number\tStarting Position\tNo Show\tFuel Scored\t"
             "Where collected Fuel\tOther Auto actions\tRobot Stuck or a Stop in Auto\tClimbed\t"
             "Fuel Scored\tBump Trench\tDeffended by Opponent\tFuel Fed\tOpposing Zone Actions\t"
             "Climbed\tMechanical Issue\tDied\tTriped/Fell Over\tScoring Efectiveness\tScored How?\t"
             "Scoring Location\tFeeding/Passing Skill\tPassed How?\tDefense Skill\tYello/Red Card\t"
             "First Pick\tSecond Pick\tComments",
            @"column order changed");
        AssertEqual([PayloadBuilder delimiter], @"\t", @"spreadsheet delimiter changed");

        AssertEqual([PayloadBuilder sanitizeValue:@"  drive,\t\nwell\r  "],
                    @"drive,  well",
                    @"spreadsheet sanitation changed");

        NSArray *values = @[
            @"AJ", @"12", @"8324", @"OT", @"false", @"500", @"1,3", @"1,2", @"true", @"C",
            @"450", @"1,2", @"true", @"300", @"1,2", @"L3", @"true", @"false", @"true",
            @"5", @"both", @"1,3", @"4", @"stationary", @"5", @"Yellow", @"Yes", @"May", @"solid"
        ];
        AssertEqual([PayloadBuilder payloadFromValues:values],
                    @"AJ\t12\t8324\tOT\tfalse\t500\t1,3\t1,2\ttrue\tC\t450\t1,2\ttrue\t300\t1,2\tL3\ttrue\tfalse\ttrue\t5\tboth\t1,3\t4\tstationary\t5\tYellow\tYes\tMay\tsolid",
                    @"payload value order changed");
        AssertEqual([PayloadBuilder payloadFromValues:@[@"too", @"short"]],
                    @"",
                    @"invalid field count must not create a QR payload");
    }
    return 0;
}
