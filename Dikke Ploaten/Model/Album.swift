//
//  Album.swift
//  Dikke Ploaten
//
//  Created by Victor Vanhove on 14/03/2019.
//  Copyright © 2019 bazookas. All rights reserved.
//

import Firebase
import ObjectMapper

class Album: ImmutableMappable, Hashable, Comparable {
	var id: String = ""
	var title: String
	var artist: String
	var cover: String
	var description: String?
	var genre: String?
	var releaseYear: String?
	var tracklist: String?
	var musicians: String?
	var images: [String]?
	
	// MARK: - Constructors
	init(title: String, artist: String, cover: String, images: [String]?, description: String?, genre: String?, releaseYear: String?, tracklist: String?, musicians: String?) {
		self.title = title
		self.artist = artist
		self.cover = cover
		self.images = images
		self.description = description
		self.genre = genre
		self.releaseYear = releaseYear
		self.tracklist = tracklist
		self.musicians = musicians
	}
	
	// MARK: - ObjectMapper
	required init(map: Map) throws {
		title = try map.value("title")
		artist = try map.value("artist")
		cover = try map.value("thumb")
		images = try? map.value("images")
		description = try? map.value("description")
		genre = try? map.value("genre")
		releaseYear = try? map.value("released_in")
		tracklist = try? map.value("tracklist")
		musicians = try? map.value("musicians")
	}
	
	func mapping(map: Map) {
		title       >>> map["title"]
		artist      >>> map["artist"]
		cover       >>> map["thumb"]
		images 	    >>> map["images"]
		description >>> map["description"]
		genre       >>> map["genre"]
		releaseYear >>> map["released_in"]
		tracklist   >>> map["tracklist"]
		musicians   >>> map["musicians"]
	}
	
	// Hashable
	var hashValue: Int {
		return id.hashValue
	}
	
	// Equatable
	static func == (lhs: Album, rhs: Album) -> Bool {
		return lhs.id == rhs.id
	}
	
	// Comparable
	static func < (lhs: Album, rhs: Album) -> Bool {
		return lhs.artist < rhs.artist
	}
	
	static func docToAlbum(document: DocumentSnapshot) -> Album {
		let album = try! Mapper<Album>().map(JSON: document.data()!)
		album.id = document.documentID
		return album
	}
}
