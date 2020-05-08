//
//  BKYKeyWordsModel.h
//  bkvoice
//
//  Created by mac on 2019/12/24.
//  Copyright © 2019 bkvoice. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BKYKeyWordsModel : NSObject
@property (nonatomic, assign) int id;
@property (nonatomic, copy) NSString *bad_word;
@property (nonatomic, assign) int delId;
@end

NS_ASSUME_NONNULL_END
