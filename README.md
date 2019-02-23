
<p align="center">
	<img height="200" src="https://raw.githubusercontent.com/TheCrypt0/yi-hack-v4/master/imgs/yi-hack-v4-header.png">
</p>
<p align="center">
	<a target="_blank" href="https://discord.gg/upPsFWZ">
        	<img src="https://img.shields.io/discord/530507539696189477.svg?logo=discord" alt="Official Discord Server">
	</a>
	<a target="_blank" href="https://github.com/TheCrypt0/yi-hack-v4/releases">
		<img src="https://img.shields.io/github/downloads/TheCrypt0/yi-hack-v4/total.svg" alt="Releases Downloads">
	</a>
	<a target="_blank" href="https://trello.com/b/EtuK8577/yi-hack-v4">
		<img src="https://img.shields.io/badge/Trello-yi--hack--v4-blue.svg" alt="Trello Board">
	</a>
	<img src="https://img.shields.io/github/license/TheCrypt0/yi-hack-v4.svg">
</p>

## Why another Yi firmware?

The answer is simple: missing updates, RTSP and not based on the latest stock firmware (which features improvements and new cool stuff). The effort and work that has been put into the other projects is great and without them the making of this new version wouldn't be possible.

## Alpha stage
The firmware is currently in alpha stage, it has been tested by the people on the [Discord Server](https://discord.gg/upPsFWZ) on their cameras. 

The **RTSP Server** is currently available to Supporters only, see the pinned messages in the channel __#rtsp-server__ in Discord for further info.

## Table of Contents

- [Features](#features)
- [Supported cameras](#supported-cameras)
- [Contribute to the development](#contribute-to-the-development)
- [Getting started](#getting-started)
- [Unbrick your camera](#unbrick-your-camera)
- [Acknowledgments](#acknowledgments)
- [Disclaimer](#disclaimer)

## Features
This firmware will add the following features:

- **NEW FEATURES**
  - **NEW CAMERAS SUPPORTED**: Yi Outdoor 1080p and Yi Cloud Dome 1080p
  - [viewd](https://github.com/TheCrypt0/viewd) - a daemon to check the `/tmp/view` buffer heads/tails location.
  - RTSP server - which will allow a RTSP stream of the video while keeping the cloud features enabled.
- In development:
  - A static image snapshot from the web interface.
  - The possibility to disable all the cloud features while keeping the RTSP stream.
- Features from  the `yi-hack-v3` firmware
  - SSH server -  _Enabled by default._
  - Telnet server -  _Disabled by default._
  - FTP server -  _Enabled by default._
  - Web server -  _Enabled by default._
  - Proxychains-ng -  _Enabled by default. Useful if the camera is region locked._

This firmware _might_ add:
- Alarm functionality via Telegram (@frekel's [PR #177 in yi-hack-v3](https://github.com/shadow-1/yi-hack-v3/pull/117))
- Auto upload of the recorded footage to the cloud (eg. Google Drive, Dropbox, etc.)
- Rotation control (on Yi Dome versions of the camera) without need for the app.
- **You decide**, just open an issue with the request.

## Supported cameras

Currently this project supports the following cameras:

- Yi Home 17CN / 27US / 47US
- Yi 1080p Home
- Yi Dome
- Yi 1080p Dome
- Yi 1080p Cloud Dome
- Yi 1080p Outdoor

Do you have one of these? Read the section below.

## Contribute to the development
#### Add support to new camers
To add support for a new camera I need to test the firmware on it, if you want to help the development open an issue with the model you own and we'll start testing it.

#### Donations
I don't like asking for donations, I prefer PRs to help the development. If you really want to send me a contribution, I will be glad to [accept it](https://paypal.me/TheCrypt0) and it will be used only to buy new cameras to test the firmware on. 

#### How to compile the Firmware
_TO DO - Maybe in the wiki_

## Getting Started
 _TO DO - (It will be really similar to yi-hack-v3's guide)_

## Unbrick your camera
_TO DO - (It happened a few times and it's often possible to recover from it)_

## Acknowledgments
Special thanks to the following people and projects, without them `yi-hack-v4` wouldn't be possible.
- @shadow-1 - [https://github.com/shadow-1/yi-hack-v3](https://github.com/shadow-1/yi-hack-v3)
- @fritz-smh - [https://github.com/fritz-smh/yi-hack](https://github.com/fritz-smh/yi-hack)
- @niclet  - [https://github.com/niclet/yi-hack-v2](https://github.com/niclet/yi-hack-v2)
- @xmflsct -  [https://github.com/xmflsct/yi-hack-1080p](https://github.com/xmflsct/yi-hack-1080p)
- @dvv - [Ideas for the RSTP stream](https://github.com/shadow-1/yi-hack-v3/issues/126)
- @andy2301 - [Ideas for the RSTP rtsp and rtsp2301](https://github.com/xmflsct/yi-hack-1080p/issues/5#issuecomment-294326131)

---
### DISCLAIMER
**I AM NOT RESPONSIBLE FOR ANY USE OR DAMAGE THIS SOFTWARE MAY CAUSE. THIS IS INTENDED FOR EDUCATIONAL PURPOSES ONLY. USE AT YOUR OWN RISK.**
