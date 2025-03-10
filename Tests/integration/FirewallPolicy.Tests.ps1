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

Describe "Get Firewall Policy" {

    BeforeAll {
        $policy = Add-FGTFirewallPolicy -name $pester_policy1 -srcintf port1 -dstintf port2 -srcaddr all -dstaddr all
        $script:uuid = $policy.uuid
        $script:policyid = $policy.policyid
        Add-FGTFirewallPolicy -name $pester_policy2 -srcintf port2 -dstintf port1 -srcaddr all -dstaddr all
    }

    It "Get Policy Does not throw an error" {
        {
            Get-FGTFirewallPolicy
        } | Should -Not -Throw
    }

    It "Get ALL Policy" {
        $policy = Get-FGTFirewallPolicy
        $policy.count | Should -Not -Be $NULL
    }

    It "Get ALL Policy with -skip" {
        $policy = Get-FGTFirewallPolicy -skip
        $policy.count | Should -Not -Be $NULL
    }

    It "Get Policy ($pester_policy1)" {
        $policy = Get-FGTFirewallPolicy -name $pester_policy1
        $policy.name | Should -Be $pester_policy1
    }

    It "Get Policy ($pester_policy1) and confirm (via Confirm-FGTFirewallPolicy)" {
        $policy = Get-FGTFirewallPolicy -name $pester_policy1
        Confirm-FGTFirewallPolicy ($policy) | Should -Be $true
    }

    It "Get Policy ($pester_policy1) and meta" {
        $policy = Get-FGTFirewallPolicy -name $pester_policy1 -meta
        $policy.name | Should -Be $pester_policy1
        $policy.q_ref | Should -Not -BeNullOrEmpty
        $policy.q_static | Should -Not -BeNullOrEmpty
        $policy.q_no_rename | Should -Not -BeNullOrEmpty
        $policy.q_global_entry | Should -Not -BeNullOrEmpty
        $policy.q_type | Should -Not -BeNullOrEmpty
        $policy.q_path | Should -Be "firewall"
        $policy.q_name | Should -Be "policy"
        $policy.q_mkey_type | Should -Be "integer"
        if ($DefaultFGTConnection.version -ge "6.2.0") {
            $policy.q_no_edit | Should -Not -BeNullOrEmpty
        }
        #$policy.q_class | Should -Not -BeNullOrEmpty
    }

    Context "Search" {

        It "Search Policy by name ($pester_policy1)" {
            $policy = Get-FGTFirewallPolicy -name $pester_policy1
            @($policy).count | Should -be 1
            $policy.name | Should -Be $pester_policy1
        }

        It "Search Policy by uuid ($script:uuid)" {
            $policy = Get-FGTFirewallPolicy -uuid $script:uuid
            @($policy).count | Should -be 1
            $policy.name | Should -Be $pester_policy1
        }

        It "Search Policy by policyid ($script:policyid)" {
            $policy = Get-FGTFirewallPolicy -policyid $script:policyid
            @($policy).count | Should -be 1
            $policy.name | Should -Be $pester_policy1
        }

    }

    AfterAll {
        Get-FGTFirewallPolicy -name $pester_policy1 | Remove-FGTFirewallPolicy -confirm:$false
        Get-FGTFirewallPolicy -name $pester_policy2 | Remove-FGTFirewallPolicy -confirm:$false
    }

}

