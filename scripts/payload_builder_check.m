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
        NSString *columns = [[PayloadBuilder columnNames] componentsJoinedByString:@","];
        AssertEqual(columns,
            @"scout,match,team,alliance,station,robotNotes,autoFuelScored,autoFuelMissed,autoTowerLevel1,"
             "teleopFuelScored,teleopFuelMissed,teleopFuelInactive,fouls,defenseRating,towerLevel,comments",
            @"column order changed");

        AssertEqual([PayloadBuilder sanitizeValue:@"  drive,\nwell  "],
                    @"drive  well",
                    @"CSV sanitation changed");

        NSArray *values = @[
            @"Alex", @"12", @"365", @"Red", @"2", @"fast",
            @"1", @"2", @"3", @"4", @"5", @"6", @"0", @"4", @"Climb", @"solid"
        ];
        AssertEqual([PayloadBuilder payloadFromValues:values],
                    @"Alex,12,365,Red,2,fast,1,2,3,4,5,6,0,4,Climb,solid",
                    @"payload value order changed");
    }
    return 0;
}
