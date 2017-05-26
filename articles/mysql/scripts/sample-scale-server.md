---
title: Azure CLI samples to scale an Azure Database for MySQL server | Microsoft Docs
description: This sample CLI script scales Azure Database for MySQL server to a different performance level after querying the metrics.
services: mysql
author: v-chenyh
ms.author: v-chenyh
manager: jhubbard
editor: jasonh
ms.assetid: 
ms.service: mysql-database
ms.tgt_pltfrm: portal
ms.devlang: azurecli
ms.topic: article
ms.custom: sample
ms.date: 05/25/2017
---

# Monitor and scale an Azure Database for MySQL server using Azure CLI
This sample CLI script scales a single Azure Database for MySQL server to a different performance level after querying the metrics.

[!INCLUDE [cloud-shell-try-it](../../../includes/cloud-shell-try-it.md)]

## Sample script
In this sample script, change the highlighted lines to customize the admin username and password. Replace the subscription id used in the az monitor commands with your own subscription id.
[!code-azurecli-interactive[main](../../../cli_scripts/mysql/scale-mysql-server/scale-mysql-server.sh?highlight=15-16 "Create and scale Azure Database for MySQL.")]

## Clean up deployment
After the script sample has been run, the following command can be used to remove the resource group and all resources associated with it.
[!code-azurecli-interactive[main](../../../cli_scripts/mysql/scale-mysql-server/delete-mysql.sh  "Delete the resource group.")]

## Script explanation
This script uses the following commands. Each command in the table links to command specific documentation.

| **Command** | **Notes** |
|---|---|
| [az group create](/cli/azure/group#create) | Creates a resource group in which all resources are stored. |
| [az mysql server create](/cli/azure/mysql/server#create) | Creates a MySQL server that hosts the databases. |
| [az monitor metrics list](/cli/azure/monitor/metrics#list) | List the metric value for the resources. |
| [az group delete](/cli/azure/group#delete) | Deletes a resource group including all nested resources. |

## Next steps
- Read more information on the Azure CLI: [Azure CLI documentation](/cli/azure/overview).
- Try additional scripts: [Azure CLI samples for Azure Database for MySQL](../sample-scripts-azure-cli.md)
- For more information on scaling, see [Service Tiers](../concepts-service-tiers.md) and [Compute Units and Storage Units](../concepts-compute-unit-and-storage.md).
