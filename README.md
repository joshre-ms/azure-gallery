# Metadata for Azure Gallery packages

This repository contains the metadata for Azure Gallery packages. We use this content to create and update the gallery packages found in the [Preview portal](https://portal.azure.com). The gallery in the [Full portal](https://manage.windowsazure.com) does not use this metadata.

## Folder structure

Each folder at the root level approximately represents a publisher. A folder contains one or more `.json` files, called *package manifests*, each of which contains the metadata for an Azure Gallery package. Every folder also includes a set of icons and screenshots which can be referenced by the package manifests. Publishers can create new gallery packages by adding additional package manifests. Conversely, removing a package manifest will also remove the corresponding gallery package.

## Package manifest schema

* `cloudEnvironments`
You can omit this property when publishing only to `PublicAzure`. But to publish to clouds other than `PublicAzure`, this element is required. A JSON array specifying the list of clouds for which the package should be published. Currently supported clouds: `PublicAzure`, `Blackforest`, `Mooncake`. 

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

* `descriptionsForEnvironments`
Optional. A JSON object containg a default description as well as descriptions per-environment. If the default description is not provided, then only the per-environment descriptions will be used. If a file has both `description` and `descriptionsForEnvironments` fields, the data in `descriptionsForEnvironments` will be used for publishing the package.

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

* `mediaReferences`
Required for supporting multiple environments. A JSON array containing the objects that specify the mediaName. mediaName is a required field in the JSON object. The example below illustrates how to specify MediaName, for `PublicAzure` and `Blackforest` environments: 
```json
"mediaReferences": {
    "PublicAzure": {
    "mediaName": "a699494373c04fc0bc8f2bb1389d6106__Windows-Server-2012-R2-20160126-en.us-127GB.vhd"
    },
    "Blackforest": {
    "mediaName": "BlackforestLatest.vhd"
    }
}
```

  If mediaName and mediaReferences are specified, mediaReferences will be used to generate the package and will overwrite the value of mediaName. 

* `createUIDefinitionHandler`
Optional. A JSON string specifying the value of the handler tag in the createuidefinition.cs file for CRP packages. 

* `addHideKey`
Optional. A boolean indicating whether the gallery package should be hidden from the public. If set to `true`, the gallery package will only be visible if the URI query parameter `microsoft_azure_marketplace_itemhidekey=xrp` is specified, e.g. https://portal.azure.com/?microsoft_azure_marketplace_itemhidekey=xrp.

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

Pull requests are not necessary to add, remove, or edit packages. If you can see this README, then you have permissions to check into the repository directly.

## Contact

For any questions, e-mail azuregalleryadmins@service.microsoft.com.
