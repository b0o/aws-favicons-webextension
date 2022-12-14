<p align="center"><img src="https://raw.githubusercontent.com/b0o/aws-favicons-webextension/main/assets/extension-icon.svg" width="100"/></p>

<h1 align="center">AWS Favicons WebExtension</h1>

<p align="center">
  <a href="https://github.com/b0o/aws-favicons-webextension/releases"><img alt="Version Badge" src="https://img.shields.io/github/v/tag/b0o/aws-favicons-webextension?style=flat&color=yellow&label=version&sort=semver"/></a>
  <a href="https://mit-license.org"><img alt="License: MIT" src="https://img.shields.io/github/license/b0o/aws-favicons-webextension?style=flat&color=green"/></a>
  <a href="https://addons.mozilla.org/en-US/firefox/addon/aws-favicons/"><img alt="Mozilla Add-on" src="https://img.shields.io/amo/v/aws-favicons"/></a>
  <a href="https://chrome.google.com/webstore/detail/aws-favicons/hpiicbcmcbcjppjembmamenajemlanli"><img alt="Chrome Extension" src="https://img.shields.io/chrome-web-store/v/hpiicbcmcbcjppjembmamenajemlanli"/></a>
</p>

Tired of all your AWS browser tabs having the same orange cube favicon? This WebExtension fixes that by setting the favicon to the appropriate one for the current service.

- [Install Firefox Add-on](https://addons.mozilla.org/en-US/firefox/addon/aws-favicons/)
- [Install Chrome Extension](https://chrome.google.com/webstore/detail/aws-favicons/hpiicbcmcbcjppjembmamenajemlanli)

![Screenshot](https://user-images.githubusercontent.com/21299126/190009554-d33253d9-8b38-423e-81dd-edeb85d677a4.png)

It's a complete rewrite of [JB4GDI/awsfaviconupdater](https://github.com/JB4GDI/awsfaviconupdater/) with much simpler code.

## Building

### Firefox

To build the extension for Firefox:

```
$ cd aws-favicons-webextension
$ npm install
$ npm run build:firefox
```

The built extension will be in `web-ext-artifacts/v2/aws_favicons-<version>.zip`. The `v2` signifies Manifest V2.

To install it into a production version of Firefox, you will first need to sign the built extension using `web-ext sign` - you'll need a Mozilla developer account for this.

### Chrome

To build the extension for Chrome:

```
$ cd aws-favicons-webextension
$ npm install
$ npm run build:chromium
```

The built extension will be in `web-ext-artifacts/v3/aws_favicons-<version>.zip`. The `v3` signifies Manifest V3.

## Updating the icons and service definitions

This repository includes [a script](https://github.com/b0o/aws-favicons-webextension/blob/main/scripts/update.sh) to update the service definitions and download the service icons. It has a few dependencies:

- a recent version of Bash
- [sed](https://www.gnu.org/software/sed/)
- [curl](https://curl.se/)
- [jq](https://github.com/stedolan/jq/)
- [pup](https://github.com/ericchiang/pup)
- [node](https://nodejs.org/)

The update script scrapes some generic metadata from the AWS cloud console in order to get a list of all AWS services and their associated icons.
The page containing this metadata is only available when logged in, but the metadata itself isn't sensitive, and it doesn't include any information about the logged-in user.

Before you run the script, you will need to log in to an AWS account and follow these steps:

1. Go to your AWS console home page (URL should be `https://<region>.console.aws.amazon.com/console/home?region=<region>#`)
2. Open the devtools (`Ctrl+Shift+I` or inspect element)
3. Navigate to the Network panel
4. Search for `console.aws.amazon.com/console/home?region` and select the first matching requst with status code `200`
5. Right click on the request and select `Copy Value > Copy as cURL`

To run the script:

1. `cd` into the root of this repo
2. Paste the cURL command into your terminal but do not run it
3. Replace the first word of the command, `curl`, with `./scripts/update.sh`
4. Press return to run the script. The `./services.json` file and the icons in `./icons/` will be updated

After the script finishes, you should log out of your AWS session and log back in to invalidate the session.

## License

&copy; 2022 Maddison Hellstrom

MIT License
