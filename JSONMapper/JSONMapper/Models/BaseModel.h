

#import <Foundation/Foundation.h>
#import "Person.h"

@interface BaseModel : NSObject
@property (nonatomic, assign) BOOL result;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *age;
@property (nonatomic, copy) NSString *ID;
@property (nonatomic, copy) NSString *desc;
@property (nonatomic, copy) NSString *null;
@property (nonatomic, copy) NSDictionary *dic;
@property (nonatomic ) Person *person;

@end
