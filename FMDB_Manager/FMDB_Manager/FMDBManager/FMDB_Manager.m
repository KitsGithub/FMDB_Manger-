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
#import <Foundation/NSEnumerator.h>
#import <Foundation/NSRange.h>
#import <Foundation/NSObjCRuntime.h>

#import "ManagerConst.h"

typedef enum : NSUInteger {
    Creat_DBOperationType,  //创建
    Inser_DBOperationType,  //插入
} DBOperationType;



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
    
    if (!dbPath.length) {
        if ([self.delegate respondsToSelector:@selector(dbPath)]) {
            dbPath = [self.delegate dbPath];
            NSLog(@"%@",dbPath);
        }
    }
}

/**
 关闭所有数据库通道
 */
- (void)closeAllSquilteTable {
    //获取所有的表名
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    if ([db open]) {
        FMResultSet *resultSet = [db executeQuery:@"SELECT * FROM sqlite_master where type='table';"];
        NSLog(@"已存在的表名 - %@",resultSet.columnNameToIndexMap[@"name"]);
    }
    
    
    
}

#pragma mark - 私有方法
/**
 获取模型的类型与名称

 @param modelClass 模型的class
 @return 返回一个字典模型。其字典格式为
 @{
    NSString *pType = dic[@"pType"]; //属性类型
    NSString *pName = dic[@"pName"]; //属性名称
 }
 */
- (NSArray<NSMutableDictionary *> *)getPropertyNameArrayWith:(id)modelClass {
    // 动态获取模型的属性名
    NSMutableArray *pArray = [NSMutableArray array];
    unsigned int count = 0;
    
    Ivar *ivarList = class_copyIvarList(modelClass, &count);
    
    for (int index = 0; index < count; ++index) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        
        // 获得属性名字
        const char *cName = ivar_getName(ivarList[index]);
        const char *cType = ivar_getTypeEncoding(ivarList[index]);
        
        // 将c语言字符串转换为oc字符串
        NSString *ocName = [[[NSString alloc] initWithCString:cName encoding:NSUTF8StringEncoding] substringFromIndex:1];
        NSString *ocType = [ManagerConst ChangeSystemTypeToNewType:cType];
        
        dic[@"pType"] = ocType;
        dic[@"pName"] = ocName;
        
        if (ocName.length) {
            [pArray addObject:dic];
        }
    }
    
    free(ivarList);
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
    
     NSArray *pArray = [self getPropertyNameArrayWith:modelClass];
     
     for (NSInteger index = 0; index < pArray.count; index++ ) {
         NSMutableDictionary *dic = pArray[index];
         //获取set方法
         SEL setSel = [self creatSetterWithPropertyName:dic[@"pName"]];
         
         if ([model respondsToSelector:setSel]) {
             if ([dic[@"pType"] isEqualToString:@"TEXT"]) {
                 NSString *value = [result stringForColumn:dic[@"pName"]];
                 [model performSelectorOnMainThread:setSel withObject:value waitUntilDone:[NSThread isMainThread]];
             } else {
                 int value = [result intForColumn:dic[@"pName"]];
//                 ((void (*)(id, SEL, int))(void *) objc_msgSend)((id)model, setSel, intValue);
                 
                 [model performSelectorOnMainThread:setSel withObject:@(value) waitUntilDone:[NSThread isMainThread]];
             }
         }
     }
    
    
    
    return model;
}



/**
 获取表名

 @param modelClass  模型的Class
 @return            如果DataSource没有指定表名，则Class就是表名
 */
- (NSString *)getTableNameWithModelClass:(id)modelClass {
    NSString *tableName;
    
    if ([self.dataSource respondsToSelector:@selector(tableNameWithModelClass:)]) {
        tableName = [self.dataSource tableNameWithModelClass:modelClass];
    } else {
        tableName = NSStringFromClass(modelClass);
    }
    return tableName;
}


#pragma mark - 通过字符串来创建该字符串的Setter方法，并返回
// 获取属性的Get方法
- (SEL)creatGetterWithPropertyName: (NSString *) propertyName{
    //1.返回get方法: oc中的get方法就是属性的本身
    return NSSelectorFromString(propertyName);
}
// 获取属性的set 方法
- (SEL)creatSetterWithPropertyName:(NSString *)propertyName {
    
    //判断首字母是否为小写字母，是则换成大写
    for (NSUInteger index = 0; index < propertyName.length; ) {
        if ([propertyName characterAtIndex:index] >= 'a' && [propertyName characterAtIndex:index] <= 'z') {
            
            int asciiCode = [propertyName characterAtIndex:0];
            asciiCode -= 32;
            
            propertyName = [propertyName stringByReplacingCharactersInRange:NSMakeRange(index, 1) withString:[NSString stringWithFormat:@"%c", asciiCode]];
            break;
        } else {
            break;
        }
    }
    
    NSString *selName = [NSString stringWithFormat:@"set%@:",propertyName];
    return NSSelectorFromString(selName);
}

