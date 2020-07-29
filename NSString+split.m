#import "NSString+split.h"
@implementation NSString (SplitPattern)
 
- (NSArray *)splitNewLine
{
    return [self splitPattern:@"(\r|(\r?\n))"];
}

- (NSArray *)splitNewLine2
{
    return [self splitPattern:@"(\r|(\r?\n\n))"];
}

- (NSArray *)splitPattern:(NSString *)pattern
{
    NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:0];
    @autoreleasepool
    {
        NSError *error = NULL;
        NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:&error];
        [self componentsSeparatedByRegularExpression:regexp usingBlock:^(NSString *component) {
            [result addObject:component];
        }];
    }
    return result;
}
 
- (void)componentsSeparatedByRegularExpression:(NSRegularExpression *)regexp usingBlock:(void (^)(NSString *))block
{
    __block int startPage = 0;
    [regexp enumerateMatchesInString:self options:0 range:NSMakeRange(0, self.length)
                          usingBlock:^(NSTextCheckingResult *match,NSMatchingFlags flag,BOOL *stop) {
        NSUInteger matchLocation = match.range.location;
        NSUInteger matchLength   = match.range.length;
        block([self substringWithRange:NSMakeRange(startPage, matchLocation - startPage)]);
        startPage = (int)(matchLocation + matchLength);
    }];
    block([self substringWithRange:NSMakeRange(startPage, self.length - startPage)]);
}
 
@end

