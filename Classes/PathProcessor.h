//
//  PathProcessor.h
//
//  Created by Dylan Bruzenak.
//  Modified by Jianbin LIN.
//  Released under a BSD-style license. See license.txt
//

/* The PathProcessor recursively descends through the given path, creating ClassInfo objects
   and using them to process annotations for any pairing of .h and .m files that are found with
   the //@generate annotation added to the header file.
*/
@interface PathProcessor : NSObject {
	
}

- (void) processSourcePath:(NSString *)sourcePath outputPath:(NSString*)outputPath;

@end