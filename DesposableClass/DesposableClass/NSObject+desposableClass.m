//
//  NSObject+desposableClass.m
//  DesposableClass
//
//  Created by Wiesner Péter Ádám on 27/02/14.
//

#import "NSObject+desposableClass.h"
#import <objc/runtime.h>

#pragma mark - DesposableClass
static NSMutableDictionary* _classes = nil;

@implementation NSObject (desposableClass)

/**
 *  A shared dictionary to store the template dictionaries, so default values can be accessed
 *
 *  @return The dictionary
 */
+(NSMutableDictionary*) classes
{
    if (!_classes)
    {
        _classes = [@{} mutableCopy];
    }
    
    return _classes;
}

#pragma mark - CREATE
+(Class) desposableClassFromTemplate:(NSDictionary*)template
{
    return [self desposableSubclassClassOf:[NSObject class] template:template];
}

+(Class) desposableSubclassClassOf:(Class)superClass template:(NSDictionary*)template
{
    //Create the class
    Class klass = objc_allocateClassPair(superClass, [self aDesposableClassName].UTF8String, 0);
    
    //For every entry in the template
    [template enumerateKeysAndObjectsUsingBlock:^(NSString* key, id obj, BOOL *stop) {

        //As dictionary only can hold objects, and all object can be referenced by an id (void*), this will do
        char *encoding = @encode(id);
        NSUInteger size, align;
        NSGetSizeAndAlignment(encoding, &size, &align);
        class_addIvar(klass, [(NSString*)key UTF8String], size, align, encoding);
        
        //add setter
        NSString* setterName = [NSString stringWithFormat:@"set%@",[key capitalizedString]];
        class_addMethod(klass, NSSelectorFromString(setterName), (IMP)setProperty, "v12@0:4@8");
        
        //add getter
        NSString* getterName = [NSString stringWithFormat:@"%@",key];
        class_addMethod(klass, NSSelectorFromString(getterName), (IMP)getProperty, "@8@0:4");
    }];
    
    //Class can be used after registering
    objc_registerClassPair(klass);
    
    //Store template for later use
    [self classes][NSStringFromClass(klass)] = template;
    
    return klass;
}

#define DisposablePrefix @"DesposableClass"
+(NSString*) aDesposableClassName
{
    //A shorter version may be needed
    return [NSString stringWithFormat:@"%@%@",DisposablePrefix,[[[NSUUID UUID] UUIDString] stringByReplacingOccurrencesOfString:@"-" withString:@""]];
}

#pragma mark - DESTROY
+(void) desposeClass:(Class)klass
{
    [[self classes] removeObjectForKey:NSStringFromClass(klass)];
    objc_disposeClassPair(klass);
}

#pragma mark - PROPERTY
static void setProperty(id self, SEL _cmd, id value)
{
    //Get the ivar name, the selectorName is usuall like setKey, this steps transforms setKey -> key
    NSString* selectorName = NSStringFromSelector(_cmd);
    NSString* iVarName = [selectorName stringByReplacingOccurrencesOfString:@"set" withString:@""];//remove set-
    iVarName = [iVarName stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[[iVarName substringWithRange:NSMakeRange(0, 1)] lowercaseString]];//Replace the first karakter with lowercase
    
    Ivar iVar = class_getInstanceVariable([self class], [iVarName UTF8String]);
    
    object_setIvar(self, iVar, value);
}

static id getProperty(id self, SEL _cmd, ...)
{
    NSString* IvarName = NSStringFromSelector(_cmd);
    Ivar iVar = class_getInstanceVariable([self class], [IvarName UTF8String]);
    id currentValue = object_getIvar(self, iVar);
    
    //If not set
    if (currentValue == nil)
    {
        //Get the default
        currentValue = [NSObject classes][NSStringFromClass([self class])][IvarName];
    }
    
    return currentValue;
}

#pragma mark - Usage
-(void) setDisposableProperty:(NSString *)property value:(id)value
{
    NSString* classString = NSStringFromClass([self class]);
    NSAssert([classString hasPrefix:DisposablePrefix], @"%@ is not a Disposable class", classString);
    
    SEL selector = NSSelectorFromString([NSString stringWithFormat:@"set%@", [property capitalizedString]]);
    ((void (*)(id, SEL, id))[self methodForSelector:selector])(self, selector, value);
}

-(id)disposableProperty:(NSString*)property
{
    NSString* classString = NSStringFromClass([self class]);
    NSAssert([classString hasPrefix:DisposablePrefix], @"%@ is not a Disposable class", classString);
    
    return [self valueForKey:property];
}

@end
