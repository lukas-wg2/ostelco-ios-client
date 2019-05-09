//
//  CountryDataSource.swift
//  ostelco-ios-client
//
//  Created by Ellen Shapiro on 4/16/19.
//  Copyright © 2019 mac. All rights reserved.
//

import ostelco_core
import UIKit

protocol CountrySelectionDelegate: class {
    func selected(country: Country)
}

class CountryDataSource: GenericTableViewDataSource<Country, CountryCell> {
    
    var selectedCountry: Country? {
        didSet {
            self.reloadData()
        }
    }
    
    private weak var delegate: CountrySelectionDelegate?
    
    init(tableView: UITableView,
         countries: [Country],
         delegate: CountrySelectionDelegate) {
        self.delegate = delegate
        super.init(tableView: tableView, items: countries)
    }
    
    override func configureCell(_ cell: CountryCell, for country: Country) {
        cell.countryLabel.text = country.name
        if country == self.selectedCountry {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
    }
    
    override func selectedItem(_ country: Country) {
        self.selectedCountry = country
        self.delegate?.selected(country: country)
    }
}