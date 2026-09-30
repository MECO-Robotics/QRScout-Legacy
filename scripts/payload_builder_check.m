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
            @"AJ", @"12", @"8324", @"Outpost Trench", @"false", @"500", @"Outpost,Neutral Zone", @"Passed,Bump", @"true", @"C",
            @"450", @"Bump,Trench", @"true", @"300", @"Collecting,Defense", @"L3", @"true", @"false", @"true",
            @"5", @"both", @"Outpost Trench,Hub", @"4", @"stationary", @"5", @"Yellow", @"Yes", @"May", @"solid"
        ];
        AssertEqual([PayloadBuilder payloadFromValues:values],
                    @"AJ\t12\t8324\tOutpost Trench\tfalse\t500\tOutpost,Neutral Zone\tPassed,Bump\ttrue\tC\t450\tBump,Trench\ttrue\t300\tCollecting,Defense\tL3\ttrue\tfalse\ttrue\t5\tboth\tOutpost Trench,Hub\t4\tstationary\t5\tYellow\tYes\tMay\tsolid",
                    @"payload value order changed");
        AssertEqual([PayloadBuilder payloadFromValues:@[@"too", @"short"]],
                    @"",
                    @"invalid field count must not create a QR payload");
    }
    return 0;
}
