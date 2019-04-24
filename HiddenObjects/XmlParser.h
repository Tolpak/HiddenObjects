//
//  XmlParser.h
//  HiddenObjects
//
//  Created by moyo on 22.04.19.
//
//

#import <Foundation/Foundation.h>

@interface XmlParser : NSObject <NSXMLParserDelegate> {
    NSMutableString *currentElement;
    int index;
}
@property (nonatomic, retain) NSString *room;
@property (nonatomic, retain) NSMutableArray *objects;

- (instancetype)initParser;
@end