// 拼接参数
- (NSString *)getValuesString:(NSString *)fieldStr {
    
    NSArray *array = [fieldStr componentsSeparatedByString:@","];
    NSString *valueString = @"(";
    for (NSInteger index = 0; index < array.count; index++) {
        
        if (index == 0) {
            valueString = [valueString stringByAppendingString:@"?"];
        } else {
            valueString = [valueString stringByAppendingString:@", ?"];
        }
    }
    
    valueString = [valueString stringByAppendingString:@");"];
    
    return valueString;
}



#pragma mark - other
- (NSString *)getCreatTableOperationStrWithPropertyArray:(NSArray *)pArray type:(DBOperationType)type {
    NSString *operationStr = @"(";
    
    for (NSInteger index = 0; index < pArray.count; index++) {
        NSDictionary *dic = pArray[index];
        
        NSString *pType = dic[@"pType"];
        NSString *pName = dic[@"pName"];
        
        if (type == Creat_DBOperationType) {            //建表字段
            operationStr = [operationStr stringByAppendingString:[NSString stringWithFormat:@"%@ %@",pName,pType]];
        } else if (type == Inser_DBOperationType) {     //插入数据字段
            operationStr = [operationStr stringByAppendingString:[NSString stringWithFormat:@"%@",pName]];
        }
        
        if (index != pArray.count - 1) {
            operationStr = [operationStr stringByAppendingString:@","];
        }
    }
    operationStr = [operationStr stringByAppendingString:@")"];
    
    if (type == Inser_DBOperationType) {
        operationStr = [operationStr stringByAppendingString:[NSString stringWithFormat:@" VALUES %@",[self getValuesString:operationStr]]];
    }
    return operationStr;
}




#pragma mark -   数据库的 - 基本操作
/**
 创建数据库
 
 @param modelClass  数据模型Class
 @param callBack    结果回调
 */
- (void)creatTableIfNotExistWithModelClass:(id)modelClass callBack:(CallBack)callBack {
    if (!dbPath.length) {
        if ([self.delegate respondsToSelector:@selector(dbPath)]) {
            dbPath = [self.delegate dbPath];
        }
    }
    
    if (![modelClass isKindOfClass:[NSObject class]]) {
        NSAssert(false, @"传入的内容应该是NSObject");
        return;
    }
    
    FMDatabaseQueue *db_Queue = [FMDatabaseQueue databaseQueueWithPath:dbPath];
    [db_Queue inDatabase:^(FMDatabase *db) {
        
        if ([db open]) {
            NSLog(@"打开成功数据库成功");
            //获取创建数据库字段
            NSString *tableField = [self getCreatTableOperationStrWithPropertyArray:[self getPropertyNameArrayWith:modelClass] type:Creat_DBOperationType];
            
            
            //获取表名
            NSString *tableName = [self getTableNameWithModelClass:modelClass];
            
            NSString *operationString = [@"CREATE TABLE IF NOT EXISTS " stringByAppendingString:tableName];
            operationString = [operationString stringByAppendingString:[NSString stringWithFormat:@" %@",tableField]];
            
            BOOL success = [db executeUpdate:operationString];
            
            if (callBack) {
                callBack(success);
            }
            
        } else {
            NSLog(@"打开失败");
        }
    }];
}

/**
 为表添加索引
 
 @param modelClass      数据模型Class
 @param indexes         索引字段
 @param IndexesName     新增的索引名
 @param callBack        结果回调
 */
- (void)creatIndexInTable:(id)modelClass withString:(NSString *)indexes andIndexName:(NSString *)IndexesName callBack:(CallBack)callBack {
    
    //获取表名
    NSString *tableName = [self getTableNameWithModelClass:modelClass];
    
    NSString *operation = [NSString stringWithFormat:@"create index %@ on %@(%@)",IndexesName,tableName,indexes];
    FMDatabaseQueue *db_Queue = [FMDatabaseQueue databaseQueueWithPath:dbPath];
    [db_Queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        if ([db open]) { //防止该表没有被创建or没有被打开
            BOOL success = [db executeUpdate:operation];
            if (callBack) {
                callBack(success);
            }
        }
    }];
}


/**
 插入数据到数据库
 
 @param modelClass 数据模型Class
 @param valuesArray 模型对应的值数组
 */
- (void)InsertDataInTable:(id)modelClass withValuesArray:(NSArray <NSObject *> *)valuesArray callBack:(CallBack)callBack {
    
    if (!valuesArray.count) {
        NSAssert(false, @"传入的数组为空");
    }
    
    //获取表名
    NSString *tableName = [self getTableNameWithModelClass:modelClass];
    
    //插入操作字符串
    NSString *operationString = [[@"INSERT INTO " stringByAppendingString:tableName] stringByAppendingString:[NSString stringWithFormat:@" %@",[self getCreatTableOperationStrWithPropertyArray:[self getPropertyNameArrayWith:modelClass] type:Inser_DBOperationType]]];
    NSLog(@"插入操作符 %@",operationString);
    
    FMDatabaseQueue *db_Queue = [FMDatabaseQueue databaseQueueWithPath:dbPath];
    [db_Queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        if ([db open]) { //防止该表没有被创建or没有被打开
            BOOL success = [db executeUpdate:operationString withArgumentsInArray:valuesArray];
            if (callBack) {
                callBack(success);
            }
        }
    }];
}



