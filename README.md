<p align="center"><img src="https://raw.githubusercontent.com/b0o/aws-favicons-webextension/main/assets/extension-icon.svg" width="100"/></p>

# AWS Favicons WebExtension [![version](https://img.shields.io/github/v/tag/b0o/aws-favicons-webextension?style=flat&color=yellow&label=version&sort=semver)](https://github.com/b0o/aws-favicons-webextension/releases) [![license: MIT](https://img.shields.io/github/license/b0o/aws-favicons-webextension?style=flat&color=green)](https://mit-license.org) [![Mozilla Add-on](https://img.shields.io/amo/v/aws-favicons)](https://addons.mozilla.org/en-US/firefox/addon/aws-favicons/)

Tired of all your AWS browser tabs having the same orange cube favicon? This Firefox add-on fixes that by setting the favicon to the appropriate one for the current service.

- [Install Firefox Add-on](https://addons.mozilla.org/en-US/firefox/addon/aws-favicons/)

![Screenshot](https://user-images.githubusercontent.com/21299126/190009554-d33253d9-8b38-423e-81dd-edeb85d677a4.png)

It's a complete rewrite of [JB4GDI/awsfaviconupdater](https://github.com/JB4GDI/awsfaviconupdater/) with much simpler code.

## Building

To build the extension for Firefox, use [mozilla/web-ext](https://github.com/mozilla/web-ext):

```
$ cd aws-favicons
$ web-ext build --verbose
```

To install it into a production version of Firefox, you will first need to sign the built extension using `web-ext sign` - you'll need a Mozilla developer account for this.

## The `update.sh` script

This repository includes a script to update the service definitions and download the service icons. It has a few dependencies:

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
3. Replace the first word of the command, `curl`, with `./update.sh`
4. Press return to run the script. The `./services.json` file and the icons in `./icons/` will be updated

After the script finishes, you should log out of your AWS session and log back in to invalidate the session.

## License

&copy; 2022 Maddison Hellstrom

MIT License
