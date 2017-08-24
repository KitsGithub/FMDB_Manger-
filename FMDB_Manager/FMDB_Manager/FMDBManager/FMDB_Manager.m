//
//  FMDB_Manager.m
//  FMDB_Manager
//
//  Created by mac on 2017/8/24.
//  Copyright © 2017年 kit. All rights reserved.
//

#import "FMDB_Manager.h"
#import <FMDB.h>
#import <objc/runtime.h>

//初始化一次之后就会记住数据库地址
static NSString *dbPath = @"";

@interface FMDB_Manager ()

@property (nonatomic, strong) NSMutableArray<NSString *> *tableNameArray;

@end

@implementation FMDB_Manager

+ (instancetype)shareManager {
    return [[self alloc] initWithShareManager];
}

- (instancetype)initWithShareManager {
    static FMDB_Manager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[FMDB_Manager alloc] init];
    });
    return manager;
}


/**
 打开当前用户所有的表
 需要在 didFinishLaunchingWithOptions 初始化并调用
 */
- (void)openAllSqliteTable {
    //获取所有的表名
    NSString *smsPaht = [[NSBundle mainBundle] pathForResource:@"FMDB_Manager_Test" ofType:@"sqlite"];
    FMDatabase *db = [FMDatabase databaseWithPath:smsPaht];
    if ([db open]) {
        FMResultSet *resultSet = [db executeQuery:@"SELECT * FROM sqlite_master where type='table';"];
        [self.tableNameArray addObject:resultSet.columnNameToIndexMap[@"name"]];
    }
    
    
    [self creatTableWithTableType:@"123"];
}

/**
 关闭所有数据库通道
 */
- (void)closeAllSquilteTable {
    
}

#pragma mark - 动态取出模型的所有属性
- (NSArray *)getPropertyNameArrayWith:(id)model {
    // 动态获取模型的属性名
    NSMutableArray *pArray = [NSMutableArray array];
    unsigned int count = 0;
    
    objc_property_t *properties = class_copyPropertyList([model class], &count);
    
    for (int index = 0; index < count; ++index) {
        // 根据索引获得对应的属性(属性是一个结构体,包含很多其他的信息)
        objc_property_t property = properties[index];
        // 获得属性名字
        const char *cname = property_getName(property);
        // 将c语言字符串转换为oc字符串
        NSString *ocname = [[NSString alloc] initWithCString:cname encoding:NSUTF8StringEncoding];
        
        [pArray addObject:ocname];
    }
    return pArray;
}

// 获取模型属性的值
- (NSArray *)getProperyWith:(id)model andArray:(NSMutableArray *)pArray {
    for (NSInteger index = 0; index < pArray.count; index++) {
        NSMutableString *resultString = [[NSMutableString alloc] init];
        //获取get方法
        SEL getSel = [self creatGetterWithPropertyName:pArray[index]];
        //获得类和方法的签名
        NSMethodSignature *signature = [model methodSignatureForSelector:getSel];
        
        //从签名获得调用对象
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
        
        //设置target
        [invocation setTarget:model];
        
        //设置selector
        [invocation setSelector:getSel];
        
        //接收返回的值
        NSObject *__unsafe_unretained returnValue = nil;
        
        //调用
        [invocation invoke];
        
        //接收返回值
        [invocation getReturnValue:&returnValue];
        
        [resultString appendFormat:@"%@", returnValue];
        [pArray replaceObjectAtIndex:index withObject:resultString];
        
    }
    return pArray;
    
}

// 设置模型属性的值
- (id)setPropertyWithResule:(FMResultSet *)result WithClass:(Class)modelClass {
    
    //实例化一个model
    id model = [[modelClass alloc] init];
    
    NSArray *pArray = [self getPropertyNameArrayWith:model];
    
    for (NSInteger index = 0; index < pArray.count; index++ ) {
        //获取set方法
        SEL setSel = [self creatSetterWithPropertyName:pArray[index]];
        
        if ([model respondsToSelector:setSel]) {
            NSString *value = [result stringForColumn:pArray[index]];
            value = [value stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[[value substringToIndex:1] uppercaseString]];
            [model performSelectorOnMainThread:setSel withObject:value waitUntilDone:[NSThread isMainThread]];
            
        }
        
    }
    return model;
}

#pragma mark - 通过字符串来创建该字符串的Setter方法，并返回
// 获取属性的Get方法
- (SEL)creatGetterWithPropertyName: (NSString *) propertyName{
    //1.返回get方法: oc中的get方法就是属性的本身
    return NSSelectorFromString(propertyName);
}
// 获取属性的set 方法
- (SEL)creatSetterWithPropertyName:(NSString *)propertyName {
    NSString *selName = [NSString stringWithFormat:@"set%@:",propertyName];
    return NSSelectorFromString(selName);
}



#pragma mark -   数据库的 - 基本操作
// 建表
- (void)creatTableWithTableType:(id)model {
    if (!dbPath.length) {
        if ([self.delegate respondsToSelector:@selector(dbPath)]) {
            dbPath = [self.delegate dbPath];
        }
    }
    
    FMDatabaseQueue *db_Queue = [FMDatabaseQueue databaseQueueWithPath:dbPath];
    [db_Queue inDatabase:^(FMDatabase *db) {
        
        if ([db open]) {
            NSLog(@"打开成功数据库成功");
            NSString *tableField = [NSString string];
            NSString *tableName = NSStringFromClass([model class]);
            
            
            NSString *operationString = [@"CREATE TABLE IF NOT EXISTS " stringByAppendingString:tableName];
            operationString = [operationString stringByAppendingString:tableField];
            
            BOOL success = [db executeUpdate:operationString];
            
            if (success) {
                NSLog(@"%@创建成功",tableName);
            } else {
                NSLog(@"%@创建失败",tableName);
            }
            
            
        } else {
            NSLog(@"打开失败");
        }
    }];
}

// 删表
- (NSString *)deletedTableData:(id)type withOption:(NSString *)option {
    return nil;
}


// 改表
- (NSString *)alterTable:(id)type withOpton1:(NSString *)option1 andOption2:(NSString *)option2 {
    return nil;
}

// 查表
- (NSString *)SearchTable:(id)type withOption:(NSString *)option {
    return nil;
}


- (NSString *)getOptionStringWithModel:(id)model {
    NSMutableArray *propertyArray = [NSMutableArray array];
    [self getProperyWith:model andArray:propertyArray];
    
    
    
    return nil;
}



#pragma mark - lazyLoad
- (NSMutableArray<NSString *> *)tableNameArray {
    if (!_tableNameArray) {
        _tableNameArray = [NSMutableArray array];
    }
    return _tableNameArray;
}

@end
