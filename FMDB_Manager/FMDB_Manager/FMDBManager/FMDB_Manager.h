//
//  FMDB_Manager.h
//  FMDB_Manager
//
//  Created by mac on 2017/8/24.
//  Copyright © 2017年 kit. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FMDB_Manager_Delegate <NSObject>

@required


@optional
- (NSString *)dbPath;


@end


@protocol FMDB_Manager_DataSource <NSObject>
@optional
- (NSString *)tableName;

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
// 建表
- (void)creatTableIfNotExistWithTableType:(id)model;

// 删除表中内容
- (void)deletedTableData:(id)model withOption:(NSString *)option;


// 插表
- (void)InsertDataInTable:(id)model modelArray:(NSMutableArray *)array;

// 改表
- (NSString *)alterTable:(id)type withOpton1:(NSString *)option1 andOption2:(NSString *)option2;

// 查表
- (NSString *)SearchTable:(id)type withOption:(NSString *)option;




@end
