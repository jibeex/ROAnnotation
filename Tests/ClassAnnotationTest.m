//
//  ClassAnnotationTest.m
//  ROAnnotation
//
//  Created on 18/10/13.
//  Released under a BSD-style license. See license.txt.
//
//

#import <XCTest/XCTest.h>
#import "ROAnnotation.h"
#import "Person.h"

@interface ClassAnnotationTest : XCTestCase

@end

@implementation ClassAnnotationTest

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
}

- (void)tearDown
{
    
    
    
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testAnnotationInHeader
{
    ROAnnotation* annotation = [ROAnnotation annotationOfType:@"classAnnotationInHeader" atClass:[Person class]];
    XCTAssertTrue(annotation != nil, @"Error");
    XCTAssertTrue([[annotation valueForAttribute:@"source"]isEqualToString:@"simpleValue"], @"Error");
}

- (void)testAnnotationInImplementation
{
    
    
    
    ROAnnotation* annotation = [ROAnnotation annotationOfType:@"classAnnotationInInplementation" atClass:[Person class]];
    XCTAssertTrue(annotation != nil, @"Error");
    XCTAssertTrue([[annotation valueForAttribute:@"someAttribute"]isEqualToString:@"simpleValue"], @"Error");
}

@end
