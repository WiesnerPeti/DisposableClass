//
//  NSObject+desposableClass.h
//  DesposableClass
//
//  Created by Wiesner Péter Ádám on 27/02/14.
//  Copyright (c) 2014 Distinction. All rights reserved.
//

@import Foundation;

@interface NSObject(desposableClass)

+(Class) desposableClassFromTemplate:(NSDictionary*)template; //Create a plain object with the given iVars (key = name, value = type and default value)
+(Class) desposableSubclassClassOf:(Class)superClass template:(NSDictionary*)template; //Create a desposable subclass for a class with the given iVars

/**
@warning Only call, when all of the class' instance are deallocated
 */
+(void) desposeClass:(Class)klass; //Despose the class

#define set(__P__,__V__) setDisposableProperty:__P__ value:__V__
-(void)setDisposableProperty:(NSString*)property value:(id)value;

#define prop(__P__) disposableProperty:__P__
-(id)disposableProperty:(NSString*)property;

@end
