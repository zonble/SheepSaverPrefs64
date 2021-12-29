//
//  PrefsEditor.swift
//  SheepShaverPrefs
//  Preferences editing in Cocoa on Mac OS X
//
//  Created by Alonzo Machiraju on 12/28/21.
//  Updated from PrefsEditor.h, created by Alexei Svitkine, Copyright (C) 2006
//

/*
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

import Foundation
import Cocoa

let CDROMRefNum = -62         // RefNum of driver

class PrefsEditor : NSObject {
    @IBOutlet var window : NSWindow!
    @IBOutlet var diskSaveSize : NSView!
    @IBOutlet var diskSaveSizeField : NSTextField!
    
    var diskArray = [String]()

    // Setup
    @IBOutlet var disks : NSTableView!
    @IBOutlet var bootFrom : NSComboBox!
    @IBOutlet var disableCdrom : NSButton!
    @IBOutlet var ramSize : NSTextField!
    @IBOutlet var ramSizeStepper : NSStepper!
    @IBOutlet var romFile : NSTextField!
    @IBOutlet var unixRoot : NSTextField!
    // Audio/Video
    @IBOutlet var videoType : NSPopUpButton!
    @IBOutlet var refreshRate : NSPopUpButton!
    @IBOutlet var width : NSComboBox!
    @IBOutlet var height : NSComboBox!
    @IBOutlet var qdAccel : NSButton!
    @IBOutlet var disableSound : NSButton!
    @IBOutlet var outDevice : NSTextField!
    @IBOutlet var mixDevice : NSTextField!
    
    // Keyboard/Mouse
    @IBOutlet var useRawKeyCodes : NSButton!
    @IBOutlet var rawKeyCodes : NSTextField!
    @IBOutlet var mouseWheel : NSPopUpButton!
    @IBOutlet var scrollLines : NSTextField!
    @IBOutlet var scrollLinesStepper : NSStepper!
    
    // CPU/Misc
    @IBOutlet var ignoreIllegalMemoryAccesses : NSButton!
    @IBOutlet var dontUseCPUWhenIdle : NSButton!
    @IBOutlet var enableJIT : NSButton!
    @IBOutlet var enable68kDREmulator : NSButton!
    @IBOutlet var modemPort : NSTextField!
    @IBOutlet var printerPort : NSTextField!
    @IBOutlet var ethernetInterface : NSTextField!
    
    override init() {
        AddPrefsDefaults()
        AddPlatformPrefsDefaults()

        // Load preferences from settings file
        LoadPrefs()
        Bundle.main.bundlePath.cString(using: .utf16)
        chdir("..")
    }
    
    // MARK: - Setup
    
    func awakeFromNib() {
        var dsk : String?
        var index = 0
        
        while (dsk = PrefsFindString("disk", index++)) != NULL {
            diskArray.append(dsk)
        }
        
        disks.dataSource = self
        disks.reloadData()

        let bootdriver = PrefsFindInt32("bootdriver")
        var active = 0
        
        switch (bootdriver) {
            case 0:
                active = 0
            case CDROMRefNum:
                active = 1
            default:
                break
        }
        
        bootFrom.selectItem(at: active)

        romFile.stringValue = getStringFromPrefs("rom")
        unixRoot.stringValue = getStringFromPrefs("extfs")
        
        disableCdrom.intValue = PrefsFindBool("nocdrom")
        ramSize.intValue = PrefsFindInt32("ramsize") / (1024*1024)
        ramSizeStepper.intValue = PrefsFindInt32("ramsize") / (1024*1024)

        var display_type = 0
        
        let dis_width = 640
        let dis_height = 480

        guard let str = PrefsFindString("screen") else {
            if "win/\(dis_width)/\(dis_height)" ==  2 {
                display_type = 0
            } else if "dga/\(dis_width)/\(dis_height)" == 2 {
                display_type = 1
            }
        }

        videoType.selectItem(at: display_type)
        width.intValue = dis_width
        height.intValue = dis_height

        let frameskip = PrefsFindInt32("frameskip")
        
        var item = -1
        
        switch (frameskip) {
            case 12:
                item = 0
            case 8:
                item = 1
            case 6:
                item = 2
            case 4:
                item = 3
            case 2:
                item = 4
            case 1:
                item = 5
            case 0:
                item = 5
            default:
                break
        }
        
        if item >= 0 {
            refreshRate.selectItem(at: item)
        }

        qdAccel.intValue = PrefsFindBool("gfxaccel")
        disableSound.intValue = PrefsFindBool("nosound")
        useRawKeyCodes.intValue = PrefsFindBool("keycodes")
        
        outDevice.stringValue = getStringFromPrefs("dsp")
        mixDevice.stringValue = getStringFromPrefs("mixer")
        rawKeyCodes.stringValue = getStringFromPrefs("keycodefile")
        
        rawKeyCodes.enabled = useRawKeyCodes.intValue

        let wheelmode = PrefsFindInt32("mousewheelmode")
        var wheel = 0
        
        switch (wheelmode) {
            case 0:
                wheel = 0
            case 1:
                wheel = 1
            default:
                break
        }
        
        mouseWheel.selectItem(at: wheel)

        scrollLines.intValue = PrefsFindInt32("mousewheellines")
        scrollLinesStepper.intValue = PrefsFindInt32("mousewheellines")

        ignoreIllegalMemoryAccesses.intValue = PrefsFindBool("ignoresegv")
        dontUseCPUWhenIdle.intValue = PrefsFindBool("idlewait")
        enableJIT.intValue = PrefsFindBool("jit")
        enable68kDREmulator.intValue = PrefsFindBool("jit68k")
      
        modemPort.stringValue = getStringFromPrefs("seriala")
        printerPort.stringValue = getStringFromPrefs("serialb")
        ethernetInterface.stringValue = getStringFromPrefs("ether")
    }
    
    // MARK: - Interface Methods
    
    @IBAction func addDisk(sender : AnyObject) {
        let openPanel = NSOpenPanel()
        
        openPanel.canChooseDirectories = false
        openPanel.allowsMultipleSelection = false
        openPanel.beginSheet(forDirectory: "", file: "Unknown", modalFor: window, modalDelegate: self, didEndSelector: #selector(addDiskEnd(_): returnCode: contextInfo:)), contextInfo: nil)
    }
    
    @IBAction func removeDisk(sender : AnyObject) {
        if disks.selectedRow >= 0 {
            diskArray.remove(at: disks.selectedRow)
            disks.reloadData()
        }
    }
    @IBAction func createDisk(sender : AnyObject) {
        let savePanel = NSSavePanel()
        
        savePanel.accessoryView = diskSaveSize
        savePanel.beginSheet(forDirectory: "", file: "New.dsk", modalFor: window, modalDelegate: self, didEndSelector: #selector(self.createDiskEnd(_: returnCode: contextInfo:)), contextInfo: nil)
        
    }
    @IBAction func useRawKeyCodesClicked(sender : AnyObject) {
        rawKeyCodes.setEnabled(useRawKeyCodes.intValue)
    }
    
    // MARK: - Helper Methods
    
    func getStringFromPrefs(_ key: UnsafePointer<Int8>?) -> String? {
        let value = PrefsFindString(key)
        if value == nil {
            return ""
        }
        return value
    }
    
    func addDiskEnd(_ openPanel: NSOpenPanel?, returnCode theReturnCode: Int, contextInfo theContextInfo: UnsafeMutableRawPointer?) {
        if theReturnCode == NSOKButton {
            let cwd = [Int8](repeating: 0, count: 1024)
            let filename = [Int8](repeating: 0, count: 1024)
            var cwdlen: Int
            strlcpy(filename, `open`?.filename().cString(using: .ascii), MemoryLayout.size(ofValue: filename))
            getcwd(cwd, MemoryLayout.size(ofValue: cwd))
            cwdlen = strlen(cwd)
            if !strncmp(cwd, filename, cwdlen) {
                if cwdlen >= 0 && cwd[cwdlen - 1] != "/" {
                    cwdlen += 1
                }
                diskArray.append(filename + cwdlen)
            } else {
                if let aFilename = `open`?.filename() {
                    diskArray.append(aFilename)
                }
            }
            disks.reloadData()
        }
    }

    func createDiskEnd(_ savePanel: NSSavePanel?, returnCode theReturnCode: Int, contextInfo theContextInfo: UnsafeMutableRawPointer?) {
        if theReturnCode == NSOKButton {
            let size = diskSaveSizeField.intValue
            if size >= 0 && size <= 10000 {
                let cmd = [Int8](repeating: 0, count: 1024)
                snprintf(cmd, MemoryLayout.size(ofValue: cmd), "dd if=/dev/zero \"of=%s\" bs=1024k count=%d", save?.filename().cString(using: .ascii), diskSaveSizeField.intValue)
                let ret = system(cmd)
                if ret == 0 {
                    let cwd = [Int8](repeating: 0, count: 1024)
                    let filename = [Int8](repeating: 0, count: 1024)
                    var cwdlen: Int
                    strlcpy(filename, save?.filename().cString(using: .ascii), MemoryLayout.size(ofValue: filename))
                    getcwd(cwd, MemoryLayout.size(ofValue: cwd))
                    cwdlen = strlen(cwd)
                    if !strncmp(cwd, filename, cwdlen) {
                        if cwdlen >= 0 && cwd[cwdlen - 1] != "/" {
                            cwdlen += 1
                        }
                        diskArray.append(filename + cwdlen)
                    } else {
                        if let aFilename = save?.filename() {
                            diskArray.append(aFilename)
                        }
                    }
                    disks.reloadData()
                }
            }
        }
    }
}
