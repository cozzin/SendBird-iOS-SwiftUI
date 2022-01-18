//
//  ChannelListView.swift
//  SendbirdExample
//
//  Created by Ernest Hong on 2022/01/18.
//

import SwiftUI

struct ChannelListView: View {
    var body: some View {
        List((0..<10)) {
            Text("\($0)")
        }
    }
}

struct ChannelListView_Previews: PreviewProvider {
    static var previews: some View {
        ChannelListView()
    }
}
