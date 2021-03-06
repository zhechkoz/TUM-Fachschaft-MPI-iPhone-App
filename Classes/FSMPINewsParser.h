// FSMPI App - Fachschaft für Mathematik, Physik & Informatik TU München
// ---------------------------------------------------------------------
// RSS feed parser for the FSMPI news feed

#import <Foundation/Foundation.h>

@class FSMPINewsParser;

@protocol FSMPINewsParserDelegate
- (void)newsParser:(FSMPINewsParser*)parser didParseNewsItem:(NSDictionary*)newsItemDictionary;
- (void)newsParserDidFinishParsing:(FSMPINewsParser*)parser;
- (void)newsParser:(FSMPINewsParser*)parser didFailWithError:(NSError*)error;
@end

@interface FSMPINewsParser : NSObject 
<NSXMLParserDelegate>
{	
	NSXMLParser *xmlParser;
	NSMutableDictionary *currentNewsItem;
	NSString *currentNewsItemKey;
	NSMutableString *currentNewsItemValue;
	BOOL inEntryTag;
	
	id<FSMPINewsParserDelegate>__unsafe_unretained delegate;
}

@property (strong) NSString *currentNewsItemKey;
@property (strong) NSMutableString *currentNewsItemValue;
@property (assign) id<FSMPINewsParserDelegate>delegate;

- (void)loadAndParseNews;
- (void)parseReceivedData:(NSData*)data;

@end
