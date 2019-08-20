//
//  WXMComponentDataObject.m
//  ModuleDebugging
//
//  Created by edz on 2019/7/7.
//  Copyright © 2019 wq. All rights reserved.
//

#import "WXMComponentData.h"
@implementation WXMParameterObject @end
@implementation WXMListenObject @end
@implementation WXMSignal {
    SignalCallBack _callback;
}

- (void)setValue:(id)value forKey:(NSString *)key {
    if ([key isEqualToString:WXM_SIGNAL_CALLBACK] && value) {
        _callback = (SignalCallBack) value;
    }
}

- (void)sendNext:(id)parameter {
    if (!_callback) return;
    void *blockPtr = (__bridge void *)(_callback);
    @synchronized (blockPtr) {
        _callback(parameter);
    };
}
@end

