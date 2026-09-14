#import "PayloadBuilder.h"

@implementation PayloadBuilder

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

@end
