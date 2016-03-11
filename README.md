# Metadata for Azure Gallery packages

This repository contains the metadata for Azure Gallery packages. We use this content to create and update the gallery packages found in the [Preview portal](https://portal.azure.com). The gallery in the [Full portal](https://manage.windowsazure.com) does not use this metadata.

## Folder structure

Each folder at the root level approximately represents a publisher. A folder contains one or more `.json` files, called *package manifests*, each of which contains the metadata for an Azure Gallery package. Every folder also includes a set of icons and screenshots which can be referenced by the package manifests. Publishers can create new gallery packages by adding additional package manifests. Conversely, removing a package manifest will also remove the corresponding gallery package.

## Package manifest schema

* `cloudEnvironments`
You can omit this property when publishing only to `PublicAzure`. But to publish to clouds other than `PublicAzure`, this element is required. A JSON array specifying the list of clouds for which the package should be published. Currently supported clouds: `PublicAzure`, `Blackforest`. 

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
Multicloud support: The `links` field is the old format which will be supported for publishing only to `PublicAzure`. To publish to multiple clouds, the `linksForEnvironments` field should be used. If a file has both `links` and `linksForEnvironments` fields, the data in `linksForEnvironments` will be used for publishing the package. 

* `linksForEnvironments`
Optional. A JSON array containing objects that specify a `label` and `uri`. The `uri` field has a list of links for specifying Default urls for all clouds and overrides for specific clouds. If the Default url is not provided, that link will be made available only to the clouds specified. In the example below, the "Learn more" link will be available in all clouds and has an override for the `Blackforest` environment. The "Documentation" link will be available only for `Blackforest` and not for `PublicAzure` and other clouds. 
```json
"linksForEnvironments": [
    {
        "label": "Learn more",
        "uri": [
            {
                "Default": "http://www.microsoft.com/server-cloud/products/windows-server-2012-r2/",
                "Blackforest": "http://www.microsoft.com/server-cloud/products/windows-server-2012-r2/blackforest"
            }
        ]
    },
    {
        "label": "Documentation",
        "uri": [
            {
                "Blackforest": "http://technet.microsoft.com/library/hh801901.aspx/Blackforest"
            }
        ]
    }
]
```

* `eula`
Optional. A JSON string containing a URL to legal terms for a gallery package.

* `privacy`
Optional. A JSON string containing a URL to a privacy statement for a gallery package.

* `screenshot`
Optional. A JSON string specifying the relative path to a screenshot for a gallery package.

* `supportedExtensions`
Optional. A JSON string array specifying the list of extensions supported by this image. Do not alter these values without prior consent. This flag might be used to render specific configuration UI for these extensions while creating virtual machine in portal.

* `mediaName`
Required if publishing only to PublicAzure. A JSON string that is the `Name` value of an Operating System Image ([OS Image](http://msdn.microsoft.com/library/azure/jj157191.aspx)) or Virtual Machine Image ([VM Image](http://msdn.microsoft.com/library/azure/dn499770.aspx)). Ensure that your image is published and replicated before adding a package manifest that references it.

  Multicloud support: This element is required if publishing only to PublicAzure. If the package needs to be published to multiple environments, the `mediaReferences` element(see below) should be used.

* `imageVersions`
This element is optional and used only for PublicAzure. If the package is being published to multiple environments, `mediaReferences`(see below) should be used to specify these. A JSON array containing objects that specify the versions available for this image. 
The objects are made of the following properties:
  * `version`: image version string displayed to the user
  * `publishedDate`: date this version of the image was published
  * `mediaName`: the name of the an Operating System Image or Virtual Machine Image for this version (see required `mediaName` above)

  If there are image versions specified but none are selected by the user, the media name used will be the one in the required `mediaName`

  Example:
```json
"imageVersions": [
  {
    "version": "2.1.0",
    "publishedDate": "1/13/2015",
    "mediaName": "9e10b89011d34e0bad91898f40759f25__MyImage-2.1.0-en-us"
  },
  {
    "version": "2.0.13",
    "publishedDate": "7/14/2014",
    "mediaName": "9e10b89011d34e0bad91898f40759f25__MyImage-2.0.13-en-us"
  }
]
```

* `mediaReferences`
Required for supporting multiple environments. A JSON array containing the objects that specify the mediaName and imageVersions available. Both mediaName and imageVersions are required fields in the JSON object. If you do not want to specify imageVersions, the element should still be present, but you can assign it to null("imageVersions": null). The example below illustrates how to specify MediaName and imageVersions, for `PublicAzure` and `Blackforest` environments: 
```json
"mediaReferences": {
    "PublicAzure": {
    "mediaName": "a699494373c04fc0bc8f2bb1389d6106__Windows-Server-2012-R2-20160126-en.us-127GB.vhd",
    "imageVersions": [
        {
        "version": "December, 2015",
        "publishedDate": "12/14/2015",
        "mediaName": "a699494373c04fc0bc8f2bb1389d6106__Windows-Server-2012-R2-20151214-en.us-127GB.vhd"
        },
        {
        "version": "January, 2016",
        "publishedDate": "01/26/2016",
        "mediaName": "a699494373c04fc0bc8f2bb1389d6106__Windows-Server-2012-R2-20160126-en.us-127GB.vhd"
        }
        ]
    },
    "Blackforest": {
    "mediaName": "BlackforestLatest.vhd",
    "imageVersions": [
        {
        "version": "December, 2015",
        "publishedDate": "12/14/2015",
        "mediaName": "BlackforestVersion2015.vhd"
        },
        {
        "version": "January, 2016",
        "publishedDate": "01/26/2016",
        "mediaName": "BlackforestLatest.vhd"
        }
        ]
    }
}
```

  If both [mediaName, imageVersions] and [mediaReferences] are specified, mediaReferences will be used to generate the package and will overwrite the values of mediaName and imageVersions. 

* `createUIDefinitionHandler`
Optional. A JSON string specifying the value of the handler tag in the createuidefinition.cs file for CRP packages. 

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
