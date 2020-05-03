
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

## RTSP Server
I've been working on a functional RTSP implementation for the past 3 months. After that I published on Discord the first working closed-beta, available to supporters only.
Since then I fixed some issues with Xiaomi's H264 encoder that happened to hang ffmpeg of Shinobi and Home Assistant.

Now everything works as it should and the app functionalities are intact (but they can be disabled if you want).

Tested on the following platforms (but it should work with anything that accepts an RTSP stream:
- Home Assistant
- Shinobi
- Zoneminder
- Synology Surveillance Station

I'm really thankful to those who supported the project and helped me by donating or sending me new cameras to test on, therefore I would like to reward them allowing to be the first ones to test the new functionalities.

Here's a quick guide on how to enable it: [Enable RTSP Server](https://github.com/TheCrypt0/yi-hack-v4/wiki/Enable-RTSP-Server).

## Table of Contents

- [Features](#features)
- [Supported cameras](#supported-cameras)
- [Getting started](#getting-started)
- [Unbrick your camera](#unbrick-your-camera)
- [Acknowledgments](#acknowledgments)
- [Disclaimer](#disclaimer)

## Features
This firmware will add the following features:

- **NEW FEATURES**
  - **NEW CAMERAS SUPPORTED**: Yi Outdoor 1080p and Yi Cloud Dome 1080p.
  - **RTSP server** - which will allow a RTSP stream of the video while keeping the cloud features enabled (available to the supporters of the project).
  - viewd - a daemon to check the `/tmp/view` buffer heads/tails location (needed by the RTSP).
  - **MQTT** - detect motion directly from your home server!
  - WebServer - user-friendly stats and configurations.
  - SSH server -  _Enabled by default._
  - Telnet server -  _Disabled by default._
  - FTP server -  _Enabled by default._
  - Web server -  _Enabled by default._
  - The possibility to change some camera settings (copied from official app):
    - camera on/off
    - video saving mode
    - detection sensitivity
    - status led
    - ir led
    - rotate
  - PTZ support through a web page.
  - Proxychains-ng - _Disabled by default. Useful if the camera is region locked._
  - The possibility to disable all the cloud features while keeping the RTSP stream.

## Supported cameras

Currently this project supports the following cameras:

- Yi Home 17CN / 27US / 47US
- Yi 1080p Home
- Yi Dome
- Yi 1080p Dome
- Yi 1080p Cloud Dome
- Yi 1080p Outdoor

## Getting Started
1. Check that you have a correct Xiaomi Yi camera. (see the section above)

2. Get an microSD card, preferably of capacity 16gb or less and format it by selecting File System as FAT32.

**_IMPORTANT: The microSD card must be formatted in FAT32. exFAT formatted microSD cards will not work._**

3. Get the correct firmware files for your camera from this link: https://github.com/TheCrypt0/yi-hack-v4/releases

| Camera | rootfs partition | home partition | Remarks |
| --- | --- | --- | --- |
| **Yi Home** | - | - | Not yet supported. |
| **Yi Home 17CN / 27US / 47US** | rootfs_y18 | home_y18 | Firmware files required for the Yi Home 17CN / 27US / 47US camera. |
| **Yi 1080p Home** | rootfs_y20 | home_y20 | Firmware files required for the Yi 1080p Home camera. |
| **Yi Dome** | rootfs_v201 | home_v201 | Firmware files required for the Yi Dome camera. |
| **Yi 1080p Dome** | rootfs_h20 | home_h20 | Firmware files required for the Yi 1080p Dome camera. |
| **Yi 1080p Cloud Dome** | rootfs_y19 | home_y19 | Firmware files required for the Yi 1080p Cloud Dome camera. |
| **Yi Outdoor** | rootfs_h30 | home_h30 | Firmware files required for the Yi Outdoor camera. |

4. Save both files on root path of microSD card.

**_IMPORTANT: Make sure that the filename stored on microSD card are correct and didn't get changed. e.g. The firmware filenames for the Yi 1080p Dome camera must be home_h20 and rootfs_h20._**

5. Remove power to the camera, insert the microSD card, turn the power back ON. 

6. The yellow light will come ON and flash for roughly 30 seconds, which means the firmware is being flashed successfully. The camera will boot up.

7. The yellow light will come ON again for the final stage of flashing. This will take up to 2 minutes.

8. Blue light should come ON indicating that your WiFi connection has been successful.

9. Go in the browser and access the web interface of the camera as a website. By default, the hostname of the camera is `yi-hack-v4`. Access the web interface by entering the following in your web browser: http://yi-hack-v4

Depending upon your network setup, accessing the web interface with the hostname **may not work**. In this case, the IP address of the camera has to be found.

This can be done from the App. Open it and go to the Camera Settings --> Network Info --> IP Address.

Access the web interface by entering the IP address of the came in a web browser. e.g. http://192.168.1.5

**_IMPORTANT: If you have multiple cameras. It is important to configure each camera with a unique hostname. Otherwise the web interface will only be accessible by IP address._**

10. Done! You are now successfully running yi-hack-v4!

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
- @roleoroleo - [PTZ Implementation](https://github.com/roleoroleo/yi-hack-MStar)

---
### DISCLAIMER
**I AM NOT RESPONSIBLE FOR ANY USE OR DAMAGE THIS SOFTWARE MAY CAUSE. THIS IS INTENDED FOR EDUCATIONAL PURPOSES ONLY. USE AT YOUR OWN RISK.**
