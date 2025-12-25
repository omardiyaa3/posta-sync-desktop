# SPDX-FileCopyrightText: 2024 WorldPosta
# SPDX-License-Identifier: GPL-2.0-or-later
#
# Posta Sync Desktop Client - WorldPosta Branding
#

set( APPLICATION_NAME       "Posta Sync" )
set( APPLICATION_SHORTNAME  "PostaSync" )
set( APPLICATION_EXECUTABLE "postasync" )
set( APPLICATION_ICON_NAME  "PostaSync" )

set( APPLICATION_CONFIG_NAME "${APPLICATION_EXECUTABLE}" )
set( APPLICATION_DOMAIN     "worldposta.com" )
set( APPLICATION_VENDOR     "WorldPosta" )
set( APPLICATION_UPDATE_URL "https://updates.nextcloud.org/client/" CACHE STRING "URL for updater" )
set( APPLICATION_HELP_URL   "https://worldposta.com/help" CACHE STRING "URL for the help menu" )

set( APPLICATION_ICON_SET   "SVG" )
set( APPLICATION_SERVER_URL "" CACHE STRING "URL for the server to use. If entered, the UI field will be pre-filled with it" )
set( APPLICATION_SERVER_URL_ENFORCE OFF ) # Allow users to enter their own server
set( APPLICATION_REV_DOMAIN "com.worldposta.postasync" )
set( DEVELOPMENT_TEAM "" CACHE STRING "Apple Development Team ID for code signing" )
set( APPLICATION_VIRTUALFILE_SUFFIX "postasync" CACHE STRING "Virtual file suffix (not including the .)")
set( APPLICATION_OCSP_STAPLING_ENABLED OFF )
set( APPLICATION_FORBID_BAD_SSL OFF )

set( LINUX_PACKAGE_SHORTNAME "postasync" )
set( LINUX_APPLICATION_ID "${APPLICATION_REV_DOMAIN}.${LINUX_PACKAGE_SHORTNAME}")

set( THEME_CLASS            "NextcloudTheme" )
set( WIN_SETUP_BITMAP_PATH  "${CMAKE_SOURCE_DIR}/admin/win/nsi" )

set( MAC_INSTALLER_BACKGROUND_FILE "${CMAKE_SOURCE_DIR}/admin/osx/installer-background.png" CACHE STRING "The MacOSX installer background image")

## Updater options
option( BUILD_UPDATER "Build updater" OFF )

option( WITH_PROVIDERS "Build with providers list" OFF )

option( ENFORCE_VIRTUAL_FILES_SYNC_FOLDER "Enforce use of virtual files sync folder when available" OFF )
option( DISABLE_VIRTUAL_FILES_SYNC_FOLDER "Disable use of virtual files sync folder even when available" OFF )

option(ENFORCE_SINGLE_ACCOUNT "Enforce use of a single account in desktop client" OFF)

option( DO_NOT_USE_PROXY "Do not use system wide proxy, instead always do a direct connection to server" OFF )

option( WIN_DISABLE_USERNAME_PREFILL "Do not prefill the Windows user name when creating a new account" OFF )

## Theming options - WorldPosta Design System Colors
# Primary/Brand: #679a41 (WorldPosta Green)
# Secondary: #293c51 (Dark Slate Blue)
set(NEXTCLOUD_BACKGROUND_COLOR "#679a41" CACHE STRING "Default Posta Sync background color")
set( APPLICATION_WIZARD_HEADER_BACKGROUND_COLOR ${NEXTCLOUD_BACKGROUND_COLOR} CACHE STRING "Hex color of the wizard header background")
set( APPLICATION_WIZARD_HEADER_TITLE_COLOR "#ffffff" CACHE STRING "Hex color of the text in the wizard header")
option( APPLICATION_WIZARD_USE_CUSTOM_LOGO "Use the logo from ':/client/theme/colored/wizard_logo.(png|svg)' else the default application icon is used" ON )

#
## Windows Shell Extensions & MSI - Generate new GUIDs for WorldPosta builds
#
if(WIN32)
    # Context Menu - NEW GUID for WorldPosta
    set( WIN_SHELLEXT_CONTEXT_MENU_GUID      "{A1B2C3D4-1234-5678-9ABC-DEF012345678}" )

    # Overlays - NEW GUIDs for WorldPosta
    set( WIN_SHELLEXT_OVERLAY_GUID_ERROR     "{A2B3C4D5-2345-6789-ABCD-EF0123456789}" )
    set( WIN_SHELLEXT_OVERLAY_GUID_OK        "{A3B4C5D6-3456-789A-BCDE-F01234567890}" )
    set( WIN_SHELLEXT_OVERLAY_GUID_OK_SHARED "{A4B5C6D7-4567-89AB-CDEF-012345678901}" )
    set( WIN_SHELLEXT_OVERLAY_GUID_SYNC      "{A5B6C7D8-5678-9ABC-DEF0-123456789012}" )
    set( WIN_SHELLEXT_OVERLAY_GUID_WARNING   "{A6B7C8D9-6789-ABCD-EF01-234567890123}" )

    # MSI Upgrade Code (without brackets) - NEW GUID for WorldPosta
    set( WIN_MSI_UPGRADE_CODE                "B1C2D3E4-7890-ABCD-EF01-234567890ABC" )

    # Windows build options
    option( BUILD_WIN_MSI "Build MSI scripts and helper DLL" OFF )
    option( BUILD_WIN_TOOLS "Build Win32 migration tools" OFF )
endif()

if (APPLE AND CMAKE_OSX_DEPLOYMENT_TARGET VERSION_GREATER_EQUAL 11.0)
    option( BUILD_FILE_PROVIDER_MODULE "Build the macOS virtual files File Provider module" OFF )
endif()
