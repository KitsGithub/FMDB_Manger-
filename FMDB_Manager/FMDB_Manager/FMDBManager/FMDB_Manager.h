//
//  FMDB_Manager.h
//  FMDB_Manager
//
//  Created by mac on 2017/8/24.
//  Copyright © 2017年 kit. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^CallBack)(BOOL success);
typedef void(^FMResultsCallBack)(NSArray <NSObject *> *array);

/**
 代理协议
 */
@protocol FMDB_Manager_Delegate <NSObject>

@required


@optional
- (NSString *)dbPath;


@end


/**
 数据源协议
 */
@protocol FMDB_Manager_DataSource <NSObject>
@optional
- (NSString *)tableNameWithModelClass:(id)Class;

@end


@interface FMDB_Manager : NSObject

@property (nonatomic, weak) id <FMDB_Manager_Delegate> delegate;
@property (nonatomic, weak) id <FMDB_Manager_DataSource> dataSource;

/**
 单例初始化
 */
+ (instancetype)shareManager;

/**
 打开当前用户所有的表
 需要在 didFinishLaunchingWithOptions 初始化并调用
 */
- (void)openAllSqliteTable;

/**
 关闭所有数据库通道
 */
- (void)closeAllSquilteTable;


/* 数据库 - 基本操作 */
/**
 创建数据库

 @param modelClass      数据模型Class
 @param callBack        结果回调
 */
- (void)creatTableIfNotExistWithModelClass:(id)modelClass callBack:(CallBack)callBack;


/**
 为表添加索引

 @param modelClass      数据模型Class
 @param indexes         索引字段
 @param IndexesName     新增的索引名
 @param callBack        结果回调
 */
- (void)creatIndexInTable:(id)modelClass withString:(NSString *)indexes andIndexName:(NSString *)IndexesName callBack:(CallBack)callBack;


/**
 插入数据到 表

 @param modelClass      数据模型Class
 @param valuesArray     模型对应的值数组
 @param callBack        结果回调
 */
- (void)InsertDataInTable:(id)modelClass withValuesArray:(NSArray <NSObject *> *)valuesArray callBack:(CallBack)callBack;


/**
 删除表数据

 @param modelClass      数据模型Class
 @param options         删除条件
 @param callBack        结果回调
 */
- (void)DeletedDataFromTable:(id)modelClass withOptions:(NSString *)options callBack:(CallBack)callBack;

/**
 查询表数据

 @param modelClass      数据模型Class
 @param options         查询条件
 @param callBack        查询结果回调 带modelClassObject 的对象数组 @[<ModelClassObject1>,<ModelClassObject2>,...]
 */
- (void)SearchTable:(id)modelClass withOptions:(NSString *)options callBack:(FMResultsCallBack)callBack;


/**
 修改表的数据

 @param modelClass      数据模型Class
 @param option1         修改内容
 @param option2         修改条件
 @param callBack        修改结果回调
 */
- (void)alterTableWithTableName:(id)modelClass withOpton1:(NSString *)option1 andOption2:(NSString *)option2 callBack:(CallBack)callBack;


/**
 删除数据库表

 @param modelClass      数据模型Class __ 如没有设置DataSource，则取Class名为表名试着删除
 @param callBack        删除结果
 */
- (void)deletedTableWithTableName:(id)modelClass callBack:(CallBack)callBack;;

@end
