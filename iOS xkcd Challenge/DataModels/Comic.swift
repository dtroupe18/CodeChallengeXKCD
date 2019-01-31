//
//  Comic.swift
//  iOS xkcd Challenge
//
//  Created by David Troupe on 1/28/19.
//  Copyright © 2019 Studio. All rights reserved.
//

import Foundation

struct Comic: Codable {
  let month: String
  let number: Int
  let link, year, news, safeTitle: String
  let transcript, alt: String
  let imageURL: String
  let title, day: String
  
  enum CodingKeys: String, CodingKey {
    case month, link, year, news
    case safeTitle = "safe_title"
    case imageURL = "img"
    case number = "num"
    case transcript, alt, title, day
  }
}

struct FailableDecodable<Base : Decodable> : Decodable {
  
  let base: Base?
  
  init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    self.base = try? container.decode(Base.self)
  }
}
