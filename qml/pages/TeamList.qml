import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.slackfish 1.0 as Slack

import "TeamList.js" as TeamList

Page {
    id: page

    ListModel {
        id: teamsModel
    }

    SilicaFlickable {
        anchors.fill: parent

        PullDownMenu {
            MenuItem {
                text: qsTr("About")
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("About.qml"))
                }
            }

            MenuItem {
                text: qsTr("Sign into a Workspace")

                onClicked: {
                    Slack.Config.addNewTeam()
                }
            }
        }

        SilicaListView {
            id: teamListView
            anchors.fill: parent
            model: teamsModel

            header: PageHeader {
                title: qsTr("Slackfish")
            }

            delegate: ListItem {
                id: delegate
                contentHeight: Theme.itemSizeSmall

                property color infoColor: delegate.highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
                property color textColor: delegate.highlighted ? Theme.highlightColor : Theme.primaryColor
                property color currentColor: model.unreadCount > 0 ? textColor : infoColor

                menu: ContextMenu {
                    MenuItem {
                        text: qsTr("Logout from this Workspace")
                        onClicked: remorseAction(qsTr("Logging out"), function() {
                            Slack.Config.removeTeam(model.uuid)
                        })
                    }
                }

                Row {
                    id: row
                    width: parent.width - Theme.paddingLarge * (Screen.sizeCategory >= Screen.Large ? 4 : 2)
                    anchors.verticalCenter: parent.verticalCenter
                    x: Theme.paddingLarge * (Screen.sizeCategory >= Screen.Large ? 2 : 1)
                    spacing: Theme.paddingMedium

                    Image {
                        id: icon
                        //source: "image://theme/" + Team.getIcon(model) + "?" + (delegate.highlighted ? currentColor : Channel.getIconColor(model, currentColor))
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Label {
                        width: parent.width - icon.width - Theme.paddingMedium
                        wrapMode: Text.Wrap
                        anchors.verticalCenter: parent.verticalCenter
                        font.pixelSize: Theme.fontSizeMedium
                        font.bold: model.unreadCount > 0
                        text: model.client.config.teamName
                        color: currentColor
                    }
                }
                onClicked: {
                    console.log("Opening team " + model.client.config.teamName)
                    if (model.client.initialized) {
                        pageStack.push(Qt.resolvedUrl("ChannelList.qml"), {"slackClient": model.client})
                    } else {
                        pageStack.push(Qt.resolvedUrl("Loader.qml"), {"slackClient": model.client})
                    }
                }
            }
        }
    }

    Component.onCompleted: {
        TeamList.init()
    }

}
