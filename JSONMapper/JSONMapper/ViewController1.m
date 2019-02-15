

#import "ViewController1.h"
#import "Person.h"
#import "BaseModel.h"
#import "NSObject+JSONMapper.h"

@interface ViewController1 ()
@property (nonatomic) BaseModel *model;
@property (nonatomic) BaseModel *model1;
@end

@implementation ViewController1

- (void)dealloc{
     NSLog(@"dealloc");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"字典转模型";
    self.view.backgroundColor = [UIColor whiteColor];

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
}

@end
