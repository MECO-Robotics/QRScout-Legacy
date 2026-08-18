#import "PayloadBuilder.h"

@implementation PayloadBuilder

+ (NSArray<NSString *> *)columnNames {
    return @[
        @"scout", @"match", @"team", @"alliance", @"station", @"robotNotes",
        @"autoMobility", @"autoFuel", @"autoAmp", @"teleopSpeaker", @"teleopAmp",
        @"teleopFeed", @"fouls", @"defenseRating", @"endgame", @"comments"
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
