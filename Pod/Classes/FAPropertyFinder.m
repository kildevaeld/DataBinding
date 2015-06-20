//
//  FAMapperPropertyFinder.m
//  FAMapper
//
//  Created by Rasmus Kildevaeld on 23/11/13.
//  Copyright (c) 2013 Rasmus Kildevaeld. All rights reserved.
//

#import "FAPropertyFinder.h"

static const char *getIvarType(Ivar prop) {
    const char *ivar = ivar_getTypeEncoding(prop);
    if (ivar[0] != '@') {
        return (const char *)[[NSData dataWithBytes:(ivar + 1) length:strlen(ivar) - 1] bytes];
    } else if (ivar[0] == '@' && strlen(ivar) == 2) {
        return "id";
    } else if (ivar[0] == '@') {
        return [[[NSString stringWithUTF8String:ivar] stringByReplacingCharactersInRange:NSMakeRange(0, 3) withString:@""] stringByReplacingCharactersInRange:NSMakeRange(strlen(ivar)-4, 1) withString:@""].UTF8String;
    }
    return "";

}

static const char * getPropertyType(objc_property_t property) {
    const char *attributes = property_getAttributes(property);
    
    char buffer[1 + strlen(attributes)];
    strcpy(buffer, attributes);
    char *state = buffer, *attribute;
    while ((attribute = strsep(&state, ",")) != NULL) {
        if (attribute[0] == 'T' && attribute[1] != '@') {
            
            // it's a C primitive type:
            /*
             if you want a list of what will be returned for these primitives, search online for
             "objective-c" "Property Attribute Description Examples"
             apple docs list plenty of examples of what you get for int "i", long "l", unsigned "I", struct, etc.
             */
            
            return (const char *)[[NSData dataWithBytes:(attribute + 1) length:strlen(attribute) - 1] bytes];
        }
        else if (attribute[0] == 'T' && attribute[1] == '@' && strlen(attribute) == 2) {
            // it's an ObjC id type:
            return "id";
        }
        else if (attribute[0] == 'T' && attribute[1] == '@') {
            // it's another ObjC object type:
            return [[[NSString stringWithUTF8String:attribute] stringByReplacingCharactersInRange:NSMakeRange(0, 3) withString:@""] stringByReplacingCharactersInRange:NSMakeRange(strlen(attribute)-4, 1) withString:@""].UTF8String;
            
            //return (const char *)[[NSData dataWithBytes:(attribute + 3) length:strlen(attribute)-3] bytes];
        }
    }
    return "";
}


@interface FAPropertyFinder ()

+ (NSDictionary *)propertiesForClass:(Class)klass;

+ (NSDictionary *)ivarsForClass:(Class)klass;

@end

@implementation FAPropertyFinder

+ (BOOL)hasProperty:(NSString *)property onClass:(Class)klass {
    NSDictionary *propDict = [self propertiesForClass:klass];
    //NSDictionary *ivarDict = [self ivarsForClass:klass];
    
    if (propDict[property])
        return YES;
    /*else if (ivarDict[property])
         return YES;
    else if (ivarDict[[NSString stringWithFormat:@"_%@",property]])
        return YES;*/
    return NO;
}

+ (Class)propertyType:(NSString*)property onClass:(Class)klass {
    NSDictionary *propDict = [self propertiesForClass:klass];
    //NSDictionary *ivarDict = [self ivarsForClass:klass];
    if (propDict[property])
        return NSClassFromString(propDict[property]);
    /*else if (ivarDict[property])
        return NSClassFromString(ivarDict[property]);*/
    return nil;
}

+ (NSDictionary *)propertiesForClass:(Class)klass {
    if (klass == NULL) {
        return nil;
    }
    
    NSMutableDictionary *results = [[NSMutableDictionary alloc] init];
    
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList(klass, &outCount);
    for (i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        const char *propName = property_getName(property);
        if(propName) {
            const char *propType = getPropertyType(property);
            NSString *propertyName = [NSString stringWithUTF8String:propName];
            NSString *propertyType = [NSString stringWithUTF8String:propType];
            if (propertyType == nil || propertyName == nil)
                continue;
            
            [results setObject:propertyType forKey:propertyName];
        }
    }
    free(properties);
    
    if (class_getSuperclass(klass) != [NSObject class]) {
        Class superclass = class_getSuperclass(klass);
        [results addEntriesFromDictionary:[self propertiesForClass:superclass]];
    }
    // returning a copy here to make sure the dictionary is immutable
    return [NSDictionary dictionaryWithDictionary:results];
}

+ (NSDictionary *)ivarsForClass:(Class)klass {
    if (klass == NULL) {
        return nil;
    }
    
    NSMutableDictionary *results = [[NSMutableDictionary alloc] init];
    
    unsigned int outCount, i;
    Ivar *properties = class_copyIvarList(klass, &outCount);
    for (i = 0; i < outCount; i++) {
        Ivar property = properties[i];
        const char *propName = ivar_getName(property);
        if(propName) {
            const char *ivarType = getIvarType(property);
            if (ivarType == NULL)
                continue;
            NSString *propertyName = [NSString stringWithUTF8String:propName];
            NSString *propertyType = [NSString stringWithUTF8String:ivarType];
            [results setObject:propertyType forKey:propertyName];
        }
    }
    free(properties);
    
    // returning a copy here to make sure the dictionary is immutable
    return [NSDictionary dictionaryWithDictionary:results];
}

@end
