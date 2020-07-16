/***************************************************************************
 *   Copyright (C) 2020 by Stefan Kebekus                                  *
 *   stefan.kebekus@gmail.com                                              *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 3 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.             *
 ***************************************************************************/

import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Controls.Material 2.14
import QtQuick.Layouts 1.14

import "../items"

Page {
    id: pg
    title: qsTr("Weather")


    header: StandardHeader {}

    Component {
        id: stationDelegate

        ItemDelegate {
            text: model.modelData.id
            icon.source: "/icons/material/ic_cloud_queue.svg" // to be replaced by badge
            icon.color: "transparent"

            width: pg.width

            onClicked: {
                mobileAdaptor.vibrateBrief()
                dialogLoader.active = false
                dialogLoader.dialogArgs = {station: model.modelData}
                dialogLoader.text = ""
                dialogLoader.source = "../dialogs/WeatherReport.qml"
                dialogLoader.active = true
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent

        // disabled for now
        SwitchDelegate {
            id: autoUpdate
            text: qsTr("Enable automatic updates")
                    + (false ? `<br><font color="#606060" size="2">`
                            + qsTr("Automatic updates enabled")
                            +"</font>"
                            : `<br><font color="#606060" size="2">`
                            + qsTr("Automatic updates disabled")
                            + `</font>`
                    )
            Layout.fillWidth: true
            Component.onCompleted: autoUpdate.checked = false
            onToggled: {
                mobileAdaptor.vibrateBrief()
                autoUpdate.checked = false //globalSettings.weatherAutoUpdate = autoUpdate.checked
            }
        }

        ListView {
            id: stationList
            Layout.fillHeight: true
            Layout.fillWidth: true
            clip: true

            model: meteorologist.reports
            delegate: stationDelegate
            ScrollIndicator.vertical: ScrollIndicator {}

            Rectangle {
                anchors.fill: parent
                color: "white"
                visible: stationList.count == 0

                Label {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.topMargin: Qt.application.font.pixelSize*2

                    horizontalAlignment: Text.AlignHCenter
                    textFormat: Text.RichText
                    wrapMode: Text.Wrap
                    text: meteorologist.updated
                            ? qsTr("No stations available in a radius of 75 nm from your position or your current route.")
                            : qsTr("Weather has not been updated yet.<p>Please tap <strong>Update all stations</strong> below.</p>")
                }
            }
        }
    } // Column

    footer: Pane {
        width: parent.width

        Material.elevation: 3
        visible: true

        ToolButton {
            id: downloadUpdatesActionButton
            anchors.centerIn: parent
            text: qsTr("Update all statons…")
            icon.source: "/icons/material/ic_file_download.svg"

            onClicked: {
                mobileAdaptor.vibrateBrief()
                meteorologist.update(satNav.lastValidCoordinate)
            }
        }
    } // Pane (footer)
    
} // Page
