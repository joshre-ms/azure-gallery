# Metadata for Azure Gallery packages

This repository contains the metadata for Azure Gallery packages. We use this content to create and update the gallery packages found in the [Preview portal](https://portal.azure.com). The gallery in the [Full portal](https://manage.windowsazure.com) does not use this metadata.

## Folder structure

Each folder at the root level approximately represents a publisher. A folder contains one or more `.json` files, called *package manifests*, each of which contains the metadata for an Azure Gallery package. Every folder also includes a set of icons and screenshots which can be referenced by the package manifests. Publishers can create new gallery packages by adding additional package manifests. Conversely, removing a package manifest will also remove the corresponding gallery package.

## Package manifest schema

* `publisher`
Required. A JSON string that is used to construct the package identity and is the short form of the publisher name. If a `publisherDisplayName` is not specified, then it is also used as the long form.

* `publisherDisplayName`
Optional. A JSON string that is used as the long form of the publisher name. When specified, it overrides the `publisher` value used in the Legal Terms section of a gallery details blade.

* `label`
Required. A JSON string that is used to construct the package identity.

* `displayName`
Required. A JSON string that is used as the display name of a gallery package.

* `imageType`
Optional. A JSON string to indicate if the `mediaName` is referencing an OS image or a VM image. Allowed values are `OSImage` and `VMImage`. By default, the value is assumed to be an OS image.

* `dataDisksCount`
Optional. A JSON string to indicate the number of data disks the VM image contains. This is used by the portal to filter out VM sizes that support fewer data disks than the VM image requires. If `imageType` is `OSImage`, this value is ignored.

* `mediaName`
Required. A JSON string that is the `Name` value of an Operating System Image ([OS Image](http://msdn.microsoft.com/library/azure/jj157191.aspx)) or Virtual Machine Image ([VM Image](http://msdn.microsoft.com/library/azure/dn499770.aspx)). Ensure that your image is published and replicated before adding a package manifest that references it.

* `os`
Required. A JSON string that denotes the platform of the image specified in `mediaName`. The only valid values are `Windows` and `Linux`.

* `description`
Required. A JSON string that contains the description of a gallery package. You can use basic HTML tags to format the content.

* `iconPath`
Required. A JSON string specifying the relative path to the icons for a gallery package.

* `categories`
Required. A JSON array that references categories in the Azure Gallery. Do not alter these values without prior consent. Note that if the image should be made available only to users with an MSDN subscription, you must specify `47970b32416a` as one of the categories.

* `recommendedSizes`
Required. A JSON array containing exactly three recommended virtual machine sizes. The first size will be used as the default  when creating a virtual machine using the portal. For a complete list of possible values for this property, see [List Role Sizes](http://msdn.microsoft.com/en-us/library/azure/dn469422.aspx).

* `links`
Optional. A JSON array containing objects that specify a `label` and `uri`. These links are shown in the details blade for a gallery package. You can specify up to five links.

* `eula`
Optional. A JSON string containing a URL to legal terms for a gallery package.

* `privacy`
Optional. A JSON string containing a URL to a privacy statement for a gallery package.

* `screenshot`
Optional. A JSON string specifying the relative path to a screenshot for a gallery package.

* `supportedExtensions`
Optional. A JSON string array specifying the list of extensions supported by this image. Do not alter these values without prior consent. This flag might be used to render specific configuration UI for these extensions while creating virtual machine in portal.

#### Additional notes

* The file name for a package manifest is not used in creating a gallery package. Feel free to name your package manifests in a a way that helps your organize them best.
* Editing the `publisher` and `label` values will alter the identity of the gallery package. Changes to a gallery package's identity will result in a new gallery package, which requires us to manually delete the old gallery package under its former  identity. Favor edits to `publisherDisplayName` and `displayName` over `publisher` and `label`, respectively.
* If you must edit the `publisher` and\or `label` fields please submit a delete request for the old package manifest and upload new package manifest with the edited `publisher` and\or `label` fields.

## Icons

The relative path specified by `iconPath` in a package manifest must point to a folder that includes the following four images:

1. Small.png (40x40 px)
2. Medium.png (90x90 px)
3. Large.png (115x115 px)
4. Wide.png (255x115 px)

You can group icons under subfolders if you have different ones per product. Just be sure to include the subfolder in the `iconPath` for the package manifest that uses them.

## Screenshots

Images must be exactly 533px by 324px and in PNG format. Specifying a screenshot for a gallery package is completely optional, so do not feel compelled to include one unless it makes sense for your offering.

## Contributing workflow

Here’s how we suggest you go about changing your gallery packages:

1. [Fork this project][fork] to your account.
2. [Create a branch][branch] for the change you intend to make.
3. Make your changes to your fork.
4. [Send a pull request][pr] from your fork’s branch to our `master` branch.

Changes to the respective gallery packages will be processed once we approve the pull request.

[fork]: http://help.github.com/forking/
[branch]: https://help.github.com/articles/creating-and-deleting-branches-within-your-repository
[pr]: http://help.github.com/pull-requests/

## Contact

For any questions, e-mail azuregalleryadmins@service.microsoft.com.
