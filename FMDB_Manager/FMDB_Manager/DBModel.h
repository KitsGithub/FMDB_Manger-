//
//  DBModel.h
//  FMDB_Manager
//
//  Created by mac on 2017/8/25.
//  Copyright © 2017年 kit. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DBModel : NSObject

@property (nonatomic, copy) NSString *name;

@property (nonatomic, weak) NSNumber *age;

@property (nonatomic, copy) NSString *sex;

@property (nonatomic, weak) NSNumber *school;



@end
