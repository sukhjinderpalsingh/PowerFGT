---
external help file: PowerFGT-help.xml
Module Name: PowerFGT
online version:
schema: 2.0.0
---

# Remove-FGTFirewallPolicyMember

## SYNOPSIS
Remove a FortiGate Policy Member

## SYNTAX

```
Remove-FGTFirewallPolicyMember [-policy] <PSObject> [-srcaddr <String[]>] [-srcintf <String[]>]
 [-dstaddr <String[]>] [-dstintf <String[]>] [-vdom <String[]>] [-connection <PSObject>]
 [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Remove a FortiGate Policy Member (source or destination address/interface)

## EXAMPLES

### EXAMPLE 1
```
$MyFGTPolicy = Get-FGTFirewallPolicy -name MyFGTPolicy
PS C:\>$MyFGTPolicy | Remove-FGTFirewallPolicyMember -srcaddr MyAddress1
```

Remove source MyAddress1 member to MyFGTPolicy

### EXAMPLE 2
```
$MyFGTPolicy = Get-FGTFirewallPolicy -name MyFGTPolicy
PS C:\>$MyFGTPolicy | Remove-FGTFirewallPolicyMember -dstaddr MyAddress1, MyAddress2
```

Remove destination MyAddress1 and MyAddress2 member to MyFGTPolicy

### EXAMPLE 3
```
$MyFGTPolicy = Get-FGTFirewallPolicy -name MyFGTPolicy
PS C:\>$MyFGTPolicy | Remove-FGTFirewallPolicyMember -srcintf port1
```

Remove port1 member to source interface of MyFGTPolicy

### EXAMPLE 4
```
$MyFGTPolicy = Get-FGTFirewallPolicy -name MyFGTPolicy
PS C:\>$MyFGTPolicy | Remove-FGTFirewallPolicyMember -dstintf port2
```

Remove port2 member to destination interface of MyFGTPolicy

## PARAMETERS

### -policy
{{ Fill policy Description }}

```yaml
Type: PSObject
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -srcaddr
{{ Fill srcaddr Description }}

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -srcintf
{{ Fill srcintf Description }}

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -dstaddr
{{ Fill dstaddr Description }}

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -dstintf
{{ Fill dstintf Description }}

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -vdom
{{ Fill vdom Description }}

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -connection
{{ Fill connection Description }}

```yaml
Type: PSObject
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: $DefaultFGTConnection
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ProgressAction
{{ Fill ProgressAction Description }}

```yaml
Type: ActionPreference
Parameter Sets: (All)
Aliases: proga

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
