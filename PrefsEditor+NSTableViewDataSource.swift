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
import AppKit

extension PrefsEditor : NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return diskArray.count
    }
    
    func func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        return diskArray[row]
    }
}