Describe "Add Firewall Policy" {

    BeforeAll {
        Add-FGTFirewallPolicy -name $pester_policy2 -srcintf port2 -dstintf port3 -srcaddr all -dstaddr all
    }

    AfterEach {
        Get-FGTFirewallPolicy -name $pester_policy1 | Remove-FGTFirewallPolicy -confirm:$false
    }

    It "Add Policy $pester_policy1 (port1/port2 : All/All)" {
        $p = Add-FGTFirewallPolicy -name $pester_policy1 -srcintf port1 -dstintf port2 -srcaddr all -dstaddr all
        @($p).count | Should -Be "1"
        $policy = Get-FGTFirewallPolicy -name $pester_policy1
        $policy.name | Should -Be $pester_policy1
        $policy.uuid | Should -Not -BeNullOrEmpty
        $policy.srcintf.name | Should -Be "port1"
        $policy.dstintf.name | Should -Be "port2"
        $policy.srcaddr.name | Should -Be "all"
        $policy.dstaddr.name | Should -Be "all"
        $policy.action | Should -Be "accept"
        $policy.status | Should -Be "enable"
        $policy.service.name | Should -Be "all"
        $policy.schedule | Should -Be "always"
        $policy.nat | Should -Be "disable"
        $policy.logtraffic | Should -Be "utm"
        $policy.comments | Should -BeNullOrEmpty
    }

    Context "Multi Source / destination Interface" {

        It "Add Policy $pester_policy1 (src intf: port1, port3 and dst intf: port2)" {
            $p = Add-FGTFirewallPolicy -name $pester_policy1 -srcintf port1, port3 -dstintf port2 -srcaddr all -dstaddr all
            @($p).count | Should -Be "1"
            $policy = Get-FGTFirewallPolicy -name $pester_policy1
            $policy.name | Should -Be $pester_policy1
            $policy.uuid | Should -Not -BeNullOrEmpty
            ($policy.srcintf.name).count | Should -be "2"
            $policy.srcintf.name | Should -BeIn "port1", "port3"
            $policy.dstintf.name | Should -Be "port2"
            $policy.srcaddr.name | Should -Be "all"
            $policy.dstaddr.name | Should -Be "all"
            $policy.action | Should -Be "accept"
            $policy.status | Should -Be "enable"
            $policy.service.name | Should -Be "all"
            $policy.schedule | Should -Be "always"
            $policy.nat | Should -Be "disable"
            $policy.logtraffic | Should -Be "utm"
            $policy.comments | Should -BeNullOrEmpty
        }

        It "Add Policy $pester_policy1 (src intf: port1 and dst intf: port2, port4)" {
            $p = Add-FGTFirewallPolicy -name $pester_policy1 -srcintf port1 -dstintf port2, port4 -srcaddr all -dstaddr all
            @($p).count | Should -Be "1"
            $policy = Get-FGTFirewallPolicy -name $pester_policy1
            $policy.name | Should -Be $pester_policy1
            $policy.uuid | Should -Not -BeNullOrEmpty
            $policy.srcintf.name | Should -Be "port1"
            ($policy.dstintf.name).count | Should -be "2"
            $policy.dstintf.name | Should -BeIn "port2", "port4"
            $policy.srcaddr.name | Should -Be "all"
            $policy.dstaddr.name | Should -Be "all"
            $policy.action | Should -Be "accept"
            $policy.status | Should -Be "enable"
            $policy.service.name | Should -Be "all"
            $policy.schedule | Should -Be "always"
            $policy.nat | Should -Be "disable"
            $policy.logtraffic | Should -Be "utm"
            $policy.comments | Should -BeNullOrEmpty
        }

        It "Add Policy $pester_policy1 (src intf: port1, port3 and dst intf: port2, port4)" {
            $p = Add-FGTFirewallPolicy -name $pester_policy1 -srcintf port1, port3 -dstintf port2, port4 -srcaddr all -dstaddr all
            @($p).count | Should -Be "1"
            $policy = Get-FGTFirewallPolicy -name $pester_policy1
            $policy.name | Should -Be $pester_policy1
            $policy.uuid | Should -Not -BeNullOrEmpty
            ($policy.srcintf.name).count | Should -be "2"
            $policy.srcintf.name | Should -BeIn "port1", "port3"
            ($policy.dstintf.name).count | Should -be "2"
            $policy.dstintf.name | Should -BeIn "port2", "port4"
            $policy.srcaddr.name | Should -Be "all"
            $policy.dstaddr.name | Should -Be "all"
            $policy.action | Should -Be "accept"
            $policy.status | Should -Be "enable"
            $policy.service.name | Should -Be "all"
            $policy.schedule | Should -Be "always"
            $policy.nat | Should -Be "disable"
            $policy.logtraffic | Should -Be "utm"
            $policy.comments | Should -BeNullOrEmpty
        }

    }

    Context "Multi Source / destination address" {

        BeforeAll {
            Add-FGTFirewallAddress -Name $pester_address1 -ip 192.0.2.1 -mask 255.255.255.255
            Add-FGTFirewallAddress -Name $pester_address2 -ip 192.0.2.2 -mask 255.255.255.255
            Add-FGTFirewallAddress -Name $pester_address3 -ip 192.0.2.3 -mask 255.255.255.255
            Add-FGTFirewallAddress -Name $pester_address4 -ip 192.0.2.4 -mask 255.255.255.255
        }

        It "Add Policy $pester_policy1 (src addr: $pester_address1 and dst addr: all)" {
            $p = Add-FGTFirewallPolicy -name $pester_policy1 -srcintf port1 -dstintf port2 -srcaddr $pester_address1 -dstaddr all
            @($p).count | Should -Be "1"
            $policy = Get-FGTFirewallPolicy -name $pester_policy1
            $policy.name | Should -Be $pester_policy1
            $policy.uuid | Should -Not -BeNullOrEmpty
            $policy.srcintf.name | Should -BeIn "port1"
            $policy.dstintf.name | Should -Be "port2"
            $policy.srcaddr.name | Should -Be $pester_address1
            $policy.dstaddr.name | Should -Be "all"
            $policy.action | Should -Be "accept"
            $policy.status | Should -Be "enable"
            $policy.service.name | Should -Be "all"
            $policy.schedule | Should -Be "always"
            $policy.nat | Should -Be "disable"
            $policy.logtraffic | Should -Be "utm"
            $policy.comments | Should -BeNullOrEmpty
        }

        It "Add Policy $pester_policy1 (src addr: $pester_address1, $pester_address3 and dst addr: all)" {
            $p = Add-FGTFirewallPolicy -name $pester_policy1 -srcintf port1 -dstintf port2 -srcaddr $pester_address1, $pester_address3 -dstaddr all
            @($p).count | Should -Be "1"
            $policy = Get-FGTFirewallPolicy -name $pester_policy1
            $policy.name | Should -Be $pester_policy1
            $policy.uuid | Should -Not -BeNullOrEmpty
            $policy.srcintf.name | Should -BeIn "port1"
            $policy.dstintf.name | Should -Be "port2"
            ($policy.srcaddr.name).count | Should -Be "2"
            $policy.srcaddr.name | Should -BeIn $pester_address1, $pester_address3
            $policy.dstaddr.name | Should -Be "all"
            $policy.action | Should -Be "accept"
            $policy.status | Should -Be "enable"
            $policy.service.name | Should -Be "all"
            $policy.schedule | Should -Be "always"
            $policy.nat | Should -Be "disable"
            $policy.logtraffic | Should -Be "utm"
            $policy.comments | Should -BeNullOrEmpty
        }

        It "Add Policy $pester_policy1 (src addr: all and dst addr: $pester_address2)" {
            $p = Add-FGTFirewallPolicy -name $pester_policy1 -srcintf port1 -dstintf port2 -srcaddr all -dstaddr $pester_address2
            @($p).count | Should -Be "1"
            $policy = Get-FGTFirewallPolicy -name $pester_policy1
            $policy.name | Should -Be $pester_policy1
            $policy.uuid | Should -Not -BeNullOrEmpty
            $policy.srcintf.name | Should -BeIn "port1"
            $policy.dstintf.name | Should -Be "port2"
            $policy.srcaddr.name | Should -Be "all"
            $policy.dstaddr.name | Should -Be $pester_address2
            $policy.action | Should -Be "accept"
            $policy.status | Should -Be "enable"
            $policy.service.name | Should -Be "all"
            $policy.schedule | Should -Be "always"
            $policy.nat | Should -Be "disable"
            $policy.logtraffic | Should -Be "utm"
            $policy.comments | Should -BeNullOrEmpty
        }

        It "Add Policy $pester_policy1 (src addr: all and dst addr: $pester_address2, $pester_address4)" {
            $p = Add-FGTFirewallPolicy -name $pester_policy1 -srcintf port1 -dstintf port2 -srcaddr all -dstaddr $pester_address2, $pester_address4
            @($p).count | Should -Be "1"
            $policy = Get-FGTFirewallPolicy -name $pester_policy1
            $policy.name | Should -Be $pester_policy1
            $policy.uuid | Should -Not -BeNullOrEmpty
            $policy.srcintf.name | Should -BeIn "port1"
            $policy.dstintf.name | Should -Be "port2"
            $policy.srcaddr.name | Should -Be "all"
            ($policy.dstaddr.name).count | Should -Be "2"
            $policy.dstaddr.name | Should -BeIn $pester_address2, $pester_address4
            $policy.action | Should -Be "accept"
            $policy.status | Should -Be "enable"
            $policy.service.name | Should -Be "all"
            $policy.schedule | Should -Be "always"
            $policy.nat | Should -Be "disable"
            $policy.logtraffic | Should -Be "utm"
            $policy.comments | Should -BeNullOrEmpty
        }

        It "Add Policy $pester_policy1 (src addr: $pester_address1, $pester_address3 and dst addr: $pester_address2, $pester_address4)" {
            $p = Add-FGTFirewallPolicy -name $pester_policy1 -srcintf port1 -dstintf port2 -srcaddr $pester_address1, $pester_address3 -dstaddr $pester_address2, $pester_address4
            @($p).count | Should -Be "1"
            $policy = Get-FGTFirewallPolicy -name $pester_policy1
            $policy.name | Should -Be $pester_policy1
            $policy.uuid | Should -Not -BeNullOrEmpty
            $policy.srcintf.name | Should -BeIn "port1"
            $policy.dstintf.name | Should -Be "port2"
            ($policy.srcaddr.name).count | Should -Be "2"
            $policy.srcaddr.name | Should -BeIn $pester_address1, $pester_address3
            ($policy.dstaddr.name).count | Should -Be "2"
            $policy.dstaddr.name | Should -BeIn $pester_address2, $pester_address4
            $policy.action | Should -Be "accept"
            $policy.status | Should -Be "enable"
            $policy.service.name | Should -Be "all"
            $policy.schedule | Should -Be "always"
            $policy.nat | Should -Be "disable"
            $policy.logtraffic | Should -Be "utm"
            $policy.comments | Should -BeNullOrEmpty
        }

        AfterAll {
            Get-FGTFirewallAddress -name $pester_address1 | Remove-FGTFirewallAddress -confirm:$false
            Get-FGTFirewallAddress -name $pester_address2 | Remove-FGTFirewallAddress -confirm:$false
            Get-FGTFirewallAddress -name $pester_address3 | Remove-FGTFirewallAddress -confirm:$false
            Get-FGTFirewallAddress -name $pester_address4 | Remove-FGTFirewallAddress -confirm:$false
        }

    }

    It "Add Policy $pester_policy1 (with nat)" {
        $p = Add-FGTFirewallPolicy -name $pester_policy1 -srcintf port1 -dstintf port2 -srcaddr all -dstaddr all -nat
        @($p).count | Should -Be "1"
        $policy = Get-FGTFirewallPolicy -name $pester_policy1
        $policy.name | Should -Be $pester_policy1
        $policy.uuid | Should -Not -BeNullOrEmpty
        $policy.srcintf.name | Should -Be "port1"
        $policy.dstintf.name | Should -Be "port2"
        $policy.srcaddr.name | Should -Be "all"
        $policy.dstaddr.name | Should -Be "all"
        $policy.action | Should -Be "accept"
        $policy.status | Should -Be "enable"
        $policy.service.name | Should -Be "all"
        $policy.schedule | Should -Be "always"
        $policy.nat | Should -Be "enable"
        $policy.logtraffic | Should -Be "utm"
        $policy.comments | Should -BeNullOrEmpty
    }

    It "Add Policy $pester_policy1 (with action deny)" {
        $p = Add-FGTFirewallPolicy -name $pester_policy1 -srcintf port1 -dstintf port2 -srcaddr all -dstaddr all -action deny
        @($p).count | Should -Be "1"
        $policy = Get-FGTFirewallPolicy -name $pester_policy1
        $policy.name | Should -Be $pester_policy1
        $policy.uuid | Should -Not -BeNullOrEmpty
        $policy.srcintf.name | Should -Be "port1"
        $policy.dstintf.name | Should -Be "port2"
        $policy.srcaddr.name | Should -Be "all"
        $policy.dstaddr.name | Should -Be "all"
        $policy.action | Should -Be "deny"
        $policy.status | Should -Be "enable"
        $policy.service.name | Should -Be "all"
        $policy.schedule | Should -Be "always"
        $policy.nat | Should -Be "disable"
        $policy.logtraffic | Should -Be "disable"
        $policy.comments | Should -BeNullOrEmpty
    }

    It "Add Policy $pester_policy1 (with action deny with log)" {
        $p = Add-FGTFirewallPolicy -name $pester_policy1 -srcintf port1 -dstintf port2 -srcaddr all -dstaddr all -action deny -log all
        @($p).count | Should -Be "1"
        $policy = Get-FGTFirewallPolicy -name $pester_policy1
        $policy.name | Should -Be $pester_policy1
        $policy.uuid | Should -Not -BeNullOrEmpty
        $policy.srcintf.name | Should -Be "port1"
        $policy.dstintf.name | Should -Be "port2"
        $policy.srcaddr.name | Should -Be "all"
        $policy.dstaddr.name | Should -Be "all"
        $policy.action | Should -Be "deny"
        $policy.status | Should -Be "enable"
        $policy.service.name | Should -Be "all"
        $policy.schedule | Should -Be "always"
        $policy.nat | Should -Be "disable"
        $policy.logtraffic | Should -Be "all"
        $policy.comments | Should -BeNullOrEmpty
    }

    It "Add Policy $pester_policy1 (status disable)" {
        $p = Add-FGTFirewallPolicy -name $pester_policy1 -srcintf port1 -dstintf port2 -srcaddr all -dstaddr all -status:$false
        @($p).count | Should -Be "1"
        $policy = Get-FGTFirewallPolicy -name $pester_policy1
        $policy.name | Should -Be $pester_policy1
        $policy.uuid | Should -Not -BeNullOrEmpty
        $policy.srcintf.name | Should -Be "port1"
        $policy.dstintf.name | Should -Be "port2"
        $policy.srcaddr.name | Should -Be "all"
        $policy.dstaddr.name | Should -Be "all"
        $policy.action | Should -Be "accept"
        $policy.status | Should -Be "disable"
        $policy.service.name | Should -Be "all"
        $policy.schedule | Should -Be "always"
        $policy.nat | Should -Be "disable"
        $policy.logtraffic | Should -Be "utm"
        $policy.comments | Should -BeNullOrEmpty
    }

    It "Add Policy $pester_policy1 (with 1 service : HTTP)" {
        $p = Add-FGTFirewallPolicy -name $pester_policy1 -srcintf port1 -dstintf port2 -srcaddr all -dstaddr all -service HTTP
        @($p).count | Should -Be "1"
        $policy = Get-FGTFirewallPolicy -name $pester_policy1
        $policy.name | Should -Be $pester_policy1
        $policy.uuid | Should -Not -BeNullOrEmpty
        $policy.srcintf.name | Should -Be "port1"
        $policy.dstintf.name | Should -Be "port2"
        $policy.srcaddr.name | Should -Be "all"
        $policy.dstaddr.name | Should -Be "all"
        $policy.action | Should -Be "accept"
        $policy.status | Should -Be "enable"
        $policy.service.name | Should -Be "HTTP"
        $policy.schedule | Should -Be "always"
        $policy.nat | Should -Be "disable"
        $policy.logtraffic | Should -Be "utm"
        $policy.comments | Should -BeNullOrEmpty
    }

    It "Add Policy $pester_policy1 (with 2 services : HTTP, HTTPS)" {
        $p = Add-FGTFirewallPolicy -name $pester_policy1 -srcintf port1 -dstintf port2 -srcaddr all -dstaddr all -service HTTP, HTTPS
        @($p).count | Should -Be "1"
        $policy = Get-FGTFirewallPolicy -name $pester_policy1
        $policy.name | Should -Be $pester_policy1
        $policy.uuid | Should -Not -BeNullOrEmpty
        $policy.srcintf.name | Should -Be "port1"
        $policy.dstintf.name | Should -Be "port2"
        $policy.srcaddr.name | Should -Be "all"
        $policy.dstaddr.name | Should -Be "all"
        $policy.action | Should -Be "accept"
        $policy.status | Should -Be "enable"
        $policy.service.name | Should -BeIn "HTTP", "HTTPS"
        $policy.schedule | Should -Be "always"
        $policy.nat | Should -Be "disable"
        $policy.logtraffic | Should -Be "utm"
        $policy.comments | Should -BeNullOrEmpty
    }

    It "Add Policy $pester_policy1 (with logtraffic all)" {
        $p = Add-FGTFirewallPolicy -name $pester_policy1 -srcintf port1 -dstintf port2 -srcaddr all -dstaddr all -logtraffic all
        @($p).count | Should -Be "1"
        $policy = Get-FGTFirewallPolicy -name $pester_policy1
        $policy.name | Should -Be $pester_policy1
        $policy.uuid | Should -Not -BeNullOrEmpty
        $policy.srcintf.name | Should -Be "port1"
        $policy.dstintf.name | Should -Be "port2"
        $policy.srcaddr.name | Should -Be "all"
        $policy.dstaddr.name | Should -Be "all"
        $policy.action | Should -Be "accept"
        $policy.status | Should -Be "enable"
        $policy.service.name | Should -Be "all"
        $policy.schedule | Should -Be "always"
        $policy.nat | Should -Be "disable"
        $policy.logtraffic | Should -Be "all"
        $policy.comments | Should -BeNullOrEmpty
    }

    It "Add Policy $pester_policy1 (with logtraffic disable)" {
        $p = Add-FGTFirewallPolicy -name $pester_policy1 -srcintf port1 -dstintf port2 -srcaddr all -dstaddr all -logtraffic disable
        @($p).count | Should -Be "1"
        $policy = Get-FGTFirewallPolicy -name $pester_policy1
        $policy.name | Should -Be $pester_policy1
        $policy.uuid | Should -Not -BeNullOrEmpty
        $policy.srcintf.name | Should -Be "port1"
        $policy.dstintf.name | Should -Be "port2"
        $policy.srcaddr.name | Should -Be "all"
        $policy.dstaddr.name | Should -Be "all"
        $policy.action | Should -Be "accept"
        $policy.status | Should -Be "enable"
        $policy.service.name | Should -Be "all"
        $policy.schedule | Should -Be "always"
        $policy.nat | Should -Be "disable"
        $policy.logtraffic | Should -Be "disable"
        $policy.comments | Should -BeNullOrEmpty
    }

    #Add Schedule ? need API
    It "Add Policy $pester_policy1 (with schedule none)" {
        $p = Add-FGTFirewallPolicy -name $pester_policy1 -srcintf port1 -dstintf port2 -srcaddr all -dstaddr all -schedule none
        @($p).count | Should -Be "1"
        $policy = Get-FGTFirewallPolicy -name $pester_policy1
        $policy.name | Should -Be $pester_policy1
        $policy.uuid | Should -Not -BeNullOrEmpty
        $policy.srcintf.name | Should -Be "port1"
        $policy.dstintf.name | Should -Be "port2"
        $policy.srcaddr.name | Should -Be "all"
        $policy.dstaddr.name | Should -Be "all"
        $policy.action | Should -Be "accept"
        $policy.status | Should -Be "enable"
        $policy.service.name | Should -Be "All"
        $policy.schedule | Should -Be "none"
        $policy.nat | Should -Be "disable"
        $policy.logtraffic | Should -Be "utm"
        $policy.comments | Should -BeNullOrEmpty
    }

    It "Add Policy $pester_policy1 (with comments)" {
        $p = Add-FGTFirewallPolicy -name $pester_policy1 -srcintf port1 -dstintf port2 -srcaddr all -dstaddr all -comments "Add via PowerFGT"
        @($p).count | Should -Be "1"
        $policy = Get-FGTFirewallPolicy -name $pester_policy1
        $policy.name | Should -Be $pester_policy1
        $policy.uuid | Should -Not -BeNullOrEmpty
        $policy.srcintf.name | Should -Be "port1"
        $policy.dstintf.name | Should -Be "port2"
        $policy.srcaddr.name | Should -Be "all"
        $policy.dstaddr.name | Should -Be "all"
        $policy.action | Should -Be "accept"
        $policy.status | Should -Be "enable"
        $policy.service.name | Should -Be "All"
        $policy.schedule | Should -Be "always"
        $policy.nat | Should -Be "disable"
        $policy.logtraffic | Should -Be "utm"
        $policy.comments | Should -Be "Add via PowerFGT"
    }

    It "Add Policy $pester_policy1 (with policyid)" {
        $p = Add-FGTFirewallPolicy -name $pester_policy1 -srcintf port1 -dstintf port2 -srcaddr all -dstaddr all -policyid 23
        @($p).count | Should -Be "1"
        $policy = Get-FGTFirewallPolicy -name $pester_policy1
        $policy.name | Should -Be $pester_policy1
        $policy.uuid | Should -Not -BeNullOrEmpty
        $policy.policyid | Should -Be "23"
        $policy.srcintf.name | Should -Be "port1"
        $policy.dstintf.name | Should -Be "port2"
        $policy.srcaddr.name | Should -Be "all"
        $policy.dstaddr.name | Should -Be "all"
        $policy.action | Should -Be "accept"
        $policy.status | Should -Be "enable"
        $policy.service.name | Should -Be "All"
        $policy.schedule | Should -Be "always"
        $policy.nat | Should -Be "disable"
        $policy.logtraffic | Should -Be "utm"
        $policy.comments | Should -BeNullOrEmpty
    }

    #Disable missing API for create IP Pool
    It "Add Policy $pester_policy1 (with IP Pool)" -skip:$true {
        $p = Add-FGTFirewallPolicy -name $pester_policy1 -srcintf port1 -dstintf port2 -srcaddr all -dstaddr all -nat -ippool "MyIPPool"
        @($p).count | Should -Be "1"
        $policy = Get-FGTFirewallPolicy -name $pester_policy1
        $policy.name | Should -Be $pester_policy1
        $policy.uuid | Should -Not -BeNullOrEmpty
        $policy.srcintf.name | Should -Be "port1"
        $policy.dstintf.name | Should -Be "port2"
        $policy.srcaddr.name | Should -Be "all"
        $policy.dstaddr.name | Should -Be "all"
        $policy.action | Should -Be "accept"
        $policy.status | Should -Be "enable"
        $policy.service.name | Should -BeIn "HTTP", "HTTPS"
        $policy.schedule | Should -Be "always"
        $policy.nat | Should -Be "enable"
        $policy.logtraffic | Should -Be "disable"
        $policy.comments | Should -BeNullOrEmpty
        $policy.ippool | Should -Be "enable"
        $policy.poolname | Should -Be "MyIPPool"
    }

    It "Add Policy $pester_policy1 (with data (1 field))" {
        $data = @{ "logtraffic-start" = "enable" }
        $p = Add-FGTFirewallPolicy -name $pester_policy1 -srcintf port1 -dstintf port2 -srcaddr all -dstaddr all -data $data
        @($p).count | Should -Be "1"
        $policy = Get-FGTFirewallPolicy -name $pester_policy1
        $policy.name | Should -Be $pester_policy1
        $policy.uuid | Should -Not -BeNullOrEmpty
        $policy.srcintf.name | Should -Be "port1"
        $policy.dstintf.name | Should -Be "port2"
        $policy.srcaddr.name | Should -Be "all"
        $policy.dstaddr.name | Should -Be "all"
        $policy.action | Should -Be "accept"
        $policy.status | Should -Be "enable"
        $policy.service.name | Should -Be "All"
        $policy.schedule | Should -Be "always"
        $policy.nat | Should -Be "disable"
        $policy.logtraffic | Should -Be "utm"
        $policy.comments | Should -BeNullOrEmpty
        $policy.'logtraffic-start' | Should -Be "enable"
    }

    It "Add Policy $pester_policy1 (with data (2 fields))" {
        $data = @{ "logtraffic-start" = "enable" ; "comments" = "Add via PowerFGT and -data" }
        $p = Add-FGTFirewallPolicy -name $pester_policy1 -srcintf port1 -dstintf port2 -srcaddr all -dstaddr all -data $data
        @($p).count | Should -Be "1"
        $policy = Get-FGTFirewallPolicy -name $pester_policy1
        $policy.name | Should -Be $pester_policy1
        $policy.uuid | Should -Not -BeNullOrEmpty
        $policy.srcintf.name | Should -Be "port1"
        $policy.dstintf.name | Should -Be "port2"
        $policy.srcaddr.name | Should -Be "all"
        $policy.dstaddr.name | Should -Be "all"
        $policy.action | Should -Be "accept"
        $policy.status | Should -Be "enable"
        $policy.service.name | Should -Be "All"
        $policy.schedule | Should -Be "always"
        $policy.nat | Should -Be "disable"
        $policy.logtraffic | Should -Be "utm"
        $policy.comments | Should -Be "Add via PowerFGT and -data"
        $policy.'logtraffic-start' | Should -Be "enable"
    }

    It "Add Policy $pester_policy1 (with SSL/SSH Profile: certificate-inspection)" {
        $p = Add-FGTFirewallPolicy -name $pester_policy1 -srcintf port1 -dstintf port2 -srcaddr all -dstaddr all -sslsshprofile certificate-inspection
        @($p).count | Should -Be "1"
        $policy = Get-FGTFirewallPolicy -name $pester_policy1
        $policy.name | Should -Be $pester_policy1
        $policy.uuid | Should -Not -BeNullOrEmpty
        $policy.srcintf.name | Should -Be "port1"
        $policy.dstintf.name | Should -Be "port2"
        $policy.srcaddr.name | Should -Be "all"
        $policy.dstaddr.name | Should -Be "all"
        $policy.action | Should -Be "accept"
        $policy.status | Should -Be "enable"
        $policy.service.name | Should -Be "All"
        $policy.schedule | Should -Be "always"
        $policy.nat | Should -Be "disable"
        $policy.logtraffic | Should -Be "utm"
        $policy.comments | Should -BeNullOrEmpty
        $policy.'utm-status' | Should -Be "enable"
        $policy.'ssl-ssh-profile' | Should -Be "certificate-inspection"
    }

    It "Add Policy $pester_policy1 (with SSL/SSH Profile: deep-inspection)" {
        $p = Add-FGTFirewallPolicy -name $pester_policy1 -srcintf port1 -dstintf port2 -srcaddr all -dstaddr all -sslsshprofile deep-inspection
        @($p).count | Should -Be "1"
        $policy = Get-FGTFirewallPolicy -name $pester_policy1
        $policy.name | Should -Be $pester_policy1
        $policy.uuid | Should -Not -BeNullOrEmpty
        $policy.srcintf.name | Should -Be "port1"
        $policy.dstintf.name | Should -Be "port2"
        $policy.srcaddr.name | Should -Be "all"
        $policy.dstaddr.name | Should -Be "all"
        $policy.action | Should -Be "accept"
        $policy.status | Should -Be "enable"
        $policy.service.name | Should -Be "All"
        $policy.schedule | Should -Be "always"
        $policy.nat | Should -Be "disable"
        $policy.logtraffic | Should -Be "utm"
        $policy.comments | Should -BeNullOrEmpty
        $policy.'utm-status' | Should -Be "enable"
        $policy.'ssl-ssh-profile' | Should -Be "deep-inspection"
    }

    It "Add Policy $pester_policy1 (with AV Profile: default)" {
        $p = Add-FGTFirewallPolicy -name $pester_policy1 -srcintf port1 -dstintf port2 -srcaddr all -dstaddr all -avprofile default
        @($p).count | Should -Be "1"
        $policy = Get-FGTFirewallPolicy -name $pester_policy1
        $policy.name | Should -Be $pester_policy1
        $policy.uuid | Should -Not -BeNullOrEmpty
        $policy.srcintf.name | Should -Be "port1"
        $policy.dstintf.name | Should -Be "port2"
        $policy.srcaddr.name | Should -Be "all"
        $policy.dstaddr.name | Should -Be "all"
        $policy.action | Should -Be "accept"
        $policy.status | Should -Be "enable"
        $policy.service.name | Should -Be "all"
        $policy.schedule | Should -Be "always"
        $policy.nat | Should -Be "disable"
        $policy.logtraffic | Should -Be "utm"
        $policy.comments | Should -BeNullOrEmpty
        $policy.'utm-status' | Should -Be "enable"
        $policy.'av-profile' | Should -Be "default"
    }

    It "Add Policy $pester_policy1 (with Web Filter Profile: default)" {
        $p = Add-FGTFirewallPolicy -name $pester_policy1 -srcintf port1 -dstintf port2 -srcaddr all -dstaddr all -webfilterprofile default
        @($p).count | Should -Be "1"
        $policy = Get-FGTFirewallPolicy -name $pester_policy1
        $policy.name | Should -Be $pester_policy1
        $policy.uuid | Should -Not -BeNullOrEmpty
        $policy.srcintf.name | Should -Be "port1"
        $policy.dstintf.name | Should -Be "port2"
        $policy.srcaddr.name | Should -Be "all"
        $policy.dstaddr.name | Should -Be "all"
        $policy.action | Should -Be "accept"
        $policy.status | Should -Be "enable"
        $policy.service.name | Should -Be "all"
        $policy.schedule | Should -Be "always"
        $policy.nat | Should -Be "disable"
        $policy.logtraffic | Should -Be "utm"
        $policy.comments | Should -BeNullOrEmpty
        $policy.'utm-status' | Should -Be "enable"
        $policy.'webfilter-profile' | Should -Be "default"
    }

    It "Add Policy $pester_policy1 (with DNS Filter Profile: default)" {
        $p = Add-FGTFirewallPolicy -name $pester_policy1 -srcintf port1 -dstintf port2 -srcaddr all -dstaddr all -dnsfilterprofile default
        @($p).count | Should -Be "1"
        $policy = Get-FGTFirewallPolicy -name $pester_policy1
        $policy.name | Should -Be $pester_policy1
        $policy.uuid | Should -Not -BeNullOrEmpty
        $policy.srcintf.name | Should -Be "port1"
        $policy.dstintf.name | Should -Be "port2"
        $policy.srcaddr.name | Should -Be "all"
        $policy.dstaddr.name | Should -Be "all"
        $policy.action | Should -Be "accept"
        $policy.status | Should -Be "enable"
        $policy.service.name | Should -Be "all"
        $policy.schedule | Should -Be "always"
        $policy.nat | Should -Be "disable"
        $policy.logtraffic | Should -Be "utm"
        $policy.comments | Should -BeNullOrEmpty
        $policy.'utm-status' | Should -Be "enable"
        $policy.'dnsfilter-profile' | Should -Be "default"
    }

    It "Add Policy $pester_policy1 (with IP Sensor: default)" {
        $p = Add-FGTFirewallPolicy -name $pester_policy1 -srcintf port1 -dstintf port2 -srcaddr all -dstaddr all -ipssensor default
        @($p).count | Should -Be "1"
        $policy = Get-FGTFirewallPolicy -name $pester_policy1
        $policy.name | Should -Be $pester_policy1
        $policy.uuid | Should -Not -BeNullOrEmpty
        $policy.srcintf.name | Should -Be "port1"
        $policy.dstintf.name | Should -Be "port2"
        $policy.srcaddr.name | Should -Be "all"
        $policy.dstaddr.name | Should -Be "all"
        $policy.action | Should -Be "accept"
        $policy.status | Should -Be "enable"
        $policy.service.name | Should -Be "all"
        $policy.schedule | Should -Be "always"
        $policy.nat | Should -Be "disable"
        $policy.logtraffic | Should -Be "utm"
        $policy.comments | Should -BeNullOrEmpty
        $policy.'utm-status' | Should -Be "enable"
        $policy.'ips-sensor' | Should -Be "default"
    }

    It "Add Policy $pester_policy1 (with Application List: default)" {
        $p = Add-FGTFirewallPolicy -name $pester_policy1 -srcintf port1 -dstintf port2 -srcaddr all -dstaddr all -applicationlist default
        @($p).count | Should -Be "1"
        $policy = Get-FGTFirewallPolicy -name $pester_policy1
        $policy.name | Should -Be $pester_policy1
        $policy.uuid | Should -Not -BeNullOrEmpty
        $policy.srcintf.name | Should -Be "port1"
        $policy.dstintf.name | Should -Be "port2"
        $policy.srcaddr.name | Should -Be "all"
        $policy.dstaddr.name | Should -Be "all"
        $policy.action | Should -Be "accept"
        $policy.status | Should -Be "enable"
        $policy.service.name | Should -Be "all"
        $policy.schedule | Should -Be "always"
        $policy.nat | Should -Be "disable"
        $policy.logtraffic | Should -Be "utm"
        $policy.comments | Should -BeNullOrEmpty
        $policy.'utm-status' | Should -Be "enable"
        $policy.'application-list' | Should -Be "default"
    }

    It "Add Policy $pester_policy1 (with inspection-mode: flow)" -skip:($fgt_version -lt "6.2.0") {
        $p = Add-FGTFirewallPolicy -name $pester_policy1 -srcintf port1 -dstintf port2 -srcaddr all -dstaddr all -inspectionmode flow
        @($p).count | Should -Be "1"
        $policy = Get-FGTFirewallPolicy -name $pester_policy1
        $policy.name | Should -Be $pester_policy1
        $policy.uuid | Should -Not -BeNullOrEmpty
        $policy.srcintf.name | Should -Be "port1"
        $policy.dstintf.name | Should -Be "port2"
        $policy.srcaddr.name | Should -Be "all"
        $policy.dstaddr.name | Should -Be "all"
        $policy.action | Should -Be "accept"
        $policy.status | Should -Be "enable"
        $policy.service.name | Should -Be "all"
        $policy.schedule | Should -Be "always"
        $policy.nat | Should -Be "disable"
        $policy.logtraffic | Should -Be "utm"
        $policy.comments | Should -BeNullOrEmpty
        $policy.'inspection-mode' | Should -Be "flow"
    }

    It "Add Policy $pester_policy1 (with inspection-mode: proxy)" -skip:($fgt_version -lt "6.2.0") {
        $p = Add-FGTFirewallPolicy -name $pester_policy1 -srcintf port1 -dstintf port2 -srcaddr all -dstaddr all -inspectionmode proxy
        @($p).count | Should -Be "1"
        $policy = Get-FGTFirewallPolicy -name $pester_policy1
        $policy.name | Should -Be $pester_policy1
        $policy.uuid | Should -Not -BeNullOrEmpty
        $policy.srcintf.name | Should -Be "port1"
        $policy.dstintf.name | Should -Be "port2"
        $policy.srcaddr.name | Should -Be "all"
        $policy.dstaddr.name | Should -Be "all"
        $policy.action | Should -Be "accept"
        $policy.status | Should -Be "enable"
        $policy.service.name | Should -Be "all"
        $policy.schedule | Should -Be "always"
        $policy.nat | Should -Be "disable"
        $policy.logtraffic | Should -Be "utm"
        $policy.comments | Should -BeNullOrEmpty
        $policy.'inspection-mode' | Should -Be "proxy"
    }

    It "Try to Add Policy $pester_policy1 (but there is already a object with same name)" {
        #Add first policy
        Add-FGTFirewallPolicy -name $pester_policy1 -srcintf port1 -dstintf port2 -srcaddr all -dstaddr all
        #Add Second policy with same name
        { Add-FGTFirewallPolicy -name $pester_policy1 -srcintf port1 -dstintf port2 -srcaddr all -dstaddr all } | Should -Throw "Already a Policy using the same name"
    }

    It "Try to Add Policy without name (unnamed policy)" {
        #TODO: Add check where unnamed policy is allowed (need cmdlet for modified System Settings)
        { Add-FGTFirewallPolicy -srcintf port1 -dstintf port2 -srcaddr all -dstaddr all } | Should -Throw "You need to specifiy a name"
    }

    Context "Unnamed Policy" {

        BeforeAll {
            #Change settings for enable unnamed policy
            Set-FGTSystemSettings -gui_allow_unnamed_policy
        }

        AfterEach {
            Get-FGTFirewallPolicy -policyid 23 | Remove-FGTFirewallPolicy -confirm:$false
        }

        It "Add unnamed Policy" {
            $p = Add-FGTFirewallPolicy -srcintf port1 -dstintf port2 -srcaddr all -dstaddr all -policyid 23
            @($p).count | Should -Be "1"
            $policy = Get-FGTFirewallPolicy -policyid 23
            $policy.name | Should -Be ""
            $policy.uuid | Should -Not -BeNullOrEmpty
            $policy.srcintf.name | Should -Be "port1"
            $policy.dstintf.name | Should -Be "port2"
            $policy.srcaddr.name | Should -Be "all"
            $policy.dstaddr.name | Should -Be "all"
            $policy.action | Should -Be "accept"
            $policy.status | Should -Be "enable"
            $policy.service.name | Should -Be "all"
            $policy.schedule | Should -Be "always"
            $policy.nat | Should -Be "disable"
            $policy.logtraffic | Should -Be "utm"
            $policy.comments | Should -BeNullOrEmpty
            $policy.ippool | Should -Be "disable"
            $policy.comments | Should -BeNullOrEmpty
        }

        AfterAll {
            #Reverse settings for enable unnamed policy
            Set-FGTSystemSettings -gui_allow_unnamed_policy:$false
        }
    }

    AfterAll {
        Get-FGTFirewallPolicy -name $pester_policy2 | Remove-FGTFirewallPolicy -confirm:$false
    }
}

