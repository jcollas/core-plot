#import <Foundation/Foundation.h>
#import "CPNumericData.h"

/**	@category CPNumericData(TypeConversion)
 *	@brief Type conversion methods for CPNumericData.
 **/
@interface CPNumericData(TypeConversion)

/// @name Type Conversion
/// @{
-(CPNumericData *)dataByConvertingToDataType:(CPNumericDataType)newDataType;

-(CPNumericData *)dataByConvertingToType:(CPDataTypeFormat)newDataType
                             sampleBytes:(NSUInteger)newSampleBytes
                               byteOrder:(CFByteOrder)newByteOrder;
///	@}

@end