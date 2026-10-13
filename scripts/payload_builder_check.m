#import <Foundation/Foundation.h>
#include <string.h>
#import "PayloadBuilder.h"

static void AssertEqual(NSString *actual, NSString *expected, NSString *message) {
    if (![actual isEqualToString:expected]) {
        NSLog(@"FAIL: %@\nExpected: %@\nActual: %@", message, expected, actual);
        exit(1);
    }
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
        if (![scannerPayload hasPrefix:@"QRSCOUT2-"] ||
            [scannerPayload rangeOfCharacterFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].location != NSNotFound) {
            NSLog(@"FAIL: scanner payload is not keyboard safe: %@", scannerPayload);
            return 1;
        }
        NSString *base64URL = [scannerPayload substringFromIndex:@"QRSCOUT2-".length];
        NSString *base64 = [base64URL stringByReplacingOccurrencesOfString:@"-" withString:@"+"];
        base64 = [base64 stringByReplacingOccurrencesOfString:@"_" withString:@"/"];
        while (base64.length % 4 != 0) {
            base64 = [base64 stringByAppendingString:@"="];
        }
        NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:base64 options:0];
        NSDictionary *decoded = [NSJSONSerialization JSONObjectWithData:decodedData options:0 error:nil];
        if (![decoded[@"v"] isEqual:@2] || ![decoded[@"fields"] isKindOfClass:[NSDictionary class]]) {
            NSLog(@"FAIL: scanner payload did not decode to a version 2 named-field record");
            return 1;
        }
        NSDictionary *fields = decoded[@"fields"];
        if (fields.count != 29) {
            NSLog(@"FAIL: scanner payload field count changed: %lu", (unsigned long)fields.count);
            return 1;
        }
        [[PayloadBuilder fieldIdentifiers] enumerateObjectsUsingBlock:^(NSString *identifier, NSUInteger index, BOOL *stop) {
            AssertEqual(fields[identifier], values[index], [NSString stringWithFormat:@"field %@ shifted", identifier]);
        }];
        if (argc == 2 && strcmp(argv[1], "--emit-scanner-payload") == 0) {
            printf("%s\n", scannerPayload.UTF8String);
        }
    }
    return 0;
}
