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
            WantsContinuousUpdates = FontDelegate!.WantsContinuousUpdates()
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
            if let Family = FontHelper.FontFamilyForPostscriptFile(Font.PostscriptName)
            {
                FontSizeBox.stringValue = "\(Font.FontSize.RoundedTo(0))"
                FontSizeSlider.doubleValue = Double(Font.FontSize)
                FontColorPicker.color = Font.FontColor
            SelectThenHighlight(Family, Font.PostscriptName)
            }
        }
    }
    
    func SelectThenHighlight(_ FontFamily: String, _ PSName: String)
    {
        if let FamilyIndex = FontHelper.FamilyIndex(FontFamily, In: FontData)
        {
            let FData = FontData[FamilyIndex]
            if let StyleIndex = FontHelper.StyleIndex(PSName, In: FData)
            {
                let ISet = IndexSet(integer: FamilyIndex)
                FontTable.selectRowIndexes(ISet, byExtendingSelection: false)
                FontTable.scrollRowToVisible(FamilyIndex)
                PopulateStyleControl(With: FamilyIndex)
                FontStyleCombo.selectItem(at: StyleIndex)
                UpdateSampleText()
            }
        }
    }
    
    func PopulateUI()
    {
        FontData = FontHelper.FontData
        FontTable.reloadData()
        SampleTextField.stringValue = ""
    }
    
    var FontData = [FontDataType]()
    
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
        UpdateSampleText()
        UpdateOnChange()
    }
    
    @IBAction func HandleFontNameClicked(_ sender: Any)
    {
        if let Table = sender as? NSTableView
        {
            let ItemIndex = Table.selectedRow
            PopulateStyleControl(With: ItemIndex)
            UpdateSampleText()
            UpdateOnChange()
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
        let Reasonable = ReasonableIndex(For: FData)
        FontStyleCombo.selectItem(at: Reasonable)
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
        UpdateOnChange()
    }
    
    @IBAction func HandleShowFontListPressed(_ sender: Any)
    {
        let Storyboard = NSStoryboard(name: "FontPickerUI", bundle: nil)
        if let WindowController = Storyboard.instantiateController(withIdentifier: "FontNameWindow") as? FontNameWindow
        {
            let WindowView = WindowController.contentViewController as? FontNameView
            if let Font = ReadUI()
            {
                if let Family = FontHelper.FontFamilyForPostscriptFile(Font.PostscriptName)
                {
                    if let FData = FontHelper.FontDataFor(Family, In: FontData)
                    {
                        var FontNames = [String]()
                        for Variant in FData.Variants
                        {
                            FontNames.append(Variant.Postscript)
                        }
                        FontNames.sort()
                        WindowView?.LoadNames(FontNames)
                        let Window = WindowController.window
                        self.view.window?.beginSheet(Window!, completionHandler: nil)
                    }
                }
            }
        }
    }
    
    func UpdateSampleText()
    {
        if let Font = ReadUI()
        {
        let SampleFont = NSFont(name: Font.PostscriptName, size: CGFloat(Font.FontSize))
        SampleTextField.textColor = Font.FontColor
        SampleTextField.font = SampleFont
        if let FamilyName = FontHelper.FontFamilyForPostscriptFile(Font.PostscriptName)
        {
            if let FontStyle = FontHelper.PostscriptStyle(In: FamilyName, Postscript: Font.PostscriptName)
            {
                SampleTextField.stringValue = "\(FamilyName) \(FontStyle)"
                return
            }
        }
        }
        SampleTextField.stringValue = "Huh?"
    }
    
    func ReadUI() -> StoredFont?
    {
        let FontFamilyIndex = FontTable.selectedRow
        if FontFamilyIndex < 0
        {
            return nil
        }
        let FData = FontData[FontFamilyIndex]
        let FontSize = FontSizeSlider.doubleValue
        let FontColor = FontColorPicker.color.usingColorSpace(.sRGB)!
        let StyleIndex = FontStyleCombo.indexOfSelectedItem
        let FontStyle = FData.Variants[StyleIndex].1
        let Final = StoredFont(FontStyle, CGFloat(FontSize), FontColor)
        return Final
    }
    
    func UpdateOnChange()
    {
        if WantsContinuousUpdates
        {
           if let Final = ReadUI()
           {
            FontDelegate?.NewFont(Final)
           }
        }
    }
    
    @IBAction func HandleFontSizeSliderChanged(_ sender: Any)
    {
        if let Slider = sender as? NSSlider
        {
            let SliderValue = Slider.doubleValue
            let ForText = "\(SliderValue.RoundedTo(0))"
            FontSizeBox.stringValue = ForText
            UpdateSampleText()
            UpdateOnChange()
        }
    }
    
    func controlTextDidEndEditing(_ obj: Notification)
    {
        if let TextField = obj.object as? NSTextField
        {
            switch TextField
            {
                case FontSizeBox:
                    if let DVal = Double(TextField.stringValue)
                    {
                        if DVal >= 8.0 && DVal <= 96.0
                        {
                            FontSizeSlider.doubleValue = DVal
                            UpdateSampleText()
                            UpdateOnChange()
                            return
                        }
                    }
                    TextField.stringValue = "\(FontSizeSlider.doubleValue.RoundedTo(0))"
                    UpdateSampleText()
                    UpdateOnChange()
                    
                default:
                    return
            }
        }
    }
    
    @IBAction func HandleOKClicked(_ sender: Any)
    {
        let Final = ReadUI()
        FontDelegate?.Closed(true, Final)
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

