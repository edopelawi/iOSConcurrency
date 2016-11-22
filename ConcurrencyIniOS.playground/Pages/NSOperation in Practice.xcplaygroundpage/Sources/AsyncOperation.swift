/*
 * Copyright (c) 2016 Razeware LLC
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

import Foundation

public class AsyncOperation: Operation {
	
	public enum State: String {
    case ready, executing, finished
    
    fileprivate var keyPath: String {
      return "is" + rawValue
    }
  }
  
  public var state = State.ready {
    willSet {
      willChangeValue(forKey: newValue.keyPath)
      willChangeValue(forKey: state.keyPath)
    }
    didSet {
      didChangeValue(forKey: oldValue.keyPath)
      didChangeValue(forKey: state.keyPath)
    }
  }
}


extension AsyncOperation {
  // NSOperation Overrides
  override public var isReady: Bool {
    return super.isReady && state == .ready
  }
  
  override public var isExecuting: Bool {
    return state == .executing
  }
  
  override public var isFinished: Bool {
    return state == .finished
  }
  
  override public var isAsynchronous: Bool {
    return true
  }
  
  override public func start() {
    if isCancelled {
      state = .finished
      return
    }
    
    main()
    state = .executing
  }
  
  public override func cancel() {
    state = .finished
  }
}

// TODO: Revisit how to update this operator declaration later.
infix operator |> { associativity left precedence 150 }
public func |>(lhs: Operation, rhs: Operation) -> Operation {
  rhs.addDependency(lhs)
  return rhs
}

