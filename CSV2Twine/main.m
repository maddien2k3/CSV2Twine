//
//  main.m
//  CSV2Twine
//
//  Created by Martin Reichl on 25.02.13.
//  Copyright (c) 2013 WeLoveApps. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString* kSeparatorString = @";";

#define XLog NSLog

#pragma mark - Data Management

@interface WLAConverter : NSObject
@property(nonatomic, strong) NSMutableArray* data;  //key-values
@end

@implementation WLAConverter

-(void) loadDataFromFile:(NSString*)filepath{
    
    self.data = [@[] mutableCopy];
    
    NSError *error;
    NSString *dataString = [[NSString alloc]
                            initWithContentsOfFile:filepath
                            encoding:NSUTF8StringEncoding
                            error:&error];
    
    if(error) XLog(@"could not read city values");
    
    if(dataString != nil && !error){
        NSArray* lines = [dataString componentsSeparatedByString:@"\n"];
        NSMutableArray* keys = [[[[lines objectAtIndex:0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] componentsSeparatedByString:kSeparatorString] mutableCopy];
        //        [keys removeObject:keys[0]];
        
        for(int i=1;i<lines.count;++i){
            NSMutableDictionary* dataDict = [[NSMutableDictionary alloc] initWithCapacity:keys.count];
            NSString* line = [lines[i] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            NSArray* values = [line componentsSeparatedByString:kSeparatorString];
            if(values.count != keys.count){
                if(values.count > 0)
                    XLog(@"error in input data at line %d", i+1);
                continue;
            }
            for(int j=0;j<keys.count;++j){
                [dataDict setObject:values[j] forKey:keys[j]];
            }
            [_data addObject:dataDict];
        }
    }
    NSLog(@"finished conversion");
}

-(void) writeOutputTo:(NSString*)outputPath{
    NSString* output = @"";
    for(NSDictionary* dataDict in self.data){
        output = [output stringByAppendingFormat:@"[%@]\n",[dataDict objectForKey:@"Key"]];
        for(NSString* key in [dataDict allKeys]){
            if(key.length == 0) continue;
            NSString* value = [dataDict objectForKey:key];
            value = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            if(![key isEqualToString:@"Key"]){
                if(value.length > 0 && ![value isEqualToString:@""]){
                    output = [output stringByAppendingFormat:@"\t%@ = %@\n",[key lowercaseString],value];
                }else if([dataDict objectForKey:@"EN"] != nil){
                    //write default english if nothing is set
                    output = [output stringByAppendingFormat:@"\t%@ = %@\n",[key lowercaseString],[dataDict objectForKey:@"EN"]];
                }
            }
        }
    }
    NSError* error;
    [output writeToFile:outputPath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if(error){
        NSLog(@"error: %@", [error localizedDescription]);
    }else{
        NSLog(@"conversion successful!");
    }
}
@end



int main(int argc, const char * argv[])
{
    
    @autoreleasepool {
        
        // insert code here...
        NSLog(@"Hello, World!");
        WLAConverter* converter = [[WLAConverter alloc] init];
        [converter loadDataFromFile:[NSString stringWithCString:argv[1] encoding:NSUTF8StringEncoding]];
        [converter writeOutputTo:[NSString stringWithCString:argv[2] encoding:NSUTF8StringEncoding]];
    }
    return 0;
}

