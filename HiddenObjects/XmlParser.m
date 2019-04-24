//
//  XmlParser.m
//  HiddenObjects
//
//  Created by moyo on 22.04.19.
//
//

#import "XmlParser.h"

@implementation XmlParser

- (instancetype)initParser {
    if (self == [super init]) {
        _objects = [[NSMutableArray alloc] init];
        _room = [[NSString alloc] init];
    }
    return self;
}
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary<NSString *,NSString *> *)attributeDict {
    if ([elementName isEqualToString:@"item"]) {
        if ([[attributeDict objectForKey:@"position"] intValue] == 1) {
            [self.objects addObject:[NSMutableArray array]];
        }
        [self.objects.lastObject addObject:[attributeDict mutableCopy]];
        [[self.objects.lastObject lastObject] removeObjectForKey:@"position"];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if (!currentElement) {
        currentElement = [[NSMutableString alloc] init];
    }
    [currentElement appendString:string];
    currentElement = [[currentElement stringByReplacingOccurrencesOfString:@"\n" withString:@""] mutableCopy];
    currentElement = [[currentElement stringByReplacingOccurrencesOfString:@"\t" withString:@""] mutableCopy];
    currentElement = [[currentElement stringByReplacingOccurrencesOfString:@"assets/" withString:@""] mutableCopy];

}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    if ([elementName isEqualToString:@"background"]) {
        _room = currentElement;
    }
    if ([elementName isEqualToString:@"item"]) {
        [[self.objects.lastObject lastObject] setValue:currentElement forKey:@"fileName"];
    }
    currentElement = nil;
}

-(void) dealloc {
    [_objects release];
    [_room release];
    [super dealloc];
}



@end
