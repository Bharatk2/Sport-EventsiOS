//
//  Cache.swift
//  SportEvents
//
//  Created by Bharat Kumar on 2/9/21.
//

import Foundation

// MARK: - Cache Instructions
/* Cache helps us to avoid unnecesery reloading of data or fetching. This helps us to fetch the image by observing the url
  It will help us to avoid making duplicate data. */

class Cache<Key: Hashable, Value> {
    private var cache: [Key: Value] = [ : ]
    private var queue = DispatchQueue(label: "Cache serial queue")

    func cache(value: Value, for key: Key) {
        queue.async {
            self.cache[key] = value
        }
    }

    func value(for key: Key) -> Value? {
        queue.sync {
            return self.cache[key]
            
        }
    }
}
