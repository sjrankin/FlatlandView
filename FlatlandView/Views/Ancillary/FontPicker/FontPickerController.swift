//
//  FontPickerController.swift
//  Flatland
//
//  Created by Stuart Rankin on 7/7/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class FontPickerController: NSViewController, NSTableViewDelegate, NSTableViewDataSource,
                            NSTextFieldDelegate
{
    public weak var FontDelegate: FontProtocol? = nil
    {
        didSet
        {
            PopulateUI()
            InitializeWith(FontDelegate?.CurrentFont())
        }
    }
    
    var CurrentFont: StoredFont? = nil
    var CurrentColor: NSColor? = nil
    var WantsContinuousUpdates: Bool = false
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        FontStyleCombo.removeAllItems()
        FontColorPicker.color = NSColor.black
        FontSizeBox.stringValue = "8"
        FontSizeSlider.doubleValue = 8.0
        StyleCount.stringValue = ""
        SampleTextField.font = NSFont(name: "Avenir-Heavy", size: 36.0)
        SampleTextField.textColor = NSColor.systemBlue
        SampleTextField.stringValue = "Please Wait"
    }
    
    func InitializeWith(_ CallerFont: StoredFont?)
    {
        if let Font = CallerFont
        {
            
        }
    }
    
    func PopulateUI()
    {
        #if true
        FontData = FontHelper.FontData
        #else
        let FontFamilies = NSFontManager.shared.availableFontFamilies
        for FontFamilyName in FontFamilies
        {
            let FD = FontDataType(FontFamilyName)
            if let MemberData = NSFontManager.shared.availableMembers(ofFontFamily: FontFamilyName)
            {
                var PSNames = [(String, String)]()
                for Member in MemberData
                {
                    if let PSName = Member[0] as? String
                    {
                        if let FontName = Member[1] as? String
                        {
                            PSNames.append((FontName, PSName))
                        }
                    }
                }
                for (FontName, PSName) in PSNames
                {
                    FD.Variants.append((FontName, PSName))
                }
            }
            FontData.append(FD)
        }
        FontData.sort(by: {$0.FontFamilyName.caseInsensitiveCompare($1.FontFamilyName) == .orderedAscending})
        #endif
        FontTable.reloadData()
        SampleTextField.stringValue = ""
    }
    
    var FontData = [FontDataType]()
    
    func SelectFontName(_ FromFont: NSFont?)
    {
        if FromFont == nil
        {
            FontTable.deselectAll(self)
        }
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int
    {
        return FontData.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?
    {
        var CellContents = ""
        var CellIdentifier = ""
        if tableColumn == tableView.tableColumns[0]
        {
            CellIdentifier = "FontNameColumn"
            CellContents = FontData[row].FontFamilyName
        }
        
        let Cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: CellIdentifier), owner: self) as? NSTableCellView
        Cell?.textField?.stringValue = CellContents
        return Cell
    }
    
    @IBAction func HandleFontColorChanged(_ sender: Any)
    {
        if WantsContinuousUpdates
        {
            if let Picker =  sender as? NSColorWell
            {
                UpdateSampleText()
            }
        }
    }
    
    @IBAction func HandleFontNameClicked(_ sender: Any)
    {
        if let Table = sender as? NSTableView
        {
            let ItemIndex = Table.selectedRow
            PopulateStyleControl(With: ItemIndex)
            UpdateSampleText()
        }
    }
    
    func PopulateStyleControl(With FontIndex: Int)
    {
        let SelectedIndex = FontStyleCombo.indexOfSelectedItem
        if SelectedIndex > -1
        {
            FontStyleCombo.deselectItem(at: SelectedIndex)
        }
        let FData = FontData[FontIndex]
        FontStyleCombo.removeAllItems()
        for (SomeStyle, _) in FData.Variants
        {
            FontStyleCombo.addItem(withObjectValue: SomeStyle)
        }
        FontStyleCombo.selectItem(at: ReasonableIndex(For: FData))
        let Count = FData.Variants.count
        let Plural = Count != 1 ? "s" : ""
        let StyleText = "\(Count) style\(Plural)"
        StyleCount.stringValue = StyleText
        UpdateSampleText()
    }
    
    func ReasonableIndex(For Font: FontDataType) -> Int
    {
        if Font.Variants.count == 1
        {
            return 0
        }
        var Index = 0
        for (SomeStyle, _) in Font.Variants
        {
            if SomeStyle.caseInsensitiveCompare("Regular") == .orderedSame
            {
                return Index
            }
            Index = Index + 1
        }
        Index = 0
        for (SomeStyle, _) in Font.Variants
        {
            if SomeStyle.caseInsensitiveCompare("Medium") == .orderedSame
            {
                return Index
            }
            Index = Index + 1
        }
        return 0
    }
    
    @IBAction func HandleFontStyleChanged(_ sender: Any)
    {
        UpdateSampleText()
    }
    
    @IBAction func HandleShowFontListPressed(_ sender: Any)
    {
        let Storyboard = NSStoryboard(name: "FontPickerUI", bundle: nil)
        if let WindowController = Storyboard.instantiateController(withIdentifier: "FontNameWindow") as? FontNameWindow
        {
            let WindowView = WindowController.contentViewController as? FontNameView
            WindowView?.LoadNames(FontNameList)
            let Window = WindowController.window
            self.view.window?.beginSheet(Window!, completionHandler: nil)
        }
    }
    
    var FontNameList = [String]()
    
    func UpdateSampleText()
    {
        let FontFamilyIndex = FontTable.selectedRow
        if FontFamilyIndex < 0
        {
            SampleTextField.stringValue = "Huh?"
            return
        }
        let FData = FontData[FontFamilyIndex]
        let FontSize = FontSizeSlider.doubleValue
        let FontColor = FontColorPicker.color
        let StyleIndex = FontStyleCombo.indexOfSelectedItem
        let FontStyle = FData.Variants[StyleIndex].1
        let SampleFont = NSFont(name: FontStyle, size: CGFloat(FontSize))
        SampleTextField.textColor = FontColor
        SampleTextField.font = SampleFont
        SampleTextField.stringValue = "\(FData.FontFamilyName) \(FData.Variants[StyleIndex].0)"
    }
    
    
    @IBAction func HandleFontSizeSliderChanged(_ sender: Any)
    {
        if let Slider = sender as? NSSlider
        {
            let SliderValue = Slider.doubleValue
            let ForText = "\(SliderValue.RoundedTo(0))"
            FontSizeBox.stringValue = ForText
            UpdateSampleText()
        }
    }
    
    func FontFamilyForPostscriptName(_ Name: String) -> String?
    {
        for FData in FontData
        {
            for (_, PSName) in FData.Variants
            {
                if PSName == Name
                {
                    return FData.FontFamilyName
                }
            }
        }
        return nil
    }
    
    @IBAction func HandleOKClicked(_ sender: Any)
    {
        FontDelegate?.Closed(true, nil)
        view.window?.close()
    }
    
    @IBAction func HandleCancelClicked(_ sender: Any)
    {
        FontDelegate?.Closed(false, nil)
        view.window?.close()
    }
    
    @IBOutlet weak var StyleCount: NSTextField!
    @IBOutlet weak var FontListButton: NSButton!
    @IBOutlet weak var FontStyleCombo: NSComboBox!
    @IBOutlet weak var FontSizeBox: NSTextField!
    @IBOutlet weak var FontSizeSlider: NSSlider!
    @IBOutlet weak var FontColorPicker: NSColorWell!
    @IBOutlet weak var SampleTextField: NSTextField!
    @IBOutlet weak var FontTable: NSTableView!
}