Describe "Add Firewall Policy Member" {

    BeforeAll {
        #Create some Address object
        Add-FGTFirewallAddress -Name $pester_address1 -ip 192.0.2.1 -mask 255.255.255.255
        Add-FGTFirewallAddress -Name $pester_address2 -ip 192.0.2.2 -mask 255.255.255.255
        Add-FGTFirewallAddress -Name $pester_address3 -ip 192.0.2.3 -mask 255.255.255.255
        Add-FGTFirewallAddress -Name $pester_address4 -ip 192.0.2.4 -mask 255.255.255.255
    }

    AfterEach {
        Get-FGTFirewallPolicy -name $pester_policy1 | Remove-FGTFirewallPolicy -confirm:$false
    }

    Context "Add Member(s) to Source Address" {

        It "Add 1 member to Policy Src Address $pester_address1 (with All before)" {
            $p = Add-FGTFirewallPolicy -name $pester_policy1 -srcintf port1 -dstintf port2 -srcaddr all -dstaddr all
            @($p).count | Should -Be "1"
            Get-FGTFirewallPolicy -Name $pester_policy1 | Add-FGTFirewallPolicyMember -srcaddr $pester_address1
            $policy = Get-FGTFirewallPolicy -name $pester_policy1
            $policy.name | Should -Be $pester_policy1
            $policy.uuid | Should -Not -BeNullOrEmpty
            $policy.srcintf.name | Should -BeIn "port1"
            $policy.dstintf.name | Should -Be "port2"
            $policy.srcaddr.name | Should -Be $pester_address1
            $policy.dstaddr.name | Should -Be "all"
            $policy.action | Should -Be "accept"
            $policy.status | Should -Be "enable"
            $policy.service.name | Should -Be "all"
            $policy.schedule | Should -Be "always"
            $policy.nat | Should -Be "disable"
            $policy.logtraffic | Should -Be "utm"
            $policy.comments | Should -BeNullOrEmpty
        }

        It "Add 2 members to Policy Src Address $pester_address1, $pester_address3 (with All before)" {
            $p = Add-FGTFirewallPolicy -name $pester_policy1 -srcintf port1 -dstintf port2 -srcaddr all -dstaddr all
            @($p).count | Should -Be "1"
            Get-FGTFirewallPolicy -Name $pester_policy1 | Add-FGTFirewallPolicyMember -srcaddr $pester_address1, $pester_address3
            $policy = Get-FGTFirewallPolicy -name $pester_policy1
            $policy.name | Should -Be $pester_policy1
            $policy.uuid | Should -Not -BeNullOrEmpty
            $policy.srcintf.name | Should -BeIn "port1"
            $policy.dstintf.name | Should -Be "port2"
            ($policy.srcaddr.name).count | Should -Be "2"
            $policy.srcaddr.name | Should -Be $pester_address1, $pester_address3
            $policy.dstaddr.name | Should -Be "all"
            $policy.action | Should -Be "accept"
            $policy.status | Should -Be "enable"
            $policy.service.name | Should -Be "all"
            $policy.schedule | Should -Be "always"
            $policy.nat | Should -Be "disable"
            $policy.logtraffic | Should -Be "utm"
            $policy.comments | Should -BeNullOrEmpty
        }

        It "Add 1 member to Policy Src Address $pester_address3 (with $pester_address1 before)" {
            $p = Add-FGTFirewallPolicy -name $pester_policy1 -srcintf port1 -dstintf port2 -srcaddr $pester_address1 -dstaddr all
            @($p).count | Should -Be "1"
            Get-FGTFirewallPolicy -Name $pester_policy1 | Add-FGTFirewallPolicyMember -srcaddr $pester_address3
            $policy = Get-FGTFirewallPolicy -name $pester_policy1
            $policy.name | Should -Be $pester_policy1
            $policy.uuid | Should -Not -BeNullOrEmpty
            $policy.srcintf.name | Should -BeIn "port1"
            $policy.dstintf.name | Should -Be "port2"
            ($policy.srcaddr.name).count | Should -Be "2"
            $policy.srcaddr.name | Should -Be $pester_address1, $pester_address3
            $policy.dstaddr.name | Should -Be "all"
            $policy.action | Should -Be "accept"
            $policy.status | Should -Be "enable"
            $policy.service.name | Should -Be "all"
            $policy.schedule | Should -Be "always"
            $policy.nat | Should -Be "disable"
            $policy.logtraffic | Should -Be "utm"
            $policy.comments | Should -BeNullOrEmpty
        }

    }

    Context "Add Member(s) to Destination Address" {

        It "Add 1 member to Policy Dst Address $pester_address2 (with All before)" {
            $p = Add-FGTFirewallPolicy -name $pester_policy1 -srcintf port1 -dstintf port2 -srcaddr all -dstaddr all
            @($p).count | Should -Be "1"
            Get-FGTFirewallPolicy -Name $pester_policy1 | Add-FGTFirewallPolicyMember -dstaddr $pester_address2
            $policy = Get-FGTFirewallPolicy -name $pester_policy1
            $policy.name | Should -Be $pester_policy1
            $policy.uuid | Should -Not -BeNullOrEmpty
            $policy.srcintf.name | Should -BeIn "port1"
            $policy.dstintf.name | Should -Be "port2"
            $policy.srcaddr.name | Should -Be "all"
            $policy.dstaddr.name | Should -Be "$pester_address2"
            $policy.action | Should -Be "accept"
            $policy.status | Should -Be "enable"
            $policy.service.name | Should -Be "all"
            $policy.schedule | Should -Be "always"
            $policy.nat | Should -Be "disable"
            $policy.logtraffic | Should -Be "utm"
            $policy.comments | Should -BeNullOrEmpty
        }

        It "Add 2 members to Policy Dst Address $pester_address2, $pester_address4 (with All before)" {
            $p = Add-FGTFirewallPolicy -name $pester_policy1 -srcintf port1 -dstintf port2 -srcaddr all -dstaddr all
            @($p).count | Should -Be "1"
            Get-FGTFirewallPolicy -Name $pester_policy1 | Add-FGTFirewallPolicyMember -dstaddr $pester_address2, $pester_address4
            $policy = Get-FGTFirewallPolicy -name $pester_policy1
            $policy.name | Should -Be $pester_policy1
            $policy.uuid | Should -Not -BeNullOrEmpty
            $policy.srcintf.name | Should -BeIn "port1"
            $policy.dstintf.name | Should -Be "port2"
            $policy.srcaddr.name | Should -Be "all"
            ($policy.dstaddr.name).count | Should -Be "2"
            $policy.dstaddr.name | Should -BeIn $pester_address2, $pester_address4
            $policy.action | Should -Be "accept"
            $policy.status | Should -Be "enable"
            $policy.service.name | Should -Be "all"
            $policy.schedule | Should -Be "always"
            $policy.nat | Should -Be "disable"
            $policy.logtraffic | Should -Be "utm"
            $policy.comments | Should -BeNullOrEmpty
        }

        It "Add 1 member to Policy Dst Address $pester_address4 (with $pester_address2 before)" {
            $p = Add-FGTFirewallPolicy -name $pester_policy1 -srcintf port1 -dstintf port2 -srcaddr all -dstaddr $pester_address2
            @($p).count | Should -Be "1"
            Get-FGTFirewallPolicy -Name $pester_policy1 | Add-FGTFirewallPolicyMember -dstaddr $pester_address4
            $policy = Get-FGTFirewallPolicy -name $pester_policy1
            $policy.name | Should -Be $pester_policy1
            $policy.uuid | Should -Not -BeNullOrEmpty
            $policy.srcintf.name | Should -BeIn "port1"
            $policy.dstintf.name | Should -Be "port2"
            $policy.srcaddr.name | Should -Be "all"
            ($policy.dstaddr.name).count | Should -Be "2"
            $policy.dstaddr.name | Should -BeIn $pester_address2, $pester_address4
            $policy.action | Should -Be "accept"
            $policy.status | Should -Be "enable"
            $policy.service.name | Should -Be "all"
            $policy.schedule | Should -Be "always"
            $policy.nat | Should -Be "disable"
            $policy.logtraffic | Should -Be "utm"
            $policy.comments | Should -BeNullOrEmpty
        }
    }

    Context "Add Member(s) to Source and Destination Address" {

        It "Add 1 member to Policy src Address $pester_address1 dst Address $pester_address2 (with All before)" {
            $p = Add-FGTFirewallPolicy -name $pester_policy1 -srcintf port1 -dstintf port2 -srcaddr all -dstaddr all
            @($p).count | Should -Be "1"
            Get-FGTFirewallPolicy -Name $pester_policy1 | Add-FGTFirewallPolicyMember -srcaddr $pester_address1 -dstaddr $pester_address2
            $policy = Get-FGTFirewallPolicy -name $pester_policy1
            $policy.name | Should -Be $pester_policy1
            $policy.uuid | Should -Not -BeNullOrEmpty
            $policy.srcintf.name | Should -BeIn "port1"
            $policy.dstintf.name | Should -Be "port2"
            $policy.srcaddr.name | Should -Be "$pester_address1"
            $policy.dstaddr.name | Should -Be "$pester_address2"
            $policy.action | Should -Be "accept"
            $policy.status | Should -Be "enable"
            $policy.service.name | Should -Be "all"
            $policy.schedule | Should -Be "always"
            $policy.nat | Should -Be "disable"
            $policy.logtraffic | Should -Be "utm"
            $policy.comments | Should -BeNullOrEmpty
        }

        It "Add 2 members to Policy Src Address $pester_address1, $pester_address3 and Dst Address $pester_address2, $pester_address4 (with All before)" {
            $p = Add-FGTFirewallPolicy -name $pester_policy1 -srcintf port1 -dstintf port2 -srcaddr all -dstaddr all
            @($p).count | Should -Be "1"
            Get-FGTFirewallPolicy -Name $pester_policy1 | Add-FGTFirewallPolicyMember -srcaddr $pester_address1, $pester_address3 -dstaddr $pester_address2, $pester_address4
            $policy = Get-FGTFirewallPolicy -name $pester_policy1
            $policy.name | Should -Be $pester_policy1
            $policy.uuid | Should -Not -BeNullOrEmpty
            $policy.srcintf.name | Should -BeIn "port1"
            $policy.dstintf.name | Should -Be "port2"
            ($policy.srcaddr.name).count | Should -Be "2"
            $policy.srcaddr.name | Should -BeIn $pester_address1, $pester_address3
            ($policy.dstaddr.name).count | Should -Be "2"
            $policy.dstaddr.name | Should -BeIn $pester_address2, $pester_address4
            $policy.action | Should -Be "accept"
            $policy.status | Should -Be "enable"
            $policy.service.name | Should -Be "all"
            $policy.schedule | Should -Be "always"
            $policy.nat | Should -Be "disable"
            $policy.logtraffic | Should -Be "utm"
            $policy.comments | Should -BeNullOrEmpty
        }

        It "Add 1 members to Policy Src Address $pester_address3 and Dst Address $pester_address4 (with $pester_address1/$pester_address2 before)" {
            $p = Add-FGTFirewallPolicy -name $pester_policy1 -srcintf port1 -dstintf port2 -srcaddr $pester_address1 -dstaddr $pester_address2
            @($p).count | Should -Be "1"
            Get-FGTFirewallPolicy -Name $pester_policy1 | Add-FGTFirewallPolicyMember -srcaddr $pester_address3 -dstaddr $pester_address4
            $policy = Get-FGTFirewallPolicy -name $pester_policy1
            $policy.name | Should -Be $pester_policy1
            $policy.uuid | Should -Not -BeNullOrEmpty
            $policy.srcintf.name | Should -BeIn "port1"
            $policy.dstintf.name | Should -Be "port2"
            ($policy.srcaddr.name).count | Should -Be "2"
            $policy.srcaddr.name | Should -BeIn $pester_address1, $pester_address3
            ($policy.dstaddr.name).count | Should -Be "2"
            $policy.dstaddr.name | Should -BeIn $pester_address2, $pester_address4
            $policy.action | Should -Be "accept"
            $policy.status | Should -Be "enable"
            $policy.service.name | Should -Be "all"
            $policy.schedule | Should -Be "always"
            $policy.nat | Should -Be "disable"
            $policy.logtraffic | Should -Be "utm"
            $policy.comments | Should -BeNullOrEmpty
        }
    }

    Context "Add Member(s) to Source Interface" {

        It "Add 1 member to Policy Src Interface $pester_port1 (with any before)" {
            $p = Add-FGTFirewallPolicy -name $pester_policy1 -srcintf any -dstintf $pester_port2 -srcaddr all -dstaddr all
            @($p).count | Should -Be "1"
            Get-FGTFirewallPolicy -Name $pester_policy1 | Add-FGTFirewallPolicyMember -srcintf $pester_port1
            $policy = Get-FGTFirewallPolicy -name $pester_policy1
            $policy.name | Should -Be $pester_policy1
            $policy.uuid | Should -Not -BeNullOrEmpty
            $policy.srcintf.name | Should -Be $pester_port1
            $policy.dstintf.name | Should -Be $pester_port2
            ($policy.srcintf.name).count | Should -Be "1"
            $policy.srcaddr.name | Should -Be "all"
            $policy.dstaddr.name | Should -Be "all"
            $policy.action | Should -Be "accept"
            $policy.status | Should -Be "enable"x
            $policy.service.name | Should -Be "all"
            $policy.schedule | Should -Be "always"
            $policy.nat | Should -Be "disable"
            $policy.logtraffic | Should -Be "utm"
            $policy.comments | Should -BeNullOrEmpty
        }

        It "Add 2 members to Policy Src Interface $pester_port1, $pester_port3 (with any before)" {
            $p = Add-FGTFirewallPolicy -name $pester_policy1 -srcintf any -dstintf $pester_port2 -srcaddr all -dstaddr all
            @($p).count | Should -Be "1"
            Get-FGTFirewallPolicy -Name $pester_policy1 | Add-FGTFirewallPolicyMember -srcintf $pester_port3, $pester_port4
            $policy = Get-FGTFirewallPolicy -name $pester_policy1
            $policy.name | Should -Be $pester_policy1
            $policy.uuid | Should -Not -BeNullOrEmpty
            $policy.srcintf.name | Should -Be $pester_port3, $pester_port4
            $policy.dstintf.name | Should -Be $pester_port2
            ($policy.srcintf.name).count | Should -Be "2"
            $policy.srcaddr.name | Should -Be "all"
            $policy.dstaddr.name | Should -Be "all"
            $policy.action | Should -Be "accept"
            $policy.status | Should -Be "enable"x
            $policy.service.name | Should -Be "all"
            $policy.schedule | Should -Be "always"
            $policy.nat | Should -Be "disable"
            $policy.logtraffic | Should -Be "utm"
            $policy.comments | Should -BeNullOrEmpty
        }

        It "Add 1 member to Policy Src Interface $pester_port3 (with $pester_port1 before)" {
            $p = Add-FGTFirewallPolicy -name $pester_policy1 -srcintf $pester_port1 -dstintf $pester_port2 -srcaddr all -dstaddr all
            @($p).count | Should -Be "1"
            Get-FGTFirewallPolicy -Name $pester_policy1 | Add-FGTFirewallPolicyMember -srcintf $pester_port3
            $policy = Get-FGTFirewallPolicy -name $pester_policy1
            $policy.name | Should -Be $pester_policy1
            $policy.uuid | Should -Not -BeNullOrEmpty
            $policy.srcintf.name | Should -Be $pester_port1, $pester_port3
            $policy.dstintf.name | Should -Be $pester_port2
            ($policy.srcintf.name).count | Should -Be "2"
            $policy.srcaddr.name | Should -Be "all"
            $policy.dstaddr.name | Should -Be "all"
            $policy.action | Should -Be "accept"
            $policy.status | Should -Be "enable"x
            $policy.service.name | Should -Be "all"
            $policy.schedule | Should -Be "always"
            $policy.nat | Should -Be "disable"
            $policy.logtraffic | Should -Be "utm"
            $policy.comments | Should -BeNullOrEmpty
        }

    }

    Context "Add Member(s) to Destination Interface" {

        It "Add 1 member to Policy Dst Interface $pester_port2 (with any before)" {
            $p = Add-FGTFirewallPolicy -name $pester_policy1 -srcintf $pester_port1 -dstintf any -srcaddr all -dstaddr all
            @($p).count | Should -Be "1"
            Get-FGTFirewallPolicy -Name $pester_policy1 | Add-FGTFirewallPolicyMember -dstintf $pester_port2
            $policy = Get-FGTFirewallPolicy -name $pester_policy1
            $policy.name | Should -Be $pester_policy1
            $policy.uuid | Should -Not -BeNullOrEmpty
            $policy.srcintf.name | Should -Be $pester_port1
            $policy.dstintf.name | Should -Be $pester_port2
            ($policy.dstintf.name).count | Should -Be "1"
            $policy.srcaddr.name | Should -Be "all"
            $policy.dstaddr.name | Should -Be "all"
            $policy.action | Should -Be "accept"
            $policy.status | Should -Be "enable"
            $policy.service.name | Should -Be "all"
            $policy.schedule | Should -Be "always"
            $policy.nat | Should -Be "disable"
            $policy.logtraffic | Should -Be "utm"
            $policy.comments | Should -BeNullOrEmpty
        }

        It "Add 2 members to Policy Dst Interface $pester_port2, $pester_port4 (with any before)" {
            $p = Add-FGTFirewallPolicy -name $pester_policy1 -srcintf $pester_port1 -dstintf any -srcaddr all -dstaddr all
            @($p).count | Should -Be "1"
            Get-FGTFirewallPolicy -Name $pester_policy1 | Add-FGTFirewallPolicyMember -dstintf $pester_port2, $pester_port4
            $policy = Get-FGTFirewallPolicy -name $pester_policy1
            $policy.name | Should -Be $pester_policy1
            $policy.uuid | Should -Not -BeNullOrEmpty
            $policy.srcintf.name | Should -Be $pester_port1
            $policy.dstintf.name | Should -BeIn $pester_port2, $pester_port4
            ($policy.dstintf.name).count | Should -Be "2"
            $policy.srcaddr.name | Should -Be "all"
            $policy.dstaddr.name | Should -Be "all"
            $policy.action | Should -Be "accept"
            $policy.status | Should -Be "enable"
            $policy.service.name | Should -Be "all"
            $policy.schedule | Should -Be "always"
            $policy.nat | Should -Be "disable"
            $policy.logtraffic | Should -Be "utm"
            $policy.comments | Should -BeNullOrEmpty
        }

        It "Add 1 member to Policy Dst Interface $pester_port4 (with $pester_port2 before)" {
            $p = Add-FGTFirewallPolicy -name $pester_policy1 -srcintf $pester_port1 -dstintf $pester_port2 -srcaddr all -dstaddr all
            @($p).count | Should -Be "1"
            Get-FGTFirewallPolicy -Name $pester_policy1 | Add-FGTFirewallPolicyMember -dstintf $pester_port4
            $policy = Get-FGTFirewallPolicy -name $pester_policy1
            $policy.name | Should -Be $pester_policy1
            $policy.uuid | Should -Not -BeNullOrEmpty
            $policy.srcintf.name | Should -Be $pester_port1
            $policy.dstintf.name | Should -Be $pester_port2, $pester_port4
            ($policy.dstintf.name).count | Should -Be "2"
            $policy.srcaddr.name | Should -Be "all"
            $policy.dstaddr.name | Should -Be "all"
            $policy.action | Should -Be "accept"
            $policy.status | Should -Be "enable"
            $policy.service.name | Should -Be "all"
            $policy.schedule | Should -Be "always"
            $policy.nat | Should -Be "disable"
            $policy.logtraffic | Should -Be "utm"
            $policy.comments | Should -BeNullOrEmpty
        }

    }

    AfterAll {
        Get-FGTFirewallAddress -name $pester_address1 | Remove-FGTFirewallAddress -confirm:$false
        Get-FGTFirewallAddress -name $pester_address2 | Remove-FGTFirewallAddress -confirm:$false
        Get-FGTFirewallAddress -name $pester_address3 | Remove-FGTFirewallAddress -confirm:$false
        Get-FGTFirewallAddress -name $pester_address4 | Remove-FGTFirewallAddress -confirm:$false
    }

}

