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

extension PrefsEditor : NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        while (PrefsFindString("disk") != nil) {
            PrefsRemoveItem("disk")
        }

        for i in 0..<diskArray.count {
            PrefsAddString("disk", diskArray[i].cString(using: .ascii))
        }
        PrefsReplaceInt32("bootdriver", int32((bootFrom.indexOfSelectedItem == 1 ? Int(CDROMRefNum) : 0)))
        PrefsReplaceString("rom", "\(String(describing: romFile))".cString(using: .ascii))
        PrefsReplaceString("extfs", "\(String(describing: unixRoot))".cString(using: .ascii))
        PrefsReplaceBool("nocdrom", (disableCdrom.intValue != 0))
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
        PrefsReplaceInt32("frameskip", int32(rate))
        PrefsReplaceBool("gfxaccel", (qdAccel.intValue != 0))

        PrefsReplaceBool("nosound", (disableSound.intValue != 0))
        PrefsReplaceString("dsp", "\(String(describing: outDevice))".cString(using: .ascii))
        PrefsReplaceString("mixer", "\(String(describing: mixDevice))".cString(using: .ascii))

        PrefsReplaceBool("keycodes", (useRawKeyCodes.intValue != 0))
        PrefsReplaceString("keycodefile", "\(rawKeyCodes)".cString(using: .ascii))

        PrefsReplaceInt32("mousewheelmode", int32(mouseWheel.indexOfSelectedItem))
        PrefsReplaceInt32("mousewheellines", scrollLines.intValue)

        PrefsReplaceBool("ignoresegv", (ignoreIllegalMemoryAccesses.intValue != 0))
        PrefsReplaceBool("idlewait", (dontUseCPUWhenIdle.intValue != 0))
        PrefsReplaceBool("jit", (enableJIT.intValue != 0))
        PrefsReplaceBool("jit68k", (enable68kDREmulator.intValue != 0))

        PrefsReplaceString("seriala", "\(String(describing: modemPort))".cString(using: .ascii))
        PrefsReplaceString("serialb", "\(String(describing: printerPort))".cString(using: .ascii))
        PrefsReplaceString("ether", "\(String(describing: ethernetInterface))".cString(using: .ascii))

        SavePrefs()
        PrefsExit()
        exit(0)
    }
}
