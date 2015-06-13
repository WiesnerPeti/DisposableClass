//
//  NSObject+desposableClass.h
//  DesposableClass
//
//  Created by Wiesner Péter Ádám on 27/02/14.
//

@import Foundation;

@interface NSObject(desposableClass)

/**
 *  Creates an NSObject subclass with the given template as properties.
 *
 *  @param template The dictionary describing the properties of the class. The key is the name of the property and the value defines the type and default value for that property.
 *
 *  @return The disposable class
 */
+(Class) desposableClassFromTemplate:(NSDictionary*)template;

/**
 *  Creates a custom subclass with the given template as properties.
 *
 *  @param template The dictionary describing the properties of the class. The key is the name of the property and the value defines the type and default value for that property.
 *
 *  @return The disposable class
 */
+(Class) desposableSubclassClassOf:(Class)superClass template:(NSDictionary*)template;

/**
 *  Destroy the disposable class
 *
 *  @param klass The class to destroy
 *  @warning Only call, when all of the class' instance are deallocated
 */
+(void) desposeClass:(Class)klass;

#define set(__P__,__V__) setDisposableProperty:__P__ value:__V__
/**
 *  Set a property of the disposable class
 *
 *  @param property Name of the property
 *  @param value    Value of the property
 *
 *  @note The method asserts, if it is not called on a Disposable Class
 */
-(void)setDisposableProperty:(NSString*)property value:(id)value;


#define prop(__P__) disposableProperty:__P__
/**
 *  Gets the value of a property of the disposable class
 *
 *  @param property Name of the property
 *
 *  @return Value of the property
 *
 *  @note The method asserts, if it is not called on a Disposable Class
 */
-(id)disposableProperty:(NSString*)property;

@end
