//
//  NSObject+KVO.h
//  KVO
//
//  Created by mac on 2018/3/19.
//  Copyright © 2018年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 kvo回调block

 @param newValue 新值
 @param oldValue 旧值
 */
typedef void(^CompleteHandler)(id newValue, id oldValue);

/**
 事件监听回调

 @param sender 参数
 */
typedef void(^FuncHandler)(id sender);

/**
 通知监听回调

 @param noti 参数
 */
typedef void(^NotificationHandler)(NSNotification *noti);

/**
 输入文本变化回调

 @param str str
 */
typedef void(^TextHandler)(NSString *str);

/**
 获取属性字符串

 @param objc 对象
 @param keyPath 属性
 @return 字符串
 */
#define keypath(objc,keyPath) @(((void)objc.keyPath,#keyPath))

@interface NSObject (KVO)

/**
 添加kvo

 @param keyPath 监听的属性
 @param completeHandler 回调
 */
-(void)addObserverForKeyPath:(NSString *)keyPath complete:(CompleteHandler)completeHandler;

/**
 监听事件

 @param selector 事件方法字符串
 @param funcHandler 回调
 */
-(void)addFuncObserverForSelector:(NSString *)selector withFuncHandler:(FuncHandler)funcHandler;

/**
 监听通知

 @param name 通知名
 @param object obj
 @param notificationHandler 回调
 */
-(void)addNotificationObserverForName:(NSString *)name object:(id)object withNotificationHandler:(NotificationHandler)notificationHandler;


/**
 textField.text or textView.text change

 @param textHandler 回调
 */
-(void)addTextObserverWithTextHandler:(TextHandler)textHandler;
@end
