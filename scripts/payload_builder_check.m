#import <Foundation/Foundation.h>
#include <string.h>
#import "PayloadBuilder.h"

static void AssertEqual(NSString *actual, NSString *expected, NSString *message) {
    if (![actual isEqualToString:expected]) {
        NSLog(@"FAIL: %@\nExpected: %@\nActual: %@", message, expected, actual);
        exit(1);
    }
}

static NSData *DecodeBase64URL(NSString *encoded) {
    NSString *base64 = [encoded stringByReplacingOccurrencesOfString:@"-" withString:@"+"];
    base64 = [base64 stringByReplacingOccurrencesOfString:@"_" withString:@"/"];
    while (base64.length % 4 != 0) {
        base64 = [base64 stringByAppendingString:@"="];
    }
    return [[NSData alloc] initWithBase64EncodedString:base64 options:0];
}

int main(int argc, const char * argv[]) {
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

        NSString *scannerPayload = [PayloadBuilder scannerPayloadFromValues:values];
        if (![scannerPayload hasPrefix:@"QRSCOUT3-"] ||
            [scannerPayload rangeOfCharacterFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].location != NSNotFound) {
            NSLog(@"FAIL: scanner payload is not keyboard safe: %@", scannerPayload);
            return 1;
        }
        if (scannerPayload.length > [PayloadBuilder scannerPayloadLimit]) {
            NSLog(@"FAIL: scanner payload is longer than the scanner's %lu-character limit: %lu",
                  (unsigned long)[PayloadBuilder scannerPayloadLimit], (unsigned long)scannerPayload.length);
            return 1;
        }
        NSString *base64URL = [scannerPayload substringFromIndex:@"QRSCOUT3-".length];
        NSArray *decoded = [NSJSONSerialization JSONObjectWithData:DecodeBase64URL(base64URL) options:0 error:nil];
        NSArray *expectedCodes = @[
            @"AJ", @12, @8324, @0, @0, @500, @5, @3, @1, @1,
            @450, @3, @1, @300, @3, @3, @1, @0, @1, @5,
            @2, @5, @4, @1, @5, @1, @0, @1, @"solid"
        ];
        if (![decoded isKindOfClass:[NSArray class]] || ![decoded isEqualToArray:expectedCodes]) {
            NSLog(@"FAIL: compact scanner payload changed\nExpected: %@\nActual: %@", expectedCodes, decoded);
            return 1;
        }

        NSMutableArray *tooLong = [values mutableCopy];
        tooLong[28] = [@"x" stringByPaddingToLength:300 withString:@"x" startingAtIndex:0];
        AssertEqual([PayloadBuilder scannerPayloadFromValues:tooLong], @"",
                    @"payloads that the S-1103T would truncate must be rejected");
        if ([PayloadBuilder scannerPayloadFromValues:@[@"too", @"short"]].length != 0) {
            NSLog(@"FAIL: invalid scanner field count must be rejected");
            return 1;
        }
        if (argc == 2 && strcmp(argv[1], "--emit-scanner-payload") == 0) {
            printf("%s\n", scannerPayload.UTF8String);
        }
    }
    return 0;
}
