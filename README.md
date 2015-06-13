# DisposableClass
Category to create a class for temporary use. You can create the class by defining a template dictionary. The keys will be the name of the property, and the value will determine it's type. The value will be also the default value for the property.

# Create the class
    //Creates a class with a property of type NSNumber and the default value @2
    [NSObject desposableClassFromTemplate:@{
                                            @"key" : @2
                                            }];
    id object = [klass new];
    
# Set a property

    [object set(@"key", @4)];
  
# Get a property

    [object prop(@"key")]
  
