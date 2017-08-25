//
//  ManagerConst.m
//  FMDB_Manager
//
//  Created by mac on 2017/8/25.
//  Copyright © 2017年 kit. All rights reserved.
//

#import "ManagerConst.h"

/**
 *  成员变量类型（属性类型）
 */
NSString *const KXPropertyTypeInt = @"i";
NSString *const KXPropertyTypeShort = @"s";
NSString *const KXPropertyTypeFloat = @"f";
NSString *const KXPropertyTypeDouble = @"d";
NSString *const KXPropertyTypeLong = @"l";
NSString *const KXPropertyTypeLongLong = @"q";
NSString *const KXPropertyTypeChar = @"c";
NSString *const KXPropertyTypeBOOL1 = @"c";
NSString *const KXPropertyTypeBOOL2 = @"b";
NSString *const KXPropertyTypeBOOL3 = @"B";
NSString *const KXPropertyTypePointer = @"*";

NSString *const KXPropertyTypeIvar = @"^{objc_ivar=}";
NSString *const KXPropertyTypeMethod = @"^{objc_method=}";
NSString *const KXPropertyTypeBlock = @"@?";
NSString *const KXPropertyTypeClass = @"#";
NSString *const KXPropertyTypeSEL = @":";
NSString *const KXPropertyTypeId = @"@";

@implementation ManagerConst

+ (NSString *)ChangeSystemTypeToNewType:(const char *)type {
    
    NSString *ocType = [[NSString alloc] initWithCString:type encoding:NSUTF8StringEncoding];
    
    if ([ocType isEqualToString:KXPropertyTypeId]) {
        return @"";
    } else if (
               [ocType isEqualToString:KXPropertyTypeInt]       ||
               [ocType isEqualToString:KXPropertyTypeShort]     ||
               [ocType isEqualToString:KXPropertyTypeFloat]     ||
               [ocType isEqualToString:KXPropertyTypeDouble]    ||
               [ocType isEqualToString:KXPropertyTypeLong]      ||
               [ocType isEqualToString:KXPropertyTypeLongLong]  ||
               [ocType isEqualToString:KXPropertyTypeBOOL1]     ||
               [ocType isEqualToString:KXPropertyTypeBOOL2]     ||
               [ocType isEqualToString:KXPropertyTypeBOOL3]     )
    {

        return @"INTEGER";
    } else if (ocType.length > 3 && [ocType hasPrefix:@"@\""]) {
        
        NSString *type = [ocType substringWithRange:NSMakeRange(2, ocType.length - 3)];
        return @"TEXT";
        
    }
    
    
    
    
    return @"";
}

@end
