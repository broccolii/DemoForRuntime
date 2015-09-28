//
//  ViewController.m
//  DemoForRuntime
//
//  Created by Broccoli on 15/9/28.
//  Copyright © 2015年 Broccoli. All rights reserved.
//

#import "ViewController.h"
#import "CustomClass.h"
#import <objc/runtime.h>

@interface ViewController ()
{
    CustomClass *allobj;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self methodSwizzle];
    
//    allobj = [[CustomClass alloc] init];
//    allobj.varTest1 =@"varTest1String";
//    NSLog(@"%@", [self nameOfInstance:@"varTest1String"]);
}

// method swizzle 方法交换
- (void)methodSwizzle {
    Method m1 = class_getInstanceMethod([NSString class], @selector(lowercaseString));
    Method m2 = class_getInstanceMethod([NSString class], @selector(uppercaseString));
    method_exchangeImplementations(m1, m2);
    
    NSLog(@"%@", [@"AaBbCcDdEeFf" lowercaseString]);
    NSLog(@"%@", [@"AaBbCcDdEeFf" uppercaseString]);
}

// 反射机制
- (NSString *)nameOfInstance:(id)instance {
    unsigned int numIvars = 0;
    NSString *key = nil;
    
    // 获取一个类中的实例变量
    Ivar *ivars = class_copyIvarList([CustomClass class], &numIvars);
    
    for (int i = 0; i < numIvars; i ++) {
        Ivar thisIvar = ivars[i];
        
        const char *type = ivar_getTypeEncoding(thisIvar);
        NSString *stringType = [NSString stringWithCString:type encoding:NSUTF8StringEncoding];
        // 不是 class 就跳过
        if (![stringType hasPrefix:@"@"]) {
            continue;
        }
        // 读取 实力变量的值
        if (object_getIvar(allobj, thisIvar)) {
            // 返回实例变量的名字
            key = [NSString stringWithUTF8String:ivar_getName(thisIvar)];
            break;
        }
    }
    free(ivars);
    return key;
}

// 获取一个类的所有属性
- (void)propertyNameList {
    u_int count;
    
    objc_property_t *properties = class_copyPropertyList([UIViewController class], &count);
    for (int i = 0; i < count; i ++) {
        const char* propertyName = property_getName(properties[i]);
        NSString *strName = [NSString stringWithCString:propertyName encoding:NSUTF8StringEncoding];
        NSLog(@"%@", strName);
    }
}

// 获取一个类的所有方法
- (void)getClassAllMethod {
    u_int count;
    
    Method *methods = class_copyMethodList([CustomClass class], &count);
    for (int i = 0; i < count; i ++) {
        SEL name = method_getName(methods[i]);
        NSString *strName = [NSString stringWithCString:sel_getName(name) encoding:NSUTF8StringEncoding];
        NSLog(@"%@", strName);
    }
}

// 获取类名
- (void) getClassName {
    CustomClass *obj = [[CustomClass alloc] init];
    NSString *className = [NSString stringWithCString:object_getClassName(obj) encoding:NSUTF8StringEncoding];
    NSLog(@"className: %@", className);
}
// copy 对象
- (void)copyObj {

    CustomClass *obj = [[CustomClass alloc] init];
    NSLog(@"%p", &obj);
    
    id objTest =  object_copy(obj, sizeof(obj));
    NSLog(@"%p", &objTest);
    
    [objTest func1];
}

// 释放 对象
- (void)objectDispose {
    CustomClass *obj = [[CustomClass alloc] init];
    NSLog(@"%lu", (unsigned long)[obj retainCount]);
    NSLog(@"%p", &obj);
    object_dispose(obj);
    NSLog(@"%lu", (unsigned long)[obj retainCount]);
    NSLog(@"%p", &obj);
    [obj release];
    NSLog(@"%lu", (unsigned long)[obj retainCount]);
}
@end
