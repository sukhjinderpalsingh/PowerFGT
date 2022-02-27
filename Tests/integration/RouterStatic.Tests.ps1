#
# Copyright 2020, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

#include common configuration
. ../common.ps1


BeforeAll {
    Connect-FGT @invokeParams
}

Describe "Get Router Static" {

    BeforeAll {
        Add-FGTRouterStatic -seq_num 10 -dst 192.2.0.0/24 -gateway 198.51.100.254 -distance 15 -priority 5 -device port2
        Add-FGTRouterStatic -seq_num 11 -dst 198.51.100.0/24 -gateway 192.2.0.254 -distance 15 -priority 5 -device port2
    }

    It "Get Route Does not throw an error" {
        {
            Get-FGTRouterStatic
        } | Should -Not -Throw
    }

    It "Get ALL Route" {
        $route = Get-FGTRouterStatic
        $route.count | Should -Not -Be $NULL
    }

    It "Get ALL Route with -skip" {
        $route = Get-FGTRouterStatic -skip
        $route.count | Should -Not -Be $NULL
    }

    It "Get Route with gateway 198.51.100.254" {
        $route = Get-FGTRouterStatic -filter_attribute gateway -filter_value 198.51.100.254
        $route.gateway | Should -Be "198.51.100.254"
    }

    It "Get Route with gateway 192.2.0.254 and confirm (via Confirm-FGTRouterStatic)" {
        $route = Get-FGTRouterStatic -filter_attribute gateway -filter_value 192.2.0.254
        Confirm-FGTRouterStatic ($route) | Should -Be $true
    }

    Context "Search" {

        It "Search Route by gateway" {
            $route = Get-FGTRouterStatic -filter_attribute gateway -filter_value 198.51.100.254
            @($route).count | Should -be 1
            $route.gateway | Should -Be "198.51.100.254"
        }

    }

    AfterAll {
        Get-FGTRouterStatic -filter_attribute gateway -filter_value 198.51.100.254 | Remove-FGTRouterStatic -confirm:$false
        Get-FGTRouterStatic -filter_attribute gateway -filter_value 192.2.0.254 | Remove-FGTRouterStatic -confirm:$false
    }

}

