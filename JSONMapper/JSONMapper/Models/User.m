

#import "User.h"

@implementation User

+ (NSDictionary *)yx_modelClassInArray{
    return @{
             @"persons" : [Person class]
             };
}

+ (NSDictionary *)yx_loadModelCustomPropertyMapper{
    return @{
             @"id" : @"ID",
             @"desciption":  @"desc",
             @"newName" : @"name"
             };
}

+ (NSDictionary *)yx_exportModelCustomPropertyMapper{
    return @{
             @"ID" : @"id",
             @"desc":  @"desciption",
             @"name" : @"newName"
             };
}

+ (void)yx_objectTransformModelDidFinish{
    NSLog(@"转换完毕");
}


@end
