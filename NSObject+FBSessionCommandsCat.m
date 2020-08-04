//
//  NSObject+FBSessionCommandsCat.m
//  Demo
//
//  Created by wudi on 2020/8/4.
//  Copyright © 2020 wudi. All rights reserved.
//

#import "NSObject+FBSessionCommandsCat.h"
#import <objc/runtime.h>

@implementation NSObject (FBSessionCommandsCat)
+ (void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Method ori_Method =  class_getClassMethod(NSClassFromString(@"FBSessionCommands"), NSSelectorFromString(@"handleCreateSession:")  );
        Method my_Method = class_getClassMethod(self, @selector(swizzled_handleCreateSession:));
        
        method_exchangeImplementations(ori_Method, my_Method);
    });

}



+ (id)swizzled_handleCreateSession:(id)request{
    if ([request valueForKey:@"arguments"]) {
        NSDictionary *arguments = [request valueForKey:@"arguments"];
        NSDictionary *requirements = arguments[@"desiredCapabilities"];
        NSArray *launchArguments = (NSArray<NSString *> *)requirements[@"arguments"] ?: @[];
        NSMutableArray *muLaunchArguments = [NSMutableArray arrayWithArray:launchArguments];
        [muLaunchArguments addObject:@"xxxxxxxx"];//自己设定的标记
        //在app里可以用如下方式判断
        //[NSProcessInfo.processInfo.arguments containsObject:@"xxxxxxxx"]
        NSMutableDictionary *muArguments = [NSMutableDictionary dictionaryWithDictionary:arguments];
        NSMutableDictionary *muRequirements = [NSMutableDictionary dictionaryWithDictionary:requirements];
        [muRequirements setObject:muLaunchArguments forKey:@"arguments"];
        [muArguments setObject:muRequirements forKey:@"desiredCapabilities"];
        
        [request setValue:muArguments forKey:@"arguments"];
        
        return [self swizzled_handleCreateSession:request];
        
    }
    return [self swizzled_handleCreateSession:request];
}
@end
