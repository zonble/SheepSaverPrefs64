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

extension PrefsEditor : NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        while PrefsFindString("disk") {
            PrefsRemoveItem("disk")
        }

        for i in 0..<diskArray.count() {
            PrefsAddString("disk", diskArray[i].cString(using: .ascii))
        }
        PrefsReplaceInt32("bootdriver", (bootFrom.indexOfSelectedItem == 1 ? Int(CDROMRefNum) : 0))
        PrefsReplaceString("rom", "\(romFile)".cString(using: .ascii))
        PrefsReplaceString("extfs", "\(unixRoot)".cString(using: .ascii))
        PrefsReplaceBool("nocdrom", disableCdrom.intValue)
        PrefsReplaceInt32("ramsize", ramSize.intValue << 20)

        let pref = [Int8](repeating: 0, count: 256)
        snprintf(pref, MemoryLayout.size(ofValue: pref), "%s/%d/%d", videoType.indexOfSelectedItem == 0 ? "win" : "dga", width.intValue, height.intValue)
        PrefsReplaceString("screen", pref)

        var rate = 8
        switch refreshRate.indexOfSelectedItem {
        case 0:
            rate = 12
        case 1:
            rate = 8
        case 2:
            rate = 6
        case 3:
            rate = 4
        case 4:
            rate = 2
        case 5:
            rate = 1
        default:
            break
        }
        PrefsReplaceInt32("frameskip", rate)
        PrefsReplaceBool("gfxaccel", qdAccel.intValue)

        PrefsReplaceBool("nosound", disableSound.intValue)
        PrefsReplaceString("dsp", "\(outDevice)".cString(using: .ascii))
        PrefsReplaceString("mixer", "\(mixDevice)".cString(using: .ascii))

        PrefsReplaceBool("keycodes", useRawKeyCodes.intValue)
        PrefsReplaceString("keycodefile", "\(rawKeyCodes)".cString(using: .ascii))

        PrefsReplaceInt32("mousewheelmode", mouseWheel.indexOfSelectedItem)
        PrefsReplaceInt32("mousewheellines", scrollLines.intValue)

        PrefsReplaceBool("ignoresegv", ignoreIllegalMemoryAccesses.intValue)
        PrefsReplaceBool("idlewait", dontUseCPUWhenIdle.intValue)
        PrefsReplaceBool("jit", enableJIT.intValue)
        PrefsReplaceBool("jit68k", enable68kDREmulator.intValue)

        PrefsReplaceString("seriala", "\(modemPort)".cString(using: .ascii))
        PrefsReplaceString("serialb", "\(printerPort)".cString(using: .ascii))
        PrefsReplaceString("ether", "\(ethernetInterface)".cString(using: .ascii))

        SavePrefs()
        PrefsExit()
        exit(0)
    }
}
