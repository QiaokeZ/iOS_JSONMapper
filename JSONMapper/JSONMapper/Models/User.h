

#import <Foundation/Foundation.h>
#import "Person.h"

@interface User : NSObject
@property (nonatomic) NSString *name;
@property (nonatomic) NSString *age;
@property (nonatomic) NSString *ID;
@property (nonatomic) NSString *desc;
@property (nonatomic) NSMutableArray <Person *> *persons;
@property (nonatomic) NSMutableArray *strs;
@end
