#import "PayloadBuilder.h"

@implementation PayloadBuilder

+ (NSArray<NSString *> *)columnNames {
    return @[
        @"scout", @"match", @"team", @"alliance", @"station", @"robotNotes",
        @"autoFuelScored", @"autoFuelMissed", @"autoTowerLevel1",
        @"teleopFuelScored", @"teleopFuelMissed", @"teleopFuelInactive",
        @"fouls", @"defenseRating", @"towerLevel", @"comments"
    ];
}

+ (NSString *)sanitizeValue:(NSString *)value {
    if (value == nil) {
        return @"";
    }

    NSString *sanitized = [value stringByReplacingOccurrencesOfString:@"," withString:@" "];
    sanitized = [sanitized stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    return [sanitized stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

+ (NSString *)payloadFromValues:(NSArray<NSString *> *)values {
    return [values componentsJoinedByString:@","];
}

@end
