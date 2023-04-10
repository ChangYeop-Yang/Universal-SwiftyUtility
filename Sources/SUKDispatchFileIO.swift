/*
 * Copyright (c) 2022 Universal-SystemKit. All rights reserved.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

// swiftlint:disable all
#if os(iOS) || os(macOS)
import Dispatch
import Foundation

import Logging

@objc public class SUKDispatchFileIO: NSObject, SUKClass {
    
    // MARK: - Typealias
    public typealias FileIOReadCompletion = (Data, Int32) -> Swift.Void
    public typealias FileIOWriteCompletion = (Int32) -> Swift.Void
    
    // MARK: - Object Properties
    public static var label: String = "com.SwiftyUtility.SUKDispatchFileIO"
    public static var identifier: String = "870EBBA7-3167-4147-BE3A-82E0C4A108A2"
    
    private let implementQueue: DispatchQueue
    private let serialQueue = DispatchQueue(label: "com.SwiftyUtility.serial.SUKDispatchFileIO")
    
    // MARK: - Initalize
    public init(qualityOfService: DispatchQoS.QoSClass = .default) {
        self.implementQueue = DispatchQueue(label: SUKDispatchFileIO.label, qos: .background, attributes: .concurrent)
    }
}

// MARK: - Private Extension SUKDispatchFileIO
private extension SUKDispatchFileIO {
    
    final func createFileChannel(filePath: String, oflag: Int32) -> Optional<DispatchIO> {
        
        let fileDescriptor = open(filePath, oflag)
        
        if fileDescriptor == EOF {
            logger.error("[SUKDispatchFileIO][\(filePath)] Could't create file descriptor")
            return nil
        }
        
        let channel = DispatchIO(type: .stream, fileDescriptor: fileDescriptor, queue: self.implementQueue) { error in
            
            // DispatchIO를 생성하는 과정 중에 오류가 발생여부를 확인합니다.
            if error != Int32.zero {
                logger.error("[SUKDispatchFileIO][\(filePath)] Could't create DispatchIO")
            }
            
            // DispatchIO를 생성하지 못하는 경우에는 파일 읽기 또는 쓰기 작업을 수행하기 위한 생성 한 FileDescriptor 종료합니다.
            close(fileDescriptor)
        }
        
        return channel
    }
}

// MARK: - Public Extension SUKDispatchFileIO
public extension SUKDispatchFileIO {
    
    final func write(contents: Data, filePath: String, completion: @escaping FileIOWriteCompletion) {

        self.serialQueue.async {
            
            guard let channel = self.createFileChannel(filePath: filePath, oflag: O_WRONLY | O_CREAT) else { return }
            
            do {
                try contents.withUnsafeBytes { (pointer: UnsafeRawBufferPointer) throws -> Swift.Void in
                    
                    guard let baseAddress = pointer.baseAddress else { return }
                    
                    let bytes = UnsafeRawBufferPointer(start: baseAddress, count: contents.count)
                    
                    channel.write(offset: off_t.zero, data: .init(bytes: bytes), queue: self.implementQueue) { done, data, error in
                    
                        // 정상적으로 파일 쓰기 작업이 완료 된 경우에 파일 내용을 전달합니다.
                        if error == Int32.zero && done {
                            // 쓰기 작업에 수행 한 모든 파일 내용을 전달합니다.
                            completion(error)
                            
                            // 파일 작업을 위해서 사용 된 File Descriptor 을 닫습니다.
                            close(channel.fileDescriptor)
                            logger.info("[SUKDispatchFileIO][\(filePath)] Close O_WRONLY FileDescriptor")
                        }
                    }
                }
                
            } catch let error as NSError {
                logger.error("[SUKDispatchFileIO] \(error.description)")
                return
            }
            
        }
    }
    
    @discardableResult
    final func read(filePath: String, completion: @escaping FileIOReadCompletion) -> Bool {
        
        // 파일 읽기 작업을 수행하기 전에 해당 파일이 실제로 존재하는지 확인합니다.
        guard FileManager.default.fileExists(atPath: filePath) else {
            logger.error("[SUKDispatchFileIO][\(filePath)] The file does not exist at the specified path")
            return false
        }
                
        guard let channel = createFileChannel(filePath: filePath, oflag: O_RDONLY) else { return false }
                
        var rawData = Data()
        
        channel.read(offset: off_t.zero, length: Int.max, queue: self.implementQueue) { done, data, error in

            if error == Int32.zero {

                // 정상적으로 파일로부터 데이터를 읽어들이는 경우
                if let contentsOf = data { rawData.append(contentsOf: contentsOf) }

                // 정상적으로 파일 읽기 작업이 완료 된 경우에 파일 내용을 전달합니다.
                if done {
                    // 읽어들인 모든 파일 내용을 전달합니다.
                    completion(rawData, error)
                    
                    // 파일 작업을 위해서 사용 된 File Descriptor 을 닫습니다.
                    close(channel.fileDescriptor)
                    logger.info("[SUKDispatchFileIO][\(filePath)] Close O_RDONLY FileDescriptor")
                }
            }
        }
        
        return true
    }
}
#endif
