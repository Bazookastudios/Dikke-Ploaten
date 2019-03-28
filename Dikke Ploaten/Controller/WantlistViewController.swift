//
//  SecondViewController.swift
//  Dikke Ploaten
//
//  Created by Victor Vanhove on 13/03/2019.
//  Copyright © 2019 bazookas. All rights reserved.
//

import UIKit
import Firebase

//A lot of duplicate code (see CollectionViewController), best way to solve this?
class WantlistViewController: UITableViewController {
	
	// MARK: - Properties
	var albums: [Album] = []
	
	var albumSection = [String]()
	var albumDictionary = [String: [Album]]()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Gets data from database and updates on changes
		Database().updateWantlist(albums: albums) { albums in
			self.albums = albums
			self.generateWordsDict()
			self.tableView.reloadData()
		}
	}
	
	func generateWordsDict() {
		for album in albums {
			let key = String(album.artist.prefix(1))
			if albumDictionary[key] == nil {
				albumDictionary[key] = []
			}
			if !(albumDictionary[key]!.contains(album)){
				albumDictionary[key]!.append(album)
			}
		}
		
		albumSection = [String](albumDictionary.keys)
		albumSection = albumSection.sorted()
	}
	
	// MARK: - TableView
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return albumSection.count
	}
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return albumSection[section]
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return albumDictionary[albumSection[section]]?.count ?? 0
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "albumCell") as! AlbumTableViewCell
		
		let headerKey = albumSection[indexPath.section]
		
		if  let albumValue = albumDictionary[headerKey] {
			let album = albumValue[indexPath.row]
			
			cell.updateUI(forAlbum: album)
		}
		return cell
	}
	
	override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
		return albumSection
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		self.tableView.deselectRow(at: indexPath, animated: true)
	}
}

