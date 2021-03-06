//
//  SearchViewController.swift
//  Dikke Ploaten
//
//  Created by Victor Vanhove on 14/03/2019.
//  Copyright © 2019 bazookas. All rights reserved.
//

import UIKit
import Firebase
import ObjectMapper
import OrderedSet

class SearchViewController: UITableViewController, UISearchResultsUpdating {
	
	// MARK: - Properties
	
	var albums = [Album]()
	var filteredAlbums = [Album]()
	
	let searchController = UISearchController(searchResultsController: nil)
	
	override func viewWillAppear(_ animated: Bool) {
		
		// Add searchbar to nav
		addSearchBar()
		
		// Gets all albums from database
		Database.shared.getAlbumList { albums in
			self.albums = albums
			self.tableView.reloadData()
		}
		
	}
	
	func addSearchBar() {
		searchController.searchResultsUpdater = self
		searchController.hidesNavigationBarDuringPresentation = false
		searchController.dimsBackgroundDuringPresentation = false
		searchController.searchBar.sizeToFit()
		self.navigationItem.titleView = searchController.searchBar
		self.definesPresentationContext = true
	}
	
	func updateSearchResults(for searchController: UISearchController) {
		filteredAlbums = albums.filter { ($0.title.contains(searchController.searchBar.text!)) || ($0.artist.contains(searchController.searchBar.text!)) }
		self.tableView.reloadData()
	}
	
	// MARK: - Table View
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1//albums.count
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if searchController.isActive {
			return filteredAlbums.count
		}
		return albums.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "albumCell") as! AlbumTableViewCell
		
		var album = albums[indexPath.row]
		
		if searchController.isActive {
			album = filteredAlbums[indexPath.row]
		}
		
		if Database.shared.cache.user.plates.first(where: {$0.albumID == album.id}) != nil {
			cell.updateUISearch(forAlbum: album, image: "inCollection")
		} else if Database.shared.cache.user.wantList.first(where: {$0.albumID == album.id}) != nil {
			cell.updateUISearch(forAlbum: album, image: "inWantlist")
		} else {
			cell.updateUISearch(forAlbum: album)
		}
		
		return cell
	}
	
	override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
		
		let album: Album
		if self.searchController.isActive {
			album = filteredAlbums[indexPath.row]
		} else {
			album = albums[indexPath.row]
		}
		
		if Database.shared.cache.user.plates.first(where: {$0.albumID == album.id}) == nil && Database.shared.cache.user.wantList.first(where: {$0.albumID == album.id}) == nil {
			let add = addAddOrRemoveAction(forIndexPath: indexPath, forAlbum: album)
			let want = addWantOrRemoveAction(forIndexPath: indexPath, forAlbum: album)
			return [add, want]
		}
		return []
	}
}

extension SearchViewController {
	func addAddOrRemoveAction(forIndexPath indexPath: IndexPath, forAlbum album: Album) -> UITableViewRowAction {
		
		if Database.shared.cache.user.plates.first(where: {$0.albumID == album.id}) != nil {
			// Already in plates, show remove item
			let remove = UITableViewRowAction(style: .default, title: "\u{232B}\n" + "remove".localized(), handler: { _, _ in
				// Write instance to database
				Database.shared.deleteCollectionAlbum(albumId: album.id) { err in
					if let err = err {
						print(err)
						let alertController = UIAlertController(title: "whoops".localized(), message: err.localizedDescription, preferredStyle: .alert)
						alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
						self.present(alertController, animated: true, completion: nil)
					}
					
					//Show toast alert
					let alertMessage = "is_removed_from_collection".localized().replacingOccurrences(of: "%album", with: album.title).replacingOccurrences(of: "%artist", with: album.artist)
					self.showToast(controller: self, message: alertMessage, seconds: 2)
					self.searchController.isActive = false
					self.tableView.reloadData()
				}
			})
			remove.backgroundColor = .red
			return remove
		} else {
			// Not yet in plates, show add item
			let add = UITableViewRowAction(style: .default, title: "\u{2630}\n" + "add".localized(), handler: { _, _ in
				// Write instance to database
				Database.shared.addToCollection(album: album, completionHandler: { err in
					if let err = err {
						print(err)
						let alertController = UIAlertController(title: "whoops".localized(), message: err.localizedDescription, preferredStyle: .alert)
						alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
						self.present(alertController, animated: true, completion: nil)
					}
					self.tableView.reloadData()
				})
				//Show toast alert
				let alertMessage = "is_added_to_collection".localized().replacingOccurrences(of: "%album", with: album.title).replacingOccurrences(of: "%artist", with: album.artist)
				self.showToast(controller: self, message: alertMessage, seconds: 2)
				self.searchController.isActive = false
			})
			add.backgroundColor = UIColor(red: 0.11, green: 0.74, blue: 0.61, alpha: 1.0)
			return add
		}
	}
	
	func addWantOrRemoveAction(forIndexPath indexPath: IndexPath, forAlbum album: Album) -> UITableViewRowAction {
		
		if Database.shared.cache.user.wantList.first(where: {$0.albumID == album.id}) != nil {
			// Already in plates, show remove item
			let remove = UITableViewRowAction(style: .default, title: "\u{232B}\n" + "remove".localized(), handler: { _, _ in
				// Write instance to database
				Database.shared.deleteWantlistAlbum(albumId: album.id) { err in
					if let err = err {
						print(err)
						let alertController = UIAlertController(title: "whoops".localized(), message: err.localizedDescription, preferredStyle: .alert)
						alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
						self.present(alertController, animated: true, completion: nil)
					}
					
					//Show toast alert
					let alertMessage = "is_removed_from_wantlist".localized().replacingOccurrences(of: "%album", with: album.title).replacingOccurrences(of: "%artist", with: album.artist)
					self.showToast(controller: self, message: alertMessage, seconds: 2)
					self.searchController.isActive = false
				}
			})
			remove.backgroundColor = .red
			return remove
		} else {
			// Not yet in wantlist, show add item
			let want = UITableViewRowAction(style: .default, title: "\u{2665}\n" + "want".localized(), handler: { _, index in
				var album = self.albums[index.row]
				if self.searchController.isActive {
					album = self.filteredAlbums[indexPath.row]
				}
				// Write instance to database
				Database.shared.addToWantlist(album: album, completionHandler: { err in
					if let err = err {
						print(err)
						let alertController = UIAlertController(title: "whoops".localized(), message: err.localizedDescription, preferredStyle: .alert)
						alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
						self.present(alertController, animated: true, completion: nil)
					}
					self.tableView.reloadData()
				})
				//Show toast alert
				let alertMessage = "is_added_to_wantlist".localized().replacingOccurrences(of: "%album", with: album.title).replacingOccurrences(of: "%artist", with: album.artist)
				self.showToast(controller: self, message: alertMessage, seconds: 2)
				self.searchController.isActive = false
			})
			want.backgroundColor = UIColor(red: 1.00, green: 0.65, blue: 0.00, alpha: 1.0)
			return want
		}
	}
	
}