Describe "Move Firewall Policy" {

    BeforeEach {
        $p1 = Add-FGTFirewallPolicy -name $pester_policy1 -srcintf port1 -dstintf port2 -srcaddr all -dstaddr all -service SSH
        $script:policyid1 = [int]$p1.policyid
        $p2 = Add-FGTFirewallPolicy -name $pester_policy2 -srcintf port1 -dstintf port2 -srcaddr all -dstaddr all -service HTTP
        $script:policyid2 = [int]$p2.policyid
        $p3 = Add-FGTFirewallPolicy -name $pester_policy3 -srcintf port1 -dstintf port2 -srcaddr all -dstaddr all -service HTTPS
        $script:policyid3 = [int]$p3.policyid
    }

    AfterEach {
        Get-FGTFirewallPolicy -name $pester_policy1 | Remove-FGTFirewallPolicy -confirm:$false
        Get-FGTFirewallPolicy -name $pester_policy2 | Remove-FGTFirewallPolicy -confirm:$false
        Get-FGTFirewallPolicy -name $pester_policy3 | Remove-FGTFirewallPolicy -confirm:$false
    }

    Context "Move Policy Using id" {

        It "Move Policy SSH after HTTPS (using id)" {
            Get-FGTFirewallPolicy -name $pester_policy1 | Move-FGTFirewallPolicy -after -id $policyid3
            $policy = Get-FGTFirewallPolicy
            $policy[0].name | Should -Be $pester_policy2
            $policy[1].name | Should -Be $pester_policy3
            $policy[2].name | Should -Be $pester_policy1
        }

        It "Move Policy HTTPS before SSH (using id)" {
            Get-FGTFirewallPolicy -name $pester_policy3 | Move-FGTFirewallPolicy -before -id $policyid1
            $policy = Get-FGTFirewallPolicy
            $policy[0].name | Should -Be $pester_policy3
            $policy[1].name | Should -Be $pester_policy1
            $policy[2].name | Should -Be $pester_policy2
        }
    }

    Context "Move Policy Using Firewall Policy Object" {

        It "Move Policy SSH after HTTPS (using Firewall Policy Object)" {
            Get-FGTFirewallPolicy -name $pester_policy1 | Move-FGTFirewallPolicy -after -id (Get-FGTFirewallPolicy -name $pester_policy3)
            $policy = Get-FGTFirewallPolicy
            $policy[0].name | Should -Be $pester_policy2
            $policy[1].name | Should -Be $pester_policy3
            $policy[2].name | Should -Be $pester_policy1
        }

        It "Move Policy HTTPS before SSH (using Firewall Policy Object)" {
            Get-FGTFirewallPolicy -name $pester_policy3 | Move-FGTFirewallPolicy -before -id (Get-FGTFirewallPolicy -name $pester_policy1)
            $policy = Get-FGTFirewallPolicy
            $policy[0].name | Should -Be $pester_policy3
            $policy[1].name | Should -Be $pester_policy1
            $policy[2].name | Should -Be $pester_policy2
        }
    }
}

