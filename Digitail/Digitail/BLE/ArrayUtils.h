//
//  ArrayUtils.h
//  iCoin-Wallet
//
//  Created by Iottive on 02/05/19.
//  Copyright © 2019 Iottive. All rights reserved.
//
//
//
//  Distributed under the permissive zlib License
//  Get the latest version from here:
//
//  https://github.com/nicklockwood/ArrayUtils
//
//  This software is provided 'as-is', without any express or implied
//  warranty.  In no event will the authors be held liable for any damages
//  arising from the use of this software.
//
//  Permission is granted to anyone to use this software for any purpose,
//  including commercial applications, and to alter it and redistribute it
//  freely, subject to the following restrictions:
//
//  1. The origin of this software must not be misrepresented; you must not
//  claim that you wrote the original software. If you use this software
//  in a product, an acknowledgment in the product documentation would be
//  appreciated but is not required.
//
//  2. Altered source versions must be plainly marked as such, and must not be
//  misrepresented as being the original software.
//
//  3. This notice may not be removed or altered from any source distribution.
//

#import <Foundation/Foundation.h>


@interface NSArray (ArrayUtils)

- (NSArray *)arrayByRemovingObject:(id)object;
- (NSArray *)arrayByRemovingObjectAtIndex:(NSUInteger)index;
- (NSArray *)arrayByRemovingLastObject;
- (NSArray *)arrayByRemovingFirstObject;
- (NSArray *)arrayByInsertingObject:(id)object atIndex:(NSUInteger)index;
- (NSArray *)arrayByReplacingObjectAtIndex:(NSUInteger)index withObject:(id)object;
- (NSArray *)shuffledArray;
- (NSArray *)mappedArrayUsingBlock:(id (^)(id object))block;
- (NSArray *)reversedArray;
- (NSArray *)arrayByMergingObjectsFromArray:(NSArray *)array;
- (NSArray *)objectsInCommonWithArray:(NSArray *)array;
- (NSArray *)uniqueObjects;
- (void)forEachObjectPerformBlock:(void(^)(id obj))block;
- (NSArray *)arrayByMappingObjectsUsingFullBlock:(id(^)(id obj, NSUInteger idx, BOOL *stop))block;
- (NSArray *)arrayByMappingObjectsUsingBlock:(id(^)(id obj))block;
- (NSArray *)arrayByFilteringObjectsUsingBlock:(BOOL(^)(id obj))block;
- (NSArray *)arrayByFilteringObjectsUsingFullBlock:(BOOL(^)(id obj, NSUInteger idx, BOOL *stop))block;
- (id)objectPassingTest:(BOOL(^)(id obj))block;
- (id)objectPassingTestFull:(BOOL(^)(id obj, NSUInteger i, BOOL *stop))block;
- (void)each:(void(^)(id obj))block;
- (NSArray *)map:(id(^)(id obj))block;
- (NSArray *)grep:(BOOL(^)(id obj))block;
- (id)find:(BOOL(^)(id obj))block;

@end


@interface NSMutableArray (ArrayUtils)

- (void)removeFirstObject;
- (void)shuffle;
- (void)reverse;
- (void)mergeObjectsFromArray:(NSArray *)array;
- (void)removeDuplicateObjects;
- (id)shift;
- (void)push:(id)obj;


@end
