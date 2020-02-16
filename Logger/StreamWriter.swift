    import Foundation
    
    extension OutputStream {
        
        func write(_ string: String, encoding: String.Encoding = String.Encoding.utf8, allowLossyConversion: Bool = true) -> Int {
            if let data = string.data(using: encoding, allowLossyConversion: allowLossyConversion) {
                var bytesRemaining = data.count
                var totalBytesWritten = 0
                
                while bytesRemaining > 0 {
                    let bytesWritten = data.withUnsafeBytes {
                        self.write(
                            $0.advanced(by: totalBytesWritten),
                            maxLength: bytesRemaining
                        )
                    }
                    if bytesWritten < 0 {
                        // "Can not OutputStream.write(): \(self.streamError?.localizedDescription)"
                        return -1
                    } else if bytesWritten == 0 {
                        // "OutputStream.write() returned 0"
                        return totalBytesWritten
                    }
                    
                    bytesRemaining -= bytesWritten
                    totalBytesWritten += bytesWritten
                }
                
                return totalBytesWritten
            }
            
            return -1
        }        
    }
