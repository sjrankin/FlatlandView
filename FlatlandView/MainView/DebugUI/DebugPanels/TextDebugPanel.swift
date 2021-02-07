//
//  TextDebugPanel.swift
//  Flatland
//
//  Created by Stuart Rankin on 2/5/21.
//  Copyright © 2021 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class TextDebugPanel: PanelController, NSTableViewDelegate, NSTableViewDataSource, NSTextFieldDelegate
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        InitialsCombo.removeAllItems()
        CitiesSwitch.state = .on
        AdditionalCitiesSwitch.state = .off
        POIsSwitch.state = .off
        WHSSwitch.state = .off
        SetSource([.CityNames])
        LoadAllNames()
        SuggestionList.reloadData()
        SearchHowSegment.selectedSegment = 0
    }
    
    func LoadAllNames()
    {
        CurrentWords.removeAll()
        SetSource(PreviousSourceSet)
        for WordList in MainSourceList.Lists
        {
            for Word in WordList.Words
            {
                CurrentWords.append(Word.OriginalWord)
            }
        }
    }
    
    var MainSourceList = WordGroup()
    
    var CurrentWords: [String] = [String]()
    
    // MARK: - TableView functions
    
    func numberOfRows(in tableView: NSTableView) -> Int
    {
        return CurrentWords.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?
    {
        var CellContents = ""
        var CellIdentifier = ""
        
        if tableColumn == tableView.tableColumns[0]
        {
            CellContents = CurrentWords[row]
            CellIdentifier = "NameColumn"
        }
        
        let Cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: CellIdentifier), owner: self) as? NSTableCellView
        Cell?.textField?.stringValue = CellContents
        return Cell
    }
    
    func tableViewSelectionDidChange(_ notification: Notification)
    {
        if let Table = notification.object as? NSTableView
        {
            let Row = Table.selectedRow
            let SelectedText = CurrentWords[Row]
            SearchField.stringValue = SelectedText
        }
    }
    
    // MARK: - Text field functions
    
    func controlTextDidChange(_ obj: Notification)
    {
        if let TextField = obj.object as? NSTextField
        {
            let SearchFor = TextField.stringValue
            switch TextField
            {
                case SearchField:
                    if SearchFor.isEmpty
                    {
                        LoadAllNames()
                        SuggestionList.reloadData()
                    }
                    else
                    {
                        let Start = SearchField.stringValue.first!.uppercased()
                        InitialsCombo.selectItem(withObjectValue: Start)
                        if let StartingWords = MainSourceList.MatchingWords(Find: SearchFor, SearchHow: SearchHow)
                        {
                            CurrentWords.removeAll()
                            for Word in StartingWords
                            {
                                CurrentWords.append(Word)
                            }
                            SuggestionList.reloadData()
                        }
                        else
                        {
                            CurrentWords.removeAll()
                            SuggestionList.reloadData()
                        }
                    }
                    
                default:
                    break
            }
        }
    }
    
    var PreviousSourceSet = [GlobalWords]()
    
    func SetSource(_ Sources: [GlobalWords])
    {
        PreviousSourceSet = Sources
        MainSourceList = GlobalWordLists.WordList(For: Sources)!
        MainSourceList.SortWords()
        let Initials = MainSourceList.LetterSet()
        InitialsCombo.removeAllItems()
        for Initial in Initials
        {
            InitialsCombo.addItem(withObjectValue: Initial.uppercased())
        }
    }
    
    var SearchHow: StringSearchTypes = .StartsWith
    
    @IBAction func HandleSearchStrategyChanged(_ sender: Any)
    {
        if let Segment = sender as? NSSegmentedControl
        {
            switch Segment.selectedSegment
            {
                case 0:
                    SearchHow = .StartsWith
                    
                case 1:
                    SearchHow = .Contains
                    
                default:
                    return
            }
            if let StartingWords = MainSourceList.MatchingWords(Find: SearchField.stringValue, SearchHow: SearchHow)
            {
                CurrentWords.removeAll()
                for Word in StartingWords
                {
                    CurrentWords.append(Word)
                }
                SuggestionList.reloadData()
            }
            else
            {
                CurrentWords.removeAll()
                SuggestionList.reloadData()
            }
        }
    }
    
    @IBAction func HandleSearchInChanged(_ sender: Any)
    {
        var StringSource = [GlobalWords]()
        if WHSSwitch.state == .on
        {
            StringSource.append(.UNESCOSiteNames)
        }
        if POIsSwitch.state == .on
        {
            StringSource.append(.POINames)
        }
        if CitiesSwitch.state == .on
        {
            StringSource.append(.CityNames)
        }
        if AdditionalCitiesSwitch.state == .on
        {
            StringSource.append(.AdditionalCityNames)
        }
        if StringSource.isEmpty
        {
            StringSource.append(.CityNames)
            CitiesSwitch.state = .on
        }
        SetSource(StringSource)
        LoadAllNames()
        SuggestionList.reloadData()
    }
    
    @IBAction func HandleInitialsChanged(_ sender: Any)
    {
        if let Combo = sender as? NSComboBox
        {
            let Index = Combo.indexOfSelectedItem
            guard Index > -1 else
            {
                return
            }
            let Letters = MainSourceList.LetterSet()
            let Initial = Letters[Index]
            SearchField.stringValue = Initial
            if let StartingWords = MainSourceList.MatchingWords(Find: Initial)
            {
                CurrentWords.removeAll()
                for Word in StartingWords
                {
                    CurrentWords.append(Word)
                }
                SuggestionList.reloadData()
            }
        }
    }
    
    @IBOutlet weak var InitialsCombo: NSComboBoxCell!
    @IBOutlet weak var SearchHowSegment: NSSegmentedControl!
    @IBOutlet weak var WHSSwitch: NSSwitch!
    @IBOutlet weak var POIsSwitch: NSSwitch!
    @IBOutlet weak var CitiesSwitch: NSSwitch!
    @IBOutlet weak var SuggestionList: NSTableView!
    @IBOutlet weak var SearchField: NSTextField!
    @IBOutlet weak var AdditionalCitiesSwitch: NSSwitch!
}
