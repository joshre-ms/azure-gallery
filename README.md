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
=======
## Microsoft Open Source Code of Conduct

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

# Azure Technical Documentation Contributor Guide
You've found the GitHub repository that houses the source for the Azure technical documentation that is published on [https://docs.microsoft.com/azure](https://docs.microsoft.com/azure).

This repository also contains guidance to help you contribute to our technical documentation. For a list of the articles in the contributors' guide, see [the index](contributor-guide/contributor-guide-index.md).

## Contribute to Azure documentation
Thank you for your interest in Azure documentation!

* [Ways to contribute](#ways-to-contribute)
* [Code of conduct](#code-of-conduct)
* [About your contributions to Azure content](#about-your-contributions-to-azure-content)
* [Repository organization](#repository-organization)
* [Use GitHub, Git, and this repository](#use-github-git-and-this-repository)
* [How to use markdown to format your topic](#how-to-use-markdown-to-format-your-topic)
* [More resources](#more-resources)
* [Index of all contributors' guide articles](contributor-guide/contributor-guide-index.md) (opens new page)

## Ways to contribute
You can submit updates to the [Azure documentation](https://docs.microsoft.com/azure) as follows:

* You can easily contribute to technical articles in the GitHub user interface. Either find the article in this repository, or visit the article on [https://docs.microsoft.com/azure](https://docs.microsoft.com/azure) and click the link in the article that goes to the GitHub source for the article.
* If you are making substantial changes to an existing article, adding or changing images, or contributing a new article, you need to fork this repository, install Git Bash, Markdown Pad, and learn some git commands.

## About your contributions to Azure content
### Minor corrections
Minor corrections or clarifications you submit for documentation and code examples in this repo are covered by the [docs.microsoft.com Terms of Use](https://docs.microsoft.com/legal/termsofuse).

### Larger submissions
If you submit a pull request with new or significant changes to documentation and code examples, we'll send a comment in GitHub asking you to submit an online Contribution License Agreement (CLA) if you are not an employee of Microsoft. We need you to complete the online form before we can accept your pull request.

## Repository organization
The content in the azure-docs repository follows the organization of documentation on https://docs.microsoft.com/azure. This repository contains two root folders:

### \articles
The *\articles* folder contains the documentation articles formatted as markdown files with an *.md* extension. Articles are typically grouped by Azure service.

Articles need to follow strict file naming guidelines - for details, see [our file naming guidance](contributor-guide/file-names-and-locations.md).

The *\articles* folder contains the *\media* folder for root directory article media files, inside which are subfolders with the images for each article.  The service folders contain a separate media folder for the articles within each service folder. The article image folders are named identically to the article file, minus the *.md* file extension.

### \includes
You can create reusable content sections to be included in one or more articles. See [Custom extensions used in our technical content](contributor-guide/custom-markdown-extensions.md).

### \markdown templates
This folder contains our standard markdown template with the basic markdown formatting you need for an article.

### \contributor-guide
This folder contains articles that are part of our contributors' guide.

## Use GitHub, Git, and this repository
For information about how to contribute, how to use the GitHub UI to contribute small changes, and how to fork and clone the repository for more significant contributions, see [Install and set up tools for authoring in GitHub](contributor-guide/tools-and-setup.md).

If you install GitBash and choose to work locally, the steps for creating a new local working branch, making changes, and submitting the changes back to the main branch are listed in [Git commands for creating a new article or updating an existing article](contributor-guide/git-commands-for-master.md)

### Branches
We recommend that you create local working branches that target a specific scope of change. Each branch should be limited to a single concept/article both to streamline work flow and reduce the possibility of merge conflicts.  The following efforts are of the appropriate scope for a new branch:

* A new article (and associated images)
* Spelling and grammar edits on an article.
* Applying a single formatting change across a large set of articles (e.g. new copyright footer).

## How to use markdown to format your topic
All the articles in this repository use GitHub flavored markdown.  Here's a list of resources.

* [Markdown basics](https://help.github.com/articles/markdown-basics/)
* [Printable markdown cheatsheet](./contributor-guide/media/documents/markdown-cheatsheet.pdf?raw=true)

## Article metadata
Article metadata enables certain functionalities, such as author attribution, contributor attribution, breadcrumbs, article descriptions, and SEO optimizations as well as reporting Microsoft uses to evaluate the performance of the content. So, the metadata is important! [Here's the guidance for making sure your metadata is done right](contributor-guide/article-metadata.md).

### Labels
Automated labels are assigned to pull requests to help us manage the pull request workflow and to help let you know what's going on with your pull request:

* Contribution License Agreement related
  * cla-not-required: The change is relatively minor and does not require that you sign a CLA.
  * cla-required: The scope of the change is relatively large and requires that you sign a CLA.
  * cla-signed: The contributor signed the CLA, so the pull request can now move forward for review.
* Pillar labels: Labels such as PnP, Modern Apps, and TDC help categorize the pull requests by the internal organization that needs to review the pull request.
* Change sent to author: The author has been notified of the pending pull request.

## More resources
See the [index of our contributor's guide](contributor-guide/contributor-guide-index.md) for all our guidance topics.