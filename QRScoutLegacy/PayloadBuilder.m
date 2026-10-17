#import "PayloadBuilder.h"

@implementation PayloadBuilder

static const NSUInteger QRScoutScannerPayloadLimit = 245;

+ (NSArray<NSString *> *)columnNames {
    return @[
        @"Scouter Initials", @"Match Number", @"Team Number", @"Starting Position", @"No Show",
        @"Fuel Scored", @"Where collected Fuel", @"Other Auto actions",
        @"Robot Stuck or a Stop in Auto", @"Climbed", @"Fuel Scored", @"Bump Trench",
        @"Deffended by Opponent", @"Fuel Fed", @"Opposing Zone Actions", @"Climbed",
        @"Mechanical Issue", @"Died", @"Triped/Fell Over", @"Scoring Efectiveness",
        @"Scored How?", @"Scoring Location", @"Feeding/Passing Skill", @"Passed How?",
        @"Defense Skill", @"Yello/Red Card", @"First Pick", @"Second Pick", @"Comments"
    ];
}

+ (NSArray<NSString *> *)fieldIdentifiers {
    return @[
        @"si", @"mn", @"tn", @"sp", @"ns", @"afs", @"afc", @"aaa", @"ast", @"acl",
        @"tfs", @"bt", @"dbo", @"ff", @"oza", @"ecl", @"mi", @"di", @"ti", @"se",
        @"sh", @"sl", @"fps", @"ph", @"ds", @"ca", @"fp", @"s2p", @"co"
    ];
}

+ (NSString *)delimiter {
    return @"\t";
}

