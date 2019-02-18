# JSONMapper
## 快速、简单、方便的字典转模型框架 ##

### 字典转模型

``` objectivec
//BaseModel.h
#import <Foundation/Foundation.h>
#import "Person.h"
#import "NSObject+JSONMapper.h"

@interface BaseModel : NSObject<JSONMapper>
@property (nonatomic, assign) BOOL result;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *age;
@property (nonatomic, copy) NSString *ID;
@property (nonatomic, copy) NSString *desc;
@property (nonatomic, copy) NSString *null;
@property (nonatomic, copy) NSDictionary *dic;
@property (nonatomic ) Person *person;
@end

//BaseModel.m
#import "BaseModel.h"
#import "Person.h"

@implementation BaseModel

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

//User.h
#import <Foundation/Foundation.h>
#import "Person.h"
#import "NSObject+JSONMapper.h"

@interface User : NSObject<JSONMapper>
@property (nonatomic) NSString *name;
@property (nonatomic) NSString *age;
@property (nonatomic) NSString *ID;
@property (nonatomic) NSString *desc;
@property (nonatomic) NSMutableArray <Person *> *persons;
@property (nonatomic) NSMutableArray *strs;
@end

//User.m
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

//Person.h
#import <Foundation/Foundation.h>

@interface Person : NSObject
@property (nonatomic, copy) NSString * name;
@property (nonatomic, copy) NSString * age;
@property (nonatomic, copy) NSString * sex;
@end

//Person.m
#import "Person.h"

@implementation Person

@end

```
### 字典转模型
``` objectivec

NSDictionary *json = @{
                       @"desciption":@"1111",
                       @"id":@"8888888",
                       @"newName":@"jack",
                       @"null":[NSNull null],
                       @"result":[NSNumber numberWithBool:false],
                       @"person": @{
                                   @"name" : @"jack",
                                   @"age" : @"26",
                                   @"sex" : @"男"
                               }
                       };

BaseModel *model = [BaseModel yx_modelWithObject:json];
NSLog(@"model.id = %@",model.ID);
NSLog(@"model.desciption = %@",model.desc);
NSLog(@"model.name = %@",model.name);
NSLog(@"model.null = %@",model.null);
NSLog(@"model.result = %d",model.result);
NSLog(@"model.person.name = %@",model.person.name);
NSLog(@"model.person.age = %@",model.person.age);
NSLog(@"model.person.sex = %@",model.person.sex);
NSLog(@"\n");

BaseModel *model1 = [[BaseModel new] yx_setModelWithObject:json];
NSLog(@"model1.id = %@",model1.ID);
NSLog(@"model1.desciption = %@",model1.desc);
NSLog(@"model1.name = %@",model1.name);
NSLog(@"model1.null = %@",model1.null);
NSLog(@"model1.result = %d",model.result);
NSLog(@"model1.person.name = %@",model1.person.name);
NSLog(@"model1.person.age = %@",model1.person.age);
NSLog(@"model1.person.sex = %@",model1.person.sex);
```
### 数组字典转模型
``` objectivec
NSArray *json = @[
                       @{
                           @"desciption":@"1111",
                           @"id":@"111",
                           @"newName":@"1",
                           @"null":[NSNull null],
                           @"strs":@[@"123",@"456",@"789"],
                           @"persons":@[
                                           @{
                                               @"name" : @"aa",
                                               @"age" : @"26",
                                               @"sex" : @"男"
                                           },
                                           @{
                                               @"name" : @"bb",
                                               @"age" : @"16",
                                               @"sex" : @"男"
                                            },
                                           @{
                                               @"name" : @"cc",
                                               @"age" : @"36",
                                               @"sex" : @"女"
                                            }
                    
                                        ]
                          
                           },
                       @{
                           @"desciption":@"2222",
                           @"id":@"222",
                           @"newName":@"2",
                           @"null":[NSNull null],
                           @"strs":@[@"123",@"456",@"789"],
                           @"persons":@[
                                   @{
                                       @"name" : @"dd",
                                       @"age" : @"26",
                                       @"sex" : @"男"
                                       },
                                   @{
                                       @"name" : @"ee",
                                       @"age" : @"16",
                                       @"sex" : @"男"
                                       },
                                   @{
                                       @"name" : @"ff",
                                       @"age" : @"36",
                                       @"sex" : @"女"
                                       }
                                   
                                   ]
                           
                           }
                       ];

NSMutableArray<User *> *models = [User yx_modelArrayWithObject:json];
NSMutableArray<User *> *models1 = [[User new] yx_setModelArrayWithObject:json];
NSLog(@"%@",models);
NSLog(@"%@",models1);
```
### 模型转字典
``` objectivec
NSDictionary *json = @{
                       @"desciption":@"1111",
                       @"id":@"8888888",
                       @"newName":@"Android",
                       @"null":[NSNull null],
                       @"person": @{
                               @"name" : @"iOS",
                               @"age" : @"26",
                               @"sex" : @"男"
                               },
                       @"dic": @{
                               @"name" : @"PHP",
                               @"age" : @"26",
                               @"sex" : @"男",
                               @"dic1": @{
                                       @"name" : @"Java",
                                       @"age" : @"26",
                                       @"sex" : @"男"
                                       }
                               }
                       };


BaseModel *model = [BaseModel yx_modelWithObject:json];
NSDictionary *d = [model yx_keyValues];
NSLog(@"%@", d);
```

