Describe "Configure Firewall Policy" {

    BeforeAll {
        $policy = Add-FGTFirewallPolicy -name $pester_policy1 -srcintf port1 -dstintf port2 -srcaddr all -dstaddr all
        $script:uuid = $policy.uuid
    }

    Context "Multi Source / Destination Interface" {

        It "Set Policy $pester_policy1 (src intf: port1, port3)" {
            $p = Get-FGTFirewallPolicy -name $pester_policy1 | Set-FGTFirewallPolicy -srcintf port1, port3
            @($p).count | Should -Be "1"
            $policy = Get-FGTFirewallPolicy -name $pester_policy1
            $policy.name | Should -Be $pester_policy1
            $policy.uuid | Should -Not -BeNullOrEmpty
            ($policy.srcintf.name).count | Should -be "2"
            $policy.srcintf.name | Should -BeIn "port1", "port3"
        }

        It "Set Policy $pester_policy1 (dst intf: port2, port4)" {
            $p = Get-FGTFirewallPolicy -name $pester_policy1 | Set-FGTFirewallPolicy -dstintf port2, port4
            @($p).count | Should -Be "1"
            $policy = Get-FGTFirewallPolicy -name $pester_policy1
            $policy.name | Should -Be $pester_policy1
            $policy.uuid | Should -Not -BeNullOrEmpty
            ($policy.dstintf.name).count | Should -be "2"
            $policy.dstintf.name | Should -BeIn "port2", "port4"
        }

        It "Set Policy $pester_policy1 (src intf: port3 and dst intf: port4)" {
            $p = Get-FGTFirewallPolicy -name $pester_policy1 | Set-FGTFirewallPolicy -srcintf port3 -dstintf port4
            @($p).count | Should -Be "1"
            $policy = Get-FGTFirewallPolicy -name $pester_policy1
            $policy.name | Should -Be $pester_policy1
            $policy.uuid | Should -Not -BeNullOrEmpty
            ($policy.srcintf.name).count | Should -be "1"
            $policy.srcintf.name | Should -BeIn "port3"
            ($policy.dstintf.name).count | Should -be "1"
            $policy.dstintf.name | Should -BeIn "port4"
        }

    }

    Context "Multi Source / Destination address" {

        BeforeAll {
            Add-FGTFirewallAddress -Name $pester_address1 -ip 192.0.2.1 -mask 255.255.255.255
            Add-FGTFirewallAddress -Name $pester_address2 -ip 192.0.2.2 -mask 255.255.255.255
            Add-FGTFirewallAddress -Name $pester_address3 -ip 192.0.2.3 -mask 255.255.255.255
            Add-FGTFirewallAddress -Name $pester_address4 -ip 192.0.2.4 -mask 255.255.255.255
        }

        It "Set Policy $pester_policy1 (src addr: $pester_address1)" {
            $p = Get-FGTFirewallPolicy -name $pester_policy1 | Set-FGTFirewallPolicy -srcaddr $pester_address1
            @($p).count | Should -Be "1"
            $policy = Get-FGTFirewallPolicy -name $pester_policy1
            $policy.name | Should -Be $pester_policy1
            $policy.uuid | Should -Not -BeNullOrEmpty
            $policy.srcaddr.name | Should -Be $pester_address1
        }

        It "Set Policy $pester_policy1 (src addr: $pester_address1, $pester_address3)" {
            $p = Get-FGTFirewallPolicy -name $pester_policy1 | Set-FGTFirewallPolicy -srcaddr $pester_address1, $pester_address3
            @($p).count | Should -Be "1"
            $policy = Get-FGTFirewallPolicy -name $pester_policy1
            $policy.name | Should -Be $pester_policy1
            $policy.uuid | Should -Not -BeNullOrEmpty
            ($policy.srcaddr.name).count | Should -Be "2"
            $policy.srcaddr.name | Should -BeIn $pester_address1, $pester_address3
        }

        It "Set Policy $pester_policy1 (dst addr: $pester_address2)" {
            $p = Get-FGTFirewallPolicy -name $pester_policy1 | Set-FGTFirewallPolicy -dstaddr $pester_address2
            @($p).count | Should -Be "1"
            $policy = Get-FGTFirewallPolicy -name $pester_policy1
            $policy.name | Should -Be $pester_policy1
            $policy.uuid | Should -Not -BeNullOrEmpty
            $policy.dstaddr.name | Should -Be $pester_address2
        }

        It "Set Policy $pester_policy1 (dst addr: $pester_address2, $pester_address4)" {
            $p = Get-FGTFirewallPolicy -name $pester_policy1 | Set-FGTFirewallPolicy -dstaddr $pester_address2, $pester_address4
            @($p).count | Should -Be "1"
            $policy = Get-FGTFirewallPolicy -name $pester_policy1
            $policy.name | Should -Be $pester_policy1
            $policy.uuid | Should -Not -BeNullOrEmpty
            ($policy.dstaddr.name).count | Should -Be "2"
            $policy.dstaddr.name | Should -BeIn $pester_address2, $pester_address4
        }

        It "Set Policy $pester_policy1 (src addr: all and dst addr: all)" {
            $p = Get-FGTFirewallPolicy -name $pester_policy1 | Set-FGTFirewallPolicy -srcaddr all -dstaddr all
            @($p).count | Should -Be "1"
            $policy = Get-FGTFirewallPolicy -name $pester_policy1
            $policy.name | Should -Be $pester_policy1
            $policy.uuid | Should -Not -BeNullOrEmpty
            ($policy.srcaddr.name).count | Should -Be "1"
            $policy.srcaddr.name | Should -Be "all"
            ($policy.dstaddr.name).count | Should -Be "1"
            $policy.dstaddr.name | Should -Be "all"
        }

        AfterAll {
            Get-FGTFirewallAddress -name $pester_address1 | Remove-FGTFirewallAddress -confirm:$false
            Get-FGTFirewallAddress -name $pester_address2 | Remove-FGTFirewallAddress -confirm:$false
            Get-FGTFirewallAddress -name $pester_address3 | Remove-FGTFirewallAddress -confirm:$false
            Get-FGTFirewallAddress -name $pester_address4 | Remove-FGTFirewallAddress -confirm:$false
        }

    }

    It "Set Policy $pester_policy1 with nat" {
        $p = Get-FGTFirewallPolicy -name $pester_policy1 | Set-FGTFirewallPolicy -nat
        @($p).count | Should -Be "1"
        $policy = Get-FGTFirewallPolicy -name $pester_policy1
        $policy.name | Should -Be $pester_policy1
        $policy.uuid | Should -Not -BeNullOrEmpty
        $policy.nat | Should -Be "enable"
    }

    It "Set Policy $pester_policy1 without nat" {
        $p = Get-FGTFirewallPolicy -name $pester_policy1 | Set-FGTFirewallPolicy -nat:$false
        @($p).count | Should -Be "1"
        $policy = Get-FGTFirewallPolicy -name $pester_policy1
        $policy.name | Should -Be $pester_policy1
        $policy.uuid | Should -Not -BeNullOrEmpty
        $policy.nat | Should -Be "disable"
    }

    It "Set Policy $pester_policy1 (with action deny)" {
        $p = Get-FGTFirewallPolicy -name $pester_policy1 | Set-FGTFirewallPolicy -action deny
        @($p).count | Should -Be "1"
        $policy = Get-FGTFirewallPolicy -name $pester_policy1
        $policy.name | Should -Be $pester_policy1
        $policy.uuid | Should -Not -BeNullOrEmpty
        $policy.action | Should -Be "deny"
    }

    It "Set Policy $pester_policy1 (with action accept)" {
        $p = Get-FGTFirewallPolicy -name $pester_policy1 | Set-FGTFirewallPolicy -action accept
        @($p).count | Should -Be "1"
        $policy = Get-FGTFirewallPolicy -name $pester_policy1
        $policy.name | Should -Be $pester_policy1
        $policy.uuid | Should -Not -BeNullOrEmpty
        $policy.action | Should -Be "accept"
    }

    It "Set Policy $pester_policy1 (with action deny and log)" {
        $p = Get-FGTFirewallPolicy -name $pester_policy1 | Set-FGTFirewallPolicy -action deny -logtraffic all
        @($p).count | Should -Be "1"
        $policy = Get-FGTFirewallPolicy -name $pester_policy1
        $policy.name | Should -Be $pester_policy1
        $policy.uuid | Should -Not -BeNullOrEmpty
        $policy.action | Should -Be "deny"
        $policy.logtraffic | Should -Be "all"
    }

    It "Set Policy $pester_policy1 (with action accept and logtraffic disable)" {
        $p = Get-FGTFirewallPolicy -name $pester_policy1 | Set-FGTFirewallPolicy -action accept -logtraffic disable
        @($p).count | Should -Be "1"
        $policy = Get-FGTFirewallPolicy -name $pester_policy1
        $policy.name | Should -Be $pester_policy1
        $policy.uuid | Should -Not -BeNullOrEmpty
        $policy.action | Should -Be "accept"
        $policy.logtraffic | Should -Be "disable"
    }

    It "Set Policy $pester_policy1 (with logtraffic all)" {
        $p = Get-FGTFirewallPolicy -name $pester_policy1 | Set-FGTFirewallPolicy -logtraffic all
        @($p).count | Should -Be "1"
        $policy = Get-FGTFirewallPolicy -name $pester_policy1
        $policy.name | Should -Be $pester_policy1
        $policy.uuid | Should -Not -BeNullOrEmpty
        $policy.logtraffic | Should -Be "all"
    }

    It "Set Policy $pester_policy1 (with logtraffic utm)" {
        $p = Get-FGTFirewallPolicy -name $pester_policy1 | Set-FGTFirewallPolicy -logtraffic utm
        @($p).count | Should -Be "1"
        $policy = Get-FGTFirewallPolicy -name $pester_policy1
        $policy.name | Should -Be $pester_policy1
        $policy.uuid | Should -Not -BeNullOrEmpty
        $policy.logtraffic | Should -Be "utm"
    }

    It "Set Policy $pester_policy1 (status disable)" {
        $p = Get-FGTFirewallPolicy -name $pester_policy1 | Set-FGTFirewallPolicy -status:$false
        @($p).count | Should -Be "1"
        $policy = Get-FGTFirewallPolicy -name $pester_policy1
        $policy.name | Should -Be $pester_policy1
        $policy.uuid | Should -Not -BeNullOrEmpty
        $policy.status | Should -Be "disable"
    }

    It "Set Policy $pester_policy1 (status enable)" {
        $p = Get-FGTFirewallPolicy -name $pester_policy1 | Set-FGTFirewallPolicy -status
        @($p).count | Should -Be "1"
        $policy = Get-FGTFirewallPolicy -name $pester_policy1
        $policy.name | Should -Be $pester_policy1
        $policy.uuid | Should -Not -BeNullOrEmpty
        $policy.status | Should -Be "enable"
    }

    It "Set Policy $pester_policy1 (with 1 service : HTTP)" {
        $p = Get-FGTFirewallPolicy -name $pester_policy1 | Set-FGTFirewallPolicy -service HTTP
        @($p).count | Should -Be "1"
        $policy = Get-FGTFirewallPolicy -name $pester_policy1
        $policy.name | Should -Be $pester_policy1
        $policy.uuid | Should -Not -BeNullOrEmpty
        $policy.service.name | Should -Be "HTTP"
    }

    It "Set Policy $pester_policy1 (with 2 services : SSH, HTTPS)" {
        $p = Get-FGTFirewallPolicy -name $pester_policy1 | Set-FGTFirewallPolicy -service SSH, HTTPS
        @($p).count | Should -Be "1"
        $policy = Get-FGTFirewallPolicy -name $pester_policy1
        $policy.name | Should -Be $pester_policy1
        $policy.uuid | Should -Not -BeNullOrEmpty
        $policy.service.name | Should -BeIn "SSH", "HTTPS"
    }

    It "Set Policy $pester_policy1 (with 1 service : ALL))" {
        $p = Get-FGTFirewallPolicy -name $pester_policy1 | Set-FGTFirewallPolicy -service ALL
        @($p).count | Should -Be "1"
        $policy = Get-FGTFirewallPolicy -name $pester_policy1
        $policy.name | Should -Be $pester_policy1
        $policy.uuid | Should -Not -BeNullOrEmpty
        $policy.service.name | Should -Be "all"
    }

    #Add Schedule ? need API
    It "Set Policy $pester_policy1 (with schedule none)" {
        $p = Get-FGTFirewallPolicy -name $pester_policy1 | Set-FGTFirewallPolicy -schedule none
        @($p).count | Should -Be "1"
        $policy = Get-FGTFirewallPolicy -name $pester_policy1
        $policy.name | Should -Be $pester_policy1
        $policy.uuid | Should -Not -BeNullOrEmpty
        $policy.schedule | Should -Be "none"
    }

    It "Set Policy $pester_policy1 (with schedule always)" {
        $p = Get-FGTFirewallPolicy -name $pester_policy1 | Set-FGTFirewallPolicy -schedule always
        @($p).count | Should -Be "1"
        $policy = Get-FGTFirewallPolicy -name $pester_policy1
        $policy.name | Should -Be $pester_policy1
        $policy.uuid | Should -Not -BeNullOrEmpty
        $policy.schedule | Should -Be "always"
    }

    It "Set Policy $pester_policy1 (with comments)" {
        $p = Get-FGTFirewallPolicy -name $pester_policy1 | Set-FGTFirewallPolicy -comments "Modify via PowerFGT"
        @($p).count | Should -Be "1"
        $policy = Get-FGTFirewallPolicy -name $pester_policy1
        $policy.name | Should -Be $pester_policy1
        $policy.uuid | Should -Not -BeNullOrEmpty
        $policy.comments | Should -Be "Modify via PowerFGT"
    }

    It "Set Policy $pester_policy1 (with comments: null)" {
        $p = Get-FGTFirewallPolicy -name $pester_policy1 | Set-FGTFirewallPolicy -comments ""
        @($p).count | Should -Be "1"
        $policy = Get-FGTFirewallPolicy -name $pester_policy1
        $policy.name | Should -Be $pester_policy1
        $policy.uuid | Should -Not -BeNullOrEmpty
        $policy.comments | Should -BeNullOrEmpty
    }

    #Disable missing API for create IP Pool
    It "Set Policy $pester_policy1 (with IP Pool)" -skip:$true {
        $p = Get-FGTFirewallPolicy -name $pester_policy1 | Set-FGTFirewallPolicy -ippool "MyIPPool"
        @($p).count | Should -Be "1"
        $policy = Get-FGTFirewallPolicy -name $pester_policy1
        $policy.name | Should -Be $pester_policy1
        $policy.uuid | Should -Not -BeNullOrEmpty
        $policy.ippool | Should -Be "enable"
        $policy.poolname | Should -Be "MyIPPool"
    }

    It "Set Policy $pester_policy1 (with data (1 field))" {
        $data = @{ "logtraffic-start" = "enable" }
        $p = Get-FGTFirewallPolicy -name $pester_policy1 | Set-FGTFirewallPolicy -data $data
        @($p).count | Should -Be "1"
        $policy = Get-FGTFirewallPolicy -name $pester_policy1
        $policy.name | Should -Be $pester_policy1
        $policy.uuid | Should -Not -BeNullOrEmpty
        $policy.'logtraffic-start' | Should -Be "enable"
    }

    It "Set Policy $pester_policy1 (with data (2 fields))" {
        $data = @{ "logtraffic-start" = "disable" ; "comments" = "Modify via PowerFGT and -data" }
        $p = Get-FGTFirewallPolicy -name $pester_policy1 | Set-FGTFirewallPolicy -data $data
        @($p).count | Should -Be "1"
        $policy = Get-FGTFirewallPolicy -name $pester_policy1
        $policy.name | Should -Be $pester_policy1
        $policy.uuid | Should -Not -BeNullOrEmpty
        $policy.comments | Should -Be "Modify via PowerFGT and -data"
        $policy.'logtraffic-start' | Should -Be "disable"
    }

    It "Set Policy $pester_policy1 (with SSL/SSH Profile: certificate-inspection)" {
        $p = Get-FGTFirewallPolicy -name $pester_policy1 | Set-FGTFirewallPolicy -sslsshprofile certificate-inspection
        @($p).count | Should -Be "1"
        $policy = Get-FGTFirewallPolicy -name $pester_policy1
        $policy.name | Should -Be $pester_policy1
        $policy.uuid | Should -Not -BeNullOrEmpty
        $policy.'utm-status' | Should -Be "enable"
        $policy.'ssl-ssh-profile' | Should -Be "certificate-inspection"
    }

    It "Add Policy $pester_policy1 (with SSL/SSH Profile: deep-inspection)" {
        $p = Get-FGTFirewallPolicy -name $pester_policy1 | Set-FGTFirewallPolicy -sslsshprofile deep-inspection
        @($p).count | Should -Be "1"
        $policy = Get-FGTFirewallPolicy -name $pester_policy1
        $policy.name | Should -Be $pester_policy1
        $policy.uuid | Should -Not -BeNullOrEmpty
        $policy.'utm-status' | Should -Be "enable"
        $policy.'ssl-ssh-profile' | Should -Be "deep-inspection"
    }

    It "Set Policy $pester_policy1 (with SSL/SSH Profile: null / no-inspection)" {
        $p = Get-FGTFirewallPolicy -name $pester_policy1 | Set-FGTFirewallPolicy -sslsshprofile ""
        @($p).count | Should -Be "1"
        $policy = Get-FGTFirewallPolicy -name $pester_policy1
        $policy.name | Should -Be $pester_policy1
        $policy.uuid | Should -Not -BeNullOrEmpty
        $policy.'utm-status' | Should -Be "enable"
        #after 6.2.0, when set default value, it is configured to no-inspection
        if ($DefaultFGTConnection.version -ge "6.2.0") {
            $policy.'ssl-ssh-profile' | Should -Be "no-inspection"
        }
        else {
            $policy.'ssl-ssh-profile' | Should -Be "certificate-inspection"
        }
    }

    It "Set Policy $pester_policy1 (with AV Profile: default)" {
        $p = Get-FGTFirewallPolicy -name $pester_policy1 | Set-FGTFirewallPolicy -avprofile default
        @($p).count | Should -Be "1"
        $policy = Get-FGTFirewallPolicy -name $pester_policy1
        $policy.name | Should -Be $pester_policy1
        $policy.uuid | Should -Not -BeNullOrEmpty
        $policy.'utm-status' | Should -Be "enable"
        $policy.'av-profile' | Should -Be "default"
    }

    It "Set Policy $pester_policy1 (with AV Profile: null)" {
        $p = Get-FGTFirewallPolicy -name $pester_policy1 | Set-FGTFirewallPolicy -avprofile ""
        @($p).count | Should -Be "1"
        $policy = Get-FGTFirewallPolicy -name $pester_policy1
        $policy.name | Should -Be $pester_policy1
        $policy.uuid | Should -Not -BeNullOrEmpty
        $policy.'utm-status' | Should -Be "enable"
        $policy.'av-profile' | Should -BeNullOrEmpty
    }

    It "Set Policy $pester_policy1 (with Web Filter Profile: default)" {
        $p = Get-FGTFirewallPolicy -name $pester_policy1 | Set-FGTFirewallPolicy -webfilterprofile default
        @($p).count | Should -Be "1"
        $policy = Get-FGTFirewallPolicy -name $pester_policy1
        $policy.name | Should -Be $pester_policy1
        $policy.uuid | Should -Not -BeNullOrEmpty
        $policy.'utm-status' | Should -Be "enable"
        $policy.'webfilter-profile' | Should -Be "default"
    }

    It "Set Policy $pester_policy1 (with Web Filter Profile: null)" {
        $p = Get-FGTFirewallPolicy -name $pester_policy1 | Set-FGTFirewallPolicy -webfilterprofile ""
        @($p).count | Should -Be "1"
        $policy = Get-FGTFirewallPolicy -name $pester_policy1
        $policy.name | Should -Be $pester_policy1
        $policy.uuid | Should -Not -BeNullOrEmpty
        $policy.'utm-status' | Should -Be "enable"
        $policy.'webfilter-profile' | Should -BeNullOrEmpty
    }

    It "Set Policy $pester_policy1 (with DNS Filter Profile: default)" {
        $p = Get-FGTFirewallPolicy -name $pester_policy1 | Set-FGTFirewallPolicy -dnsfilterprofile default
        @($p).count | Should -Be "1"
        $policy = Get-FGTFirewallPolicy -name $pester_policy1
        $policy.name | Should -Be $pester_policy1
        $policy.uuid | Should -Not -BeNullOrEmpty
        $policy.'utm-status' | Should -Be "enable"
        $policy.'dnsfilter-profile' | Should -Be "default"
    }

    It "Set Policy $pester_policy1 (with DNS Filter Profile: null)" {
        $p = Get-FGTFirewallPolicy -name $pester_policy1 | Set-FGTFirewallPolicy -dnsfilterprofile ""
        @($p).count | Should -Be "1"
        $policy = Get-FGTFirewallPolicy -name $pester_policy1
        $policy.name | Should -Be $pester_policy1
        $policy.uuid | Should -Not -BeNullOrEmpty
        $policy.'utm-status' | Should -Be "enable"
        $policy.'dnsfilter-profile' | Should -Be ""
    }

    It "Set Policy $pester_policy1 (with IP Sensor: default)" {
        $p = Get-FGTFirewallPolicy -name $pester_policy1 | Set-FGTFirewallPolicy -ipssensor default
        @($p).count | Should -Be "1"
        $policy = Get-FGTFirewallPolicy -name $pester_policy1
        $policy.name | Should -Be $pester_policy1
        $policy.uuid | Should -Not -BeNullOrEmpty
        $policy.'utm-status' | Should -Be "enable"
        $policy.'ips-sensor' | Should -Be "default"
    }

    It "Set Policy $pester_policy1 (with IP Sensor: null)" {
        $p = Get-FGTFirewallPolicy -name $pester_policy1 | Set-FGTFirewallPolicy -ipssensor ""
        @($p).count | Should -Be "1"
        $policy = Get-FGTFirewallPolicy -name $pester_policy1
        $policy.name | Should -Be $pester_policy1
        $policy.uuid | Should -Not -BeNullOrEmpty
        $policy.'utm-status' | Should -Be "enable"
        $policy.'ips-sensor' | Should -BeNullOrEmpty
    }

    It "Set Policy $pester_policy1 (with Application List: default)" {
        $p = Get-FGTFirewallPolicy -name $pester_policy1 | Set-FGTFirewallPolicy -applicationlist default
        @($p).count | Should -Be "1"
        $policy = Get-FGTFirewallPolicy -name $pester_policy1
        $policy.name | Should -Be $pester_policy1
        $policy.uuid | Should -Not -BeNullOrEmpty
        $policy.'utm-status' | Should -Be "enable"
        $policy.'application-list' | Should -Be "default"
    }

    It "Set Policy $pester_policy1 (with Application List: null)" {
        $p = Get-FGTFirewallPolicy -name $pester_policy1 | Set-FGTFirewallPolicy -applicationlist ""
        @($p).count | Should -Be "1"
        $policy = Get-FGTFirewallPolicy -name $pester_policy1
        $policy.name | Should -Be $pester_policy1
        $policy.uuid | Should -Not -BeNullOrEmpty
        $policy.'utm-status' | Should -Be "enable"
        $policy.'application-list' | Should -BeNullOrEmpty
    }

    It "Set Policy $pester_policy1 (with inspection-mode: proxy)" -skip:($fgt_version -lt "6.2.0") {
        $p = Get-FGTFirewallPolicy -name $pester_policy1 | Set-FGTFirewallPolicy -inspectionmode proxy
        @($p).count | Should -Be "1"
        $policy = Get-FGTFirewallPolicy -name $pester_policy1
        $policy.name | Should -Be $pester_policy1
        $policy.uuid | Should -Not -BeNullOrEmpty
        $policy.'inspection-mode' | Should -Be "proxy"
    }

    It "Set Policy $pester_policy1 (with inspection-mode: flow)" -skip:($fgt_version -lt "6.2.0") {
        $p = Get-FGTFirewallPolicy -name $pester_policy1 | Set-FGTFirewallPolicy -inspectionmode flow
        @($p).count | Should -Be "1"
        $policy = Get-FGTFirewallPolicy -name $pester_policy1
        $policy.name | Should -Be $pester_policy1
        $policy.uuid | Should -Not -BeNullOrEmpty
        $policy.'inspection-mode' | Should -Be "flow"
    }

    It "Set Name" {
        $p = Get-FGTFirewallPolicy -name $pester_policy1 | Set-FGTFirewallPolicy -name "pester_address_change"
        @($p).count | Should -Be "1"
        $policy = Get-FGTFirewallPolicy -name "pester_address_change"
        $policy.name | Should -Be "pester_address_change"
    }

    AfterAll {
        Get-FGTFirewallPolicy -uuid $script:uuid | Remove-FGTFirewallPolicy -confirm:$false
    }

}
Describe "Remove Firewall Policy" {

    BeforeEach {
        Add-FGTFirewallPolicy -name $pester_policy1 -srcintf port1 -dstintf port2 -srcaddr all -dstaddr all
    }

    It "Remove Policy $pester_policy1 by pipeline" {
        $policy = Get-FGTFirewallPolicy -name $pester_policy1
        $policy | Remove-FGTFirewallPolicy -confirm:$false
        $policy = Get-FGTFirewallPolicy -name $pester_policy1
        $policy | Should -Be $NULL
    }

}

