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

 @param modelClass  数据模型Class
 @param callBack    结果回调
 */
- (void)creatTableIfNotExistWithModelClass:(id)modelClass callBack:(CallBack)callBack;


/**
 插入数据到数据库

 @param modelClass  数据模型Class
 @param valuesArray 模型对应的值数组
 @param callBack    结果回调
 */
- (void)InsertDataInTable:(id)modelClass withValuesArray:(NSArray <NSObject *> *)valuesArray callBack:(CallBack)callBack;


/**
 删除表数据

 @param modelClass  数据模型Class
 @param options     删除条件
 @param callBack    结果回调
 */
- (void)DeletedDataFromTable:(id)modelClass withOptions:(NSString *)options callBack:(CallBack)callBack;

// 查表
- (NSArray <NSObject *> *)SearchTable:(id)modelClass withOptions:(NSString *)options callBack:(FMResultsCallBack)callBack;

// 改表
- (NSString *)alterTable:(id)type withOpton1:(NSString *)option1 andOption2:(NSString *)option2;



// 删除表



@end
