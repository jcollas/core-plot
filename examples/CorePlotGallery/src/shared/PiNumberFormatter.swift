
import Foundation

/** @brief A number formatter that converts numbers to multiples of π.
 **/
class PiNumberFormatter: NSNumberFormatter {

//MARK: - Formatting

/**
 *  @brief Converts a number into multiples of π. Use the @link NSNumberFormatter::multiplier multiplier @endlink to control the maximum fraction denominator.
 *  @param coordinateValue The numeric value.
 *  @return The formatted string.
 **/
    override func stringForObjectValue(coordinateValue: AnyObject) -> String? {
        var string: String? = nil

        if coordinateValue.respondsToSelector(Selector("doubleValue")) {
            let value = (coordinateValue as! NSNumber).doubleValue / M_PI

            var factor = round(self.multiplier!.doubleValue)
            if ( factor == 0.0 ) {
                factor = 1.0
            }

            let numerator   = round(value * factor)
            let denominator = factor
            let fraction    = numerator / denominator
            let divisor     = abs( self.gcd(numerator, b: denominator) )

            if ( fraction == 0.0 ) {
                string = "0"
            }
            else if ( abs(fraction) == 1.0 ) {
                string = String(format:"%@π", signbit(fraction) != 0 ? self.minusSign : "")
            }
            else if ( abs(numerator) == 1.0 ) {
                string = String(format: "%@π/%g", signbit(numerator) != 0 ? self.minusSign : "", denominator)
            }
            else if ( abs(numerator / divisor) == 1.0 ) {
                string = String(format:"%@π/%g", signbit(numerator) != 0 ? self.minusSign : "", denominator / divisor)
            }
            else if ( round(fraction) == fraction ) {
                string = String(format:"%g π", fraction)
            }
            else if ( divisor != denominator ) {
                string = String(format:"%g π/%g", numerator / divisor, denominator / divisor)
            }
            else {
                string = String(format:"%g π/%g", numerator, denominator)
            }
        }
        
        return string
    }


    func gcd(a: Double, b: Double) -> Double {
        var c: Double = 0.0

        var a1 = round(a)
        var b1 = b

        while ( a1 != 0.0 ) {
            c = a1
            a1 = round( fmod(b1, a1) )
            b1 = c
        }
        
        return b1
    }

}