Describe "Remove Firewall Policy Member" {

    BeforeAll {
        #Create some Address object
        Add-FGTFirewallAddress -Name $pester_address1 -ip 192.0.2.1 -mask 255.255.255.255
        Add-FGTFirewallAddress -Name $pester_address2 -ip 192.0.2.2 -mask 255.255.255.255
        Add-FGTFirewallAddress -Name $pester_address3 -ip 192.0.2.3 -mask 255.255.255.255
    }

    AfterEach {
        Get-FGTFirewallPolicy -name $pester_policy1 | Remove-FGTFirewallPolicy -confirm:$false
    }

    Context "Remove Member(s) to Source Address" {
        BeforeEach {
            Add-FGTFirewallPolicy -name $pester_policy1 -srcintf port1 -dstintf port2 -srcaddr $pester_address1, $pester_address2, $pester_address3 -dstaddr all
        }

        It "Remove 1 member to Policy Src Address $pester_address1 (with 3 members before)" {
            Get-FGTFirewallPolicy -Name $pester_policy1 | Remove-FGTFirewallPolicyMember -srcaddr $pester_address1
            $policy = Get-FGTFirewallPolicy -name $pester_policy1
            $policy.name | Should -Be $pester_policy1
            $policy.uuid | Should -Not -BeNullOrEmpty
            $policy.srcintf.name | Should -BeIn "port1"
            $policy.dstintf.name | Should -Be "port2"
            ($policy.srcaddr.name).count | Should -Be "2"
            $policy.srcaddr.name | Should -Be $pester_address2, $pester_address3
            $policy.dstaddr.name | Should -Be "all"
            $policy.action | Should -Be "accept"
            $policy.status | Should -Be "enable"
            $policy.service.name | Should -Be "all"
            $policy.schedule | Should -Be "always"
            $policy.nat | Should -Be "disable"
            $policy.logtraffic | Should -Be "utm"
            $policy.comments | Should -BeNullOrEmpty
        }

        It "Remove 2 members to Policy Src Address $pester_address1, $pester_address2 (with 3 members before)" {
            Get-FGTFirewallPolicy -Name $pester_policy1 | Remove-FGTFirewallPolicyMember -srcaddr $pester_address1, $pester_address2
            $policy = Get-FGTFirewallPolicy -name $pester_policy1
            $policy.name | Should -Be $pester_policy1
            $policy.uuid | Should -Not -BeNullOrEmpty
            $policy.srcintf.name | Should -BeIn "port1"
            $policy.dstintf.name | Should -Be "port2"
            $policy.srcaddr.name | Should -Be $pester_address3
            $policy.dstaddr.name | Should -Be "all"
            $policy.action | Should -Be "accept"
            $policy.status | Should -Be "enable"
            $policy.service.name | Should -Be "all"
            $policy.schedule | Should -Be "always"
            $policy.nat | Should -Be "disable"
            $policy.logtraffic | Should -Be "utm"
            $policy.comments | Should -BeNullOrEmpty
        }

        It "Try Remove 3 members to Policy Src Address $pester_address1, $pester_address2, $pester_address3 (with 3 members before)" {
            {
                Get-FGTFirewallPolicy -Name $pester_policy1 | Remove-FGTFirewallPolicyMember -srcaddr $pester_address1, $pester_address2, $pester_address3
            } | Should -Throw "You can't remove all members. Use Set-FGTFirewallPolicy to remove Source Address"
        }

    }

    Context "Remove Member(s) to Source Interface" {
        BeforeEach {
            Add-FGTFirewallPolicy -name $pester_policy1 -srcintf $pester_port1, $pester_port2, $pester_port3 -dstintf $pester_port4 -srcaddr all -dstaddr all
        }

        It "Remove 1 member to Policy Src Interface $pester_port1 (with 3 members before)" {
            Get-FGTFirewallPolicy -Name $pester_policy1 | Remove-FGTFirewallPolicyMember -srcintf $pester_port1
            $policy = Get-FGTFirewallPolicy -name $pester_policy1
            $policy.name | Should -Be $pester_policy1
            $policy.uuid | Should -Not -BeNullOrEmpty
            $policy.srcintf.name | Should -BeIn $pester_port2, $pester_port3
            ($policy.srcintf.name).count | Should -Be "2"
            $policy.dstintf.name | Should -Be $pester_port4
            $policy.srcaddr.name | Should -Be "all"
            $policy.dstaddr.name | Should -Be "all"
            $policy.action | Should -Be "accept"
            $policy.status | Should -Be "enable"
            $policy.service.name | Should -Be "all"
            $policy.schedule | Should -Be "always"
            $policy.nat | Should -Be "disable"
            $policy.logtraffic | Should -Be "utm"
            $policy.comments | Should -BeNullOrEmpty
        }

        It "Remove 2 members to Policy Src Interface $pester_port1, $pester_port2 (with 3 members before)" {
            Get-FGTFirewallPolicy -Name $pester_policy1 | Remove-FGTFirewallPolicyMember -srcintf $pester_port1, $pester_port2
            $policy = Get-FGTFirewallPolicy -name $pester_policy1
            $policy.name | Should -Be $pester_policy1
            $policy.uuid | Should -Not -BeNullOrEmpty
            $policy.srcintf.name | Should -BeIn $pester_port3
            $policy.dstintf.name | Should -Be $pester_port4
            ($policy.srcaddr.name).count | Should -Be "1"
            $policy.srcaddr.name | Should -Be "all"
            $policy.dstaddr.name | Should -Be "all"
            $policy.action | Should -Be "accept"
            $policy.status | Should -Be "enable"
            $policy.service.name | Should -Be "all"
            $policy.schedule | Should -Be "always"
            $policy.nat | Should -Be "disable"
            $policy.logtraffic | Should -Be "utm"
            $policy.comments | Should -BeNullOrEmpty
        }

        It "Try Remove 3 members to Policy Src Address $pester_port1, $pester_port2, $pester_port3 (with 3 members before)" {
            {
                Get-FGTFirewallPolicy -Name $pester_policy1 | Remove-FGTFirewallPolicyMember -srcintf $pester_port1, $pester_port2, $pester_port3
            } | Should -Throw "You can't remove all members. Use Set-FGTFirewallPolicy to remove Source interface"
        }

    }

    Context "Remove Member(s) to Destination Address" {
        BeforeEach {
            Add-FGTFirewallPolicy -name $pester_policy1 -srcintf port1 -dstintf port2 -srcaddr all -dstaddr $pester_address1, $pester_address2, $pester_address3
        }

        It "Remove 1 member to Policy Dst Address $pester_address1 (with 3 members before)" {
            Get-FGTFirewallPolicy -Name $pester_policy1 | Remove-FGTFirewallPolicyMember -dstaddr $pester_address1
            $policy = Get-FGTFirewallPolicy -name $pester_policy1
            $policy.name | Should -Be $pester_policy1
            $policy.uuid | Should -Not -BeNullOrEmpty
            $policy.srcintf.name | Should -BeIn "port1"
            $policy.dstintf.name | Should -Be "port2"
            $policy.srcaddr.name | Should -Be "all"
            ($policy.dstaddr.name).count | Should -Be "2"
            $policy.dstaddr.name | Should -Be $pester_address2, $pester_address3
            $policy.action | Should -Be "accept"
            $policy.status | Should -Be "enable"
            $policy.service.name | Should -Be "all"
            $policy.schedule | Should -Be "always"
            $policy.nat | Should -Be "disable"
            $policy.logtraffic | Should -Be "utm"
            $policy.comments | Should -BeNullOrEmpty
        }

        It "Remove 2 members to Policy Dst Address $pester_address1, $pester_address2 (with 3 members before)" {
            Get-FGTFirewallPolicy -Name $pester_policy1 | Remove-FGTFirewallPolicyMember -dstaddr $pester_address1, $pester_address2
            $policy = Get-FGTFirewallPolicy -name $pester_policy1
            $policy.name | Should -Be $pester_policy1
            $policy.uuid | Should -Not -BeNullOrEmpty
            $policy.srcintf.name | Should -BeIn "port1"
            $policy.dstintf.name | Should -Be "port2"
            $policy.srcaddr.name | Should -Be "all"
            $policy.dstaddr.name | Should -Be $pester_address3
            $policy.action | Should -Be "accept"
            $policy.status | Should -Be "enable"
            $policy.service.name | Should -Be "all"
            $policy.schedule | Should -Be "always"
            $policy.nat | Should -Be "disable"
            $policy.logtraffic | Should -Be "utm"
            $policy.comments | Should -BeNullOrEmpty
        }

        It "Try Remove 3 members to Policy Dst Address $pester_address1, $pester_address2, $pester_address3 (with 3 members before)" {
            {
                Get-FGTFirewallPolicy -Name $pester_policy1 | Remove-FGTFirewallPolicyMember -dstaddr $pester_address1, $pester_address2, $pester_address3
            } | Should -Throw "You can't remove all members. Use Set-FGTFirewallPolicy to remove Destination Address"
        }

    }

    Context "Remove Member(s) to Destination Interface" {
        BeforeEach {
            Add-FGTFirewallPolicy -name $pester_policy1 -srcintf $pester_port4 -dstintf $pester_port1, $pester_port2, $pester_port3 -srcaddr all -dstaddr all
        }

        It "Remove 1 member to Policy Dst Interface $pester_port1 (with 3 members before)" {
            Get-FGTFirewallPolicy -Name $pester_policy1 | Remove-FGTFirewallPolicyMember -dstintf $pester_port1
            $policy = Get-FGTFirewallPolicy -name $pester_policy1
            $policy.name | Should -Be $pester_policy1
            $policy.uuid | Should -Not -BeNullOrEmpty
            $policy.srcintf.name | Should -Be $pester_port4
            $policy.dstintf.name | Should -BeIn $pester_port2, $pester_port3
            ($policy.dstintf.name).count | Should -Be "2"
            $policy.srcaddr.name | Should -Be "all"
            $policy.dstaddr.name | Should -Be "all"
            $policy.action | Should -Be "accept"
            $policy.status | Should -Be "enable"
            $policy.service.name | Should -Be "all"
            $policy.schedule | Should -Be "always"
            $policy.nat | Should -Be "disable"
            $policy.logtraffic | Should -Be "utm"
            $policy.comments | Should -BeNullOrEmpty
        }

        It "Remove 2 members to Policy Dst Address $pester_port1, $pester_port2 (with 3 members before)" {
            Get-FGTFirewallPolicy -Name $pester_policy1 | Remove-FGTFirewallPolicyMember -dstintf $pester_port1, $pester_port2
            $policy = Get-FGTFirewallPolicy -name $pester_policy1
            $policy.name | Should -Be $pester_policy1
            $policy.uuid | Should -Not -BeNullOrEmpty
            $policy.srcintf.name | Should -Be $pester_port4
            $policy.dstintf.name | Should -BeIn $pester_port3
            ($policy.dstintf.name).count | Should -Be "1"
            $policy.srcaddr.name | Should -Be "all"
            $policy.dstaddr.name | Should -Be "all"
            $policy.action | Should -Be "accept"
            $policy.status | Should -Be "enable"
            $policy.service.name | Should -Be "all"
            $policy.schedule | Should -Be "always"
            $policy.nat | Should -Be "disable"
            $policy.logtraffic | Should -Be "utm"
            $policy.comments | Should -BeNullOrEmpty
        }

        It "Try Remove 3 members to Policy Dst Address $pester_port1, $pester_port2, $pester_port3 (with 3 members before)" {
            {
                Get-FGTFirewallPolicy -Name $pester_policy1 | Remove-FGTFirewallPolicyMember -dstintf $pester_port1, $pester_port2, $pester_port3
            } | Should -Throw "You can't remove all members. Use Set-FGTFirewallPolicy to remove Destination interface"
        }

    }

    AfterAll {
        Get-FGTFirewallAddress -name $pester_address1 | Remove-FGTFirewallAddress -confirm:$false
        Get-FGTFirewallAddress -name $pester_address2 | Remove-FGTFirewallAddress -confirm:$false
        Get-FGTFirewallAddress -name $pester_address3 | Remove-FGTFirewallAddress -confirm:$false
    }

}

AfterAll {
    Disconnect-FGT -confirm:$false
}