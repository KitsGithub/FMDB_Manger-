# FMDB_Manger
基于FMDB的二次封装。
本项目利用runTime来动态获取所传入模型Class 的属性来创建数据库，和内部封装了一些基本的数据库操作，无需类依赖，在查询的时候，无需手动创建对象。直接把查询出来对应的模型的数据传递出来。

tips:由于技术原因，因此模型里面的类型需要是Object，暂不支持int、Float、doublt 这种基本数据类型，以后会持续更新和优化。请谅解


## 目录结构FMDB_Manger
- 更新日志
- API介绍


### 更新日志
> 17.10.25 基本完成FMDB_Manager的方法编写


### API介绍
FMDB_Manger的初始化方法
```objc
FMDB_Manager *manager = [FMDB_Manager shareManager];
```

同时，为了多个不同的使用场景，因而需要外部传入数据库路径，可通过实现```delegate```来传入数据库路径
```objc
/**
代理协议
*/
@protocol FMDB_Manager_Delegate <NSObject>

@required


@optional
- (NSString *)dbPath;


@end
```
而指定```DataSource``` 则可以动态传入某个场景需要的表名，如果不实现，则表名为所传入的Class，后面API会做详细解说
```objc
/**
数据源协议
*/
@protocol FMDB_Manager_DataSource <NSObject>
@optional
- (NSString *)tableNameWithModelClass:(id)Class;

@end
```

## 数据库的增删改查方法
### 增
```objc
/**
创建数据库

@param modelClass      数据模型Class
@param callBack        结果回调
*/
- (void)creatTableIfNotExistWithModelClass:(id)modelClass callBack:(CallBack)callBack;
```
创建数据库的用法
```objc
- (void)creatDB {
    //创建数据库
    [[FMDB_Manager shareManager] creatTableIfNotExistWithModelClass:[DBModel class] callBack:^(BOOL success) {
        if (success) {
            NSLog(@"数据库创建成功");
        }
    }];
}
```

向数据库中添加新的数据
```objc
/**
插入数据到 表

@param modelClass      数据模型Class
@param valuesArray     模型对应的值数组
@param callBack        结果回调
*/
- (void)InsertDataInTable:(id)modelClass withValuesArray:(NSArray <NSObject *> *)valuesArray callBack:(CallBack)callBack;
```
增加的数据的用法
```objc
- (void)creatDataToDB {
    for (DBModel *model in self.dataArray) {
        [[FMDB_Manager shareManager] InsertDataInTable:[DBModel class] withValuesArray:@[model.name,model.age,model.sex,model.school] callBack:^(BOOL success) {
            if (success) {
                NSLog(@"插入成功");
            } else {
                NSLog(@"插入失败");
            }
        }];
    }
}
```




### 删
从表中删除数据
```objc
/**
删除表数据

@param modelClass      数据模型Class
@param options         删除条件
@param callBack        结果回调
*/
- (void)DeletedDataFromTable:(id)modelClass withOptions:(NSString *)options callBack:(CallBack)callBack;
```
删除表数据的用法
```objc
- (void)deletedData {
    [[FMDB_Manager shareManager] DeletedDataFromTable:[DBModel class] withOptions:@"age >= 50" callBack:^(BOOL success) {
        if (success) {
            NSLog(@"删除成功");
        }
    }];
}
```

### 改
```objc
/**
修改表的数据

@param modelClass      数据模型Class
@param option1         修改内容
@param option2         修改条件
@param callBack        修改结果回调
*/
- (void)alterTableWithTableName:(id)modelClass withOpton1:(NSString *)option1 andOption2:(NSString *)option2 callBack:(CallBack)callBack;
```
修改表数据的用法
```objc
- (void)updataData {
    [[FMDB_Manager shareManager] alterTableWithTableName:[DBModel class] withOpton1:@"name = '我是男人'" andOption2:@"sex = '男'" callBack:^(BOOL success) {
        if (success) {
            NSLog(@"修改成功");
        }
    }];
}
```

### 查
```objc
/**
查询表数据

@param modelClass      数据模型Class
@param options         查询条件
@param callBack        查询结果回调 带modelClassObject 的对象数组 @[<ModelClassObject1>,<ModelClassObject2>,...]
*/
- (void)SearchTable:(id)modelClass withOptions:(NSString *)options callBack:(FMResultsCallBack)callBack;
```
查询表数据的用法
```objc
//查询数据
- (void)searchData {
    [[FMDB_Manager shareManager] SearchTable:[DBModel class] withOptions:@"age = 10" callBack:^(NSArray<NSObject *> *array) {
        NSLog(@"查询出 %zd 个对象",array.count);
        for (NSInteger index = 0; index<array.count; index++) {
            DBModel *model = (DBModel *)array[index];
            NSLog(@"%@",model.name);
        }
    }];
}
```


同时，由于使用场景的不同，提供了一个为表添加索引的API 和删除数据库表的方法
```objc
/**
为表添加索引

@param modelClass      数据模型Class
@param indexes         索引字段
@param IndexesName     新增的索引名
@param callBack        结果回调
*/
- (void)creatIndexInTable:(id)modelClass withString:(NSString *)indexes andIndexName:(NSString *)IndexesName callBack:(CallBack)callBack;
```

删除数据库表的方法
```objc
/**
删除数据库表

@param modelClass      数据模型Class __ 如没有设置DataSource，则取Class名为表名试着删除
@param callBack        删除结果
*/
- (void)deletedTableWithTableName:(id)modelClass callBack:(CallBack)callBack;
```
删除数据库表的用法
```objc
//删除数据库表
- (void)deletedTable {
    [[FMDB_Manager shareManager] deletedTableWithTableName:[DBModel class] callBack:^(BOOL success) {
        if (success) {
            NSLog(@"删除成功");
        }
    }];
}
```


