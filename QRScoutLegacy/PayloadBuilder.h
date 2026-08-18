#import <Foundation/Foundation.h>

@interface PayloadBuilder : NSObject

+ (NSArray<NSString *> *)columnNames;
+ (NSString *)sanitizeValue:(NSString *)value;
+ (NSString *)payloadFromValues:(NSArray<NSString *> *)values;

@end
