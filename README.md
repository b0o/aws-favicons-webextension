# AWS Favicons

Tired of all your AWS browser tabs having the same orange cube favicon? This Firefox addon fixes that by setting the favicon to the appropriate one for the current service. You can get it on `addons.mozilla.org` (soon, not uploaded yet) or build from source.

It's a complete rewrite of [JB4GDI/awsfaviconupdater](https://github.com/JB4GDI/awsfaviconupdater/) with much simpler are more robust code.

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
- [curl](https://curl.se/)
- [jq](https://github.com/stedolan/jq/)
- [pup](https://github.com/ericchiang/pup)
- [node](https://nodejs.org/)

The update script scrapes some generic metadata from the AWS cloud console in order to get a list of all AWS services and their associated icons.
The page containing this metadata is only available when logged in, but the metadata itself isn't sensitive, and it doesn't include any information about the logged-in user.

Before you run the script, you will need to log in to an AWS account and follow these steps:

1. Open the devtools (`Ctrl+Shift+I` or inspect element)
2. Navigate to the Network tab
3. Find any request to `<region>.console.aws.amazon.com` which has status code `200`
4. Select the request, then in the `Headers` tab, find the `Cookie` field under `Request Headers`
5. Copy the cookie

Then, invoke the `update.sh` script, passing the cookie as the first argument: `./update.sh "<cookie>"`.
After the script finishes, you should log out of your AWS session and log back in to invalidate the session.

## License

&copy; 2022 Maddison Hellstrom

MIT License