/**
 删除表数据
 
 @param modelClass  数据模型Class
 @param options     删除条件
 @param callBack    结果回调
 */
- (void)DeletedDataFromTable:(id)modelClass withOptions:(NSString *)options callBack:(CallBack)callBack {
    //获取表名
    NSString *tableName = [self getTableNameWithModelClass:modelClass];
    
    NSString *optionStr = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@;",tableName,options];
    
    FMDatabaseQueue *db_Queue = [FMDatabaseQueue databaseQueueWithPath:dbPath];
    [db_Queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        if ([db open]) { //防止该表没有被创建or没有被打开
            BOOL success = [db executeUpdate:optionStr];
            if (callBack) {
                callBack(success);
            }
        }
    }];
}

/**
 查询数据库表
 
 @param modelClass  数据模型Class
 @param options     查询条件
 @param callBack    查询结果回调
 */
- (void)SearchTable:(id)modelClass withOptions:(NSString *)options callBack:(FMResultsCallBack)callBack {
    NSMutableArray *targetArray = [NSMutableArray array];
    
    //获取表名
    NSString *tableName = [self getTableNameWithModelClass:modelClass];
    
    NSString *operation = @"SELECT ";
    
    NSArray *pArray = [self getPropertyNameArrayWith:modelClass];
    NSString *pFields = [NSString string];

    for (NSInteger index = 0; index < pArray.count; index++) {
        NSMutableDictionary *dic = pArray[index];
        if (index == 0) {
            pFields = [pFields stringByAppendingString:[NSString stringWithFormat:@"%@",dic[@"pName"]]];
        } else {
            pFields = [pFields stringByAppendingString:[NSString stringWithFormat:@",%@",dic[@"pName"]]];
        }
    }
    
    operation = [operation stringByAppendingString:[NSString stringWithFormat:@"%@ FROM %@ WHERE %@;",pFields,tableName,options]];
    
    
    FMDatabaseQueue *db_Queue = [FMDatabaseQueue databaseQueueWithPath:dbPath];
    [db_Queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        if ([db open]) { //防止该表没有被创建or没有被打开
            FMResultSet *result = [db executeQuery:operation];
            while ([result next]) {
                id modelObject = [self setPropertyWithResule:result WithClass:modelClass];
                [targetArray addObject:modelObject];
            }
            if (callBack) {
                callBack([targetArray copy]);
            }
        }
    }];
    
}


/**
 修改表的数据
 
 @param modelClass      数据模型Class
 @param option1         修改内容
 @param option2         修改条件
 @param callBack        修改结果回调
 */
- (void)alterTableWithTableName:(id)modelClass withOpton1:(NSString *)option1 andOption2:(NSString *)option2 callBack:(CallBack)callBack{
    
    //获取表名
    NSString *tableName = [self getTableNameWithModelClass:modelClass];
    
    NSString *operation = [NSString string];
    operation = [operation stringByAppendingString:[NSString stringWithFormat:@"UPDATE %@ SET %@ WHERE %@",tableName,option1,option2]];
    
    FMDatabaseQueue *db_Queue = [FMDatabaseQueue databaseQueueWithPath:dbPath];
    [db_Queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        if ([db open]) { //防止该表没有被创建or没有被打开
            BOOL success = [db executeUpdate:operation];
            if (callBack) {
                callBack(success);
            }
        }
    }];
    
    
}


/**
 删除数据库表
 
 @param modelClass  数据模型Class __ 如没有设置DataSource，则取Class名为表名试着删除
 @param callBack    删除结果
 */
- (void)deletedTableWithTableName:(id)modelClass callBack:(CallBack)callBack {
    //获取表名
    NSString *tableName = [self getTableNameWithModelClass:modelClass];
    
    NSString *optionStr = [NSString stringWithFormat:@"DROP TABLE IF EXISTS %@;",tableName];
    
    FMDatabaseQueue *db_Queue = [FMDatabaseQueue databaseQueueWithPath:dbPath];
    [db_Queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        if ([db open]) { //防止该表没有被创建or没有被打开
            BOOL success = [db executeUpdate:optionStr];
            if (callBack) {
                callBack(success);
            }
        }
    }];
}


#pragma mark - lazyLoad
- (NSMutableArray<NSString *> *)tableNameArray {
    if (!_tableNameArray) {
        _tableNameArray = [NSMutableArray array];
    }
    return _tableNameArray;
}

@end