+ (NSString *)sanitizeValue:(NSString *)value {
    if (value == nil) {
        return @"";
    }

    NSString *sanitized = [value stringByReplacingOccurrencesOfString:@"\t" withString:@" "];
    sanitized = [sanitized stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    sanitized = [sanitized stringByReplacingOccurrencesOfString:@"\r" withString:@" "];
    return [sanitized stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

+ (NSString *)payloadFromValues:(NSArray<NSString *> *)values {
    if (values.count != [self columnNames].count) {
        return @"";
    }
    return [values componentsJoinedByString:[self delimiter]];
}

+ (NSNumber *)integerValue:(NSString *)value minimum:(NSInteger)minimum maximum:(NSInteger)maximum {
    NSString *sanitized = [self sanitizeValue:value];
    NSScanner *scanner = [NSScanner scannerWithString:sanitized];
    scanner.charactersToBeSkipped = nil;
    NSInteger number = 0;
    if (![scanner scanInteger:&number] || !scanner.isAtEnd || number < minimum || number > maximum) {
        return nil;
    }
    return @(number);
}

+ (NSNumber *)optionalIntegerValue:(NSString *)value minimum:(NSInteger)minimum maximum:(NSInteger)maximum {
    if ([self sanitizeValue:value].length == 0) {
        return @(-1);
    }
    return [self integerValue:value minimum:minimum maximum:maximum];
}

+ (NSNumber *)codeForValue:(NSString *)value options:(NSArray<NSString *> *)options emptyCode:(NSInteger)emptyCode {
    NSString *sanitized = [self sanitizeValue:value];
    if (sanitized.length == 0 && emptyCode >= 0) {
        return @(emptyCode);
    }
    NSUInteger index = [options indexOfObject:sanitized];
    return index == NSNotFound ? nil : @(index);
}

+ (NSNumber *)maskForValue:(NSString *)value options:(NSArray<NSString *> *)options {
    NSString *sanitized = [self sanitizeValue:value];
    if (sanitized.length == 0) {
        return @0;
    }

    NSUInteger mask = 0;
    for (NSString *component in [sanitized componentsSeparatedByString:@","]) {
        NSString *option = [component stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSUInteger index = [options indexOfObject:option];
        if (index == NSNotFound) {
            return nil;
        }
        mask |= (1UL << index);
    }
    return @(mask);
}

+ (NSString *)scannerPayloadFromValues:(NSArray<NSString *> *)values {
    if (values.count != [self fieldIdentifiers].count) {
        return @"";
    }

    NSNumber *match = [self optionalIntegerValue:values[1] minimum:1 maximum:9999];
    NSNumber *team = [self optionalIntegerValue:values[2] minimum:1 maximum:99999];
    NSNumber *startingPosition = [self codeForValue:values[3]
                                            options:@[@"Outpost Trench", @"Outpost Bump — Trench", @"Outpost Bump — Hub",
                                                      @"Hub", @"Depot Bump — Hub", @"Depot Bump — Trench", @"Depot Trench"]
                                          emptyCode:7];
    NSNumber *noShow = [self codeForValue:values[4] options:@[@"false", @"true"] emptyCode:-1];
    NSNumber *autoFuel = [self integerValue:values[5] minimum:0 maximum:500];
    NSNumber *autoCollection = [self maskForValue:values[6]
                                          options:@[@"Outpost", @"Depot", @"Neutral Zone", @"Neutral Zone — 2nd Pass",
                                                    @"Did Not Move", @"Moved Without Collecting"]];
    NSNumber *autoActions = [self maskForValue:values[7] options:@[@"Passed", @"Bump", @"Trench"]];
    NSNumber *autoStuck = [self codeForValue:values[8] options:@[@"false", @"true"] emptyCode:-1];
    NSNumber *autoClimb = [self codeForValue:values[9] options:@[@"No", @"C", @"F"] emptyCode:-1];
    NSNumber *teleopFuel = [self integerValue:values[10] minimum:0 maximum:500];
    NSNumber *bumpTrench = [self maskForValue:values[11] options:@[@"Bump", @"Trench"]];
    NSNumber *defended = [self codeForValue:values[12] options:@[@"false", @"true"] emptyCode:-1];
    NSNumber *fuelFed = [self integerValue:values[13] minimum:0 maximum:500];
    NSNumber *zoneActions = [self maskForValue:values[14] options:@[@"Collecting", @"Defense"]];
    NSNumber *endgameClimb = [self codeForValue:values[15] options:@[@"No", @"L1", @"L2", @"L3", @"F"] emptyCode:-1];
    NSNumber *mechanical = [self codeForValue:values[16] options:@[@"false", @"true"] emptyCode:-1];
    NSNumber *died = [self codeForValue:values[17] options:@[@"false", @"true"] emptyCode:-1];
    NSNumber *tipped = [self codeForValue:values[18] options:@[@"false", @"true"] emptyCode:-1];
    NSNumber *scoringEffectiveness = [self integerValue:values[19] minimum:0 maximum:5];
    NSNumber *scoredHow = [self codeForValue:values[20] options:@[@"driving", @"stationary", @"both", @"none"] emptyCode:4];
    NSNumber *scoringLocation = [self maskForValue:values[21]
                                             options:@[@"Outpost Trench", @"Outpost", @"Hub", @"Ladder", @"Depot", @"Depot Trench"]];
    NSNumber *passingSkill = [self integerValue:values[22] minimum:0 maximum:5];
    NSNumber *passedHow = [self codeForValue:values[23] options:@[@"driving", @"stationary", @"both", @"none"] emptyCode:4];
    NSNumber *defenseSkill = [self integerValue:values[24] minimum:0 maximum:5];
    NSNumber *card = [self codeForValue:values[25] options:@[@"No Card", @"Yellow", @"Red"] emptyCode:-1];
    NSNumber *firstPick = [self codeForValue:values[26] options:@[@"Yes", @"May", @"No"] emptyCode:3];
    NSNumber *secondPick = [self codeForValue:values[27] options:@[@"Yes", @"May", @"No"] emptyCode:3];

    NSArray *codedValues = @[
        [self sanitizeValue:values[0]], match ?: [NSNull null], team ?: [NSNull null],
        startingPosition ?: [NSNull null], noShow ?: [NSNull null], autoFuel ?: [NSNull null],
        autoCollection ?: [NSNull null], autoActions ?: [NSNull null], autoStuck ?: [NSNull null],
        autoClimb ?: [NSNull null], teleopFuel ?: [NSNull null], bumpTrench ?: [NSNull null],
        defended ?: [NSNull null], fuelFed ?: [NSNull null], zoneActions ?: [NSNull null],
        endgameClimb ?: [NSNull null], mechanical ?: [NSNull null], died ?: [NSNull null],
        tipped ?: [NSNull null], scoringEffectiveness ?: [NSNull null], scoredHow ?: [NSNull null],
        scoringLocation ?: [NSNull null], passingSkill ?: [NSNull null], passedHow ?: [NSNull null],
        defenseSkill ?: [NSNull null], card ?: [NSNull null], firstPick ?: [NSNull null],
        secondPick ?: [NSNull null], [self sanitizeValue:values[28]]
    ];
    if ([codedValues containsObject:[NSNull null]]) {
        return @"";
    }

    NSData *data = [NSJSONSerialization dataWithJSONObject:codedValues options:0 error:nil];
    if (data == nil) {
        return @"";
    }
    NSString *base64 = [data base64EncodedStringWithOptions:0];
    base64 = [base64 stringByReplacingOccurrencesOfString:@"+" withString:@"-"];
    base64 = [base64 stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
    base64 = [base64 stringByReplacingOccurrencesOfString:@"=" withString:@""];
    NSString *payload = [@"QRSCOUT3-" stringByAppendingString:base64];
    return payload.length <= [self scannerPayloadLimit] ? payload : @"";
}

+ (NSUInteger)scannerPayloadLimit {
    return QRScoutScannerPayloadLimit;
}

@end