Describe "Add Static Route" {

    AfterEach {
        Get-FGTRouterStatic -filter_attribute dst -filter_value "192.2.0.0 255.255.255.0" | Remove-FGTRouterStatic -confirm:$false
        Get-FGTRouterStatic -filter_attribute gateway -filter_value "198.51.100.254" | Remove-FGTRouterStatic -confirm:$false
    }

    It "Add route to 192.2.0.0/24" {
        $r = Add-FGTRouterStatic -dst 192.2.0.0/24 -gateway 198.51.100.254 -device port2
        ($r).count | Should -Be "1"
        $route = Get-FGTRouterStatic -filter_attribute gateway -filter_value 198.51.100.254
        $route.'seq-num' | Should -Not -BeNullOrEmpty
        $route.status | Should -Be "enable"
        $route.dst | Should -Be "192.2.0.0 255.255.255.0"
        $route.src | Should -Be "0.0.0.0 0.0.0.0"
        $route.gateway | Should -Be "198.51.100.254"
        $route.distance | Should -Be 10
        $route.weight | Should -Be 0
        if ($DefaultFGTConnection.version -lt "7.0.0") {
            $route.priority | Should -Be 0
        }
        else {
            $route.priority | Should -Be 1
        }
        $route.device | Should -Be "port2"
        $route.comment | Should -Be ""
        $route.blackhole | Should -Be "disable"
        $route.'dynamic-gateway' | Should -Be "disable"
        $route.dstaddr | Should -Be ""
        $route.'internet-service' | Should -Be "0"
        $route.'internet-service-custom' | Should -Be ""
        $route.'link-monitor-exempt' | Should -Be "disable"
        $route.vrf | Should -Be "0"
        $route.bfd | Should -Be "disable"
    }

    It "Add route to 192.2.0.0/24 with distance (15)" {
        $r = Add-FGTRouterStatic -dst 192.2.0.0/24 -gateway 198.51.100.254 -device port2 -distance 15
        ($r).count | Should -Be "1"
        $route = Get-FGTRouterStatic -filter_attribute gateway -filter_value 198.51.100.254
        $route.'seq-num' | Should -Not -BeNullOrEmpty
        $route.status | Should -Be "enable"
        $route.dst | Should -Be "192.2.0.0 255.255.255.0"
        $route.src | Should -Be "0.0.0.0 0.0.0.0"
        $route.gateway | Should -Be "198.51.100.254"
        $route.distance | Should -Be 15
        $route.weight | Should -Be 0
        if ($DefaultFGTConnection.version -lt "7.0.0") {
            $route.priority | Should -Be 0
        }
        else {
            $route.priority | Should -Be 1
        }
        $route.device | Should -Be "port2"
        $route.comment | Should -Be ""
        $route.blackhole | Should -Be "disable"
        $route.'dynamic-gateway' | Should -Be "disable"
        $route.dstaddr | Should -Be ""
        $route.'internet-service' | Should -Be "0"
        $route.'internet-service-custom' | Should -Be ""
        $route.'link-monitor-exempt' | Should -Be "disable"
        $route.vrf | Should -Be "0"
        $route.bfd | Should -Be "disable"
    }

    It "Add route to 192.2.0.0/24 with priority (5)" {
        $r = Add-FGTRouterStatic -dst 192.2.0.0/24 -gateway 198.51.100.254 -device port2 -priority 5
        ($r).count | Should -Be "1"
        $route = Get-FGTRouterStatic -filter_attribute gateway -filter_value 198.51.100.254
        $route.'seq-num' | Should -Not -BeNullOrEmpty
        $route.status | Should -Be "enable"
        $route.dst | Should -Be "192.2.0.0 255.255.255.0"
        $route.src | Should -Be "0.0.0.0 0.0.0.0"
        $route.gateway | Should -Be "198.51.100.254"
        $route.distance | Should -Be 10
        $route.weight | Should -Be 0
        $route.priority | Should -Be 5
        $route.device | Should -Be "port2"
        $route.comment | Should -Be ""
        $route.blackhole | Should -Be "disable"
        $route.'dynamic-gateway' | Should -Be "disable"
        $route.dstaddr | Should -Be ""
        $route.'internet-service' | Should -Be "0"
        $route.'internet-service-custom' | Should -Be ""
        $route.'link-monitor-exempt' | Should -Be "disable"
        $route.vrf | Should -Be "0"
        $route.bfd | Should -Be "disable"
    }

    It "Add route to 192.2.0.0/24 with seq-num (10)" {
        $r = Add-FGTRouterStatic -dst 192.2.0.0/24 -gateway 198.51.100.254 -device port2 -seq_num 10
        ($r).count | Should -Be "1"
        $route = Get-FGTRouterStatic -filter_attribute gateway -filter_value 198.51.100.254
        $route.'seq-num' | Should -Be "10"
        $route.status | Should -Be "enable"
        $route.dst | Should -Be "192.2.0.0 255.255.255.0"
        $route.src | Should -Be "0.0.0.0 0.0.0.0"
        $route.gateway | Should -Be "198.51.100.254"
        $route.distance | Should -Be 10
        $route.weight | Should -Be 0
        if ($DefaultFGTConnection.version -lt "7.0.0") {
            $route.priority | Should -Be 0
        }
        else {
            $route.priority | Should -Be 1
        }
        $route.device | Should -Be "port2"
        $route.comment | Should -Be ""
        $route.blackhole | Should -Be "disable"
        $route.'dynamic-gateway' | Should -Be "disable"
        $route.dstaddr | Should -Be ""
        $route.'internet-service' | Should -Be "0"
        $route.'internet-service-custom' | Should -Be ""
        $route.'link-monitor-exempt' | Should -Be "disable"
        $route.vrf | Should -Be "0"
        $route.bfd | Should -Be "disable"
    }

    It "Add route to 192.2.0.0/24 with status (enable)" {
        $r = Add-FGTRouterStatic -dst 192.2.0.0/24 -gateway 198.51.100.254 -device port2 -status
        ($r).count | Should -Be "1"
        $route = Get-FGTRouterStatic -filter_attribute gateway -filter_value 198.51.100.254
        $route.'seq-num' | Should -Not -BeNullOrEmpty
        $route.status | Should -Be "enable"
        $route.dst | Should -Be "192.2.0.0 255.255.255.0"
        $route.src | Should -Be "0.0.0.0 0.0.0.0"
        $route.gateway | Should -Be "198.51.100.254"
        $route.distance | Should -Be 10
        $route.weight | Should -Be 0
        if ($DefaultFGTConnection.version -lt "7.0.0") {
            $route.priority | Should -Be 0
        }
        else {
            $route.priority | Should -Be 1
        }
        $route.device | Should -Be "port2"
        $route.comment | Should -Be ""
        $route.blackhole | Should -Be "disable"
        $route.'dynamic-gateway' | Should -Be "disable"
        $route.dstaddr | Should -Be ""
        $route.'internet-service' | Should -Be "0"
        $route.'internet-service-custom' | Should -Be ""
        $route.'link-monitor-exempt' | Should -Be "disable"
        $route.vrf | Should -Be "0"
        $route.bfd | Should -Be "disable"
    }

    It "Add route to 192.2.0.0/24 with status (disable)" {
        $r = Add-FGTRouterStatic -dst 192.2.0.0/24 -gateway 198.51.100.254 -device port2 -status:$false
        ($r).count | Should -Be "1"
        $route = Get-FGTRouterStatic -filter_attribute gateway -filter_value 198.51.100.254
        $route.'seq-num' | Should -Not -BeNullOrEmpty
        $route.status | Should -Be "disable"
        $route.dst | Should -Be "192.2.0.0 255.255.255.0"
        $route.src | Should -Be "0.0.0.0 0.0.0.0"
        $route.gateway | Should -Be "198.51.100.254"
        $route.distance | Should -Be 10
        $route.weight | Should -Be 0
        if ($DefaultFGTConnection.version -lt "7.0.0") {
            $route.priority | Should -Be 0
        }
        else {
            $route.priority | Should -Be 1
        }
        $route.device | Should -Be "port2"
        $route.comment | Should -Be ""
        $route.blackhole | Should -Be "disable"
        $route.'dynamic-gateway' | Should -Be "disable"
        $route.dstaddr | Should -Be ""
        $route.'internet-service' | Should -Be "0"
        $route.'internet-service-custom' | Should -Be ""
        $route.'link-monitor-exempt' | Should -Be "disable"
        $route.vrf | Should -Be "0"
        $route.bfd | Should -Be "disable"
    }

    It "Add route to 192.2.0.0/24 with weight (10)" {
        $r = Add-FGTRouterStatic -dst 192.2.0.0/24 -gateway 198.51.100.254 -device port2 -weight 10
        ($r).count | Should -Be "1"
        $route = Get-FGTRouterStatic -filter_attribute gateway -filter_value 198.51.100.254
        $route.'seq-num' | Should -Not -BeNullOrEmpty
        $route.status | Should -Be "enable"
        $route.dst | Should -Be "192.2.0.0 255.255.255.0"
        $route.src | Should -Be "0.0.0.0 0.0.0.0"
        $route.gateway | Should -Be "198.51.100.254"
        $route.distance | Should -Be 10
        $route.weight | Should -Be 10
        if ($DefaultFGTConnection.version -lt "7.0.0") {
            $route.priority | Should -Be 0
        }
        else {
            $route.priority | Should -Be 1
        }
        $route.device | Should -Be "port2"
        $route.comment | Should -Be ""
        $route.blackhole | Should -Be "disable"
        $route.'dynamic-gateway' | Should -Be "disable"
        $route.dstaddr | Should -Be ""
        $route.'internet-service' | Should -Be "0"
        $route.'internet-service-custom' | Should -Be ""
        $route.'link-monitor-exempt' | Should -Be "disable"
        $route.vrf | Should -Be "0"
        $route.bfd | Should -Be "disable"
    }

    It "Add route to 192.2.0.0/24 with comment" {
        $r = Add-FGTRouterStatic -dst 192.2.0.0/24 -gateway 198.51.100.254 -device port2 -comment "Add by PowerFGT"
        ($r).count | Should -Be "1"
        $route = Get-FGTRouterStatic -filter_attribute gateway -filter_value 198.51.100.254
        $route.'seq-num' | Should -Not -BeNullOrEmpty
        $route.status | Should -Be "enable"
        $route.dst | Should -Be "192.2.0.0 255.255.255.0"
        $route.src | Should -Be "0.0.0.0 0.0.0.0"
        $route.gateway | Should -Be "198.51.100.254"
        $route.distance | Should -Be 10
        $route.weight | Should -Be 0
        if ($DefaultFGTConnection.version -lt "7.0.0") {
            $route.priority | Should -Be 0
        }
        else {
            $route.priority | Should -Be 1
        }
        $route.device | Should -Be "port2"
        $route.comment | Should -Be "Add by PowerFGT"
        $route.blackhole | Should -Be "disable"
        $route.'dynamic-gateway' | Should -Be "disable"
        $route.dstaddr | Should -Be ""
        $route.'internet-service' | Should -Be "0"
        $route.'internet-service-custom' | Should -Be ""
        $route.'link-monitor-exempt' | Should -Be "disable"
        $route.vrf | Should -Be "0"
        $route.bfd | Should -Be "disable"
    }

    It "Add route to 192.2.0.0/24 with blackhole (enable)" {
        $r = Add-FGTRouterStatic -dst 192.2.0.0/24 -blackhole
        ($r).count | Should -Be "1"
        $route = Get-FGTRouterStatic -filter_attribute dst -filter_value "192.2.0.0 255.255.255.0"
        $route.'seq-num' | Should -Not -BeNullOrEmpty
        $route.status | Should -Be "enable"
        $route.dst | Should -Be "192.2.0.0 255.255.255.0"
        $route.src | Should -Be "0.0.0.0 0.0.0.0"
        $route.gateway | Should -Be "0.0.0.0"
        $route.distance | Should -Be 10
        $route.weight | Should -Be 0
        if ($DefaultFGTConnection.version -lt "7.0.0") {
            $route.priority | Should -Be 0
        }
        else {
            $route.priority | Should -Be 1
        }
        $route.device | Should -Be ""
        $route.comment | Should -Be ""
        $route.blackhole | Should -Be "enable"
        $route.'dynamic-gateway' | Should -Be "disable"
        $route.dstaddr | Should -Be ""
        $route.'internet-service' | Should -Be "0"
        $route.'internet-service-custom' | Should -Be ""
        $route.'link-monitor-exempt' | Should -Be "disable"
        $route.vrf | Should -Be "0"
        $route.bfd | Should -Be "disable"
    }

    It "Add route to 192.2.0.0/24 with dynamic-gateway (enable)" {
        $r = Add-FGTRouterStatic -dst 192.2.0.0/24 -gateway 198.51.100.254 -device port2 -dynamic_gateway
        ($r).count | Should -Be "1"
        $route = Get-FGTRouterStatic -filter_attribute gateway -filter_value 198.51.100.254
        $route.'seq-num' | Should -Not -BeNullOrEmpty
        $route.status | Should -Be "enable"
        $route.dst | Should -Be "192.2.0.0 255.255.255.0"
        $route.gateway | Should -Be "198.51.100.254"
        $route.distance | Should -Be 10
        $route.weight | Should -Be 0
        if ($DefaultFGTConnection.version -lt "7.0.0") {
            $route.priority | Should -Be 0
        }
        else {
            $route.priority | Should -Be 1
        }
        $route.device | Should -Be "port2"
        $route.comment | Should -Be ""
        $route.blackhole | Should -Be "disable"
        $route.'dynamic-gateway' | Should -Be "enable"
        $route.dstaddr | Should -Be ""
        $route.'internet-service' | Should -Be "0"
        $route.'internet-service-custom' | Should -Be ""
        $route.'link-monitor-exempt' | Should -Be "disable"
        $route.vrf | Should -Be "0"
        $route.bfd | Should -Be "disable"
    }

    It "Add route to FortiGuard DNS with internet-service" {
        $r = Add-FGTRouterStatic -gateway 198.51.100.254 -device port2 -internet_service 1245187
        ($r).count | Should -Be "1"
        $route = Get-FGTRouterStatic -filter_attribute gateway -filter_value 198.51.100.254
        $route.'seq-num' | Should -Not -BeNullOrEmpty
        $route.status | Should -Be "enable"
        $route.dst | Should -Be "0.0.0.0 0.0.0.0"
        $route.src | Should -Be "0.0.0.0 0.0.0.0"
        $route.gateway | Should -Be "198.51.100.254"
        $route.distance | Should -Be 10
        $route.weight | Should -Be 0
        if ($DefaultFGTConnection.version -lt "7.0.0") {
            $route.priority | Should -Be 0
        }
        else {
            $route.priority | Should -Be 1
        }
        $route.device | Should -Be "port2"
        $route.comment | Should -Be ""
        $route.blackhole | Should -Be "disable"
        $route.'dynamic-gateway' | Should -Be "disable"
        $route.dstaddr | Should -Be ""
        $route.'internet-service' | Should -Be "1245187"
        $route.'internet-service-custom' | Should -Be ""
        $route.'link-monitor-exempt' | Should -Be "disable"
        $route.vrf | Should -Be "0"
        $route.bfd | Should -Be "disable"
    }

    It "Add route to 192.2.0.0/24 with link-monitor-exempt (enable)" {
        $r = Add-FGTRouterStatic -dst 192.2.0.0/24 -gateway 198.51.100.254 -device port2 -link_monitor_exempt
        ($r).count | Should -Be "1"
        $route = Get-FGTRouterStatic -filter_attribute gateway -filter_value 198.51.100.254
        $route.'seq-num' | Should -Not -BeNullOrEmpty
        $route.status | Should -Be "enable"
        $route.dst | Should -Be "192.2.0.0 255.255.255.0"
        $route.src | Should -Be "0.0.0.0 0.0.0.0"
        $route.gateway | Should -Be "198.51.100.254"
        $route.distance | Should -Be 10
        $route.weight | Should -Be 0
        if ($DefaultFGTConnection.version -lt "7.0.0") {
            $route.priority | Should -Be 0
        }
        else {
            $route.priority | Should -Be 1
        }
        $route.device | Should -Be "port2"
        $route.comment | Should -Be ""
        $route.blackhole | Should -Be "disable"
        $route.'dynamic-gateway' | Should -Be "disable"
        $route.dstaddr | Should -Be ""
        $route.'internet-service' | Should -Be "0"
        $route.'internet-service-custom' | Should -Be ""
        $route.'link-monitor-exempt' | Should -Be "enable"
        $route.vrf | Should -Be "0"
        $route.bfd | Should -Be "disable"
    }

    It "Add route to 192.2.0.0/24 with bfd (enable)" {
        $r = Add-FGTRouterStatic -dst 192.2.0.0/24 -gateway 198.51.100.254 -device port2 -bfd
        ($r).count | Should -Be "1"
        $route = Get-FGTRouterStatic -filter_attribute gateway -filter_value 198.51.100.254
        $route.'seq-num' | Should -Not -BeNullOrEmpty
        $route.status | Should -Be "enable"
        $route.dst | Should -Be "192.2.0.0 255.255.255.0"
        $route.src | Should -Be "0.0.0.0 0.0.0.0"
        $route.gateway | Should -Be "198.51.100.254"
        $route.distance | Should -Be 10
        $route.weight | Should -Be 0
        if ($DefaultFGTConnection.version -lt "7.0.0") {
            $route.priority | Should -Be 0
        }
        else {
            $route.priority | Should -Be 1
        }
        $route.device | Should -Be "port2"
        $route.comment | Should -Be ""
        $route.blackhole | Should -Be "disable"
        $route.'dynamic-gateway' | Should -Be "disable"
        $route.dstaddr | Should -Be ""
        $route.'internet-service' | Should -Be "0"
        $route.'internet-service-custom' | Should -Be ""
        $route.'link-monitor-exempt' | Should -Be "disable"
        $route.vrf | Should -Be "0"
        $route.bfd | Should -Be "enable"
    }

    <# Need to add vrf to Add-FTGInterfaces
    It "Add route to 192.2.0.0/24 with vrf" {
        $r = Add-FGTRouterStatic -dst 192.2.0.0/24 -gateway 198.51.100.254 -device port2 -vrf 1
        ($r).count | Should -Be "1"
        $route = Get-FGTRouterStatic -filter_attribute gateway -filter_value 198.51.100.254
        $route.'seq-num' | Should -Not -BeNullOrEmpty
        $route.status | Should -Be "enable"
        $route.dst | Should -Be "192.2.0.0 255.255.255.0"
        $route.src | Should -Be "0.0.0.0 0.0.0.0"
        $route.gateway | Should -Be "198.51.100.254"
        $route.distance | Should -Be 10
        $route.weight | Should -Be 0
        if ($DefaultFGTConnection.version -lt "7.0.0") {
            $route.priority | Should -Be 0
        } else {
            $route.priority | Should -Be 1
        }
        $route.device | Should -Be "port2"
        $route.comment | Should -Be ""
        $route.blackhole | Should -Be "disable"
        $route.'dynamic-gateway' | Should -Be "disable"
        $route.dstaddr| Should -Be ""
        $route.'internet-service' | Should -Be "0"
        $route.'internet-service-custom' | Should -Be ""
        $route.'link-monitor-exempt' | Should -Be "disable"
        $route.vrf | Should -Be "1"
        $route.bfd | Should -Be "enable"
    }
    #>

    <# Need to add allow_routing to Add-FTGFirewallAddress
    It "Add route to $pester_address2 (dstaddr)" {
        $r = Add-FGTRouterStatic -dstaddr $pester_address2 -gateway 198.51.100.254 -device port2
        ($r).count | Should -Be "1"
        $route = Get-FGTRouterStatic -filter_attribute gateway -filter_value 198.51.100.254
        $route.'seq-num' | Should -Not -BeNullOrEmpty
        $route.status | Should -Be "enable"
        $route.dst | Should -Be "0.0.0.0 0.0.0.0"
        $route.src | Should -Be "0.0.0.0 0.0.0.0"
        $route.gateway | Should -Be "198.51.100.254"
        $route.distance | Should -Be 10
        $route.weight | Should -Be 0
        if ($DefaultFGTConnection.version -lt "7.0.0") {
            $route.priority | Should -Be 0
        } else {
            $route.priority | Should -Be 1
        }
        $route.device | Should -Be "port2"
        $route.comment | Should -Be ""
        $route.blackhole | Should -Be "disable"
        $route.'dynamic-gateway' | Should -Be "disable"
        $route.dstaddr| Should -Be $pester_address2
        $route.'internet-service' | Should -Be "0"
        $route.'internet-service-custom' | Should -Be ""
        $route.'link-monitor-exempt' | Should -Be "disable"
        $route.vrf | Should -Be "0"
        $route.bfd | Should -Be "disable"
    }
    #>

    <#historic settings ? don't work...
    It "Add route to 192.2.0.0/24 with src (203.0.113.0/24)" {
        $r = Add-FGTRouterStatic -dst 192.2.0.0/24 -src 203.0.113.0/24 -gateway 198.51.100.254 -device port2
        ($r).count | Should -Be "1"
        $route = Get-FGTRouterStatic -filter_attribute gateway -filter_value 198.51.100.254
        $route.'seq-num' | Should -Not -BeNullOrEmpty
        $route.status | Should -Be "enable"
        $route.dst | Should -Be "192.2.0.0 255.255.255.0"
        $route.src | Should -Be "203.0.113.0 255.255.255.0"
        $route.gateway | Should -Be "198.51.100.254"
        $route.distance | Should -Be 10
        $route.weight | Should -Be 0
        if ($DefaultFGTConnection.version -lt "7.0.0") {
            $route.priority | Should -Be 0
        }
        else {
            $route.priority | Should -Be 1
        }
        $route.device | Should -Be "port2"
        $route.comment | Should -Be ""
        $route.blackhole | Should -Be "disable"
        $route.'dynamic-gateway' | Should -Be "disable"
        $route.dstaddr | Should -Be ""
        $route.'internet-service' | Should -Be "0"
        $route.'internet-service-custom' | Should -Be ""
        $route.'link-monitor-exempt' | Should -Be "disable"
        $route.vrf | Should -Be "0"
        $route.bfd | Should -Be "disable"
    }
    #>

    It "Try to Add Static with duplicate seq-num" {
        $r = Add-FGTRouterStatic -dst 192.2.0.0/24 -gateway 198.51.100.254 -device port2 -seq_num 10
        ($r).count | Should -Be "1"
        {
            Add-FGTRouterStatic -dst 192.2.0.0/24 -gateway 198.51.100.254 -device port2 -seq_num 10
        } | Should -Throw "Already a static route with this sequence number"
    }

    It "Try to Add Static with unknown device" {
        {
            Add-FGTRouterStatic -dst 192.2.0.0/24 -gateway 198.51.100.254 -device PowerFGT
        } | Should -Throw "The device interface does not exist"
    }
}

Describe "Remove Static Route" {

    BeforeEach {
        Add-FGTRouterStatic -seq_num 10 -dst 192.2.0.0/24 -gateway 198.51.100.254 -distance 15 -priority 5 -device port2
    }

    It "Remove Route 192.2.0.0/24 by pipeline" {
        $route = Get-FGTRouterStatic -filter_attribute gateway -filter_value 198.51.100.254
        $route | Remove-FGTRouterStatic -confirm:$false
        $route = Get-FGTRouterStatic -filter_attribute gateway -filter_value 198.51.100.254
        $route | Should -Be $NULL
    }

}

AfterAll {
    Disconnect-FGT -confirm:$false
}