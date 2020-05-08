//
//  BKYSQLHelper.h
//  bkvoice
//
//  Created by mac on 2019/12/24.
//  Copyright © 2019 bkvoice. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class BKYKeyWordsModel;

@interface BKYSQLHelper : NSObject

/**
 *  保存一个关键字
 */
+(void)save:(BKYKeyWordsModel *)keyword;

/**
 *  删除一个关键字
 */
+(void)remove:(BKYKeyWordsModel *)keyword;

 /**
 *  查询所有的联系人
  */
+ (NSArray *)query;
+ (BOOL)queryWithCondition:(NSString *)condition;
+ (NSArray *)queryaAll;
//查询id最大
+ (int)queryaLastItem;
@end

NS_ASSUME_NONNULL_END
