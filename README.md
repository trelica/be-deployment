# Trelica Browser Extension Helper deployment

Some macOS MDMs do not support deploying executables particularly well and you may hit problems
installing as the current user. The `trelica_install.sh` bash script manually creates the correct
files and folders to deploy the extension. Thanks to Emmanuel P for contributing an initial version
of this script.

At the start of the script you will see three variables that should be modified to include your
Trelica organization ID, the domain you are hosted on (app.trelica.com or eu.trelica.com), and a link
to the package.

If you are deploying to mulitple machines in a production environment you may wish to upload the
`TrelicaBrowserHelper` file to your own S3 bucket or equivalent.

```
# Alter these to point to your Trelica Organization ID and the correct domain (app or eu)
OrgID="a12345bc678d9e0f12a345b6c7f89def"
Domain="app.trelica.com"
TrelicaBrowserHelperUrl="https://vendeqappfiles.blob.core.windows.net/public/browserxtn/TrelicaBrowserHelper.pkg"
```

To run the script by hand, just set execute permisisons and run it.

You should then be able to get your MDM tool to deploy and run the script too.

```
chmod +x ./trelica_install.sh
sudo ./trelica_install.sh
```
